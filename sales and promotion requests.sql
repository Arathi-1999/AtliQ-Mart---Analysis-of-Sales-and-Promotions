 /*1. provide a list of products with a base price greater than 500 and that are features in promo type BOGOF(Buy one get One free) */
 select distinct p.product_name as product_Name, f.promo_type as Promo_type, f.base_price as Base_Price
 from fact_events f
 join dim_products p on f.product_code = p.product_code
 where f.base_price > 500
 and f.promo_type = "BOGOF";
 
 /*2.Generate a report that provides an overview of the number of stores in each city. The results will be stored in descending order of store counts*/
 select city, count(store_id) as no_of_stores 
 from dim_stores
 group by city
 order by no_of_stores desc;
 
/* 3. Generate a report that displays each campaign along with total revenue generated before and after campaign?*/
select c.campaign_name, 
concat(round(sum(base_price*`quantity_sold(before_promo)`)/1000000 ,2), 'M') as total_revenue_before_promo,
concat(round(sum(base_price*`quantity_sold(after_promo)`)/1000000 ,2), 'M') as total_revenue_after_promo
from fact_events 
join dim_campaigns c on fact_events.campaign_id = c.campaign_id 
group by c.campaign_name;

/*4. Produce a report that calculate the incremental sold quantity(ISU%) percentage for each category during the diwali campaign.*/
with cte as
(select p.category, sum(f.`quantity_sold(before_promo)`) as total_quantity_before_promo,
sum(f.`quantity_sold(after_promo)`) as total_quantity_after_promo
from fact_events f
join dim_products p on f.product_code = p.product_code
join dim_campaigns c on f.campaign_id=c.campaign_id
where c.campaign_name="Diwali"
group by p.category
)
select category,
round((total_quantity_after_promo - total_quantity_before_promo) /total_quantity_before_promo *100,2) as ISU_percent,
rank() over(order by (total_quantity_after_promo - total_quantity_before_promo)/total_quantity_before_promo desc) as rank_order
from cte;

/*5. Create a report featuring the top 5 products, ranked by Incremental Revenue Percentage(IR%) , across all campaigns.*/
with product as (
select p.product_name, p.category, 
round(((sum(e.base_price * e.`quantity_sold(after_promo)`)/sum(e.base_price * e.`quantity_sold(before_promo)`))-1) * 100,2) as IR_percent,
rank() over(order by ((sum(e.base_price * e. `quantity_sold(after_promo)`) /sum(e.base_price * e.`quantity_sold(before_promo)`))-1) * 100 desc) as rank_order
from fact_events e
join dim_products p on e.product_code = p.product_code
group by p.product_name, p.category
)
select product_name, category, IR_percent
from product
where rank_order <=5;


