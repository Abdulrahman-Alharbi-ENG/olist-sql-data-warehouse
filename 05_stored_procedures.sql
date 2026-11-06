USE OlistDW;
GO

CREATE OR ALTER PROCEDURE dw.usp_Load_DimCustomer
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dw.BridgeCustomer;
    DELETE FROM dw.DimCustomer;
    DBCC CHECKIDENT ('dw.DimCustomer', RESEED, 0) WITH NO_INFOMSGS;

    ;WITH Ranked AS (
        SELECT customer_unique_id, customer_zip_code_prefix,
               LOWER(LTRIM(RTRIM(customer_city))) AS city,
               UPPER(LTRIM(RTRIM(customer_state))) AS st,
               ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY customer_id) AS rn
        FROM stg.customers
    )
    INSERT INTO dw.DimCustomer (CustomerUniqueID, ZipCodePrefix, City, [State])
    SELECT customer_unique_id, customer_zip_code_prefix, city, st
    FROM Ranked WHERE rn = 1;

    INSERT INTO dw.BridgeCustomer (CustomerID, CustomerKey)
    SELECT c.customer_id, d.CustomerKey
    FROM stg.customers c
    JOIN dw.DimCustomer d ON d.CustomerUniqueID = c.customer_unique_id;
END;
GO

CREATE OR ALTER PROCEDURE dw.usp_Load_DimProduct
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dw.DimProduct;
    DBCC CHECKIDENT ('dw.DimProduct', RESEED, 0) WITH NO_INFOMSGS;

    INSERT INTO dw.DimProduct (ProductID, CategoryPT, CategoryEN, WeightG, LengthCm, HeightCm, WidthCm, PhotosQty)
    SELECT p.product_id,
           NULLIF(p.product_category_name, ''),
           COALESCE(t.product_category_name_english, 'unknown'),
           TRY_CAST(NULLIF(p.product_weight_g, '') AS INT),
           TRY_CAST(NULLIF(p.product_length_cm, '') AS INT),
           TRY_CAST(NULLIF(p.product_height_cm, '') AS INT),
           TRY_CAST(NULLIF(p.product_width_cm, '') AS INT),
           TRY_CAST(NULLIF(p.product_photos_qty, '') AS INT)
    FROM stg.products p
    LEFT JOIN stg.category_translation t
           ON t.product_category_name = p.product_category_name;
END;
GO

CREATE OR ALTER PROCEDURE dw.usp_Load_DimSeller
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dw.DimSeller;
    DBCC CHECKIDENT ('dw.DimSeller', RESEED, 0) WITH NO_INFOMSGS;

    INSERT INTO dw.DimSeller (SellerID, ZipCodePrefix, City, [State])
    SELECT seller_id, seller_zip_code_prefix,
           LOWER(LTRIM(RTRIM(seller_city))),
           UPPER(LTRIM(RTRIM(seller_state)))
    FROM stg.sellers;
END;
GO

CREATE OR ALTER PROCEDURE dw.usp_Load_FactOrderItems
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dw.FactOrderItems;
    DBCC CHECKIDENT ('dw.FactOrderItems', RESEED, 0) WITH NO_INFOMSGS;

    INSERT INTO dw.FactOrderItems
        (OrderID, OrderItemNumber, CustomerKey, ProductKey, SellerKey, PurchaseDateKey,
         OrderStatus, Price, FreightValue, PurchaseTS, DeliveredTS, EstimatedDelivery, IsDataIssue)
    SELECT i.order_id,
           CAST(i.order_item_id AS INT),
           b.CustomerKey, p.ProductKey, s.SellerKey,
           CONVERT(INT, FORMAT(CAST(o.order_purchase_timestamp AS DATE), 'yyyyMMdd')),
           o.order_status,
           CAST(i.price AS DECIMAL(10,2)),
           CAST(i.freight_value AS DECIMAL(10,2)),
           TRY_CAST(NULLIF(o.order_purchase_timestamp, '') AS DATETIME2),
           TRY_CAST(NULLIF(o.order_delivered_customer_date, '') AS DATETIME2),
           TRY_CAST(NULLIF(o.order_estimated_delivery_date, '') AS DATETIME2),
           CASE WHEN o.order_status = 'delivered'
                 AND (o.order_delivered_customer_date IS NULL
                      OR o.order_delivered_customer_date = '')
                THEN 1 ELSE 0 END
    FROM stg.order_items i
    JOIN stg.orders        o ON o.order_id   = i.order_id
    JOIN dw.BridgeCustomer b ON b.CustomerID = o.customer_id
    JOIN dw.DimProduct     p ON p.ProductID  = i.product_id
    JOIN dw.DimSeller      s ON s.SellerID   = i.seller_id;
END;
GO

CREATE OR ALTER PROCEDURE dw.usp_LoadStarSchema
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dw.FactOrderItems;

        EXEC dw.usp_Load_DimCustomer;
        EXEC dw.usp_Load_DimProduct;
        EXEC dw.usp_Load_DimSeller;
        EXEC dw.usp_Load_FactOrderItems;

        DECLARE @expected INT = (SELECT COUNT(*) FROM stg.order_items);
        DECLARE @actual   INT = (SELECT COUNT(*) FROM dw.FactOrderItems);

        IF @expected <> @actual
            THROW 50001, 'Row count mismatch between stg.order_items and dw.FactOrderItems', 1;

        COMMIT TRANSACTION;

        SELECT 'SUCCESS' AS Status, @actual AS FactRows;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO