USE OlistDW;
GO

-- Date dimension
CREATE TABLE dw.DimDate (
    DateKey INT NOT NULL PRIMARY KEY,
    FullDate DATE NOT NULL,
    [Year] INT NOT NULL,
    [Quarter] INT NOT NULL,
    [Month] INT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    [Day] INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName NVARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL
);
GO

SET DATEFIRST 7;

WITH Dates AS (
    SELECT CAST('2016-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM Dates WHERE d < '2018-12-31'
)
INSERT INTO dw.DimDate
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd')),
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    MONTH(d),
    DATENAME(MONTH, d),
    DAY(d),
    DATEPART(WEEKDAY, d),
    DATENAME(WEEKDAY, d),
    CASE WHEN DATENAME(WEEKDAY, d) IN ('Friday','Saturday') THEN 1 ELSE 0 END
FROM Dates
OPTION (MAXRECURSION 0);
GO

-- Customer dimension (one row per real person) + bridge
CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerUniqueID NVARCHAR(50) NOT NULL UNIQUE,
    ZipCodePrefix NVARCHAR(10),
    City NVARCHAR(100),
    [State] NVARCHAR(10)
);
GO

CREATE TABLE dw.BridgeCustomer (
    CustomerID NVARCHAR(50) NOT NULL PRIMARY KEY,
    CustomerKey INT NOT NULL FOREIGN KEY REFERENCES dw.DimCustomer(CustomerKey)
);
GO

-- Product dimension
CREATE TABLE dw.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID NVARCHAR(50) NOT NULL UNIQUE,
    CategoryPT NVARCHAR(100),
    CategoryEN NVARCHAR(100) NOT NULL,
    WeightG INT,
    LengthCm INT,
    HeightCm INT,
    WidthCm INT,
    PhotosQty INT
);
GO

-- Seller dimension
CREATE TABLE dw.DimSeller (
    SellerKey INT IDENTITY(1,1) PRIMARY KEY,
    SellerID NVARCHAR(50) NOT NULL UNIQUE,
    ZipCodePrefix NVARCHAR(10),
    City NVARCHAR(100),
    [State] NVARCHAR(10)
);
GO

-- Fact table (grain: one row per item within an order)
CREATE TABLE dw.FactOrderItems (
    OrderItemKey INT IDENTITY(1,1) NOT NULL,
    OrderID NVARCHAR(50) NOT NULL,
    OrderItemNumber INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    SellerKey INT NOT NULL,
    PurchaseDateKey INT NOT NULL,
    OrderStatus NVARCHAR(30) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FreightValue DECIMAL(10,2) NOT NULL,
    PurchaseTS DATETIME2 NULL,
    DeliveredTS DATETIME2 NULL,
    EstimatedDelivery DATETIME2 NULL,
    IsDataIssue BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_FactOrderItems PRIMARY KEY (OrderItemKey),
    CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_Fact_Product FOREIGN KEY (ProductKey) REFERENCES dw.DimProduct(ProductKey),
    CONSTRAINT FK_Fact_Seller FOREIGN KEY (SellerKey) REFERENCES dw.DimSeller(SellerKey),
    CONSTRAINT FK_Fact_Date FOREIGN KEY (PurchaseDateKey) REFERENCES dw.DimDate(DateKey)
);
GO