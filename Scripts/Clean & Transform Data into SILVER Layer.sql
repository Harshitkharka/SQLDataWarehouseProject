CREATE OR ALTER PROCEDURE SILVER.LOAD_DATA AS
BEGIN
    -- ====================================
    -- Load Clean Customer Data
    -- ====================================
    PRINT 'Inserting into silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname, 
        cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'N/A'
        END,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'N/A'
        END,
        cst_create_date
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rnk
        FROM bronze.crm_cust_info
    ) ranked
    WHERE rnk = 1;

    -- ====================================
    -- Load Clean Product Data
    -- ====================================
    PRINT 'Inserting into silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key_id, prd_nm, prd_cost,
        prd_line, prd_start_dt, prd_end_dt
    )
    SELECT 
        prd_id,
        SUBSTRING(prd_key, 1, 5),
        SUBSTRING(prd_key, 7, LEN(prd_key)),
        prd_nm,
        ISNULL(prd_cost, 0),
        CASE 
            WHEN prd_line = 'R' THEN 'Road'
            WHEN prd_line = 'M' THEN 'Mountain'
            WHEN prd_line = 'S' THEN 'Sport'
            ELSE 'Others'
        END,
        prd_start_dt,
        DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (
            PARTITION BY SUBSTRING(prd_key, 7, LEN(prd_key))
            ORDER BY prd_start_dt
        ))
    FROM bronze.crm_prd_info;

    -- ====================================
    -- Load Clean Sales Details
    -- ====================================
    PRINT 'Inserting into silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details
    SELECT 
        sls_ord_num, sls_prd_key, sls_cust_id,
        sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantity,
        REPLACE(sls_price, '-', '') AS sls_price
    FROM bronze.crm_sales_details;

    -- ====================================
    -- Load Clean ERP Customer Info
    -- ====================================
    PRINT 'Inserting into silver.erp_CUST_AZ12';
    TRUNCATE TABLE silver.erp_CUST_AZ12;

    INSERT INTO silver.erp_CUST_AZ12 (CID, BDATE, GEN)
    SELECT 
        CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) ELSE CID END,
        CASE WHEN BDATE > GETDATE() THEN NULL ELSE BDATE END,
        CASE 
            WHEN GEN = 'F' THEN 'Female'
            WHEN GEN = 'M' THEN 'Male'
            WHEN GEN = ' ' THEN NULL
            ELSE GEN
        END
    FROM bronze.erp_CUST_AZ12;

    -- ====================================
    -- Load Clean ERP Location Info
    -- ====================================
    PRINT 'Inserting into silver.erp_LOC_A101';
    TRUNCATE TABLE silver.erp_LOC_A101;

    INSERT INTO silver.erp_LOC_A101 (CID, CNTRY)
    SELECT 
        CID,
        CASE 
            WHEN CNTRY IN ('US', 'USA') THEN 'United States'
            WHEN CNTRY = '' THEN NULL
            ELSE CNTRY
        END
    FROM bronze.erp_LOC_A101;

    -- ====================================
    -- Load Product Category Mapping
    -- ====================================
    PRINT 'Inserting into silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2
    SELECT * FROM bronze.erp_PX_CAT_G1V2;

    PRINT '===== SUCCESSFULLY LOADED INTO SILVER LAYER =====';
END;
GO

-- Execute SILVER layer transformation
EXEC SILVER.LOAD_DATA;
