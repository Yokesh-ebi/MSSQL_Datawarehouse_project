use master;
go
  
--Cheks if the database is already exixts if it is then it deletes it and create a new one
If exists (select 1 from sys.databases where name='DataWarehouse')
Begin
	Alter Database DataWarehouse set Single_User with Rollback Immediate;
	Drop Database DataWarehouse
End;

--Creating the data warehouse
Go
Create Database DataWarehouse;

use DataWarehouse;

--Creating the Schemas
go
Create Schema bronze;
go
Create Schema silver;
go
Create Schema gold;
go
