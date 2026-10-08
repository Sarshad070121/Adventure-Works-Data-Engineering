-- Create View Calendar

CREATE OR ALTER VIEW gold.calendar
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Calendar/',
        FORMAT = 'PARQUET'
    ) AS QUERY1;


-- Create View Customer

CREATE OR ALTER VIEW gold.customer
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Customers/',
        FORMAT = 'PARQUET'
    ) AS QUERY2;


-- Create View Product_Categories

CREATE OR ALTER VIEW gold.product_categories
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Product_Categories/',
        FORMAT = 'PARQUET'
    ) AS QUERY3;


-- Create View Product_Subcategories

CREATE OR ALTER VIEW gold.product_subcategories
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Product_Subcategories/',
        FORMAT = 'PARQUET'
    ) AS QUERY4;


-- Create View Products

CREATE OR ALTER VIEW gold.products
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Products/',
        FORMAT = 'PARQUET'
    ) AS QUERY5;


-- Create View Returns

CREATE OR ALTER VIEW gold.returns
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Returns/',
        FORMAT = 'PARQUET'
    ) AS QUERY6;


-- Create View Sales

CREATE OR ALTER VIEW gold.sales
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Sales/',
        FORMAT = 'PARQUET'
    ) AS QUERY7;


-- Create View Territories

CREATE OR ALTER VIEW gold.territories
AS
SELECT 
    *
FROM
    OPENROWSET(
        BULK 'https://arshadstoragedatalake.blob.core.windows.net/silver/Works_Territories/',
        FORMAT = 'PARQUET'
    ) AS QUERY8;