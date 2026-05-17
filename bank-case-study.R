
### Loading Libraries and Data

data = read.csv("~/Desktop/BankChurners.csv")

library(tidyverse)
library(caret)
library(pROC)
library(scales)
library(gridExtra)



### Inspecting and Organizing Data

data = as_tibble(data)

df = data %>%
  select(-Naive_Bayes_Classifier_Attrition_Flag_Card_Category_Contacts_Count_12_mon_Dependent_count_Education_Level_Months_Inactive_12_mon_1) %>%
  select(-Naive_Bayes_Classifier_Attrition_Flag_Card_Category_Contacts_Count_12_mon_Dependent_count_Education_Level_Months_Inactive_12_mon_2)

df = df %>%
  rename(churn_flag = Attrition_Flag) %>%
  mutate(churned = if_else(churn_flag == "Attrited Customer", 1L, 0L),
         churned_label = factor(churned, levels = c(0,1),
                                                    labels = c("Retained", "Churned")))
## Dataset Dimensions

print(nrow(df))
print(ncol(df))



### Data Analysis

## churn rate overview

churn_summary_table = df %>%
  count(churned_label) %>%
  mutate(pct = n/sum(n), label = percent(pct, 2))

churn_summary_table

churn_rate_plot = ggplot(churn_summary_table, 
       aes(x = churned_label, y = n, fill = churned_label)) +
  geom_col(width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = label), vjust = -0.4, size = 4.5, fontface = "bold") +
  scale_fill_manual(values = c("Retained" = "#2196F3", "Churned" = "#F44336")) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Overall Churn Rate",
       subtitle = "~16% of customers have left the bank",
       x = NULL, y = "Number of Customers") +
  theme_minimal(base_size = 15)

churn_rate_plot

## transaction count vs. churn 

transaction_box_plot = ggplot(df, aes(x = churned_label, y = Total_Trans_Ct, fill = churned_label)) +
  geom_boxplot(show.legend = FALSE, outlier.alpha = 0.3) +
  scale_fill_manual(values = c("Retained" = "#2196F3", "Churned" = "#F44336")) +
  labs(title = "Transaction Count by Churn Status",
       subtitle = "Churned customers make far fewer transactions",
       x = NULL, y = "Total Transactions (last 12 months)") +
  theme_minimal(base_size = 15)

transaction_box_plot

## credit utilization vs. churn

credit_util_plot = ggplot(df, aes(x = Avg_Utilization_Ratio, fill = churned_label)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(values = c("Retained" = "#2196F3", "Churned" = "#F44336")) +
  labs(title = "Credit Utilization Ratio by Churn Status",
       subtitle = "Churned customers have lower utilization — they're disengaged",
       x = "Average Utilization Ratio", y = "Density", fill = NULL) +
  theme_minimal(base_size = 15)

credit_util_plot

## churn rate by education level

churn_education = df %>%
  group_by(Education_Level) %>%
  summarise(churn_rate = mean(churned), n = n(), .groups = "drop") %>%
  filter(Education_Level != "Unknown") %>%
  mutate(Education_Level = fct_reorder(Education_Level, churn_rate))

churn_education

churn_educ_plot = ggplot(churn_education, aes(x = Education_Level, y = churn_rate, fill = churn_rate)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = percent(churn_rate, 1)), hjust = -0.1, size = 4) +
  scale_y_continuous(labels = percent, limits = c(0, 0.25)) +
  scale_fill_gradient(low = "#90CAF9", high = "#F44336") +
  coord_flip() +
  labs(title = "Churn Rate by Education Level", 
       x = NULL,
       y = "Churn Rate") +
  theme_minimal(base_size = 15)

churn_educ_plot

## months inactive vs. churn

activity = df %>%
  count(Months_Inactive_12_mon, churned_label) %>%
  group_by(Months_Inactive_12_mon) %>%
  mutate(pct = n/sum(n)) %>%
  filter(churned_label == "Churned")

activity_plot = ggplot(activity, aes(x = (Months_Inactive_12_mon), y = pct, fill = pct)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = percent(pct, 1)), vjust = -0.4, size = 4) +
  scale_y_continuous(labels = percent, limits = c(0, 0.5)) +
  scale_fill_gradient(low = "#90CAF9", high = "#F44336") +
  labs(title = "Churn Rate by Months Inactive",
       x = "Months Inactive (last 12)", y = "Churn Rate") +
  theme_minimal(base_size = 15)

activity_plot



### Statistical Analysis

## point-biserial correlations (continuous vars vs. churn)

num_vars = df %>%
  select(Customer_Age, Dependent_count, Months_on_book, Total_Relationship_Count,
         Months_Inactive_12_mon, Contacts_Count_12_mon, Credit_Limit, Total_Revolving_Bal,
         Avg_Open_To_Buy, Total_Amt_Chng_Q4_Q1, Total_Trans_Amt, Total_Trans_Ct,
         Total_Ct_Chng_Q4_Q1, Avg_Utilization_Ratio, churned)

corr_results = num_vars %>%
  select(-churned) %>%
  map_dfr(~ { test = cor.test(.x, num_vars$churned, method = "pearson")
  tibble(correlation = test$estimate, p_value = test$p.value)},
  .id = "variable") %>%
  arrange(desc(abs(correlation)))

corr_results


## chi-square tests for categorical variables

cat_vars = c("Gender", "Education_Level", "Marital_Status", "Income_Category", "Card_Category")

for (v in cat_vars) {
  tbl = table(df[[v]], df$churned_label)
  chi = chisq.test(tbl)
  cat(sprintf("%-20s chi^2 = %6.2f df = %d p = %.4f\n",
              v, chi$statistic, chi$parameter, chi$p.value))
}


### Logistic Regression Model

## Model Data Setup

model_data = df %>%
  select(churned, Customer_Age, Gender, Dependent_count, Education_Level,
         Marital_Status, Income_Category, Card_Category, Months_on_book,
         Total_Relationship_Count, Months_Inactive_12_mon, Contacts_Count_12_mon,
         Total_Trans_Ct, Total_Trans_Amt, Total_Revolving_Bal, Avg_Utilization_Ratio,
         Total_Ct_Chng_Q4_Q1, Total_Amt_Chng_Q4_Q1) %>%
  mutate(churned = factor(churned, levels = c(0,1), 
                          labels = c("Retained", "Churned")),
         Gender = factor(Gender),
         Education_Level = factor(Education_Level),
         Marital_Status = factor(Marital_Status),
         Income_Category = factor(Income_Category),
         Card_Category = factor(Card_Category)) %>%
  drop_na()


## Train and Test Split 75/25

set.seed(365)

train_idx = createDataPartition(model_data$churned, p = 0.75, list = FALSE)

train_data = model_data[train_idx, ]

test_data = model_data[-train_idx, ]

nrow(train_data) 

nrow(test_data)


## fit logistic regression

logit_model = glm(churned ~ ., data = train_data, family = binomial(link = "logit"))

summary(logit_model)


## odds ratios --> easier to interpret

odds_ratio = exp(cbind(OR = coef(logit_model), confint(logit_model)))

print(round(odds_ratio, 3))


## predictions on test set

pred_prob = predict(logit_model, newdata = test_data, type = "response")

pred_class = factor(if_else(pred_prob >= 0.5, "Churned", "Retained"),
                    levels = c("Retained", "Churned"))


## confusion matrix and accuracy metrics

cm = confusionMatrix(pred_class, test_data$churned, positive = "Churned")

cm


## roc curve and auc

roc_on = roc(as.numeric(test_data$churned == "Churned"), pred_prob)

auc_value = auc(roc_on)

p_roc = ggroc(roc_on, colour = "#F44336", size = 1.2) +
  geom_abline(slope = 1, intercept = 1, linetype = "dashed", color = "grey50") +
  annotate("text", x = 0.35, y = 0.15,
           label = paste0("AUC = ", round(auc_value, 3)),
           size = 5, color = "#F44336", fontface = "bold") +
  labs(title = "ROC Curve – Logistic Regression",
       subtitle = "Higher AUC = better model discrimination",
       x = "Specificity", y = "Sensitivity") +
  theme_minimal(base_size = 13)

p_roc


## feature importance (absolute z-values)

coef_data = broom::tidy(logit_model) %>%
  filter(term != "(Intercept)") %>%
  mutate(abs_stat = abs(statistic),
         significant = p.value < 0.05,
         term = fct_reorder(term, abs_stat)) %>%
  top_n(15, abs_stat)

coef_plot = ggplot(coef_data, aes(x = term, y = abs_stat, fill = significant)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "#F44336", "FALSE" = "#90CAF9")) +
  coord_flip() +
  labs(title = "Top 15 Predictors of Churn",
       subtitle = "Red = statistically significant (p < 0.05)",
       x = NULL, y = "Absolute Z-statistic") +
  theme_minimal(base_size = 13)

coef_plot











