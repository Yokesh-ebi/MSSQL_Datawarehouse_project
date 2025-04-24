Create Or Alter Procedure silver.load_silver As
Begin
    Declare @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime; 
    Begin Try
        Set @batch_start_time = GetDate();
        Print '================================================';
        Print 'Loading Silver Layer';
        Print '================================================';

        Print '------------------------------------------------';
        Print 'Loading CRM Tables';
        Print '------------------------------------------------';

        -- Loading silver.crm_cust_info
        Set @start_time = GetDate();
        Print '>> Truncating Table: silver.crm_cust_info';
        Truncate Table silver.crm_cust_info;
        Print '>> Inserting Data Into: silver.crm_cust_info';
        Insert Into silver.crm_cust_info (
            cst_id, 
            cst_key, 
            cst_firstname, 
            cst_lastname, 
            cst_marital_status, 
            cst_gndr,
            cst_create_date
        )
        Select
            cst_id,
            cst_key,
            Trim(cst_firstname) As cst_firstname,
            Trim(cst_lastname) As cst_lastname,
            Case 
                When Upper(Trim(cst_marital_status)) = 'S' Then 'Single'
                When Upper(Trim(cst_marital_status)) = 'M' Then 'Married'
                Else 'n/a'
            End As cst_marital_status,
            Case 
                When Upper(Trim(cst_gndr)) = 'F' Then 'Female'
                When Upper(Trim(cst_gndr)) = 'M' Then 'Male'
                Else 'n/a'
            End As cst_gndr,
            cst_create_date
        From (
            Select
                *,
                Row_Number() Over (Partition By cst_id Order By cst_create_date Desc) As flag_last
            From bronze.crm_cust_info
            Where cst_id Is Not Null
        ) t
        Where flag_last = 1;
        Set @end_time = GetDate();
        Print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) As NVarChar) + ' seconds';
        Print '>> -------------';

        -- Loading silver.crm_prd_info
        Set @start_time = GetDate();
        Print '>> Truncating Table: silver.crm_prd_info';
        Truncate Table silver.crm_prd_info;
        Print '>> Inserting Data Into: silver.crm_prd_info';
        Insert Into silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        Select
            prd_id,
            Replace(Substring(prd_key, 1, 5), '-', '_') As cat_id,
            Substring(prd_key, 7, Len(prd_key)) As prd_key,
            prd_nm,
            IsNull(prd_cost, 0) As prd_cost,
            Case 
                When Upper(Trim(prd_line)) = 'M' Then 'Mountain'
                When Upper(Trim(prd_line)) = 'R' Then 'Road'
                When Upper(Trim(prd_line)) = 'S' Then 'Other Sales'
                When Upper(Trim(prd_line)) = 'T' Then 'Touring'
                Else 'n/a'
            End As prd_line,
            Cast(prd_start_dt As Date) As prd_start_dt,
            Cast(
                Lead(prd_start_dt) Over (Partition By prd_key Order By prd_start_dt) - 1 
                As Date
            ) As prd_end_dt
        From bronze.crm_prd_info;
        Set @end_time = GetDate();
        Print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) As NVarChar) + ' seconds';
        Print '>> -------------';

        -- Loading crm_sales_details
        Set @start_time = GetDate();
        Print '>> Truncating Table: silver.crm_sales_details';
        Truncate Table silver.crm_sales_details;
        Print '>> Inserting Data Into: silver.crm_sales_details';
        Insert Into silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        Select 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            Case 
                When sls_order_dt = 0 Or Len(sls_order_dt) != 8 Then Null
                Else Cast(Cast(sls_order_dt As VarChar) As Date)
            End As sls_order_dt,
            Case 
                When sls_ship_dt = 0 Or Len(sls_ship_dt) != 8 Then Null
                Else Cast(Cast(sls_ship_dt As VarChar) As Date)
            End As sls_ship_dt,
            Case 
                When sls_due_dt = 0 Or Len(sls_due_dt) != 8 Then Null
                Else Cast(Cast(sls_due_dt As VarChar) As Date)
            End As sls_due_dt,
            Case 
                When sls_sales Is Null Or sls_sales <= 0 Or sls_sales != sls_quantity * Abs(sls_price) 
                    Then sls_quantity * Abs(sls_price)
                Else sls_sales
            End As sls_sales,
            sls_quantity,
            Case 
                When sls_price Is Null Or sls_price <= 0 
                    Then sls_sales / NullIf(sls_quantity, 0)
                Else sls_price
            End As sls_price
        From bronze.crm_sales_details;
        Set @end_time = GetDate();
        Print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) As NVarChar) + ' seconds';
        Print '>> -------------';

        -- Loading erp_cust_az12
        Set @start_time = GetDate();
        Print '>> Truncating Table: silver.erp_cust_az12';
        Truncate Table silver.erp_cust_az12;
        Print '>> Inserting Data Into: silver.erp_cust_az12';
        Insert Into silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        Select
            Case
                When cid Like 'NAS%' Then Substring(cid, 4, Len(cid))
                Else cid
            End As cid, 
            Case
                When bdate > GetDate() Then Null
                Else bdate
            End As bdate,
            Case
                When Upper(Trim(gen)) In ('F', 'FEMALE') Then 'Female'
                When Upper(Trim(gen)) In ('M', 'MALE') Then 'Male'
                Else 'n/a'
            End As gen
        From bronze.erp_cust_az12;
        Set @end_time = GetDate();
        Print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) As NVarChar) + ' seconds';
        Print '>> -------------';

        Print '------------------------------------------------';
        Print 'Loading ERP Tables';
        Print '------------------------------------------------';

        -- Loading erp_loc_a101
        Set @start_time = GetDate();
        Print '>> Truncating Table: silver.erp_loc_a101';
        Truncate Table silver.erp_loc_a101;
        Print '>> Inserting Data Into: silver.erp_loc_a101';
        Insert Into silver.erp_loc_a101 (
            cid,
            cntry
        )
        Select
            Replace(cid, '-', '') As cid, 
            Case
                When Trim(cntry) = 'DE' Then 'Germany'
                When Trim(cntry) In ('US', 'USA') Then 'United States'
                When Trim(cntry) = '' Or cntry Is Null Then 'n/a'
                Else Trim(cntry)
            End As cntry
        From bronze.erp_loc_a101;
        Set @end_time = GetDate();
        Print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) As NVarChar) + ' seconds';
        Print '>> -------------';

        -- Loading erp_px_cat_g1v2
        Set @start_time = GetDate();
        Print '>> Truncating Table: silver.erp_px_cat_g1v2';
        Truncate Table silver.erp_px_cat_g1v2;
        Print '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        Insert Into silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        Select
            id,
            cat,
            subcat,
            maintenance
        From bronze.erp_px_cat_g1v2;
        Set @end_time = GetDate();
        Print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) As NVarChar) + ' seconds';
        Print '>> -------------';

        Set @batch_end_time = GetDate();
        Print '=========================================='
        Print 'Loading Silver Layer is Completed';
        Print '   - Total Load Duration: ' + Cast(DateDiff(Second, @batch_start_time, @batch_end_time) As NVarChar) + ' seconds';
        Print '=========================================='

    End Try
    Begin Catch
        Print '=========================================='
        Print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        Print 'Error Message' + Error_Message();
        Print 'Error Message' + Cast(Error_Number() As NVarChar);
        Print 'Error Message' + Cast(Error_State() As NVarChar);
        Print '=========================================='
    End Catch
End

