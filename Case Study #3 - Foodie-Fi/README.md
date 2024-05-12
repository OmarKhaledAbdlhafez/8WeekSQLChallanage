# 🥑 Case Study #3: Foodie-Fi

<img src="https://user-images.githubusercontent.com/81607668/129742132-8e13c136-adf2-49c4-9866-dec6be0d30f0.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/129744449-37b3229b-80b2-4cce-b8e0-707d7f48dcec.png)

**Table 1: `plans`**

<img width="207" alt="image" src="https://user-images.githubusercontent.com/81607668/135704535-a82fdd2f-036a-443b-b1da-984178166f95.png">

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: `subscriptions`**

<img width="245" alt="image" src="https://user-images.githubusercontent.com/81607668/135704564-30250dd9-6381-490a-82cf-d15e6290cf3a.png">

Customer subscriptions show the **exact date** where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the `start_date` in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn, they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***

## Question and Solution

## 🎞️ A. Customer Journey

Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.

**Table: Sample of `subscriptions` table**

## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

To determine the count of unique customers for Foodie-Fi, I utilize the `COUNT()` function wrapped around `DISTINCT`.

<img width="159" alt="image" src="https://user-images.githubusercontent.com/81607668/129764903-bb0480aa-bf92-46f7-b0e1-f4d0f9e96ae1.png">

- Foodie-Fi has 1,000 unique customers.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

In other words, the question is asking for the monthly count of users on the trial plan subscription.
- To start, extract the numerical value of month from `start_date` column using the `DATE_PART()` function, specifying the 'month' part of a date. 
- Filter the results to retrieve only users with trial plan subscriptions (`plan_id = 0). 


**Answer:**

<img width="366" alt="image" src="https://user-images.githubusercontent.com/81607668/129826377-f4da52b6-13de-4871-be98-bf438f2ac230.png">

Among all the months, March has the highest number of trial plans, while February has the lowest number of trial plans.

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.


**Answer:**

| plan_id | plan_name     | num_of_events |
| ------- | ------------- | ------------- |
| 1       | basic monthly | 8             |
| 2       | pro monthly   | 60            |
| 3       | pro annual    | 63            |
| 4       | churn         | 71            |

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?


**Answer:**

<img width="368" alt="image" src="https://user-images.githubusercontent.com/81607668/129840630-adebba8c-9219-4816-bba6-ba8119f298d9.png">

- Out of the total customer base of Foodie-Fi, 307 customers have churned. This represents approximately 30.7% of the overall customer count.

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

**Answer:**

<img width="378" alt="image" src="https://user-images.githubusercontent.com/81607668/129834269-98ab360b-985a-4c25-9d42-c89b97ba6ba8.png">

- A total of 92 customers churned immediately after the initial free trial period, representing approximately 9% of the entire customer base.

### 6. What is the number and percentage of customer plans after their initial free trial?


**Answer:**

| plan_id | converted_customers | conversion_percentage |
| ------- | ------------------- | --------------------- |
| 1       | 546                 | 54.6                  |
| 2       | 325                 | 32.5                  |
| 3       | 37                  | 3.7                   |
| 4       | 92                  | 9.2                   |

- More than 80% of Foodie-Fi's customers are on paid plans with a majority opting for Plans 1 and 2. 
- There is potential for improvement in customer acquisition for Plan 3 as only a small percentage of customers are choosing this higher-priced plan.

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


**Answer:**

<img width="448" alt="image" src="https://user-images.githubusercontent.com/81607668/130024738-f16ad7dc-5fed-469f-9c6d-0a24453e1dcd.png">

### 8. How many customers have upgraded to an annual plan in 2020?

**Answer:**

<img width="160" alt="image" src="https://user-images.githubusercontent.com/81607668/129848711-3b64442a-5724-4723-bea7-e4515a8687ec.png">

- 196 customers have upgraded to an annual plan in 2020.

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?


**Answer:**

<img width="182" alt="image" src="https://user-images.githubusercontent.com/81607668/129856015-4bafa22c-b732-4c71-93d6-c9417e8556b9.png">

- On average, customers take approximately 105 days from the day they join Foodie-Fi to upgrade to an annual plan.
