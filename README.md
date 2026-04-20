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
