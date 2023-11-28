--*************************************************************************--
-- Title: Assignment06
-- Author: Colleen Price
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-11-19,Colleen Price,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CPrice')
	 Begin 
	  Alter Database [Assignment06DB_CPrice] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CPrice;
	 End
	Create Database Assignment06DB_CPrice;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CPrice;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Select * from Assignment06DB_CPrice.dbo.Categories;

--Select  CategoryID, CategoryName
--From Assignment06DB_CPrice.dbo.Categories;

Go
Create --Drop
View vCategories
WITH SCHEMABINDING
As
  Select  CategoryID, CategoryName
  From dbo.Categories;
Go

Select * from vCategories;

--Select * from Assignment06DB_CPrice.dbo.Products;

--Select ProductID, 
--       ProductName, 
--	     CategoryID, 
--	     UnitPrice
--From Assignment06DB_CPrice.dbo.Products;

--Select ProductID, 
--       ProductName, 
--	     CategoryID,  
--	     UnitPrice, 
--From Assignment06DB_CPrice.dbo.Products;

Go
Create --Drop
View vProducts
WITH SCHEMABINDING
As
  Select ProductID, 
         ProductName,
	     CategoryID, 
	     UnitPrice
 From dbo.Products;
Go

Select * from vProducts

--Select * From Employees;

--Select EmployeeID,
--     EmployeeFirstName,
--	   EmployeeLastName, 
--	   ManagerID
--From Assignment06DB_CPrice.dbo.Employees;

Go
Create --Drop
View vEmployees
WITH SCHEMABINDING
As
Select EmployeeID,
       EmployeeFirstName,
	   EmployeeLastName, 
	   ManagerID
From dbo.Employees;
Go

Select * from vEmployees;

--Select * From Inventories;

--Select InventoryID,
--       InventoryDate,
--	   EmployeeID,
--	   ProductID,
--	   Count
--From Assignment06DB_CPrice.dbo.Inventories;

Go
Create --Drop
View vInventories
WITH SCHEMABINDING
As
Select InventoryID,
       InventoryDate,
	   EmployeeID,
	   ProductID,
	   Count
From dbo.Inventories;
Go

Select * from vInventories;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Select * from Categories;
--Select * from Products;

--Select CategoryName
--From Categories;

--Select ProductName, 
--       UnitPrice
--From Products;

--Select CategoryName,
--       ProductName, 
--       UnitPrice
--From dbo.Categories As c
--Join dbo.Products As p
-- On c.CategoryID = p.CategoryID
--Order By 1,2,3;

Go
Create --Drop
View vProductsByCategories
As
Select TOP 100000
       c.CategoryName,
       p.ProductName, 
       p.UnitPrice
From vCategoriesView As c
Inner Join vProductsView As p
 On c.CategoryID = p.CategoryID
Order By 1,2,3;
Go

Select * from vProductsByCategories;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Select * from Products;
--Select * from Inventories;

--Select ProductName
--From Products;

--Select InventoryDate,
--       Count
--From Inventories;

--Select ProductName,
--       InventoryDate,
--       Count
--From vProductsView As p
--Join vInventoriesView As i
-- On p.ProductID = i.ProductID
--Order By 2,1,3;

Go
Create --Drop
View vInventoriesByProductsByDates
As
Select TOP 100000
       p.ProductName,
       i.InventoryDate,
       i.Count
From vProductsView As p
Join vInventoriesView As i
 On p.ProductID = i.ProductID
Order By 2,1,3;
Go

Select * from vInventoriesByProductsByDates;

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--Select * from Inventories;
--Select * from Employees;

--Select Distinct InventoryDate
--From dbo.Inventories;

--Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
--From dbo.Employees;

--Select Distinct InventoryDate,
--       EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
--From dbo.Inventories As i
--Join dbo.Employees As e
-- On i.EmployeeID = e.EmployeeID
--Order By 1;

Go
Create --Drop
View vInventoriesByEmployeesByDates
As
Select Distinct TOP 100000
       i.InventoryDate,
       e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
From vInventoriesView As i
Join vEmployeesView As e
 On i.EmployeeID = e.EmployeeID
Order By 1,2;
Go

Select * from vInventoriesByEmployeesByDates;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Select * From Categories;
--Select * From Products;
--Select * From Inventories;

--Select CategoryName
--From Categories;

--Select ProductName 
--From Products;

--Select InventoryDate,
--       Count
--From Inventories;

--Select CategoryName,
--       ProductName,
--	   InventoryDate,
--       Count
--From dbo.Categories As c
--Join dbo.Products As p
-- On c.CategoryID = p.CategoryID
--Join dbo.Inventories As i
-- On p.ProductID = i.ProductID

--Select TOP 100000 CategoryName,
--       ProductName,
--	   InventoryDate,
--       Count
--From dbo.Categories As c
--Join dbo.Products As p
-- On c.CategoryID = p.CategoryID
--Join dbo.Inventories As i
-- On p.ProductID = i.ProductID
--Order By 1,2,3,4;

Go
Create --Drop
View vInventoriesByProductsByCategories
As
Select TOP 100000 
       c.CategoryName,
       p.ProductName,
	   i.InventoryDate,
       i.Count
From vCategoriesView As c
Join vProductsView As p
 On c.CategoryID = p.CategoryID
Join vInventoriesView As i
 On p.ProductID = i.ProductID
Order By 1,2,3,4;
Go

Select * from vInventoriesByProductsByCategories;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Select * From Inventories;
--Select * From Categories;
--Select * From Products;
--Select * From Employees;

--Select InventoryDate,
--       Count
--From Inventories;

--Select CategoryName
--From Categories;

--Select ProductName 
--From Products;

--Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
--From Employees;

--Select InventoryDate,
--       Count,
--	   CategoryName,
--	   ProductName,
--	   EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
--From Inventories As i
--Join Categories As c
-- On 

--Select Top 100000
--       c.CategoryName,
--	   p.ProductName,
--	   i.InventoryDate,
--	   i.Count,
--	   e.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
--From vInventoriesView As i
-- Inner Join vEmployeesView As e
-- On i.EmployeeID = e.EmployeeID
-- Inner Join vProductsView As p
-- On i.ProductID = p.ProductID
-- Inner Join vCategoriesView As c
-- On p.CategoryID = c.CategoryID
--Order By 3,1,2,4;

Go
Create View vInventoriesByProductsByEmployees
As
	Select Top 100000
		   c.CategoryName,
		   p.ProductName,
		   i.InventoryDate,
		   i.Count,
		   e.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	From vInventoriesView As i
	 Inner Join vEmployeesView As e
	 On i.EmployeeID = e.EmployeeID
	 Inner Join vProductsView As p
	 On i.ProductID = p.ProductID
	 Inner Join vCategoriesView As c
	 On p.CategoryID = c.CategoryID
	Order By 3,1,2,4;
Go

Select * from vInventoriesByProductsByEmployees;

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Select * From Categories;
--Select * From Products;
--Select * From Inventories;
--Select * From Employees;

--Select * 
--From Categories As c
--Join Products As p
--On c.CategoryID = p.ProductID

--Select * 
--From Categories As c
--Join Products As p
-- On cs.CategoryID = p.ProductID
--Join Inventories As i
-- On p.ProductID = i.ProductID

--Select * 
--From Categories As c
--Join Products As p
-- On c.CategoryID = p.ProductID
--Join Inventories As i
-- On p.ProductID = i.ProductID
--Join Employees As e
-- On i.EmployeeID = e.EmployeeID

--Select CategoryName, 
         --ProductName, 
		 --InventoryDate, 
		 --Count, 
		 --EmployeeFirstName, 
		 --EmployeeLastName
--From Categories As c
--Join Products As p
-- On c.CategoryID = p.ProductID
--Join Inventories As i
-- On p.ProductID = i.ProductID
--Join Employees As e
-- On i.EmployeeID = e.EmployeeID

--Select CategoryName, 
         --ProductName, 
		 --InventoryDate, 
		 --Count, 
		 --EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
--From Inventories AS i
--Join Employees AS e
-- On i.EmployeeID = e.EmployeeID
--Join Products AS p
-- On i.ProductID = p.ProductID
--Join Categories AS c
-- On p.CategoryID = c.CategoryID
--Where i.ProductID IN (Select ProductID From Products Where ProductName IN ('Chai','Chang'))

Go
Create --Drop
View vInventoriesForChaiAndChangByEmployees
As
	Select TOP 100000 
		   c.CategoryName, 
		   p.ProductName, 
		   i.InventoryDate, 
		   i.Count, 
		   e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
	From vInventoriesView AS i
	Join vEmployeesView AS e
	 On i.EmployeeID = e.EmployeeID
	Join vProductsView AS p
	 On i.ProductID = p.ProductID
	Join vCategoriesView AS c
	 On p.CategoryID = c.CategoryID
	Where i.ProductID IN (Select ProductID From vProductsView Where ProductName IN ('Chai','Chang'))
	Order By 3,1,2,4;
Go

Select * From vInventoriesForChaiAndChangByEmployees;

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Select * from Employees

--Select EmployeeFirstName, EmployeeLastName, ManagerID
--From Employees

--Select M.EmployeeFirstName + ' '+ M.EmployeeLastName AS Manager
--From Employees

--Select m.EmployeeFirstName + ' '+ m.EmployeeLastName AS Manager,
--e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
--From Employees AS e

--Select m.EmployeeFirstName + ' '+ m.EmployeeLastName AS Manager,
--e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
--From Employees AS e
--Join Employees AS m
--On e.ManagerID = m.ManagerID

--Select TOP 100000 m.EmployeeFirstName + ' '+ m.EmployeeLastName AS Manager,
--e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
--From Employees AS e
--Join Employees AS m
-- On e.ManagerID = m.ManagerID;

Go
Create --Drop
View vEmployeesByManagers
As
	Select TOP 100000 m.EmployeeFirstName + ' '+ m.EmployeeLastName AS Manager,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
	From vEmployeesView AS e
	Join vEmployeesView AS m
	 On e.ManagerID = m.ManagerID
	Order By 1,2;
Go

Select * From vEmployeesByManagers;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--Select * from vCategoriesView;
--Select * from vProductsView;
--Select * from vInventoriesView;
--Select * from vEmployeesView;

--Select Top 100000
--   c.CategoryID,
--   c.CategoryName,
--   p.ProductID,
--   p.ProductName,
--   p.UnitPrice,
--   i.InventoryID,
--   i.InventoryDate,
--   i.Count,
--   e.EmployeeID,
--   e.EmployeeFirstName + ' ' + e.EmployeeLastName As Employee,
--   m.EmployeeFirstName + ' ' + m.EmployeeLastName As Manager
--From vCategoriesView As c
--Join vProductsView As p
-- On p.CategoryID = c.CategoryID
--Join vInventoriesView As i
-- On p.ProductID = i.ProductID
--Join vEmployeesView As e
-- On i.EmployeeID = e.EmployeeID
--Join vEmployeesView As m
-- On e.ManagerID = m.EmployeeID
--Order By 1,3,6,9;

Go
Create View vInventoriesByProductsByCategoriesByEmployees
As
	Select Top 100000
	   c.CategoryID,
	   c.CategoryName,
	   p.ProductID,
	   p.ProductName,
	   p.UnitPrice,
	   i.InventoryID,
	   i.InventoryDate,
	   i.Count,
	   e.EmployeeID,
	   e.EmployeeFirstName + ' ' + e.EmployeeLastName As Employee,
	   m.EmployeeFirstName + ' ' + m.EmployeeLastName As Manager
	From vCategoriesView As c
	Join vProductsView As p
	 On p.CategoryID = c.CategoryID
	Join vInventoriesView As i
	 On p.ProductID = i.ProductID
	Join vEmployeesView As e
	 On i.EmployeeID = e.EmployeeID
	Join vEmployeesView As m
	 On e.ManagerID = m.EmployeeID
	Order By 1,3,6,9;
Go

Select * from vInventoriesByProductsByCategoriesByEmployees;

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/