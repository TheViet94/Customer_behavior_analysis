select * from customer LIMIT 20;
SELECT COUNT(*) 
FROM customer;

--Q1. Tổng doanh thu tạo ra bởi khách hàng nam so với khách hàng nữ là bao nhiêu?
select gender, sum(purchase_amount) as revenue
from customer
group by gender;
--Q2. Những khách hàng nào đã sử dụng mã giảm giá nhưng vẫn chi tiêu nhiều hơn mức chi tiêu trung bình?
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer);
--Q3. 5 sản phẩm nào có điểm đánh giá trung bình cao nhất?
select item_purchased,ROUND (AVG(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;
--Q4. So sánh số tiền mua hàng trung bình giữa phương thức vận chuyển Tiêu chuẩn (Standard) và Chuyển phát nhanh (Express).
select shipping_type,
ROUND (AVG(purchase_amount),2)
from customer
where shipping_type in('Standard', 'Express')
group by shipping_type
--Q5. Khách hàng đã đăng ký (subscribed) có chi tiêu nhiều hơn không? 
--So sánh mức chi tiêu trung bình và tổng doanh thu giữa nhóm đăng ký và không đăng ký.
select subscription_status,
COUNT(customer_id) as total_customers,
ROUND(AVG(purchase_amount),2)as avg_spend,
ROUND(sum(purchase_amount),2)as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;
--Q6. 5 sản phẩm nào có tỷ lệ phần trăm được mua kèm mã giảm giá cao nhất?
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;
--Q7. Phân loại khách hàng thành các nhóm: Mới (New), Quay lại (Returning), và Thân thiết (Loyal) dựa trên tổng số lần mua hàng trước đó, và hiển thị số lượng khách hàng trong mỗi nhóm.
with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer)

select customer_segment,count(*) AS "Number of Customers" 
from customer_type 
group by customer_segment;
--Q8. 3 sản phẩm được mua nhiều nhất trong mỗi danh mục là gì?
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
--Q9. Những khách hàng mua hàng lặp lại (hơn 5 lần mua trước đó) có khả năng đăng ký (subscribe) cao hơn không?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--Q10. Đóng góp doanh thu của mỗi nhóm độ tuổi là bao nhiêu?
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;
