USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE BRONZE.LOAD_DATA AS
BEGIN
    DECLARE @START_TIME DATETIME, @END_TIME DATETIME;

    BEGIN TRY
        -- Logging header
        PRINT '----------------------------------------------------';
        PRINT 'LOADING CRM TABLES';
        PRINT '----------------------------------------------------';

        -- Load CRM Customer Info
        SET @START_TIME = GETDATE();
        TRUNCATE TABLE BRONZE.CRM_CUST_INFO;

        BULK INSERT BRONZE.CRM_CUST_INFO
        FROM 'C:\Data analysis\Datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @END_TIME = GETDATE();
        PRINT 'CRM_CUST_INFO loaded in: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds';

        -- Load CRM Product Info
        SET @START_TIME = GETDATE();
        TRUNCATE TABLE BRONZE.CRM_PRD_INFO;

        BULK INSERT BRONZE.CRM_PRD_INFO
        FROM 'C:\Data analysis\Datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @END_TIME = GETDATE();
        PRINT 'CRM_PRD_INFO loaded in: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds';

        -- Load CRM Sales Details
        SET @START_TIME = GETDATE();
        TRUNCATE TABLE BRONZE.CRM_SALES_DETAILS;

        BULK INSERT BRONZE.CRM_SALES_DETAILS
        FROM 'C:\Data analysis\Datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @END_TIME = GETDATE();
        PRINT 'CRM_SALES_DETAILS loaded in: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds';

        PRINT '----------------------------------------------------';
        PRINT 'LOADING ERP TABLES';
        PRINT '----------------------------------------------------';

        -- Load ERP Customer Master
        SET @START_TIME = GETDATE();
        TRUNCATE TABLE BRONZE.ERP_CUST_AZ12;

        BULK INSERT BRONZE.ERP_CUST_AZ12
        FROM 'C:\Data analysis\Datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @END_TIME = GETDATE();
        PRINT 'ERP_CUST_AZ12 loaded in: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds';

        -- Load ERP Location Info
        SET @START_TIME = GETDATE();
        TRUNCATE TABLE BRONZE.ERP_LOC_A101;

        BULK INSERT BRONZE.ERP_LOC_A101
        FROM 'C:\Data analysis\Datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @END_TIME = GETDATE();
        PRINT 'ERP_LOC_A101 loaded in: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds';

        -- Load ERP Product Category
        SET @START_TIME = GETDATE();
        TRUNCATE TABLE BRONZE.ERP_PX_CAT_G1V2;

        BULK INSERT BRONZE.ERP_PX_CAT_G1V2
        FROM 'C:\Data analysis\Datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @END_TIME = GETDATE();
        PRINT 'ERP_PX_CAT_G1V2 loaded in: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        -- Error logging
        PRINT 'ERROR OCCURRED --';
        PRINT 'ERROR MESSAGE -- ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute BRONZE layer load
EXEC BRONZE.LOAD_DATA;
