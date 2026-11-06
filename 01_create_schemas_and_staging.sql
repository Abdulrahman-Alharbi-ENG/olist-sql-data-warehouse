CREATE DATABASE OlistDW;
GO
USE OlistDW;
GO

CREATE SCHEMA stg;
GO
CREATE SCHEMA dw;
GO

CREATE TABLE stg.orders (
    order_id NVARCHAR(50), customer_id NVARCHAR(50), order_status NVARCHAR(50),
    order_purchase_timestamp NVARCHAR(50), order_approved_at NVARCHAR(50),
    order_delivered_carrier_date NVARCHAR(50), order_delivered_customer_date NVARCHAR(50),
    order_estimated_delivery_date NVARCHAR(50)
);

CREATE TABLE stg.customers (
    customer_id NVARCHAR(50), customer_unique_id NVARCHAR(50),
    customer_zip_code_prefix NVARCHAR(10), customer_city NVARCHAR(100), customer_state NVARCHAR(10)
);

CREATE TABLE stg.order_items (
    order_id NVARCHAR(50), order_item_id NVARCHAR(10), product_id NVARCHAR(50),
    seller_id NVARCHAR(50), shipping_limit_date NVARCHAR(50),
    price NVARCHAR(20), freight_value NVARCHAR(20)
);

CREATE TABLE stg.products (
    product_id NVARCHAR(50), product_category_name NVARCHAR(100),
    product_name_lenght NVARCHAR(10), product_description_lenght NVARCHAR(10),
    product_photos_qty NVARCHAR(10), product_weight_g NVARCHAR(10),
    product_length_cm NVARCHAR(10), product_height_cm NVARCHAR(10), product_width_cm NVARCHAR(10)
);

CREATE TABLE stg.sellers (
    seller_id NVARCHAR(50), seller_zip_code_prefix NVARCHAR(10),
    seller_city NVARCHAR(100), seller_state NVARCHAR(10)
);

CREATE TABLE stg.category_translation (
    product_category_name NVARCHAR(100), product_category_name_english NVARCHAR(100)
);

CREATE TABLE stg.order_payments (
    order_id NVARCHAR(50), payment_sequential NVARCHAR(10), payment_type NVARCHAR(30),
    payment_installments NVARCHAR(10), payment_value NVARCHAR(20)
);

CREATE TABLE stg.order_reviews (
    review_id NVARCHAR(50), order_id NVARCHAR(50), review_score NVARCHAR(10),
    review_comment_title NVARCHAR(500), review_comment_message NVARCHAR(MAX),
    review_creation_date NVARCHAR(50), review_answer_timestamp NVARCHAR(50)
);
GO