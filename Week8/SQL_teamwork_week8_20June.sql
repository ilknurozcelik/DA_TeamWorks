/* week 8 - teamwork*/

/* Report cumulative total turnover by months in each year in pivot table format. */


select*
from(
	select distinct year(so.order_date) ord_year, month(so.order_date) ord_month,
		sum(soý.list_price*soý.quantity) over (partition by year(so.order_date) order by month(so.order_date))cum_total_turnover
	from sale.order_item as soý, sale.orders as so
	where soý.order_id=so.order_id
) main_table
pivot
(
	sum(cum_total_turnover)
	for ord_year in ([2018], [2019], [2020]))as pivot_table;

select *
from(
	select distinct year(so.order_date)ord_year, month(so.order_date)ord_month,
		sum(list_price*quantity) over (partition by year(so.order_date) order by month(so.order_date) )cum_total_turnover
	from sale.order_item as soý, sale.orders as so
	where soý.order_id=so.order_id
) t
pivot(
	sum(cum_total_turnover)
	for ord_year in ([2018],[2019],[2020])
) as pivot_table;



/* What percentage of customers purchasing a product have purchased the same product again?
 */

 select soý.product_id, so.customer_id, so.order_id,
	count(*) over(partition by soý.product_id, so.customer_id, so.order_id)
 from sale.order_item as soý, sale.orders as so
 where soý.order_id=so.order_id

 select A.product_id, customer_id, count(A.customer_id)count_cust
 from(
 select soý.product_id, so.customer_id, so.order_id,
	count(*) over(partition by soý.product_id, so.customer_id, so.order_id)count_
 from sale.order_item as soý, sale.orders as so
 where soý.order_id=so.order_id) A
 group by product_id, customer_id
 having count(A.customer_id)>=2
 order by 1

 --en az bir ürün almýþ müþteriler

 select customer_id, count(A.customer_id)count_cust
 from(
 select soý.product_id, so.customer_id, so.order_id,
	count(*) over(partition by soý.product_id, so.customer_id, so.order_id)count_
 from sale.order_item as soý, sale.orders as so
 where soý.order_id=so.order_id) A
 group by customer_id
 having count(A.customer_id)=1
 order by 1


select count(distinct customer_id)
from sale.order_item as soý, sale.orders as so
where soý.order_id=so.order_id


-- SERDAR HOCA'NIN KODU

select distinct B.product_id,FIRST_VALUE(rate) over(partition by B.product_id order by rate desc) rate
from (
select distinct A.product_id,cast(IIF(count_cust=1,0,count_cust)*1.0/total_ord as decimal(10,2)) rate
from	(
select distinct product_id,customer_id
		,count(customer_id) over(partition by product_id,customer_id) count_cust
		,count(so.order_id) over(partition by  product_id) total_ord
from	sale.order_item soi,[sale].[orders] so
		where soi.order_id=so.order_id
		)A
) B

--MATRIX HOCA'NIN KODU
create view v1 as 
select  so.customer_id,soi.product_id, count(so.order_id) morethan1
from sale.orders so, sale.order_item soi
where soi.order_id = so.order_id
group by so.customer_id,soi.product_id
having count(so.order_id) > 1

create view v2 as 
select  soi.product_id, count(so.customer_id) total_customer_for_product
from sale.orders so, sale.order_item soi
where soi.order_id = so.order_id
group by soi.product_id


with tbl as(
select distinct v2.product_id,total_customer_for_product, morethan1
from v2
left join v1
on v2.product_id = v1.product_id
)
select product_id,cast(1.0*isnull(morethan1,0)/total_customer_for_product as numeric(5,2))
from tbl;


with tbl as(
select distinct v2.product_id,total_customer_for_product, morethan1
from v2
left join v1
on v2.product_id = v1.product_id
)
select product_id, cast(1.0*(case when morethan1 is null then 0 else morethan1 end) /total_customer_for_product   as numeric(5,2)) as rate
from tbl;

/*From the following table of user IDs, actions, and dates, write a query to return the publication
and cancellation rate for each user. */


CREATE TABLE Actions.Actions2 (
			[User_ID] TINYINT NOT NULL,
			[Action] VARCHAR(10),
			[Date] DATE);


INSERT INTO Actions.Actions2
VALUES 
	(1, 'START', '01-01-2022'),
	(1, 'CANCEL', '01-02-2022'),
	(2, 'START', '01-03-2022'),
	(2, 'PUBLISH', '01-04-2022'),
	(3, 'START', '01-05-2022'),
	(3, 'CANCEL', '01-06-2022'),
	(1, 'START', '01-07-2022'),
	(1, 'PUBLISH', '01-08-2022');

select *
from Actions.Actions2;

with tbl1 as(
	select distinct User_ID, Action,
		count([Action]) over (partition by [User_ID], [Action])count_actions
	from Actions.Actions2
	where Action='Start'
),
tbl2 as(
	select *,
		count([Action]) over (partition by [User_ID], [Action])count_actions
	from Actions.Actions2
	where Action!='Start'
)
select *
from tbl1,tbl2
where tbl1.User_ID=tbl2.User_ID



select distinct User_ID, Action,
		count([Action]) over (partition by [User_ID], [Action])count_actions
from Actions.Actions2


SELECT 
   User_ID,
   SUM(CASE WHEN action = 'START' THEN 1 ELSE 0 END) AS starts, 
   SUM(CASE WHEN action = 'CANCEL' THEN 1 ELSE 0 END) AS cancels, 
   SUM(CASE WHEN action = 'PUBLISH' THEN 1 ELSE 0 END) AS publishes
FROM Actions.Actions2
GROUP BY User_ID
ORDER BY 1;


with tbl as(
	SELECT * FROM (
		SELECT *
		FROM Actions.Actions2) main_tbl
	PIVOT (
		COUNT([Date])
		for [Action] in ([START],[PUBLISH],[CANCEL]))as pivot_table
)
select User_ID,
	CAST(1.0*PUBLISH/START as DECIMAL (3,2)) Publish_Rate,
	CAST(1.0*CANCEL/START AS DECIMAL (3,2)) Cancel_Rate
from tbl;




with tbl as(
	SELECT 
	   User_ID,
	   SUM(CASE WHEN action = 'START' THEN 1 ELSE 0 END) AS START, 
	   SUM(CASE WHEN action = 'CANCEL' THEN 1 ELSE 0 END) AS CANCEL, 
	   SUM(CASE WHEN action = 'PUBLISH' THEN 1 ELSE 0 END) AS PUBLISH
	FROM Actions.Actions2
	GROUP BY User_ID
	
)
select User_ID,
	CAST(1.0*PUBLISH/START as DECIMAL (3,2)) Publish_Rate,
	CAST(1.0*CANCEL/START AS DECIMAL (3,2)) Cancel_Rate
from tbl;


select  A.User_ID
		, cast(sum(publish)*2.0/count(*)  as decimal(10,2)) Publish_rate
		, cast(sum(cancel)*2.0/count(*) as decimal(10,2)) cancel_rate
from
(
select *, IIF(action='PUBLISH',1,0) publish
	, IIF(action='CANCEL',1,0) cancel
	, IIF(action='START',1,0) start
from Actions.Actions2
)A
group by A.User_ID

/* sonra bakýlacak */

select User_ID, IIF(action='PUBLISH',1,0) publish
	, IIF(action='CANCEL',1,0) cancel
	, IIF(action='START',1,0) start
from Actions.Actions2
group by User_ID
