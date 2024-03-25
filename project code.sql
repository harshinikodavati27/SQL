/*Question 1*/
select distinct market from dim_customer
where customer='Atliq Exclusive' and region='APAC';

/*Question2*/
with up20 as
(
	select count(distinct(product_code)) as unique_products_2020 from fact_sales_monthly
    where fiscal_year=2020
),
	up21 as
(
	select count(distinct(product_code)) as unique_products_2021 from fact_sales_monthly
    where fiscal_year=2021
)

select u.unique_products_2020,p.unique_products_2021,
(p.unique_products_2021-u.unique_products_2020)*100/u.unique_products_2020 as percentage_chg
from up20 u
cross join up21 p;

/*Question 3*/
select segment,
count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;

/*Question 4*/
with up20 as
(
	select p.segment,count(distinct(p.product_code)) as product_count_2020 from dim_product p
    join fact_sales_monthly s
    using (product_code)
    where s.fiscal_year=2020
    group by segment
),
	up21 as
(
	select p.segment,count(distinct(p.product_code)) as product_count_2021 from dim_product p
    join fact_sales_monthly s
    using (product_code)
    where s.fiscal_year=2021
    group by segment
)
select	segment,
		p.product_count_2020,
        c.product_count_2021,
        c.product_count_2021-p.product_count_2020 as difference
        from up20 p
        join up21 c
        using (segment)
        group by segment;
        
/*Question 5*/
select m.product_code, p.product, max(m.manufacturing_cost) as max_manufacturing_cost
from fact_manufacturing_cost m
join dim_product p
on m.product_code=p.product_code
group by m.product_code
order by max_manufacturing_cost desc
limit 5;

select m.product_code, p.product, min(m.manufacturing_cost) as min_manufacturing_cost
from fact_manufacturing_cost m
join dim_product p
on m.product_code=p.product_code
group by p.product
order by min_manufacturing_cost
limit 5;

/*Question 6*/
select 	p.customer_code,
		c.customer,
        avg(p.pre_invoice_discount_pct) as average_discount_percentage
from fact_pre_invoice_deductions p
join dim_customer c
using (customer_code)
where p.fiscal_year=2021
and c.market="India"
group by p.customer_code
order by average_discount_percentage desc
limit 5;

/*Question 7*/
select month(s.date) as month, year(s.date) as year,s.gross_price_total
from gross_sales s
join dim_customer c
using (customer_code)
where c.customer='Atliq Exclusive'
group by month(s.date), year(s.date)
order by year(s.date),month(s.date);

/*Question 8*/
select get_fiscal_quarter(date) as Quarter,sum(sold_quantity) as Total_sold_quantity
from
fact_sales_monthly
where year(date)=2020
group by Quarter
order by Total_sold_quantity desc
limit 1;

/*Question 9*/
with cte as(
select c.channel, round(sum(gross_price_total)/1000000,2) as gross_sales_mln
from dim_customer c
join gross_sales s
using (customer_code)
group by c.channel)
select	*,
		round(gross_sales_mln*100/sum(gross_sales_mln) over(),2) as percentage
from cte;

/*Question 10*/
with cte as (
select 	p.division,
		p.product_code,
        p.product,
        sum(s.sold_quantity) as Total_sold_quantity
from dim_product p
join fact_sales_monthly s
using (product_code)
group by p.division,p.product_code,p.product),
	cte1 as (
select 	*,
		dense_rank() over(partition by division order by Total_sold_quantity desc) as rank_order
from cte)
select * from cte1
where rank_order<=3;

select distinct product from dim_product;
select distinct category from dim_product;