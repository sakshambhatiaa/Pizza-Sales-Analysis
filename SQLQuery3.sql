
--the total number of orders placed.

select count(order_id) as tot_orders
from orders

-- total revenue generated from pizza sales.

select sum(od.quantity*p.price) as tot_sales
from order_details as od
inner join pizzas as p 
on od.pizza_id = p.pizza_id

-- highest-priced pizza.

select top 1 pt.name, max(p.price) as max_price
from
pizzas as p
inner join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by name
order by max_price desc

-- lowest-priced pizza.

select top 1 pt.name, min(p.price) as min_price
from pizzas as p
inner join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by min_price asc

-- most common pizza size ordered.

select p.size, count(od.quantity) as quan
from order_details as od
inner join pizzas as p
on od.pizza_id = p.pizza_id
group by p.size
order by quan desc

-- top 5 most ordered pizza types with their quantities.

select top 5 pt.name, count(quantity) as ord_quan
from order_details as od
inner join pizzas as p
on od.pizza_id = p.pizza_id
inner join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by ord_quan desc

-- the total quantity of each pizza category ordered.

select pt.category, sum(od.quantity) as tot_orders
from order_details as od
inner join pizzas as p
on od.pizza_id = p.pizza_id
inner join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category

-- distribution of orders by hour of the day.


select DATENAME(HOUR, time) as hourly_orders, count(order_id) as order_count
from orders
group by DATENAME(HOUR, time)
order by hourly_orders

-- category-wise distribution of pizzas

select category, count(name) as pizza_count
from pizza_types
group by category

-- orders by date and the average number of pizzas ordered per day.
select avg(tot_quantity) as avg_quantity
from (select o.date, sum(od.quantity) as tot_quantity
from orders as o
inner join order_details as od
on o.order_id = od.order_id
group by o.date) as average ;

-- top 3 most ordered pizza types based on revenue.

select top 3 pt.name, sum(p.price*od.quantity) as tot_revenue
from order_details as od
inner join pizzas as p
on od.pizza_id = p.pizza_id
inner join pizza_types as pt
on p.pizza_type_id= pt.pizza_type_id
group by pt.name
order by tot_revenue desc

-- the percentage contribution of each pizza type to total revenue.

select pt.category, (sum(p.price*od.quantity)/(select sum(p.price*od.quantity)
from order_details as od
inner join pizzas as p
on od.pizza_id = p.pizza_id))*100  as revenue_percent
from pizza_types as pt
inner join pizzas as p
on pt.pizza_type_id = p.pizza_type_id 
inner join order_details as od
on p.pizza_id = od.pizza_id
group by pt.category

-- the top 3 most ordered pizza types based on revenue for each pizza category.
select
* from (select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn 
from
 (select pt.category, pt.name, sum(p.price*od.quantity) as revenue
 from order_details as od
 inner join pizzas as p
 on od.pizza_id = p.pizza_id
 inner join pizza_types as pt
 on pt.pizza_type_id = p.pizza_type_id
 group by pt.category, pt.name) as a) as b
 where rn <= 3

