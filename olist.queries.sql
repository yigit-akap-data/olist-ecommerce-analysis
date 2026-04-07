-- Analysis 1: Monthly Sales Trends and Revenue Growth
-- Goal: Tracking the business growth and identifying seasonal peaks.
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS monthly_orders,
    COUNT(o.order_id) AS total_orders,
    SUM(p.payment_value) AS total_revenue
FROM orders o 
INNER JOIN payments p USING(order_id)
GROUP BY 1
ORDER BY 1;

-- Analysis 2: Logistics Performance by Seller State
-- Goal: Identifying logistical bottlenecks and average delivery lead times.
SELECT
    s.seller_state,
    s.seller_id,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE),2) AS avg_lead_time
FROM orders o 
INNER JOIN order_items oi USING(order_id)
INNER JOIN sellers s USING(seller_id)
GROUP BY 1, 2
HAVING AVG(o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE) IS NOT NULL 
    AND COUNT(o.order_id) >= 5
ORDER BY avg_lead_time DESC;

-- Analysis 3: Payment Behavior and Category-Based Order Values
-- Goal: Analyzing installment preferences and high-value product categories.
SELECT
    p.payment_type,
    pr.product_category_name,
    COUNT(oi.order_id) AS total_orders,
    ROUND(AVG(p.payment_installments),2) AS avg_installments,
    SUM(oi.price + oi.freight_value) AS total_cost,
    ROUND(AVG(oi.price + oi.freight_value),2) AS avg_value
FROM payments p
INNER JOIN order_items oi USING(order_id)
INNER JOIN product pr USING(product_id)
GROUP BY 1, 2
ORDER BY avg_value DESC, 2;

-- Analysis 4: Correlation Between Delivery Delays and Low Review Scores
-- Goal: Proving that long lead times directly impact customer satisfaction (Scores < 3).
SELECT
    r.review_score,
    ROUND(AVG(o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE),2) AS avg_lead_time
FROM reviews r
INNER JOIN orders o USING(order_id)
INNER JOIN order_items oi USING(order_id)
INNER JOIN product pr USING(product_id)
WHERE r.review_score < 3 
    AND (o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE) IS NOT NULL 
    AND product_category_name IS NOT NULL
GROUP BY 1
ORDER BY avg_lead_time DESC, 1;
