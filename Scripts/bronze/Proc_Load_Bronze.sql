--Stored Procedure to insert data
Create or Alter Procedure bronze.load_bronze As
Begin
		Declare @bronzeLayer_start_time Datetime, @bronzeLayer_end_time Datetime
		Declare @start_time Datetime, @end_time Datetime
	Begin Try
		set @bronzeLayer_start_time=getdate()
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		set @start_time =getdate();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		Truncate Table bronze.crm_cust_info
		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		Bulk Insert bronze.crm_cust_info
		From 'C:\Users\Mugilan\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		With(

			Firstrow = 2,
			Fieldterminator =',',
			Tablock

		)
		set @end_time =getdate();
		PRINT '>> Load Duration '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds'

		PRINT '-------------------------------------------'
		set @start_time =getdate();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		Truncate Table bronze.crm_prd_info
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		Bulk Insert bronze.crm_prd_info
		From 'C:\Users\Mugilan\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		With(

			Firstrow = 2,
			Fieldterminator =',',
			Tablock

		)
		set @end_time =getdate();
		PRINT '>> Load Duration '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds'
		PRINT '-------------------------------------------'

		set @start_time =getdate();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		Truncate Table bronze.crm_sales_details
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		Bulk Insert bronze.crm_sales_details
		From 'C:\Users\Mugilan\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		With(

			Firstrow = 2,
			Fieldterminator =',',
			Tablock

		)
		set @end_time =getdate();
		PRINT '>> Load Duration '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds'
		PRINT '-------------------------------------------'

		set @start_time =getdate();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		Truncate Table bronze.erp_cust_az12
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		Bulk Insert bronze.erp_cust_az12
		From 'C:\Users\Mugilan\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		With(

			Firstrow = 2,
			Fieldterminator =',',
			Tablock

		)
		set @end_time =getdate();
		PRINT '>> Load Duration '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds'
		PRINT '-------------------------------------------'

		set @start_time =getdate();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		Truncate Table bronze.erp_loc_a101
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		Bulk Insert bronze.erp_loc_a101
		From 'C:\Users\Mugilan\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		With(

			Firstrow = 2,
			Fieldterminator =',',
			Tablock

		)
		set @end_time =getdate();
		PRINT '>> Load Duration '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds'
		PRINT '-------------------------------------------'

		set @start_time =getdate();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		Truncate Table bronze.erp_px_cat_g1v2
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		Bulk Insert bronze.erp_px_cat_g1v2
		From 'C:\Users\Mugilan\Desktop\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		With(

			Firstrow = 2,
			Fieldterminator =',',
			Tablock

		)
		set @end_time =getdate();
		PRINT '>> Load Duration '+cast(datediff(second,@start_time,@end_time)as nvarchar)+' seconds'
		PRINT '-------------------------------------------'
		PRINT '-------------------------------------------'
		PRINT '-------------------------------------------'
		set @bronzeLayer_end_time=getdate()
		PRINT '>> Total Bronze Layer Load Duration '+cast(datediff(second,@bronzeLayer_start_time,@bronzeLayer_end_time)as nvarchar)+' seconds'
	End try
	Begin catch
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	End Catch
End

execute  bronze.load_bronze
