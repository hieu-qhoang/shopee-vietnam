create or replace view tableau.fact_product_daily_vw as 
with remove_product_duplicates as (
	select *
		# dups = 1 to remove duplicates
		, row_number() over (partition by itemid, snapshot_date order by view_count ) as dups
    from shopee.product_daily_snapshot pro 
		# reduce number of records
		inner join tableau.dim_shop ds 
			on pro.shopid = ds.shop_id
            and ds.category_id != 11036670
	where pro.snapshot_date  >= (select max(statistic_date) - interval 2 day from tableau.fact_product_daily) 
		 #and pro.snapshot_date <= '2021-10-16'
) #select * from remove_product_duplicates where dups = 1;
, final as (
select row_id
	, itemid as product_id
	, snapshot_date - interval 1 day as statistic_date
	, snapshot_date
	, shopid as shop_id
    , productname as product_name
    , image as product_image
    , currency
    , status
    , catid as product_category_id
    , flag as product_flag
    , cb_option as product_cb_option
    , item_status as product_status
    , price/100000 as product_price
    , price_before_discount/100000 as product_price_before_discount
    , show_discount
    , raw_discount as product_discount
    , tier_variations
    , tier_variations_type
    , tier_variations_count
    , item_type as product_type
    , is_on_flash_sale
    , shopee_verified
    , stock as product_stock
    , ifnull(( stock - (lag(stock) over (partition by itemid order by snapshot_date asc))),0) as stock_changed
	, historical_sold
    , ifnull(abs(historical_sold - (lag(historical_sold) over (partition by itemid order by snapshot_date asc))),0) as new_items_sold
    , liked_count
	, ifnull((liked_count - (lag(liked_count) over (partition by itemid order by snapshot_date asc))),0) as new_like_count
	, view_count
	, ifnull(abs(view_count - (lag(view_count) over (partition by itemid order by snapshot_date asc))),0) as new_view_count
	, cmt_count as comment_count
	, ifnull(abs(cmt_count - (lag(cmt_count) over (partition by itemid order by snapshot_date asc))),0) as new_comment_count
    , round(rating_avg,1) as product_avg_rating
	, rating_total as total_rating_count
    , rating_count as rating_count_details
	, ifnull(abs(rating_total - (lag(rating_total) over (partition by itemid order by snapshot_date asc))),0) as new_rating_count
    , rating_count_with_context
    , rating_count_with_image
    , product_url
    , current_date as last_updated_date
from remove_product_duplicates
where dups  = 1
)
select *
from final
where statistic_date > (select max(statistic_date)  from tableau.fact_product_daily) 
