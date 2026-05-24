create DATABASE sales_analysis;

use sales_analysis;
go

select top 10 * from dbo.sales

SELECT
    s.Date,
    s.Time,
    s.[Item_Code],
    p.[Item_Name],
    p.[Category_Name],
    s.[Quantity_Sold_kilo],
    s.[Unit_Selling_Price_RMB_kg],
    w.[Wholesale_Price_RMB_kg],
    l.[Loss_Rate]
FROM dbo.sales s
LEFT JOIN dbo.products p
ON s.[Item_Code] = p.[Item_Code]

LEFT JOIN dbo.wholesale_prices w
ON s.[Item_Code] = w.[Item_Code]
AND s.Date = w.Date

LEFT JOIN dbo.loss_rates l
ON s.[Item_Code] = l.[Item_Code];

DROP VIEW sales_summary;
CREATE VIEW sales_summary AS


SELECT
    s.Date,
    s.Time,
    s.Item_Code,

    p.Item_Name,
    p.Category_Name,

    s.Quantity_Sold_kilo,

    s.Unit_Selling_Price_RMB_kg,

    w.Wholesale_Price_RMB_kg,

    l.Loss_Rate,

    s.Discount_Yes_No,

    (
        s.Quantity_Sold_kilo *
        s.Unit_Selling_Price_RMB_kg
    ) AS revenue,

    (
        (
            s.Unit_Selling_Price_RMB_kg -
            w.Wholesale_Price_RMB_kg
        )
        *
        s.Quantity_Sold_kilo
    ) AS profit

FROM sales s

LEFT JOIN products p
ON s.Item_Code = p.Item_Code

LEFT JOIN wholesale_prices w
ON s.Item_Code = w.Item_Code
AND s.Date = w.Date

LEFT JOIN loss_rates l
ON s.Item_Code = l.Item_Code;


SELECT TOP 10 * 
FROM sales_summary


/* Total Revenue */

SELECT
SUM(revenue) AS total_revenue
FROM sales_summary;


/* Top 10 Products by Revenue*/

SELECT TOP 10
    Item_Name,

    SUM(revenue) AS total_revenue

FROM sales_summary

GROUP BY Item_Name

ORDER BY total_revenue DESC;

/* Revenue by Category */

SELECT 
    Category_Name,
    SUM(revenue) as total_revenue
From sales_summary
group by Category_Name
order by total_revenue DESC;

/*Most Profitable Products*/    

SELECT TOP 10
    Item_Name,
    SUM((Unit_Selling_Price_RMB_kg - wholesale_Price_RMB_kg) * Quantity_Sold_kilo)as Most_Profitable_Products

from sales_summary
Group by Item_Name
Order by Most_Profitable_Products desc;

SELECT TOP 10
    Item_Name,

    SUM(profit) AS total_profit

FROM sales_summary

GROUP BY Item_Name

ORDER BY total_profit DESC;


/* Monthly Revenue Trend */

SELECT
    Month(Date) as month,
    SUM(revenue) as total_revenue
FROM sales_summary
GROUP BY MONTH(Date)
ORDER BY month;

/* Discount Analysis */

SELECT 
    Discount_Yes_No

FROM sales_summary
Group by Discount_Yes_No

SELECT
    Discount_Yes_No,

    SUM(revenue) AS total_revenue,

    AVG(profit) AS avg_profit

FROM sales_summary

GROUP BY Discount_Yes_No;

/*
Products sold without discounts generated significantly higher average profit compared to discounted products. 
Discounts may help sales volume, but they reduce profitability.
*/

--Loss Rate Analysis--

SELECT TOP 10
    Item_Name,
    AVG(Loss_Rate) as averege_Loss_Rate,
    SUM(revenue) as revenue

FROM sales_summary
GROUP BY Item_Name
ORDER BY revenue DESC;


SELECT TOP 10
    Item_Name,
    sum(
    profit * (1 - loss_rate / 100)) as adjusted_profit
FROM sales_summary
GROUP BY Item_Name
ORDER BY adjusted_profit DESC;

SELECT * FROM sales_summary