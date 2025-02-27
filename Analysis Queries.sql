-- now for analysis i will use these tables

select * from customer_profiles1;
select * from product_inventory;
select * from sales_trans2;

/** 1st PPV(product performance variablity) :- identifying which product performing 
well in terms of sales and which are not .this insight is crucial for inventory
management and marketing focus
**/
select s.productid,p.productname,sum(s.quantitypurchased*s.price) as totalsales,sum(s.quantitypurchased) as totalquantity 
from sales_trans2 as s
join product_inventory as p on s.productid=p.ProductID
group by s.ProductID,p.ProductName
order by totalsales desc;

### product_17,87,179,96,54 these are top 5 product

/**
customer segmentation : the company lacks a clear understanding of its customer based segmentation.
Effective segmentation is essential for targated marketing and enhancing customer satisfaction
**/

-- customer purchase frequency with cid,count of trnasactions

select * from customer_profiles1;
select * from product_inventory;
select* from sales_trans2;

## top 5 customer with the highest purchase

select customerid,count(*) as total_transaction from sales_trans2
group by CustomerID
order by total_transaction desc;

-- product category performance on the basis of total sales

select * from product_inventory;
select * from sales_trans2;

select p.category,sum(s.quantitypurchased) as totalunitsold,sum(s.quantitypurchased*s.price) as totalsales from product_inventory as p
join sales_trans2 as s on p.productid=s.productid
group by p.category
order by totalsales desc;

-- as see in above query output home & kitchen ,electronics is top two category

-- top 10 high sales product and top 10 low ssales product

select productid,sum(quantitypurchased*price) as totalrevenue from sales_trans2
group by productid
order by totalrevenue desc
limit 10;

select productid,sum(quantitypurchased*price) as totalrevenue from sales_trans2
group by productid
order by totalrevenue asc
limit 10;

-- to identify sales trend - revenue pattern of the organisation starting from the earliest date  till the last date of the table

select * from customer_profiles1;
select * from sales_trans2;

select TransactionID,newtransdate,count(*) as count_of_trans,sum(quantitypurchased) as totalquantity,sum(quantitypurchased*price) as totalsales from sales_trans2
group by TransactionID,newtransdate
order by newtransdate asc;

--  write a query to find current mont ,total sale of current month,total sale of previous mont,mom growth percentage

select * from sales_trans2;

with totalsales as(select date_format(newtransdate,'%M') as months,sum(quantitypurchased*price) as totalsales from sales_trans2
group by months
),
previoussales as(
select months,totalsales,lag(totalsales,1,null) over()as previous_sale from totalsales
)
select months ,totalsales,previous_sale,(totalsales-previous_sale)/previous_sale*100 as gp from previoussales;

-- high purchase frequency, customerid,no of transations,totalspent 

select * from customer_profiles1;
select * from sales_trans2;

select customerid,count(*) as no_of_transaction,sum(quantitypurchased*price) as totalspent from sales_trans2
group by customerid
order by totalspent desc;

-- occational customers

select * from sales_trans2;

select customerid,count(TransactionID) as count_of_trans,sum(quantitypurchased*price) as total_amount_spent from sales_trans2
group by CustomerID
having count_of_trans <=2
order by count_of_trans,total_amount_spent desc;

-- repeat purchases

select * from product_inventory;
select * from sales_trans2;

select customerid,productid,count(*) as no_of_purchased from sales_trans2
group by customerid,productid
having count(*)>1
order by no_of_purchased desc;

-- loyality indicators

select * from sales_trans2;

select customerid,min(newtransdate) as first_transaction_date,max(newtransdate) as last_transaction_date,
datediff(max(newtransdate),min(newtransdate)) as daysbetweenpurchases from sales_trans2
group by customerid
order by daysbetweenpurchases desc;

-- customer segmantation

select * from sales_trans2;

create table cust_seg as 
select customerid,case
    when totalquantity>30 then 'High'
    when totalquantity between 10 and 30 then 'Mid'
    when totalquantity between 1 and 10 then 'Low'
    else 'none'
    end as cust_segment
    from (select c.customerid,sum(s.quantitypurchased) as totalquantity from customer_profiles1 as c
    join sales_trans2 as s on c.customerid=s.customerid
    group by c.CustomerID
    ) as derivedtable;
     
select * from cust_seg;

select cust_segment,count(*) no_of_segement from cust_seg
group by cust_segment;