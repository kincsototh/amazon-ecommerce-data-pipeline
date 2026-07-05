-- =====================================================
-- 05_reporting_views.sql
-- Purpose: Create reporting views for analytics / Power BI
-- Source table: clean_amazon_orders
-- =====================================================


-- =====================================================
-- Sales performance by month
-- =====================================================
CREATE OR ALTER VIEW vw_sales_performance
AS
SELECT
    YEAR(purchase_date) AS purchase_year,
    MONTH(purchase_date) AS purchase_month,
    DATEFROMPARTS(YEAR(purchase_date), MONTH(purchase_date), 1) AS purchase_month_date,
    COUNT(*) AS total_orders,
    SUM(final_price) AS total_revenue,
    CAST(SUM(final_price) AS DECIMAL(18,2)) / NULLIF(COUNT(*), 0) AS average_order_value,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS return_rate
FROM clean_amazon_orders
GROUP BY
    YEAR(purchase_date),
    MONTH(purchase_date),
    DATEFROMPARTS(YEAR(purchase_date), MONTH(purchase_date), 1);


-- =====================================================
-- Revenue and performance by category/subcategory
-- =====================================================
CREATE OR ALTER VIEW vw_category_revenue
AS
SELECT
    category,
    subcategory,
    COUNT(*) AS total_orders,
    SUM(final_price) AS total_revenue,
    CAST(SUM(final_price) AS DECIMAL(18,2)) / NULLIF(COUNT(*), 0) AS average_order_value,
    AVG(discount) AS average_discount,
    AVG(rating) AS average_rating,
    SUM(review_count) AS total_reviews,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS return_rate
FROM clean_amazon_orders
GROUP BY
    category,
    subcategory;


-- =====================================================
-- Brand performance by category
-- =====================================================
CREATE OR ALTER VIEW vw_brand_performance
AS
SELECT
    brand,
    category,
    COUNT(*) AS total_orders,
    SUM(final_price) AS total_revenue,
    AVG(final_price) AS average_final_price,
    AVG(rating) AS average_rating,
    SUM(review_count) AS total_review_count,
    AVG(discount) AS average_discount,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS return_rate
FROM clean_amazon_orders
GROUP BY
    brand,
    category;


-- =====================================================
-- Customer behavior by location, device, and payment method
-- =====================================================
CREATE OR ALTER VIEW vw_customer_behavior
AS
SELECT
    location,
    device,
    payment_method,
    COUNT(*) AS total_orders,
    SUM(final_price) AS total_revenue,
    CAST(SUM(final_price) AS DECIMAL(18,2)) / NULLIF(COUNT(*), 0) AS average_order_value,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS return_rate
FROM clean_amazon_orders
GROUP BY
    location,
    device,
    payment_method;


-- =====================================================
-- Return analysis by product and delivery attributes
-- =====================================================
CREATE OR ALTER VIEW vw_return_analysis
AS
SELECT
    category,
    subcategory,
    brand,
    delivery_status,
    shipping_time_days,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS return_rate,
    AVG(seller_rating) AS average_seller_rating,
    AVG(rating) AS average_product_rating,
    AVG(discount) AS average_discount
FROM clean_amazon_orders
GROUP BY
    category,
    subcategory,
    brand,
    delivery_status,
    shipping_time_days;


-- =====================================================
-- Seller performance
-- =====================================================
CREATE OR ALTER VIEW vw_seller_performance
AS
SELECT
    seller_id,
    AVG(seller_rating) AS average_seller_rating,
    COUNT(*) AS total_orders,
    SUM(final_price) AS total_revenue,
    AVG(shipping_time_days) AS average_shipping_time,
    SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS return_rate,
    SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_orders,
    CAST(SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) AS delayed_rate
FROM clean_amazon_orders
GROUP BY
    seller_id;


-- =====================================================
-- Pipeline run summary
-- =====================================================
CREATE OR ALTER VIEW vw_pipeline_summary
AS
SELECT
    run_id,
    procedure_name,
    run_started_at,
    run_finished_at,
    DATEDIFF(SECOND, run_started_at, run_finished_at) AS duration_seconds,
    staging_row_count,
    clean_row_count,
    status
FROM pipeline_run_log;