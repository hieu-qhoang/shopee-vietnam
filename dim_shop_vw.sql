# Create Dim_Shop table
create or replace view tableau.dim_shop_vw as 
with category as (
	select category_id
		, name as category_name
        , snapshot_date as last_inserted_date
        , row_number () over (partition by category_id order by snapshot_date desc) as current_row
	from shopee.category_daily_snapshot
    where category_id != -1
) #select * from category where current_row = 1
, brand as (
	select username as brand_user_name
		, brand_name
        , shopid as shop_id
        , category_id
        , snapshot_date as last_inserted_date
        , row_number () over (partition by username order by snapshot_date desc) as current_row
    from shopee.brand_daily_snapshot
) #select * from brand where current_row = 1
, shop as (
	select shopid as shop_id
		, shopname as shop_name
        , username as shop_user_name
        , userid as shop_userid
        , country
        , description
        , rating_star as avg_rating_star
        , rating_normal
        , rating_bad
        , rating_good
        , shop_location
        , status as shop_status
        , cancellation_rate
        , item_count as total_item_count
        , follower_count
        , response_rate
        , response_time
        , preparation_time
        , following_count
        , shopurl
        , snapshot_date as last_inserted_date
        , row_number () over (partition by shopid order by snapshot_date desc) as current_row
    from shopee.shop_daily_snapshot
)  #select * from shop where current_row = 1
select shop.shop_id
	, shop.shop_name
	, shop.shop_user_name
	, shop.shop_userid 
    , brand.brand_user_name
    , brand.brand_name
    , category.category_id
    , category.category_name
	, shop.country
	, shop.description
	, shop.avg_rating_star
	, shop.rating_normal
	, shop.rating_bad
	, shop.rating_good
	, shop.shop_location
	, shop.shop_status
	, shop.cancellation_rate
	, shop.total_item_count
	, shop.follower_count
	, shop.response_rate
	, shop.response_time
	, shop.preparation_time
	, shop.following_count
	, shop.shopurl
	, shop.last_inserted_date
    , current_date as last_updated_date
from shop
	left join brand 
		on brand.shop_id = shop.shop_id
        and brand.current_row = 1
	left join category 
		on category.category_id = brand.category_id
        and category.current_row = 1
where shop.current_row = 1
