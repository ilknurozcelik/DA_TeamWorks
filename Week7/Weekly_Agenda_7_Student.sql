---- RDB&SQL Exercise-2 Student

----1. By using view get the average sales by staffs and years using the AVG() aggregate function.

select top 10 * from sale.staff

CREATE VIEW SALE_STAFF_YEAR AS
SELECT SS.staff_id, YEAR(SO.order_date) YEAR_, (SOI.list_price*SOI.quantity*(1-SOI.discount)) SALE_ORDER
FROM sale.staff AS SS, sale.orders AS SO, sale.order_item AS SOI
WHERE SS.staff_id = SO.staff_id AND SO.order_id = SOI.order_id;

SELECT staff_id, YEAR_, CAST(AVG(SALE_ORDER) AS numeric (10, 2))
FROM SALE_STAFF_YEAR
GROUP BY staff_id, YEAR_
ORDER BY staff_id, YEAR_

----2. Select the annual amount of product produced according to brands (use window functions).

-- GROUP BY �LE
SELECT PB.brand_name, PP.model_year, COUNT(*) ANNUAL_AMOUNT
FROM product.product AS PP, product.brand AS PB
WHERE PP.brand_id=PB.brand_id
GROUP BY PB.brand_name, PP.model_year
ORDER BY 1

SELECT PB.brand_name, PP.model_year, sum(PS.quantity) ANNUAL_AMOUNT
FROM product.product AS PP, product.brand AS PB, product.stock AS PS 
WHERE PP.brand_id=PB.brand_id AND PS.product_id=PP.product_id
GROUP BY PB.brand_name, PP.model_year
ORDER BY 1

SELECT PB.brand_name, PP.model_year, sum(SOI.quantity) ANNUAL_AMOUNT
FROM product.product AS PP, product.brand AS PB, sale.order_item AS SOI 
WHERE PP.brand_id=PB.brand_id AND SOI.product_id=PP.product_id
GROUP BY PB.brand_name, PP.model_year
ORDER BY 1

select distinct b.brand_name, p.model_year,

-- WINDOW FUNCTION �LE
SELECT DISTINCT PB.brand_name, PP.model_year, COUNT(*) OVER(PARTITION BY PB.brand_name, PP.model_year) AS ANNUAL_AMOUNT
FROM product.product AS PP, product.brand AS PB
WHERE PP.brand_id=PB.brand_id
ORDER BY 1


--- sarah hoca'n�n ��z�m�:


SELECT brand_name, model_year, SUM(S.quantity) AS TotalAmountPerYear



----3. Select the least 3 products in stock according to stores.

--stokta bulunan (quantity != 0 olan) �r�nlerin ma�aza ve �r�n _id'ye g�re grupland�r�lmas�

SELECT  store_id, product_id, quantity
FROM product.stock
WHERE quantity != 0
GROUP BY store_id, product_id, quantity
ORDER BY store_id, quantity


-- ma�aza baz�nda min ve max �r�n miktarlar�n�n bulunmas�
SELECT store_id, MIN(quantity), MAX(quantity)
FROM product.stock
WHERE quantity != 0
GROUP BY store_id
ORDER BY store_id

-- ��Z�M:
with cte_least3product AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY store_id order by store_id, quantity) as "row_number"
FROM product.stock
WHERE quantity != 0
)
SELECT *
FROM cte_least3product
WHERE row_number <=3

--PRODUCT NAME GET�REREK.
with cte_least3product AS(
SELECT PS.store_id, PS.product_id, PS.quantity, PP.product_name,
	ROW_NUMBER() OVER(PARTITION BY PS.store_id order by PS.quantity, pp.product_id) as "row_number"
FROM product.stock AS PS, product.product AS PP
WHERE quantity != 0 AND
	PS.product_id = PP.product_id
)
SELECT *
FROM cte_least3product
WHERE row_number <=3


--SARAH HOCA'NIN ��Z�M�

SELECT store_id, product_name, TotalQuantity

----4. Return the average number of sales orders in 2020 sales NEYE G�RE BELL� DE��L?

SELECT order_id
FROM sale.orders
WHERE YEAR(order_date) = 2020

SELECT 1.0 * count(order_id)/365
FROM sale.orders
WHERE YEAR(order_date) = 2020

--HOCA ��Z�M�:

select s.[store_name], sum(i.[quantity])


----5. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.

SELECT *
FROM (
	SELECT DISTINCT PB.brand_id, PP.list_price,
			RANK() OVER (PARTITION BY PB.brand_id ORDER BY PP.list_price) price_rank
	FROM product.product AS PP, product.brand AS PB
	WHERE PP.brand_id=PB.brand_id
	) AS A
WHERE price_rank <= 3;

-- HOCA ��Z�M�:
--DENSE_RANK WINDOW FUNCTION �LE
SELECT * 

--RANK W�NDOW FUNCTION �LE
SELECT * 



/*
1. What is a Window Function in SQL?

In SQL, window functions operate on a set of rows called a window frame.
They return a single value for each row from the underlying query.
*/



/*
2. Describe the Difference Between Window Functions and Aggregate Functions?

-- Both window functions and aggregate functions:

Operate on a set of values (rows).
Can calculate aggregate amounts (e.g. AVG(), SUM(), MAX(), MIN(), or COUNT()) on the set.
Can group or partition data on one or more columns.

-- Aggregate functions with GROUP BY differ from window functions in that they:

Use GROUP BY() to define a set of rows for aggregation.
Group rows based on column values.
Collapse rows based on the defined groups.
*/


/*
3. What�s the difference between Window Functions and the GROUP BY Clause?

--Window functions differ from aggregate functions used with GROUP BY in that they:

Use OVER() instead of GROUP BY() to define a set of rows.
May use many functions other than aggregates (e.g. RANK(), LAG(), or LEAD()).
Groups rows on the row�s rank, percentile, etc. as well as its column value.
Do not collapse rows.
May use a sliding window frame (which depends on the current row).
*/


/* 
4. Explain what UNBOUNDED PRECEDING does? 

--UNBOUNDED PRECEDING indicates that the window starts at the first row of the partition;

--offset PRECEDING indicates that the window starts a number of rows equivalent to the value
of offset before the current row. UNBOUNDED PRECEDING is the default.

--CURRENT ROW indicates the window begins or ends at the current row.

--UNBOUNDED FOLLOWING indicates that the window ends at the last row of the partition;
offset FOLLOWING indicates that the window ends a number of rows equivalent to the value
of offset after the current row.
*/