create schema retail_case_study;
use retail_case_study;

show tables;

select * from customer_profiles;
select * from product_inventory;
select * from sales_transaction;

/**
1. remove duplicate
2. fixing incorrect values
3 . null values
4. cleaning date
**/

/** DATA CLEANING PROCESS **/

-- REMOVE DUPLICATES

select transactionid,count(*) from sales_transaction
group by TransactionID
having count(*)>1;

## there is two duplicate transactionid 4999,5000
## no need two remove this using duplicate function

create table sales_trans1_noduplicate as
select distinct * from sales_transaction;

select transactionid,count(*) from sales_trans1_noduplicate
group by TransactionID
having count(*)>1;

## now wee use sales_trans1_noduplicate table for analysis. duplicate values has removed now

select * from sales_trans1_noduplicate;

-- fixing incorrect values

select * from sales_trans1_noduplicate;
select * from customer_profiles;
select * from product_inventory;

## so there is two table which has price column so may be there some prices differrent in both the table so we have to check that in both the table price is same or not.

select * from sales_trans1_noduplicate;
select * from product_inventory;

## check in both the table prices column has the same price or not so fo this i will use join function

select p.productid,s.transactionid,s.price as trans_price,p.price as product_price from sales_trans1_noduplicate as s
join product_inventory as p on s.ProductID=p.ProductID
where s.Price<>p.price;

### productid 51 has different-different transactionid with different price from product_price alter
### so product id price id 93.12 and in transaction price it showing 9312 so we have to chnage 9312 with 93.12
## so for this i will be used update 

set sql_safe_updates=0;

update sales_trans1_noduplicate as s
set price=(select p.price from product_inventory as p where p.ProductID=s.ProductID)
where s.productid in (select p.productid from product_inventory as p where p.price <> s.price);

# now all the transaction price same as product price

select price from sales_trans1_noduplicate where ProductID=51;

select p.productid,s.transactionid,s.price as trans_price,p.price as product_price from sales_trans1_noduplicate as s
join product_inventory as p on s.ProductID=p.ProductID
where s.Price<>p.price;

-- fixing null values

## firstly identify which table has null  values

select * from customer_profiles;
select * from product_inventory;
select * from sales_trans1_noduplicate;

## customer_profiles has empty rows in location coloumn

select count(*) as emplty_rows from customer_profiles
where location='';

## 13 rows are empty in location coloumn
set sql_safe_updates =0;

update customer_profiles
set location='unknown'
where location='';

## chnage all empty rows replace with unknown

select * from customer_profiles;

-- cleaning part (cleaning date)

select * from customer_profiles;
select * from product_inventory;
select * from sales_trans1_noduplicate;

desc customer_profiles;
desc sales_trans1_noduplicate;

## both table has date in text datatype

create table customer_profiles1 as (
select *, str_to_date(joindate,'%d-%m-%Y') as joindate_update from customer_profiles);

desc customer_profiles1;

## for customer table  i have created new table with updation of date in date datatype so now i will use new table for analysis

alter table customer_profiles1
drop column joindate;

select * from customer_profiles1;
desc customer_profiles1;  ## now we use customer_profiles1 for analysis 

## now chnage data type in sales_trnas1_nodup table

select * from sales_trans1_noduplicate;

create table sales_trans2 as(
select *, str_to_date(transactiondate,'%d-%m-%Y') as newtransdate from sales_trans1_noduplicate);

alter table sales_trans2
drop column TransactionDate;

select * from sales_trans2;
desc sales_trans2; ## now date is in date data type and now i use sales_trans2 for analysis

## write the sql query to summerize the total sales and total quantity sold per product by the company

select * from customer_profiles1;
select * from product_inventory;
select * from sales_trans2;

select productid,sum(quantitypurchased*price),sum(quantitypurchased) from sales_trans2
group by ProductID
order by ProductID;

