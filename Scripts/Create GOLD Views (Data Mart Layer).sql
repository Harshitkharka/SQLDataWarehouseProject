USE DataWarehouse;
GO

-- ============================================
-- Customer Dimension View
-- ============================================
CREATE VIEW GOLD.DIM_CUST_INFO AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY c1.cst_id) AS Customer_Key,
    c1.cst_id AS Customer_ID,
    c1.cst_key AS Customer_Number,
    c1.cst_firstname AS FirstName,
    c1.cst_lastname AS LastName,
    c1.cst_marital_status AS Marital_Status,
    L.Country,
    ISNULL(NULLIF(c1.cst_gndr, 'N/A'), c2.GEN) AS Gender,
    c1.cst_create_date AS Create_Date,
    c2.BDATE AS Birth_Date
FROM silver.crm_cust_info c1
LEFT JOIN silver.erp_CUST_AZ12 c2 ON c1.cst_key = c2.CID
LEFT JOIN (
    SELECT 
        REPLACE(CID, '-', '') AS CID,
        CASE 
            WHEN CNTRY = 'DE' OR CNTRY IS NULL THEN 'N/A'
            ELSE CNTRY
        END AS Country
    FROM silver.erp_LOC_A101
) L ON c1.cst_key = L.CID;

-- ============================================
-- Product Dimension View
-- ============================================
CREATE VIEW GOLD.DIM_PRODUCT_INFO AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY p1.prd_key_id) AS Product_Key,
    p1.prd_id AS Product_ID,
    p1.cat_id AS Category_ID,
    p1.prd_key_id AS Product_Number,
    p1.prd_nm AS Product_Name,
    p1.prd_cost AS Cost,
    p1.prd_line AS Line,
    p1.prd_start_dt AS Create_Date,
    p2.cat AS Category,
    p2.subcat AS Sub_Category,
    p2.maintenance AS Maintenance
FROM (
    SELECT 
        prd_id,
        REPLACE(cat_id, '-', '_') AS cat_id,
        prd_key_id,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    FROM silver.crm_prd_info
) p1
LEFT JOIN silver.erp_px_cat_g1v2 p2 ON p1.cat_id = p2.id
WHERE p1.prd_end_dt IS NULL;

-- ============================================
-- Sales Fact View
-- ============================================
CREATE VIEW GOLD.fact_SALES_INFO AS
SELECT 
    s.sls_ord_num AS Order_Number,
    cu.Customer_Key,
    p.Product_Key,
    s.sls_order_dt AS Order_Date,
    s.sls_ship_dt AS Shipping_Date,
    s.sls_due_dt AS Due_Date,
    s.sls_sales AS Total_Sales,
    s.sls_price AS Price,
    s.sls_quantity AS Quantity
FROM silver.crm_sales_details s
LEFT JOIN GOLD.DIM_CUST_INFO cu ON s.sls_cust_id = cu.Customer_ID
LEFT JOIN GOLD.DIM_PRODUCT_INFO p ON s.sls_prd_key = p.Product_Number;

-- ============================================
-- Preview Final Fact Table
-- ============================================
SELECT * FROM GOLD.fact_SALES_INFO;
