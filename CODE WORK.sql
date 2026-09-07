-- Monday Coffee Sales Analysis


SELECT *
FROM city;

SELECT *
FROM sales;

SELECT *
FROM customers;

SELECT *
FROM product;


-- Reports and Data Analysis


-- Q1: How many people in each city are estimated to consume coffee,
-- given that 25% of the population does?
-- Assumption: 25% of each city's population consumes coffee.

SELECT
    city_name,
    population * 0.25 AS coffee_consumers_each_city
FROM city
ORDER BY 2 DESC;


SELECT
    city_name,
    population,
    ROUND((population * 0.25 / 1000000), 2)
        AS coffee_consumers_each_city_in_millions
FROM city
ORDER BY 2 DESC;


-- Q2: What is the total revenue generated from coffee sales
-- across all cities in the last quarter of 2023?

SELECT
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
    ON c.customer_id = s.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
WHERE YEAR(s.sale_date) = 2023
    AND QUARTER(s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY 2 DESC;


-- Total company revenue.

SELECT
    SUM(total) AS total_company_revenue
FROM sales
WHERE YEAR(sale_date) = 2023
    AND QUARTER(sale_date) = 4;


-- Q3: Sales count for each product.
-- How many units of each coffee product have been sold?

SELECT
    p.product_name,
    s.product_id,
    COUNT(s.product_id) AS sales_count,
    SUM(s.total) AS total_sales
FROM sales AS s
JOIN product AS p
    ON p.product_id = s.product_id
GROUP BY
    s.product_id,
    p.product_name
ORDER BY 3 DESC;


-- Q4: Average sales amount per city.
-- What is the average sales amount per customer in each city?

SELECT
    ci.city_name,
    AVG(s.total) AS avg_revenue
FROM sales AS s
JOIN customers AS c
    ON c.customer_id = s.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
GROUP BY ci.city_name;


SELECT
    c.customer_name,
    AVG(s.total) AS avg_revenue
FROM sales AS s
JOIN customers AS c
    ON c.customer_id = s.customer_id
GROUP BY c.customer_name
HAVING avg_revenue > 600;


-- Q5: City population and coffee consumers.
-- Provide a list of cities along with their population
-- and estimated coffee consumers.

SELECT
    ci.city_name,
    ci.population,
    COUNT(c.customer_name) AS estimated_coffee_consumers
FROM city AS ci
JOIN customers AS c
    ON c.city_id = ci.city_id
GROUP BY
    ci.city_name,
    ci.population;


-- Q6: Top-selling products.
-- What are the top three selling products in each city
-- based on sales volume?

-- Using ORDER BY and LIMIT to identify the top three products.

SELECT
    p.product_name,
    p.product_id,
    COUNT(p.product_id) AS sales_volume
FROM product AS p
JOIN sales AS s
    ON s.product_id = p.product_id
JOIN customers AS c
    ON c.customer_id = s.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY 3 DESC
LIMIT 3;


-- Testing the ROW_NUMBER() function.

SELECT
    p.product_name,
    p.product_id,
    COUNT(p.product_id) AS sales_volume,
    ROW_NUMBER() OVER (
        ORDER BY COUNT(p.product_id)
    ) AS ranking
FROM product AS p
JOIN sales AS s
    ON s.product_id = p.product_id
JOIN customers AS c
    ON c.customer_id = s.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
GROUP BY
    p.product_id,
    p.product_name;


-- Using the ROW_NUMBER() function with a derived table.

SELECT *
FROM (
    SELECT
        p.product_name,
        p.product_id,
        COUNT(p.product_id) AS sales_volume,
        ROW_NUMBER() OVER (
            ORDER BY COUNT(p.product_id)
        ) AS ranking
    FROM product AS p
    JOIN sales AS s
        ON s.product_id = p.product_id
    JOIN customers AS c
        ON c.customer_id = s.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY
        p.product_id,
        p.product_name
) AS ranking_table
WHERE ranking <= 3;


-- Q7: Customer segmentation by city.
-- How many unique customers are there in each city
-- who have purchased coffee products?

SELECT
    ci.city_name,
    COUNT(c.customer_name) AS number_of_unique_customers
FROM product AS p
JOIN sales AS s
    ON s.product_id = p.product_id
JOIN customers AS c
    ON c.customer_id = s.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY 2 DESC;


-- Q8: Average sales versus rent.
-- Find each city and its average sale per customer
-- and average rent per customer.

SELECT
    ci.city_name,
    c.customer_name,
    AVG(estimated_rent) AS avg_estimated_rent,
    AVG(total) AS avg_sales_amount
FROM city AS ci
JOIN customers AS c
    ON c.city_id = ci.city_id
JOIN sales AS s
    ON s.customer_id = s.customer_id
GROUP BY
    ci.city_name,
    c.customer_name;


-- Q9: Monthly sales growth.
-- Calculate the percentage growth or decline in sales
-- over different monthly periods.

-- Test-drive mode.

SELECT
    sale_date,
    total,
    MONTH(sale_date) AS month
FROM sales
GROUP BY
    sale_date,
    total
ORDER BY 1;


SELECT
    sale_date,
    COUNT(*) AS sales_count,
    SUM(total) AS total_sales
FROM sales
GROUP BY sale_date
ORDER BY 1;


SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS year_month,
    COUNT(*) AS sales_count,
    SUM(total) AS total_sales
FROM sales
GROUP BY sale_date
ORDER BY 1;


-- Separating the year and month to understand
-- what happened during each specific period.

SELECT
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    COUNT(*) AS sales_count,
    SUM(total) AS total_sales
FROM sales
GROUP BY
    sale_year,
    sale_month
ORDER BY
    sale_year,
    sale_month;


-- Using a CTE to calculate the monthly growth rate.

WITH monthly AS (
    SELECT
        YEAR(sale_date) AS sale_year,
        MONTH(sale_date) AS sale_month,
        COUNT(*) AS sales_count,
        SUM(total) AS month_total
    FROM sales
    GROUP BY
        sale_year,
        sale_month
)

SELECT
    sale_year,
    sale_month,
    month_total,
    LAG(month_total) OVER (
        ORDER BY sale_year, sale_month
    ) AS previous_month_total,
    ROUND(
        (
            month_total
            - LAG(month_total) OVER (
                ORDER BY sale_year, sale_month
            )
        )
        / LAG(month_total) OVER (
            ORDER BY sale_year, sale_month
        ) * 100,
        2
    ) AS growth_percentage
FROM monthly
ORDER BY
    sale_year,
    sale_month;
