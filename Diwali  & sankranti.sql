/*-- 1 -- */

select distinct( product_name ),f.base_price
from dim_products p
join fact_events f on p.product_code = f.product_code
where f.promo_type = "BOGOF" and f.base_price >500 ;

/*-- 2 -- */

select city , count(store_id) as stors
from dim_stores
group by city
order by stors desc;

/*-- 3 -- */

select d.campaign_name, concat(round(sum(f.base_price *
 f.`quantity_sold(before_promo)`)/1000000,2),"M") total_revenu_before_promo,
 concat(round(sum(f.base_price *
 f.`quantity_sold(after_promo)` )/1000000,2),"M") total_revenu_after_promo
 from dim_campaigns d
 join fact_events f on d.campaign_id = f.campaign_id
 group by campaign_name;
 
 /*--4  -- */
with cte as ( 
select p.category as category, 
round((sum(f.`quantity_sold(after_promo)`)-sum(f.`quantity_sold(before_promo)`))*100/
sum(`quantity_sold(before_promo)`),2) as ISU_pct 
from dim_products p 
join fact_events f on p.product_code = f.product_code
join dim_campaigns d on d.campaign_id = f.campaign_id 
where d.campaign_name= "Diwali"
group by p.category )
select category, ISU_pct, dense_rank() over(order by ISU_pct desc) as rn
from cte;

/*-- 5 -- */

with cte as (select product_name,category, 
sum(base_price*`quantity_sold(before_promo)`) as total_rev_bp,
sum(case when promo_type = "BOGOF" 
then base_price * 0.5 *`quantity_sold(after_promo)` * 2
when promo_type = "500 Cashback" then (base_price-500)*`quantity_sold(after_promo)`
when promo_type = "50% OFF" then base_price*0.5*`quantity_sold(after_promo)`
when promo_type = "33% OFF" then base_price*0.67*`quantity_sold(after_promo)`
when promo_type = "25% OFF" then base_price*0.75*`quantity_sold(after_promo)`
end) as total_rev_ap 
from fact_events join dim_products using(product_code) 
join dim_campaigns using(campaign_id)
group by product_name,category),
cte_1 as 
( select *, (total_rev_ap - total_rev_bp) as  IR, 
round(((total_rev_ap -total_rev_bp)/total_rev_bp)*100,2) as `IR_%`
from  cte)
select product_name, category, IR, `IR_%` , rank() over(order by `IR_%` desc) as 
rnk_IR from cte_1 
limit 5 ;








