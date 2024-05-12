select * from members ;
select * from menu ;
select * from sales ;

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id , sum(price)
from sales s
inner join menu m
on s.product_id = m.product_id 
group by 1; 

-- 2. How many days has each customer visited the restaurant?
select customer_id , count( distinct order_date )
from sales 
group by 1 ;


-- 3. What was the first item from the menu purchased by each customer?
select customer_id , order_date , product_name 
from sales s
inner join menu m
on s.product_id = m.product_id
order by customer_id , order_date ;



select customer_id , order_date , product_name ,
		dense_rank() over(partition by customer_id order by order_date ) as rnk
from sales s
inner join menu m
on s.product_id = m.product_id ;

select 
customer_id , product_name
from 
(
select customer_id , order_date , product_name ,
		dense_rank() over(partition by customer_id order by order_date ) as rnk
from sales s
inner join menu m
on s.product_id = m.product_id 
) as s 
where rnk = 1 ;


with cte as  (
select customer_id , order_date , product_name ,
		dense_rank() over(partition by customer_id order by order_date ) as rnk
from sales s
inner join menu m
on s.product_id = m.product_id 
)
select 
customer_id , product_name
from cte 
where rnk = 1 ;



with cte as  (
select customer_id , order_date , product_name ,
		dense_rank() over(partition by customer_id order by order_date ) as rnk
from sales s
inner join menu m
on s.product_id = m.product_id 
)
select 
customer_id , product_name ,lead (product_name) over ( partition by customer_id)
from cte 
where rnk = 1 ;


with cte as  (
select customer_id , order_date , product_name ,
		dense_rank() over(partition by customer_id order by order_date ) as rnk
from sales s
inner join menu m
on s.product_id = m.product_id 
) ,
cte2 as (
select 
customer_id , product_name ,lead (product_name) over ( partition by customer_id) as sec_item
from cte 
where rnk = 1 
)
select * from cte2 
where sec_item is not null ;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name , count(s.product_id)
from sales s 
inner join menu m
on s.product_id = m.product_id
group by 1 ; 


-- 5. Which item was the most popular for each customer?
with cte as (
select customer_id , product_name , count(s.product_id) ,
	dense_rank() over( partition by customer_id order by count(s.product_id) desc) as rnk
from sales s 
inner join menu m
on s.product_id = m.product_id
group by 1 ,2
) 
select * from cte 
where  rnk = 1 ;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
  sales.customer_id, 
  COUNT(sales.product_id) AS total_items, 
  SUM(menu.price) AS total_sales
FROM sales
INNER JOIN members
  ON sales.customer_id = members.customer_id
  AND sales.order_date < members.join_date
INNER JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;



-- 6. Which item was purchased first by the customer after they became a member?
with cte as (
select m.customer_id , s.product_id , product_name , order_date,
	ROW_NUMBER() over ( partition by m.customer_id order by order_date) as rnk
from sales s 
inner join members m
on s.customer_id = m.customer_id
and s.order_date > m.join_date 
inner join menu me 
on s.product_id = me.product_id
) 
select * from cte 
where rnk = 1 ;



-- 7. Which item was purchased just before the customer became a member?
with cte as (
select m.customer_id , s.product_id , product_name , order_date,
	ROW_NUMBER() over ( partition by m.customer_id order by order_date desc ) as rnk
from sales s 
inner join members m
on s.customer_id = m.customer_id
and s.order_date < m.join_date 
inner join menu me 
on s.product_id = me.product_id
) 
select * from cte 
where rnk = 1 ;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

WITH points_cte AS (
  SELECT 
    menu.product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10 END AS points
  FROM menu
)

SELECT 
  sales.customer_id, 
  SUM(points_cte.points) AS total_points
FROM sales
INNER JOIN points_cte
  ON sales.product_id = points_cte.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 

  SELECT 
  sales.customer_id, 
  month(order_date) ,
  SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
    WHEN sales.order_date BETWEEN dates.join_date AND adddate(dates.join_date ,7) THEN 2 * 10 * menu.price
    ELSE 10 * menu.price END) AS points
FROM sales
INNER JOIN members AS dates
  ON sales.customer_id = dates.customer_id
  AND dates.join_date <= sales.order_date
INNER JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY 1 ,2;
