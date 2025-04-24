If Object_Id('gold.dim_customers', 'V') Is Not Null
    Drop View gold.dim_customers;
Go
Create View gold.dim_customers As
Select
    Row_Number() Over (Order By cst_id) As customer_key, -- Surrogate key
    ci.cst_id                          As customer_id,
    ci.cst_key                         As customer_number,
    ci.cst_firstname                   As first_name,
    ci.cst_lastname                    As last_name,
    la.cntry                           As country,
    ci.cst_marital_status              As marital_status,
    Case 
        When ci.cst_gndr != 'n/a' Then ci.cst_gndr -- CRM is the primary source for gender
        Else Coalesce(ca.gen, 'n/a')  			   -- Fallback to ERP data
    End                                As gender,
    ca.bdate                           As birthdate,
    ci.cst_create_date                 As create_date
From silver.crm_cust_info ci
Left Join silver.erp_cust_az12 ca
    On ci.cst_key = ca.cid
Left Join silver.erp_loc_a101 la
    On ci.cst_key = la.cid;
Go

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
If Object_Id('gold.dim_products', 'V') Is Not Null
    Drop View gold.dim_products;
Go

Create View gold.dim_products As
Select
    Row_Number() Over (Order By pn.prd_start_dt, pn.prd_key) As product_key, -- Surrogate key
    pn.prd_id       As product_id,
    pn.prd_key      As product_number,
    pn.prd_nm       As product_name,
    pn.cat_id       As category_id,
    pc.cat          As category,
    pc.subcat       As subcategory,
    pc.maintenance  As maintenance,
    pn.prd_cost     As cost,
    pn.prd_line     As product_line,
    pn.prd_start_dt As start_date
From silver.crm_prd_info pn
Left Join silver.erp_px_cat_g1v2 pc
    On pn.cat_id = pc.id
Where pn.prd_end_dt Is Null; -- Filter out all historical data
Go

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
If Object_Id('gold.fact_sales', 'V') Is Not Null
    Drop View gold.fact_sales;
Go

Create View gold.fact_sales As
Select
    sd.sls_ord_num  As order_number,
    pr.product_key  As product_key,
    cu.customer_key As customer_key,
    sd.sls_order_dt As order_date,
    sd.sls_ship_dt  As shipping_date,
    sd.sls_due_dt   As due_date,
    sd.sls_sales    As sales_amount,
    sd.sls_quantity As quantity,
    sd.sls_price    As price
From silver.crm_sales_details sd
Left Join gold.dim_products pr
    On sd.sls_prd_key = pr.product_number
Left Join gold.dim_customers cu
    On sd.sls_cust_id = cu.customer_id;
Go

