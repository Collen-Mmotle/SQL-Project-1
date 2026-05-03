-- Databricks notebook source
-- MAGIC %md
-- MAGIC

-- COMMAND ----------

-- DBTITLE 1,Section 3 - Strategic Recommendation

1. To improve underperforming products, use focused marketing

Despite having low revenue, the products in the bottom five have profit margins of 33-36%, indicating that they are not losing money.

Recommendation
Instead of stopping them, increase visibility through targeted advertising and promotions, particularly for higher-rated items.

2. Cut back on steep discounts to safeguard profit

The profit margin for orders with a 0% discount is higher (39.98%) than that of orders with a significant discount (31.53%).

Recommendation:
To preserve profitability, restrict deep discounts (>30%) and concentrate on managed discount tactics.

3. Prioritize client pleasure to boost recurring business.

More repeat orders are placed by highly satisfied customers (ratings 4-5) (1.79 vs. 1.36).
Suggestion:
To boost retention and repeat business, enhance the client experience (service, quality, and delivery).

-- COMMAND ----------

-- DBTITLE 1,Section 2 - Top 3 Insights
--Insight #1
--Customers spend a lot per purchase, with an average order value of 6,751.33, indicating strong transaction value.

SELECT 
ROUND((SUM(TotalSales) / NULLIF(COUNT(DISTINCT OrderID), 0)),2) AS Average_Order_Value
FROM Sales
WHERE YEAR(OrderDate) IN (2023, 2024);

--Insight #2 
--The business has 2,500 orders from 497 customers, showing a solid customer base and repeat purchasing activity

SELECT 
COUNT(DISTINCT OrderID) AS Total_Orders,
COUNT(DISTINCT CustomerID) AS Total_Customers
FROM Sales
WHERE YEAR(OrderDate) IN (2023, 2024);

--Insight #3
-- The business is highly profitable with a 35.05% profit margin, showing efficient cost and pricing management.

SELECT 
ROUND((SUM(Profit) * 100.0 / NULLIF(SUM(TotalSales), 0)),
2) AS Overall_Profit_Margin
FROM Sales
WHERE YEAR(OrderDate) IN (2023, 2024);

-- COMMAND ----------

-- DBTITLE 1,Section 1
WITH BaseData AS (
SELECT 
TotalSales,Profit,OrderID,CustomerID
from sales
WHERE YEAR(OrderDate) IN (2023, 2024)
)
SELECT 
round (SUM(TotalSales),2) AS Total_Revenue,
Round (SUM(Profit),2) AS Total_Profit,
ROUND((SUM(Profit) * 100.0 / NULLIF(SUM(TotalSales), 2)),2
) AS Overall_Profit_Margin,

COUNT(DISTINCT OrderID) AS Total_Orders,
COUNT(DISTINCT CustomerID) AS Total_Customers,

ROUND(
(SUM(TotalSales) / NULLIF(COUNT(DISTINCT OrderID), 2)), 2
) AS Average_Order_Value

FROM BaseData;

--

-- COMMAND ----------

-- DBTITLE 1,Question 4.3
SELECT 
p.ProductName,
round (SUM(s.TotalSales),2) AS Total_Revenue,
SUM(s.Quantity) AS Sales_Volume,
ROUND(SUM(s.Profit) * 100.0 / NULLIF(SUM(s.TotalSales), 0), 2) AS Profit_Margin,
ROUND(AVG(f.Rating), 2) AS Avg_Rating
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
LEFT JOIN customer_feedback f ON s.OrderID = f.OrderID
GROUP BY p.ProductName
ORDER BY Total_Revenue ASC
LIMIT 5;

--Recommendation
--These products have low sales but remain profitable with average customer ratings. They should not be discontinued; instead, the focus should be on improving demand through marketing and promotions, especially for higher-rated items with better growth potential.

-- COMMAND ----------

-- DBTITLE 1,Question 4.2
SELECT 
CASE 
WHEN DiscountPercent = 0 THEN '0%'
WHEN DiscountPercent > 0 AND DiscountPercent <= 0.10 THEN '1-10%'
WHEN DiscountPercent > 0.10 AND DiscountPercent <= 0.20 THEN '11-20%'
WHEN DiscountPercent > 0.20 AND DiscountPercent <= 0.30 THEN '21-30%'
ELSE 'Above 30%'
END AS Discount_Band, round (SUM(TotalSales),2) AS Total_Sales,
round(SUM(Profit),2) AS Total_Profit,
ROUND((SUM(Profit) * 100.0 / NULLIF(SUM(TotalSales), 0)), 2) AS Profit_Margin_Percentage

FROM Sales
GROUP BY 
CASE 
WHEN DiscountPercent = 0 THEN '0%'
WHEN DiscountPercent > 0 AND DiscountPercent <= 0.10 THEN '1-10%'
WHEN DiscountPercent > 0.10 AND DiscountPercent <= 0.20 THEN '11-20%'
WHEN DiscountPercent > 0.20 AND DiscountPercent <= 0.30 THEN '21-30%'
ELSE 'Above 30%'
END
ORDER BY Discount_Band;

-- Business insights:
-- Orders with no discount (0%) generate higher profit margins (39.98%) compared to orders with very high discounts (above 30%) at 31.53%. This shows that bigger discounts reduce profitability. The business should be careful with heavy discounting as it lowers profit.

-- COMMAND ----------

-- DBTITLE 1,Question 4.1
WITH CustomerOrders AS 
( SELECT  f.CustomerID,
CASE  WHEN f.Rating >= 4 THEN 'High Satisfaction (4-5)'
ELSE 'Low Satisfaction (1-3)'
END AS Satisfaction_Group, 
COUNT(DISTINCT f.OrderID) AS Orders_Per_Customer
FROM customer_feedback f
GROUP BY f.CustomerID,
CASE
WHEN f.Rating >= 4 THEN 'High Satisfaction (4-5)'
ELSE 'Low Satisfaction (1-3)'
END
)

SELECT 
Satisfaction_Group, round(AVG(Orders_Per_Customer),2) AS Avg_Orders_Per_Customer,
COUNT(DISTINCT CustomerID) AS Total_Customers
FROM CustomerOrders
GROUP BY Satisfaction_Group;

-- Business insights:
-- Customers who are more satisfied (ratings 4–5) tend to buy again more often than less satisfied ones. This shows that happy customers are more likely to come back. So, improving customer satisfaction can help increase repeat sales.

-- COMMAND ----------

-- DBTITLE 1,Question 3.5
SELECT 
c.Region,
round (SUM(s.TotalSales),2) AS TotalSales,
COUNT(s.OrderID) AS TotalOrders,
RANK() OVER (ORDER BY SUM(s.TotalSales) DESC) AS Rank
FROM Customers c
JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.Region
ORDER BY Rank;

-- COMMAND ----------

-- DBTITLE 1,Question  3.4
WITH AnnualSales AS (SELECT 
YEAR(OrderDate) AS Year,  round (SUM(TotalSales),2) AS TotalSales
FROM Sales 
WHERE YEAR(OrderDate) IN (2023,2024) 
GROUP BY YEAR(OrderDate))
SELECT  MAX(CASE WHEN Year = 2023 THEN TotalSales END) AS Sales_2023,
MAX(CASE WHEN Year = 2024 THEN TotalSales END) AS Sales_2024,
ROUND(((MAX(CASE WHEN Year = 2024 THEN TotalSales END)-MAX(CASE WHEN Year = 2023 THEN TotalSales END) ) / MAX(CASE WHEN Year = 2023 THEN TotalSales END) ) * 100, 2) AS GrowthPercentage
FROM AnnualSales;

-- COMMAND ----------

-- DBTITLE 1,Question 3.3
SELECT p.ProductName,p.Category, round (SUM(s.TotalSales),2) AS TotalSales,
round(SUM(s.Profit),2) AS TotalProfit,
round (((SUM(s.Profit)) / (SUM(s.TotalSales)) * 100),2) AS ProfitMarginPercent
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category
ORDER BY ProfitMarginPercent DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC

-- COMMAND ----------

-- DBTITLE 1,Question 3.2
WITH CustomerStatistics AS (SELECT c.CustomerID,CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, c.Region, c.Channel,    
round (SUM(s.TotalSales),2) AS TotalPurchases, 
COUNT(s.OrderID) AS NumberOfOrders,
ROUND(AVG(s.TotalSales), 2) AS AverageOrderValue FROM Customers c 
JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY  c.CustomerID, c.FirstName,c.LastName,
c.Region,c.Channel
)
SELECT *
FROM CustomerStatistics
WHERE NumberOfOrders > 3
ORDER BY TotalPurchases DESC;

-- COMMAND ----------

-- DBTITLE 1,Question 3.1

WITH ProductRevenue AS (
SELECT p.Category,p.ProductName, ROUND(SUM(s.TotalSales), 2) AS TotalRevenue,
ROW_NUMBER() OVER (PARTITION BY p.Category
ORDER BY (SUM(s.TotalSales), 2) DESC) AS rn
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Category, p.ProductName
)
SELECT Category, ProductName, TotalRevenue
FROM ProductRevenue
WHERE rn = 1;

-- COMMAND ----------

-- DBTITLE 1,Question 2.5
SELECT ProductCategory,
ROUND(AVG(Rating), 2) AS AverageRating,
COUNT(*) AS NumberOfReviews
FROM customer_feedback
GROUP BY ProductCategory
HAVING COUNT(*) >= 50;


-- Side Note- I have rounded of the average rating.

-- COMMAND ----------

-- DBTITLE 1,Question 2.4
select Channel,
    COUNT(OrderID) AS NumberOfOrders,
    round (AVG(TotalSales),2) AS AverageOrderValue,
    round (SUM(TotalSales),2) AS TotalRevenue
FROM Sales
GROUP BY Channel;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC

-- COMMAND ----------

-- DBTITLE 1,Question 2.3
SELECT YEAR(OrderDate) AS Year,
MONTH(OrderDate) AS Month,
round (SUM(TotalSales), 2) AS TotalSales
FROM Sales
WHERE YEAR(OrderDate) = 2024
GROUP BY YEAR(OrdeRDate), MONTH(OrderDate)
ORDER BY Year, Month;

-- COMMAND ----------

-- DBTITLE 1,Question 2.2
SELECT c.CustomerID,
CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
round (SUM(s.TotalSales),2) AS TotalSpent
FROM Customers c
JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
LIMIT 5

-- COMMAND ----------

-- DBTITLE 1,Question 2.1
select products.category,
round (sum(SALES.Totalsales),2) as TotalRevenue, round (sum(sales.Profit), 2) as TotalProfit
from sales
inner join products
on sales.ProductID = products.ProductID 
group by products.category
order by totalrevenue desc

-- COMMAND ----------

-- DBTITLE 1,Question 1.5
select Satisfaction,count(*) as Count
from customer_feedback
group by Satisfaction
order by count(*) desc

-- COMMAND ----------

-- DBTITLE 1,Question 1.4
select ProductName, Category, UnitPrice
from products
where UnitPrice < 1000

-- COMMAND ----------

-- DBTITLE 1,Question 1.3
select OrderID, OrderDate, TotalSales
from sales
order by OrderDate desc
limit 10

-- COMMAND ----------

-- MAGIC %md
-- MAGIC

-- COMMAND ----------

-- DBTITLE 1,Question 1.2
select region, count(*)
from customers
group by region

-- COMMAND ----------

-- DBTITLE 1,Question 1.1
select ProductID, ProductName, UnitPrice
from products
where Category = "Electronics"
order by UnitPrice desc