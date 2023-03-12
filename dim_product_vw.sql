create or replace view tableau.dim_product_vw as 
with product_summary as (
	select product_id
		, min(snapshot_date) as first_live_date
        , max(snapshot_date) as last_live_date
        , count(distinct snapshot_date) as number_of_live_days
        , sum(case when product_status = 'sold_out' then 1 else 0 end) as times_sold_out
        , max(product_price) as max_product_price
        , min(product_price) as min_product_price
        , max(product_discount) as max_product_discount
        , min(product_discount) as min_product_discount
        , sum(is_on_flash_sale) as days_on_flash_sale
        , max(historical_sold) as all_time_sold
        , sum(case when snapshot_date >= current_date - interval 7 day then new_items_sold else 0 end) as last_7_days_sold
        , max(liked_count) as all_time_like
        , sum(case when snapshot_date >= current_date - interval 7 day then new_like_count else 0 end) as last_7_days_like
        , max(view_count) as all_time_view
        , sum(case when snapshot_date >= current_date - interval 7 day then new_view_count else 0 end) as last_7_days_view
        , max(comment_count) as all_time_comment
        , sum(case when snapshot_date >= current_date - interval 7 day then new_comment_count else 0 end) as last_7_days_comment
        , max(total_rating_count) as all_time_rating
        , sum(case when snapshot_date >= current_date - interval 7 day then new_rating_count else 0 end) as last_7_days_rating
    from tableau.fact_product_daily
    group by 1
) #select * from products where last_7_days_view order by last_7_days_view desc limit 1000;
, product_current_details as (
	select *
		, row_number() over (partition by product_id order by snapshot_date desc ) as current_row
    from tableau.fact_product_daily
) #select * from product_current_details where current_row = 1 limit 1000;
select pd.product_id
	, pd.snapshot_date as last_inserted_date
	, pd.shop_id
	, pd.product_name
	, pd.product_image
	, pd.currency
	, pd.status
	, pd.product_category_id
	, pd.product_flag
	, pd.product_cb_option
	, pd.product_status as product_current_status
	, pd.product_price as product_price
	, pd.product_price_before_discount as product_price_before_discount
	, pd.product_discount
	, pd.tier_variations
	, pd.tier_variations_type
	, pd.tier_variations_count
	, pd.product_type
	, pd.is_on_flash_sale
	, pd.shopee_verified
	, pd.product_stock
# 	, pd.historical_sold
# 	, pd.liked_count
# 	, pd.view_count
# 	, pd.comment_count
	, pd.product_avg_rating
	, pd.total_rating_count
	, pd.rating_count_details
	, pd.rating_count_with_context
	, pd.rating_count_with_image
	, pd.product_url
    , ps.first_live_date
	, ps.last_live_date
	, ps.number_of_live_days
	, ps.times_sold_out
	, ps.max_product_price
	, ps.min_product_price
	, ps.max_product_discount
	, ps.min_product_discount
	, ps.days_on_flash_sale
	, ps.all_time_sold
	, ps.last_7_days_sold
	, ps.all_time_like
	, ps.last_7_days_like
	, ps.all_time_view
	, ps.last_7_days_view
	, ps.all_time_comment
	, ps.last_7_days_comment
	, ps.all_time_rating
	, ps.last_7_days_rating
	, current_date as last_updated_date
from product_current_details as pd 
	left join product_summary ps 
		on ps.product_id = pd.product_id
where pd.current_row = 1
