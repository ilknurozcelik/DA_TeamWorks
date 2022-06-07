---- C-11 WEEKLY AGENDA-6 RD&SQL STUDENT

SELECT *
FROM sale.customer

---- 1. List all the cities in the Texas and the numbers of customers in each city.----

SELECT DISTINCT city
FROM sale.customer
WHERE [state] = 'TX'

/*all cities in Texas*/
SELECT city
FROM sale.customer
WHERE [state] = 'TX'

/* The numbers of customers in each city in Texas*/
SELECT city, COUNT(DISTINCT customer_id) as customer_number
FROM sale.customer
WHERE [state] = 'TX'
GROUP BY city


---- 2. List all the cities in the California which has more than 5 customer, by showing the cities which have more customers first.---

SELECT city, COUNT(DISTINCT customer_id) as customer_number
FROM sale.customer
WHERE state = 'CA'
GROUP BY city
HAVING COUNT(DISTINCT customer_id) > 5
ORDER BY customer_number DESC


---- 3. List the top 10 most expensive products----

SELECT TOP 10 *
FROM product.product
ORDER BY list_price DESC

---- 4. List store_id, product name and list price and the quantity of the products which are located in the store id 2 and the quantity is greater than 25----

SELECT ST.store_id, PR.product_name, PR.list_price, ST.quantity
FROM product.product AS PR
INNER JOIN product.stock AS ST
ON PR.product_id = ST.product_id
WHERE ST.store_id = 2 AND ST.quantity > 25
ORDER BY ST.quantity DESC

SELECT ST.store_id, PR.product_name, PR.list_price, ST.quantity
FROM product.product AS PR
LEFT JOIN product.stock AS ST
ON PR.product_id = ST.product_id
WHERE ST.store_id = 2 AND ST.quantity > 25
ORDER BY ST.quantity DESC

--LEFT JOIN
SELECT ST.*, PR.*
FROM product.product AS PR
LEFT JOIN product.stock AS ST
ON PR.product_id = ST.product_id

---- 5. Find the sales order of the customers who lives in Boulder order by order date----
SELECT *
FROM sale.customer

SELECT SC.customer_id, SO.order_id, SO.order_status, SO.order_date
FROM sale.customer AS SC
INNER JOIN sale.orders AS SO
ON SO.customer_id = SC.customer_id
WHERE SC.city = 'Boulder'
ORDER BY SO.order_date

SELECT *
FROM sale.orders AS SO
INNER JOIN sale.customer AS SC
ON SO.customer_id = SC.customer_id
WHERE SC.city = 'Boulder'
ORDER BY SO.order_date

---- 6. Get the sales by staffs and years using the AVG() aggregate function.
SELECT *
FROM sale.orders
WHERE order_status <>4

SELECT *
FROM sale.customer

SELECT *
FROM sale.order_item

SELECT *
FROM product.product


SELECT SO.staff_id, DATEPART(YEAR, SO.order_date) AS YEAR_, count(*) AS ROWNMBR
FROM sale.orders AS SO
GROUP BY SO.staff_id, DATEPART(YEAR, SO.order_date)
ORDER BY SO.staff_id, DATEPART(YEAR, SO.order_date)

-- staf_id ve order_date'e göre  gruplandýrýlmýþ
SELECT SO.staff_id, DATEPART(YEAR, SO.order_date) AS YEAR_, AVG((SOI.list_price * SOI.quantity)*(1-SOI.discount)) AS sales
FROM sale.orders AS SO
INNER JOIN sale.order_item AS SOI
ON SO.order_id = SOI.order_id
GROUP BY SO.staff_id, DATEPART(YEAR, SO.order_date)
ORDER BY SO.staff_id, DATEPART(YEAR, SO.order_date)


SELECT SO.staff_id, DATEPART(YEAR, SO.order_date) AS YEAR_, cast(avg(round(SOI.quantity*SOI.list_price*(1-SOI.discount),2))as numeric(20,2)) AS sales
FROM sale.orders AS SO
INNER JOIN sale.order_item AS SOI
ON SO.order_id = SOI.order_id
GROUP BY SO.staff_id, DATEPART(YEAR, SO.order_date)
ORDER BY SO.staff_id, DATEPART(YEAR, SO.order_date)


--shipped date'e göre

SELECT SO.staff_id, DATEPART(YEAR, SO.shipped_date) AS YEAR_, AVG((SOI.list_price * SOI.quantity)*(1-SOI.discount)) AS sales
FROM sale.orders AS SO
INNER JOIN sale.order_item AS SOI
ON SO.order_id = SOI.order_id
GROUP BY SO.staff_id, DATEPART(YEAR, SO.shipped_date)
ORDER BY SO.staff_id, DATEPART(YEAR, SO.shipped_date)

--staf_id ve model_year'a göre gruplandýrýlmýþ
SELECT SO.staff_id, PP.model_year, AVG((SOI.list_price * SOI.quantity)*SOI.discount) AS sales
FROM product.product AS PP
INNER JOIN sale.order_item AS SOI
ON PP.product_id = SOI.product_id
INNER JOIN sale.orders AS SO
ON SO.order_id = SOI.order_id
GROUP BY SO.staff_id, PP.model_year
ORDER BY SO.staff_id, PP.model_year


---- 7. What is the sales quantity of product according to the brands and sort them highest-lowest----

SELECT PB.brand_name, PP.product_name, SUM(SOI.quantity) SALES_QUANTITY
FROM product.brand AS PB
INNER JOIN product.product AS PP
ON PB.brand_id = PP.brand_id
INNER JOIN sale.order_item AS SOI
ON PP.product_id = SOI.product_id
GROUP BY PB.brand_name, PP.product_name 
ORDER BY PB.brand_name, SUM(SOI.quantity) DESC

-- SOLUTION
SELECT PB.brand_name, SUM(SOI.quantity) SALES_QUANTITY
FROM product.brand AS PB
INNER JOIN product.product AS PP
ON PB.brand_id = PP.brand_id
INNER JOIN sale.order_item AS SOI
ON PP.product_id = SOI.product_id
GROUP BY PB.brand_name
ORDER BY SUM(SOI.quantity) DESC


---- 8. What are the categories that each brand has?----

SELECT DISTINCT PB.brand_name, PC.category_name
FROM product.product AS PP
JOIN product.brand AS PB
ON PP.brand_id=PB.brand_id
JOIN product.category AS PC
ON PP.category_id = PC.category_id
ORDER BY PB.brand_name


---- 9. Select the avg prices according to brands and categories----

SELECT PB.brand_name, PC.category_name, CAST(AVG(PP.list_price) AS numeric(7,2)) AS AVG_PRICE
FROM product.product AS PP
JOIN product.brand AS PB
ON PP.brand_id=PB.brand_id
JOIN product.category AS PC
ON PP.category_id = PC.category_id
GROUP BY PB.brand_name, PC.category_name
ORDER BY PB.brand_name



SELECT PB.brand_name, PC.category_name, PP.list_price
FROM product.product AS PP
JOIN product.brand AS PB
ON PP.brand_id=PB.brand_id
JOIN product.category AS PC
ON PP.category_id = PC.category_id
ORDER BY PB.brand_name

---- 10. Select the annual amount of product produced according to brands----

SELECT PB.brand_name, PP.model_year, COUNT(PP.product_id)AS PRODUCT_AMOUNT
FROM product.product AS PP
JOIN product.brand AS PB
ON PP.brand_id = PB.brand_id
GROUP BY PB.brand_name, PP.model_year 
ORDER BY PB.brand_name, PP.model_year


---- 11. Select the store which has the most sales quantity in 2016.----

SELECT TOP 1 ST.store_name, YEAR(SO.order_date) AS YEAR_, SUM(SOI.quantity) AS TOTAL_QUANTITY
FROM sale.order_item AS SOI
JOIN sale.orders AS SO
ON SOI.order_id = SO.order_id
JOIN sale.store AS ST
ON SO.store_id = ST.store_id
WHERE YEAR(SO.order_date) = '2018'
GROUP BY ST.store_name, YEAR(SO.order_date)
ORDER BY SUM(SOI.quantity) DESC



---- 12 Select the store which has the most sales amount in 2018.----
SELECT TOP 1 ST.store_name, YEAR(SO.order_date) AS YEAR_, CAST(SUM(SOI.quantity*SOI.list_price*(1-SOI.discount)) AS NUMERIC(10,2)) AS TOTAL_SALES
FROM sale.order_item AS SOI
JOIN sale.orders AS SO
ON SOI.order_id = SO.order_id
JOIN sale.store AS ST
ON SO.store_id = ST.store_id
WHERE YEAR(SO.order_date) = '2018'
GROUP BY ST.store_name, YEAR(SO.order_date)
ORDER BY TOTAL_SALES DESC


---- 13. Select the personnel which has the most sales amount in 2019.----

SELECT TOP 1 SO.staff_id, SS.first_name, SS.last_name, DATEPART(YEAR, SO.order_date) AS YEAR_, SUM((SOI.list_price * SOI.quantity)*(1-SOI.discount)) AS TOTAL_SALES
FROM sale.orders AS SO
INNER JOIN sale.order_item AS SOI
ON SO.order_id = SOI.order_id
INNER JOIN sale.staff AS SS
ON SS.staff_id = SO.staff_id
WHERE YEAR(SO.order_date) = '2019'
GROUP BY SO.staff_id, SS.first_name, SS.last_name, DATEPART(YEAR, SO.order_date)
ORDER BY TOTAL_SALES DESC