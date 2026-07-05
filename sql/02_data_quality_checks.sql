-- =====================================================
-- 02_data_quality_checks.sql
-- Purpose: Inspect raw staging data before cleaning
-- Source table: stg_amazon_orders
-- =====================================================
-- Check total number of rows loaded from CSV.
SELECT COUNT(*) AS total_rows
FROM stg_amazon_orders;

-- Check required columns for NULL or empty values.
SELECT *
FROM stg_amazon_orders
WHERE user_id IS NULL OR LTRIM(RTRIM(user_id)) = ''
   OR product_id IS NULL OR LTRIM(RTRIM(product_id)) = ''
   OR seller_id IS NULL OR LTRIM(RTRIM(seller_id)) = ''
   OR category IS NULL OR LTRIM(RTRIM(category)) = ''
   OR final_price IS NULL OR LTRIM(RTRIM(final_price)) = ''
   OR delivery_status IS NULL OR LTRIM(RTRIM(delivery_status)) = '';

-- Check whether VARCHAR staging columns can be converted to expected data types.
WITH casting_check AS (
    SELECT 
        user_id,
        product_id,
        category,
        seller_id,
        delivery_status,
        CASE 
            WHEN TRY_CAST(price AS DECIMAL(10,2)) IS NULL THEN 'invalid price'
            WHEN TRY_CAST(discount AS DECIMAL(10,2)) IS NULL THEN 'invalid discount'
            WHEN TRY_CAST(final_price AS DECIMAL(10,2)) IS NULL THEN 'invalid final_price'
            WHEN TRY_CAST(rating AS DECIMAL(3,2)) IS NULL THEN 'invalid rating'
            WHEN TRY_CAST(review_count AS INT) IS NULL THEN 'invalid review_count'
            WHEN TRY_CAST(stock AS INT) IS NULL THEN 'invalid stock'
            WHEN TRY_CAST(seller_rating AS DECIMAL(3,2)) IS NULL THEN 'invalid seller_rating'
            WHEN TRY_CAST(purchase_date AS DATE) IS NULL THEN 'invalid purchase_date'
            WHEN TRY_CAST(shipping_time_days AS INT) IS NULL THEN 'invalid shipping_time_days'
            WHEN TRY_CAST(is_returned AS BIT) IS NULL THEN 'invalid is_returned'
            ELSE 'all is ok'
        END AS conversion_check
    FROM stg_amazon_orders
)
SELECT *
FROM casting_check
WHERE conversion_check <> 'all is ok';

-- Check whether numeric values make business sense.
WITH business_check AS (
    SELECT 
        user_id,
        product_id,
        category,
        seller_id,
        delivery_status,
        CASE 
            WHEN TRY_CAST(final_price AS DECIMAL(10,2)) > TRY_CAST(price AS DECIMAL(10,2)) THEN 'final_price greater than price'
            WHEN TRY_CAST(rating AS DECIMAL(3,2)) < 0 OR TRY_CAST(rating AS DECIMAL(3,2)) > 5 THEN 'invalid rating range'
            WHEN TRY_CAST(seller_rating AS DECIMAL(3,2)) < 0 OR TRY_CAST(seller_rating AS DECIMAL(3,2)) > 5 THEN 'invalid seller_rating range'
            WHEN TRY_CAST(discount AS DECIMAL(10,2)) < 0 THEN 'negative discount'
            WHEN TRY_CAST(stock AS INT) < 0 THEN 'negative stock'
            WHEN TRY_CAST(shipping_time_days AS INT) < 0 THEN 'negative shipping days'
            WHEN TRY_CAST(review_count AS INT) < 0 THEN 'negative review count'
            ELSE 'all is ok'
        END AS business_check
    FROM stg_amazon_orders
)
SELECT *
FROM business_check
WHERE business_check <> 'all is ok';

-- Check allowed/status-like values for consistency.
SELECT DISTINCT delivery_status
FROM stg_amazon_orders
ORDER BY delivery_status;

SELECT DISTINCT device
FROM stg_amazon_orders
ORDER BY device;

SELECT DISTINCT payment_method
FROM stg_amazon_orders
ORDER BY payment_method;

SELECT DISTINCT is_returned
FROM stg_amazon_orders
ORDER BY is_returned;

-- Check whether delivery_status and is_returned are logically consistent.
-- Result: Returned orders have is_returned = 1, all other statuses have is_returned = 0.
SELECT 
    delivery_status,
    is_returned,
    COUNT(*) AS row_count
FROM stg_amazon_orders
GROUP BY delivery_status, is_returned
ORDER BY delivery_status, is_returned;

-- Check for possible duplicate transaction-like records.
SELECT 
    user_id,
    product_id,
    seller_id,
    purchase_date,
    final_price,
    payment_method,
    COUNT(*) AS duplicate_count
FROM stg_amazon_orders
GROUP BY 
    user_id,
    product_id,
    seller_id,
    purchase_date,
    final_price,
    payment_method
HAVING COUNT(*) > 1;