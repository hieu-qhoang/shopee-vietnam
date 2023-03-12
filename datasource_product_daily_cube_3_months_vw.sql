create or replace view tableau.product_daily_cube_3_months_vw as 
select fact.product_id
	, fact.product_status
	, fact.statistic_date
    , fact.product_price
    , fact.product_price_before_discount
    , fact.product_discount/100 as product_discount
    , fact.product_stock
    , fact.is_on_flash_sale
    , fact.stock_changed
    , fact.new_items_sold 
    , fact.new_like_count 
    , fact.new_view_count
    , fact.new_comment_count
    , fact.product_avg_rating
    , fact.new_rating_count
    , pro.product_price as current_product_price
    , pro.product_name
    , pro.product_image
    , pro.currency
    , pro.product_current_status
    , pro.product_type
    , pro.product_category_id
    , pro.product_price as product_current_price
    , pro.product_price_before_discount as product_current_price_before_discount
    , pro.shopee_verified as shopee_verified_product
    , pro.product_stock as product_current_stock
    , pro.is_on_flash_sale as is_currently_on_flash_sale
    , pro.tier_variations
    , pro.tier_variations_type
    , pro.tier_variations_count
    , pro.product_avg_rating as product_current_avg_rating
    , pro.total_rating_count
    , pro.rating_count_details
    , pro.rating_count_with_context
    , pro.rating_count_with_image
    , pro.product_url
    , pro.first_live_date
    , pro.last_live_date
    , pro.max_product_price
    , pro.min_product_price
    , pro.max_product_discount
    , pro.min_product_discount
    , pro.all_time_sold
    , pro.all_time_like
    , pro.all_time_view
    , pro.all_time_comment
    , pro.all_time_rating
    , fact.shop_id
    , shop.shop_name
    , shop.shop_user_name
    , shop.shop_userid
    , shop.brand_user_name
    , shop.brand_name
    , shop.category_id
    , shop.category_name
    , shop.country
    , shop.description as shop_description
    , shop.avg_rating_star as shop_avg_rating_star
    , shop.rating_bad + shop.rating_good + shop.rating_normal as total_rating
    , shop.shop_location
    , shop.shop_status
    , shop.cancellation_rate as shop_cancellation_rate
    , shop.total_item_count as shop_total_products
    , shop.follower_count
    , shop.response_rate
    , shop.response_time
    , shop.preparation_time
    , shop.following_count
    , shop.shopurl
    , shop.last_inserted_date as shop_last_inserted_date
    , fact.last_updated_date
from tableau.fact_product_daily fact
	left join tableau.dim_product pro 
		on pro.product_id = fact.product_id
    left join tableau.dim_shop shop 
		on shop.shop_id = fact.shop_id
where fact.statistic_date >= ((current_date() - interval 1 day) - interval 3 month)
	and fact.statistic_date >= '2021-08-16'
;
