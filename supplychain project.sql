create database sp;
use sp;
SELECT COUNT(*) 
FROM sp.`supply_chain_cleaned (1)`;
-- basic sql

-- total sales and total profit 

SELECT -- round the values 
    ROUND(SUM(`Sales`), 2) AS total_sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS total_profit
FROM sp.`supply_chain_cleaned (1)`;

-- total order

SELECT COUNT(DISTINCT `Order Id`) AS total_orders
FROM sp.`supply_chain_cleaned (1)`;

-- sales by category

SELECT
    `Category Name`,ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Category Name`
ORDER BY total_sales DESC;

-- profit by category

SELECT
    `Category Name`,ROUND(SUM(`Order Profit Per Order`), 2) AS total_profit
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Category Name`
ORDER BY total_profit DESC;

-- sales by region

SELECT
    `Order Region`,ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Order Region`
ORDER BY total_sales DESC;

-- delivery status

SELECT
    `Delivery Status`,COUNT(DISTINCT `Order Id`) AS total_orders
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Delivery Status`
ORDER BY total_orders DESC;

-- shipping mode anlysis

SELECT
    `Shipping Mode`,
    COUNT(DISTINCT `Order Id`) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Shipping Mode`
ORDER BY total_sales DESC;

-- customer segent anlysis

SELECT
    `Customer Segment`,
    COUNT(DISTINCT `Order Id`) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS total_profit
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Customer Segment`
ORDER BY total_sales DESC;

-- top 10 product sales

SELECT
    `Product Name`, ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Product Name`
ORDER BY total_sales DESC LIMIT 10;

-- montly sales

SELECT
    DATE_FORMAT(`order`, '%Y-%m') AS month,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY DATE_FORMAT(`order`, '%Y-%m')ORDER BY month;

-- intermediate sql

-- case on shipping status

SELECT
    CASE
        WHEN `Ship_Diff` < 0 THEN 'Early'
        WHEN `Ship_Diff` = 0 THEN 'On Time'
        ELSE 'Late'
    END AS delivery_timing,COUNT(*) AS total_records
FROM sp.`supply_chain_cleaned (1)`
GROUP BY delivery_timing
ORDER BY total_records DESC;

-- percentage of shipping diff and status

SELECT ROUND(
        SUM(CASE WHEN `Ship_Diff` > 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),2) AS late_delivery_percentage
FROM sp.`supply_chain_cleaned (1)`;

-- above 300000 greater than sales

SELECT `Category Name`,ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Category Name`
HAVING SUM(`Sales`) > 300000
ORDER BY total_sales DESC;

-- high sales in late deliveries

SELECT
    `Order Id`,`Customer Segment`,`Sales`,`Delivery Status`,`Shipping Mode`
FROM sp.`supply_chain_cleaned (1)`
WHERE `Delivery Status` = 'Late delivery'
  AND `Sales` > 300 AND (`Customer Segment` = 'Consumer'
       OR `Customer Segment` = 'Corporate')LIMIT 20;
       
-- product which have total sales > avg product sales

SELECT `Product Name`,ROUND(SUM(`Sales`), 2) AS total_sales
FROM sp.`supply_chain_cleaned (1)`
GROUP BY `Product Name`
HAVING SUM(`Sales`) > (SELECT AVG(product_sales)
    FROM (SELECT SUM(`Sales`) AS product_sales
        FROM sp.`supply_chain_cleaned (1)`
        GROUP BY `Product Name`) AS product_summary)
        ORDER BY total_sales DESC;
        
-- average order value

SELECT
    ROUND(SUM(`Sales`) / COUNT(DISTINCT `Order Id`), 2) AS average_order_value
FROM sp.`supply_chain_cleaned (1)`;

-- profit margin-- total profit/toatls sales * 100

SELECT
    ROUND(SUM(`Order Profit Per Order`) / SUM(`Sales`) * 100,
        2) AS profit_margin_percentage
FROM sp.`supply_chain_cleaned (1)`;

-- delivery performance

SELECT ROUND(
        SUM(CASE WHEN `Delivery Status` = 'Shipping on time' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(DISTINCT `Order Id`),
        2) AS on_time_delivery_percentage
FROM sp.`supply_chain_cleaned (1)`;

-- final combined business anlaysis

SELECT
    COUNT(DISTINCT `Order Id`) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS total_profit,
    ROUND(SUM(`Order Profit Per Order`) / SUM(`Sales`) * 100, 2) AS profit_margin_percentage,
    ROUND(SUM(CASE WHEN `Delivery Status` = 'Shipping on time' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(DISTINCT `Order Id`),
        2) AS on_time_delivery_percentage
FROM sp.`supply_chain_cleaned (1)`;