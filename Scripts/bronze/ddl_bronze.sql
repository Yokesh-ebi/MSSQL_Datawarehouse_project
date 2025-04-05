If object_Id('bronze.crm_cust_info','U') Is not null
	Drop Table bronze.crm_cust_info
Go

Create Table bronze.crm_cust_info(
	  cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE

)
Go

If object_Id('bronze.crm_prd_info','U') Is not null
	Drop Table bronze.crm_prd_info
Go

create table bronze.crm_prd_info(

	  prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME

)
Go

If object_Id('bronze.crm_sales_details','U') Is not null
	Drop Table bronze.crm_sales_details
Go

Create Table bronze.crm_sales_details(
	  sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
)
Go

If object_Id('bronze.erp_loc_a101','U') Is not null
	Drop Table bronze.erp_loc_a101
Go

Create Table bronze.erp_loc_a101(

	  cid    NVARCHAR(50),
    cntry  NVARCHAR(50)

)
Go

If object_Id('bronze.erp_cust_az12','U') Is not null
	Drop Table bronze.erp_cust_az12
Go

Create Table bronze.erp_cust_az12(

	  cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)

)
Go

If object_Id('bronze.erp_px_cat_g1v2','U') Is not null
	Drop Table bronze.erp_px_cat_g1v2
Go

Create Table bronze.erp_px_cat_g1v2(

	  id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
)
Go
