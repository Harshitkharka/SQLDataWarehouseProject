===============================================
-- ?? DATA ANALYSIS: Sales and Customer Insights
-- Database: DataWarehouse
-- Data Analyst: [Harshit kharka]
-- ===============================================

USE DataWarehouse;

-- ==================================================
-- ?? 1. YEARLY SALES & CUSTOMER TRENDS (2010–2014)
-- Summary of annual sales, customers, orders, and quantities
-- ==================================================

SELECT 
    YEAR(Order_date) AS [Year],
    SUM(Total_sales) AS [Total Sales],
    COUNT(DISTINCT Customer_key) AS [Customer Count],
    COUNT(Order_number) AS [Order Count],
    SUM(Quantity) AS [Total Quantity]
FROM gold.fact_SALES_INFO
WHERE Order_date IS NOT NULL
GROUP BY YEAR(Order_date)
ORDER BY YEAR(Order_date);

-- ==================================================
-- ?? 2. MONTHLY SALES TRENDS
-- Tracks average monthly sales and customer activity
-- ==================================================

SELECT 
    DATETRUNC(MONTH, Order_date) AS [Month],
    AVG(Total_sales) AS [Avg Monthly Sales],
    COUNT(DISTINCT Customer_key) AS [Customer Count],
    COUNT(Order_number) AS [Order Count],
    SUM(Quantity) AS [Total Quantity]
FROM gold.fact_SALES_INFO
WHERE Order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, Order_date)
ORDER BY DATETRUNC(MONTH, Order_date);

-- ==================================================
-- ?? 3. CUMULATIVE SALES OVER TIME
-- Tracks sales performance buildup over months
-- ==================================================

SELECT 
    ORDER_MONTH, 
    MONTHLY_SALES,
    SUM(MONTHLY_SALES) OVER (ORDER BY ORDER_MONTH) AS RUNNING_TOTAL
FROM (
    SELECT 
        DATETRUNC(MONTH, ORDER_DATE) AS ORDER_MONTH,
        SUM(Total_sales) AS MONTHLY_SALES
    FROM gold.fact_SALES_INFO
    WHERE Order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, ORDER_DATE)
) AS T;

-- ==================================================
-- ?? 4. PRODUCT PERFORMANCE ANALYSIS
-- Compares product sales to their average and previous month
-- ==================================================

WITH CTE AS (
    SELECT 
        DATETRUNC(MONTH, T1.order_date) AS order_month,
        T2.product_name,
        SUM(T1.total_sales) AS total_sales
    FROM gold.fact_sales_info AS T1
    JOIN gold.dim_product_info AS T2 ON T1.Product_key = T2.Product_key
    GROUP BY DATETRUNC(MONTH, T1.order_date), T2.product_name
)
SELECT 
    order_month,
    product_name,
    total_sales,
    AVG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month DESC) AS avg_sales,
    total_sales - AVG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month DESC) AS sales_diff,
    CASE 
        WHEN total_sales > AVG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month DESC) THEN 'Above Average'
        WHEN total_sales < AVG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month DESC) THEN 'Below Average'
        ELSE 'Average'
    END AS Product_Performance,
    LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS Prev_month,
    CASE 
        WHEN total_sales > LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month) THEN 'Increase'
        WHEN total_sales < LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month) THEN 'Decrease'
        ELSE 'No Change'
    END AS [Sales Trend]
FROM CTE;

-- ==================================================
-- ?? 5. CATEGORY-WISE SALES CONTRIBUTION
-- Calculates % contribution of each product category
-- ==================================================

WITH CTE AS (
    SELECT 
        T1.Category,
        SUM(T2.Total_sales) AS Total_Sales
    FROM gold.DIM_PRODUCT_INFO AS T1
    JOIN gold.fact_SALES_INFO AS T2 ON T1.Product_key = T2.Product_key
    GROUP BY T1.Category
)
SELECT 
    Category,
    Total_sales,
    (Total_sales * 1.0 / SUM(Total_Sales) OVER()) * 100 AS [Percentage %]
FROM CTE
ORDER BY [Percentage %] DESC;

-- ==================================================
-- ?? 6. CUSTOMER SEGMENTATION BASED ON SPENDING & LIFESPAN
-- Classifies customers as VIP, Regular, or New
-- ==================================================

WITH CTE AS (
    SELECT 
        Customer_key,
        SUM(total_Sales) AS Spending,
        MIN(Order_date) AS Oldest,
        MAX(Order_date) AS Newest,
        DATEDIFF(MONTH, MIN(Order_date), MAX(Order_date)) AS Lifespan,
        CASE 
            WHEN DATEDIFF(MONTH, MIN(Order_date), MAX(Order_date)) >= 12 AND SUM(total_Sales) > 2000 THEN 'VIP'
            WHEN DATEDIFF(MONTH, MIN(Order_date), MAX(Order_date)) BETWEEN 6 AND 12 AND SUM(total_Sales) BETWEEN 500 AND 1000 THEN 'Regular'
            ELSE 'New'
        END AS Segmentation
    FROM (
        SELECT 
            T2.Customer_Key,
            T1.Order_date,
            T1.Total_sales
        FROM gold.fact_SALES_INFO AS T1
        LEFT JOIN gold.DIM_CUST_INFO AS T2 ON T1.Customer_key = T2.Customer_Key
    ) AS T
    GROUP BY Customer_Key
)
SELECT 
    Segmentation,
    COUNT(Customer_Key) AS [Total Customers]
FROM CTE
GROUP BY Segmentation;

-- ==================================================
-- ?? 7. CUSTOMER PROFILE REPORT
-- Detailed metrics per customer: lifespan, total sales, last order, segment
-- ==================================================

SELECT 
    Customer_Key,
    [Customer Name],
    SUM(Total_sales) AS [Total Sales],
    SUM(Quantity) AS [Quantity Ordered],
    MIN(Order_date) AS [First Order],
    MAX(Order_date) AS [Last Order],
    DATEDIFF(MONTH, MIN(Order_date), MAX(Order_date)) AS [Lifespan],
    CASE 
        WHEN DATEDIFF(MONTH, MIN(Order_date), MAX(Order_date)) >= 12 AND SUM(total_Sales) > 2000 THEN 'VIP'
        WHEN DATEDIFF(MONTH, MIN(Order_date), MAX(Order_date)) BETWEEN 6 AND 12 AND SUM(total_Sales) BETWEEN 500 AND 1000 THEN 'Regular'
        ELSE 'New'
    END AS [Segment],
    COUNT(Order_number) AS [Order Count],
    AVG(Price) AS [Avg Order Value],
    DATEDIFF(DAY, MAX(Order_date), GETDATE()) AS [Days Since Last Order]
FROM (
    SELECT 
        T2.Customer_Key,
        CONCAT(T2.FirstName, ' ', T2.LastName) AS [Customer Name],
        T1.Total_sales,
        T1.Quantity,
        T1.Order_date,
        T1.Order_number,
        T1.Price,
        DATEDIFF(YEAR, T2.Birth_Date, GETDATE()) AS Age,
        CASE 
            WHEN DATEDIFF(YEAR, T2.Birth_Date, GETDATE()) BETWEEN 0 AND 20 THEN '0-20'
            WHEN DATEDIFF(YEAR, T2.Birth_Date, GETDATE()) BETWEEN 20 AND 40 THEN '20-40'
            WHEN DATEDIFF(YEAR, T2.Birth_Date, GETDATE()) BETWEEN 40 AND 60 THEN '40-60'
            ELSE 'Above 60'
        END AS [Age Group]
    FROM gold.fact_SALES_INFO AS T1
    LEFT JOIN gold.DIM_CUST_INFO AS T2 ON T1.Customer_key = T2.Customer_Key
) AS T
GROUP BY Customer_Key, [Customer Name];

-- ===============================================
-- END OF ANALYSIS
-- ===============================================