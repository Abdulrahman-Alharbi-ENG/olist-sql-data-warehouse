USE OlistDW;
GO

TRUNCATE TABLE stg.orders;
BULK INSERT stg.orders FROM 'C:\OlistData\olist_orders_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

TRUNCATE TABLE stg.customers;
BULK INSERT stg.customers FROM 'C:\OlistData\olist_customers_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

TRUNCATE TABLE stg.order_items;
BULK INSERT stg.order_items FROM 'C:\OlistData\olist_order_items_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

TRUNCATE TABLE stg.products;
BULK INSERT stg.products FROM 'C:\OlistData\olist_products_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

TRUNCATE TABLE stg.sellers;
BULK INSERT stg.sellers FROM 'C:\OlistData\olist_sellers_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

TRUNCATE TABLE stg.category_translation;
BULK INSERT stg.category_translation FROM 'C:\OlistData\product_category_name_translation.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

-- two categories missing from the translation file
INSERT INTO stg.category_translation VALUES
('pc_gamer', 'pc_gamer'),
('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers');

TRUNCATE TABLE stg.order_payments;
BULK INSERT stg.order_payments FROM 'C:\OlistData\olist_order_payments_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');

TRUNCATE TABLE stg.order_reviews;
BULK INSERT stg.order_reviews FROM 'C:\OlistData\olist_order_reviews_dataset.csv'
WITH (FORMAT = 'CSV', FIELDQUOTE = '"', FIRSTROW = 2, CODEPAGE = '65001');
GO