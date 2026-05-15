# Bank Customer Churn Case Study

Tools: R · tidyverse · ggplot2 · glm · caret

Dataset: IBM Credit Card Customer Churn -- 21 variables, 10,127 customers

Goal: Identify customers who are likely to leave the bank and actionable retention strategies

## Business Problem

One of banking's greatest and costly challenges is customer churn. Acquiring new customers costs significantly more than retaining existing customers. This case study uses a real-world dataset to answer:

Which customers are at risk of churning, and what behavioral signals can the bank act on before it happens?

## Dataset Overview

| Feature | Description|
|-----------|-------------|
| Clientnum | Client Number, Unique Identifier |
| Attrition_Flag | Target Variable, Churned vs. Retained |
| Customer_Age | Age of Customer in Years|
| Gender | Demographic Variable, M = Male, F = Female |
| Dependent_Count | Number of Dependents|
| Education_Level | Educational Qualification of the Account Holder |
| Marital_Status | Married, Single, Divorced, Unknown |
| Income_Category | Annual Income Category of the Account Holder |
| Card_Category | Type of Card |
| Months_on_Book | Period of Relationship with Bank |
| Total_Relationship_Count | Total Number of Products Held by Customer |
| Months_Inactive_12_Mon | Number of Months Inactive in Last 12 Months |
| Contacts_Count_12_Mon | Number of Contacts in the Last 12 Months |
| Credit_Limit | Credit Limit on Credit Card |
| Total_Revolving_Bal | Total Revolving Balance on the Credit Card |
| Avg_Open_To_Buy | Open to Buy Credit Line (Average of Last 12 Months) |
| Total_Amt_Chng_Q4_Q1 | Change in Transaction Amount (Q4 over Q1) |
| Total_Trans_Amt | Total Transaction Amount (Last 12 Months) |
| Total_Trans_Ct | Total Transaction Count (Last 12 Months) |
| Total_Ct_Chng_Q4_Q1 | Change in Transaction Count (Q4 over Q1) |
| Avg_Utilization_Ratio | Average Card Utilization Ratio |

## Data Analysis

### Churn Rate:

About 16% of customers in the dataset have churned. Therefore, with a higher churn rate a model evaluation is needed beyond simple analysis.

### Key Visual Findings:

#### Transaction Activity

Churned customers made far fewer transactions on average (median of about 45) compared to retained customers (median of about 71). This was the single strongest behavioral signal in the data.

#### Credit Utilization

Churned customers had significantly lower utilization ratios. This indicates disengagement from the card product rather than financial distress.

#### Education Level

It was found that doctorate holders had the highest churn rate (~21%), while high school customers had among the lowest. This could be an indication that highly educated customers shop more actively for better financial products.

#### Inactivity

Customers that are inactive for three months or longer churned at nearly double the rate of those with one month of inactivity. Inactivity is a leading indicator, not a lagging one.

## Statistical Analysis

### Continuous Variables (Correlation with Churn):

Point-biserial correlations revealed the top predictors.

| Variable | Correlation | Direction |
|-----------|-------------|-------------|
| Total_Trans_Ct | -0.37 | Fewer Transactions --> More Churn |
| Total_Ct_Chng_Q4_Q1 | -0.29 | Declining Activity --> More Churn |
| Total_Revolving_Bal | -0.26 | Declining Balance --> More Churn |
| Contacts_Count_12_mon | +0.20 | More Contacts --> More Churn |
| Avg_Utilization_Ratio | -0.18 | Lower Utilization --> More Churn |
| Total_Trans_Amt | -0.17 | Lower Spend --> More Churn |

### Categorical Variables (Chi-Squared Tests):

Two key categorical varibles, Gender and Card Category, were statistically significant (p< 0.05).

| Variable | Chi-Squared | Result |
|-----------|-------------|-------------|
| Gender | 13.87 | Significant |
| Income_Category | 12.83 | Significant |
| Education_Level | 12.51 | Not-Significant |
| Marital_Status | 6.06 | Not-Significant |
| Card_Category | 2.23 | Not-Significant |

### Logistic Regression Model:

#### Approach

- Algorithm: Logistic Regression
  - glm with binomial family
- Split: 75% training, 25% test
  - Stratified
  - Set Seed: 365
- Features: 17 Predictors
  - Demographics
  - Account Tenure
  - Behavioral Signals
 
#### Model Performance

| Metric | Value |
|-----------|-------------|
| AUC | ~0.916 |
| Accuracy | ~90% |
|Recall (Sensitivity) | ~58.6% |
| Precision | ~73.9% |

The AUC value of 0.916 indicates a strong discriminative ability for the model. This means the model correctly ranks a randomly selected churner over a randomly selected retained customer 91.6% of the time.

#### Top Significant Predictors (by |z-statistic|)

1. Total_Trans_Ct -- Most Powerful Predictor
2. Total_Trans_Amt -- Lower Spend Trend
3. Total_Relationship_Count -- Less Products Churn More
4. Total_Ct_Chng_Q4_Q1 -- Declining Transaction Trend
5. Contacts_Count_12_mon -- High Contact Volume Indicates Frustration

## Business Recommendations

Based on the analysis, the bank can reduce churn by targeting customers who exhibit early warning signs by the following ways:

1. Transaction-Based Warning System:
Flag customers whose transaction count drops below fifty in a rolling twelve month window. Customers who meet this criteria are at a significant risk of churn and warrant outreach.
2. Inactivity Triggers:







