CREATE OR ALTER PROCEDURE [dbo].[usp_InsertCleanAmazonOrders]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @run_started_at AS DATETIME = GETDATE();

    DELETE FROM clean_amazon_orders;

    INSERT INTO clean_amazon_orders (
        user_id,
        product_id,
        category,
        subcategory,
        brand,
        price,
        discount,
        final_price,
        rating,
        review_count,
        stock,
        seller_id,
        seller_rating,
        purchase_date,
        shipping_time_days,
        location,
        device,
        payment_method,
        is_returned,
        delivery_status
    )
    SELECT
        user_id,
        product_id,
        category,
        subcategory,
        brand,
        TRY_CAST(price AS DECIMAL(10,2)) AS price,
        TRY_CAST(discount AS DECIMAL(10,2)) AS discount,
        TRY_CAST(final_price AS DECIMAL(10,2)) AS final_price,
        TRY_CAST(rating AS DECIMAL(3,2)) AS rating,
        TRY_CAST(review_count AS INT) AS review_count,
        TRY_CAST(stock AS INT) AS stock,
        seller_id,
        TRY_CAST(seller_rating AS DECIMAL(3,2)) AS seller_rating,
        TRY_CAST(purchase_date AS DATE) AS purchase_date,
        TRY_CAST(shipping_time_days AS INT) AS shipping_time_days,
        location,
        device,
        payment_method,
        TRY_CAST(is_returned AS BIT) AS is_returned,
        delivery_status
    FROM stg_amazon_orders
    WHERE NULLIF(LTRIM(RTRIM(user_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(product_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(seller_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(category)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(final_price)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(delivery_status)), '') IS NOT NULL

      AND TRY_CAST(price AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(discount AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(final_price AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(rating AS DECIMAL(3,2)) IS NOT NULL
      AND TRY_CAST(review_count AS INT) IS NOT NULL
      AND TRY_CAST(stock AS INT) IS NOT NULL
      AND TRY_CAST(seller_rating AS DECIMAL(3,2)) IS NOT NULL
      AND TRY_CAST(purchase_date AS DATE) IS NOT NULL
      AND TRY_CAST(shipping_time_days AS INT) IS NOT NULL
      AND TRY_CAST(is_returned AS BIT) IS NOT NULL

      AND TRY_CAST(final_price AS DECIMAL(10,2)) <= TRY_CAST(price AS DECIMAL(10,2))
      AND TRY_CAST(rating AS DECIMAL(3,2)) BETWEEN 0 AND 5
      AND TRY_CAST(seller_rating AS DECIMAL(3,2)) BETWEEN 0 AND 5
      AND TRY_CAST(discount AS DECIMAL(10,2)) >= 0
      AND TRY_CAST(stock AS INT) >= 0
      AND TRY_CAST(shipping_time_days AS INT) >= 0
      AND TRY_CAST(review_count AS INT) >= 0;

    INSERT INTO pipeline_run_log (
    procedure_name,
    run_started_at,
    run_finished_at,
    staging_row_count,
    clean_row_count,
    status
    )
    VALUES (
        'usp_InsertCleanAmazonOrders',
        @run_started_at,
        GETDATE(),
        (SELECT COUNT(*) FROM stg_amazon_orders),
        (SELECT COUNT(*) FROM clean_amazon_orders),
        'SUCCESS'
    );
END;