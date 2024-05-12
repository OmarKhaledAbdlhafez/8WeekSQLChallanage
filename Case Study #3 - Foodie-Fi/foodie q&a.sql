use foodie_fi ;
SELECT
  sub.customer_id,
  plans.plan_id, 
  plans.plan_name,  
  sub.start_date
FROM foodie_fi.plans
JOIN foodie_fi.subscriptions AS sub
  ON plans.plan_id = sub.plan_id
WHERE sub.customer_id IN (1,2,11,13,15,16,18,19);



SELECT
  sub.customer_id,
  plans.plan_id, 
  plans.plan_name,  
  sub.start_date
FROM foodie_fi.plans
JOIN foodie_fi.subscriptions AS sub
  ON plans.plan_id = sub.plan_id
WHERE sub.customer_id IN (1,13,15);


-- 1. How many customers has Foodie-Fi ever had?
select count(distinct customer_id) from subscriptions ;


/*
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
In other words, the question is asking for the monthly count of users on the trial plan subscription.

To start, extract the numerical value of month from start_date column using the DATE_PART() function, specifying the 'month' part of a date.
Filter the results to retrieve only users with trial plan subscriptions (`plan_id = 0).
*/

select month(start_date) , count(customer_id)
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id
where p.plan_id =0 
group by 1 ;


/* 
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
To put it simply, we have to determine the count of plans with start dates on or after 1 January 2021 grouped by plan names.

Filter plans based on their start dates by including only the plans occurring on or after January 1, 2021.
Calculate the number of customers as the number of events.
Group results based on the plan names. For better readability, order results in ascending order of the plan ID.
*/


select month(start_date) , p.plan_id , count(customer_id)
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id
where start_date >= '2021-01-01'
group by 1 ,2;


select  p.plan_id , p.plan_name , count(customer_id)
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id
where start_date >= '2021-01-01'
group by 1 ,2;

/*
 5. How many customers have churned straight after their initial free trial - 
 what percentage is this rounded to the nearest whole number?
 */
 select  s.customer_id , start_date , p.plan_name , 
		lead(p.plan_name) over( partition by s.customer_id order by start_date) as nextplan
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id 
;

 with cte as (
 select  s.customer_id , start_date , p.plan_name , 
		lead(p.plan_name) over( partition by s.customer_id order by start_date) as nextplan
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id 
) 
select count(*)  , (count(*) / (select count(distinct customer_id)  from subscriptions )) *100 from cte 
where plan_name = 'trial'
and nextplan = 'churn' ;

-- 6. What is the number and percentage of customer plans after their initial free trial?
with cte as (
 select  s.customer_id , start_date , p.plan_name , 
		lead(p.plan_name) over( partition by s.customer_id order by start_date) as nextplan
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id 
) 
select nextplan , count(customer_id)  , (count(customer_id) / (select count(distinct customer_id)  from subscriptions )) *100 
from cte 
where  nextplan is not null 
and plan_name = 'trial' 
group by 1;


-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with cte as (

 select  s.customer_id , start_date , p.plan_name , 
		lead(start_date) over( partition by s.customer_id order by start_date) as nextdate
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id 
WHERE start_date <= '2020-12-31'

) 
select plan_name , count(customer_id)  , (count(customer_id) / (select count(distinct customer_id)  from subscriptions )) *100 
from cte 
where  nextdate is  null 
group by 1;



-- 8. How many customers have upgraded to an annual plan in 2020?
with cte as (

 select  s.customer_id , start_date , p.plan_name , 
		lead(start_date) over( partition by s.customer_id order by start_date) as nextdate
from subscriptions s 
inner join plans p
on s.plan_id = p.plan_id 
WHERE start_date <= '2020-12-31'

) 
select plan_name , count(customer_id)  , (count(customer_id) / (select count(distinct customer_id)  from subscriptions )) *100 
from cte 
where  nextdate is  null 
and plan_name = 'pro annual'
group by 1;



-- 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

WITH trial_plan AS (
-- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM subscriptions
  WHERE plan_id = 0
), annual_plan AS (
-- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM subscriptions
  WHERE plan_id = 3
)
-- Find the average of the differences between the start date of a trial plan and a pro annual plan.
SELECT 
  AVG(annual.annual_date - trial.trial_date)AS avg_days_to_upgrade
FROM trial_plan AS trial
JOIN annual_plan AS annual
  ON trial.customer_id = annual.customer_id;
  
  
  -- 10. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
  WITH ranked_cte AS (
  SELECT 
    sub.customer_id,  
  	plans.plan_id,
    plans.plan_name, 
	  LEAD(plans.plan_id) OVER ( 
      PARTITION BY sub.customer_id
      ORDER BY sub.start_date) AS next_plan_id
  FROM foodie_fi.subscriptions AS sub
  JOIN foodie_fi.plans 
    ON sub.plan_id = plans.plan_id
 WHERE year( start_date) = 2020
)
  
SELECT 
  COUNT(customer_id) AS churned_customers
FROM ranked_cte
WHERE plan_id = 2
  AND next_plan_id = 1;
  
  