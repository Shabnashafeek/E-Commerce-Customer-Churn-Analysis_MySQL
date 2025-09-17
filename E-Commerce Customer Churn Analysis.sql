USE ecomm;

-- DATA CLEANING --
-- 1 --

/* Impute mean  for the following columns, and round off to the nearest integer if 
required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, 
DaySinceLastOrder. */

SET SQL_SAFE_UPDATES = 0;

SELECT ROUND(AVG(WarehouseToHome)) AS meanwarehousetohome FROM customer_churn;
UPDATE customer_churn SET WarehouseToHome = 16 WHERE WarehouseToHome IS NULL;

SELECT ROUND(AVG(HourSpendOnApp)) AS meanhourspendonapp FROM customer_churn;
UPDATE customer_churn SET HourSpendOnApp = 3 WHERE HourSpendOnApp IS NULL;

SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) AS meanorderamounthikefromlastyear FROM customer_churn;
UPDATE customer_churn SET OrderAmountHikeFromlastYear = 16 WHERE OrderAmountHikeFromlastYear IS NULL;

SELECT ROUND(AVG(DaySinceLastOrder)) AS meandaysincelastorder FROM customer_churn;
UPDATE customer_churn SET DaySinceLastOrder = 5 WHERE DaySinceLastOrder IS NULL;

-- 2 --

-- Impute mode for the following columns: Tenure, CouponUsed, OrderCount. --

SELECT Tenure, COUNT(*) AS Modetenurecount
 FROM customer_churn GROUP BY Tenure ORDER BY Modetenurecount DESC LIMIT 1;
UPDATE customer_churn SET Tenure = 1 WHERE Tenure IS NULL;

SELECT CouponUsed, COUNT(*) AS Modecouponusedcount
 FROM customer_churn GROUP BY CouponUsed ORDER BY Modecouponusedcount DESC LIMIT 1;
UPDATE customer_churn SET CouponUsed = 1 WHERE CouponUsed IS NULL;

SELECT OrderCount, COUNT(*) AS Modeordercount
 FROM customer_churn GROUP BY OrderCount ORDER BY Modeordercount DESC LIMIT 1;
UPDATE customer_churn SET OrderCount = 2 WHERE OrderCount IS NULL;

-- 3 --

/* Handle outliers in the 'WarehouseToHome' column by deleting rows where the 
values are greater than 100. */

DELETE FROM customer_churn WHERE WarehouseToHome > 100;

-- DEALING WITH INCONSISTENCIES --

-- 1 --

/* Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and 
“Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure 
uniformity. */

UPDATE customer_churn 
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Mobile';
  
-- 2 --

/* Standardize payment mode values: Replace "COD" with "Cash on Delivery" and 
"CC" with "Credit Card" in the PreferredPaymentMode column. */

UPDATE customer_churn
SET PreferredPaymentMode = REPLACE(REPLACE(PreferredPaymentMode,'COD','Cash On Delivery'),'CC','Credit Card')
WHERE 
 PreferredPaymentMode LIKE 'COD' OR 
 PreferredPaymentMode LIKE 'CC';

-- DATA TRANSFORMATION --

-- COLOUMN RENAMING --

-- 1 --
-- Rename the column "PreferedOrderCat" to "PreferredOrderCat". --

ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat to PreferredOrderCat;

-- 2 --
--  Rename the column "HourSpendOnApp" to "HoursSpentOnApp". --

ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpendOnAPP;

-- CREATING NEW COLUMN --

SET SQL_SAFE_UPDATES=0;

-- 1 --
/* Create a new column named ‘ComplaintReceived’ with values "Yes" if the 
corresponding value in the ‘Complain’ is 1, and "No" otherwise. */

ALTER TABLE customer_churn ADD ComplaintReceived VARCHAR(10);
UPDATE customer_churn SET ComplaintReceived = CASE WHEN Complain = 1 THEN 'YES' ELSE 'NO'
END;

-- 2 --
/*Create a new column named 'ChurnStatus'. Set its value to “Churned” if the 
corresponding value in the 'Churn' column is 1, else assign “Active”. */

ALTER TABLE customer_churn ADD ChurnStatus VARCHAR(10);
UPDATE customer_churn 
SET ChurnStatus = CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Active'
END;

-- COLUMN DROPPING --
-- Drop the columns "Churn" and "Complain" from the table. --

ALTER TABLE customer_churn DROP COLUMN Complain;
ALTER TABLE customer_churn DROP COLUMN Churn;

-- DATA EXPLORATION AND ANALYSIS --

-- 1 --
-- Retrieve the count of churned and active customers from the dataset.--

SELECT
  COUNT(CASE WHEN ChurnStatus = 'Active' THEN 1 END) AS Active_customers,
  COUNT(CASE WHEN ChurnStatus = 'Churned' THEN 1 END) AS Churned_customers
FROM customer_churn;

-- 2 --
/* Display the average tenure and total cashback amount of customers who 
churned.*/

SELECT
  AVG(Tenure) AS Average_tenure,
  SUM(CashbackAmount) AS Total_cashback
FROM customer_churn WHERE ChurnStatus = 'Churned';

-- 3 --
-- Determine the percentage of churned customers who complained. --

SELECT(COUNT(CASE WHEN ComplaintReceived = 'YES' THEN 1 END) * 100 / COUNT(*))
 AS Percentage_Complained FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 4 --
/*Identify the city tier with the highest number of churned customers whose 
preferred order category is Laptop & Accessory. */

SELECT CityTier,COUNT(*) AS churned_customercount FROM customer_churn
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory' 
GROUP BY CityTier ORDER BY churned_customercount DESC LIMIT 1;

-- 5 --
-- Identify the most preferred payment mode among active customers. --

SELECT PreferredPaymentMode AS Most_preffered_paymentmode,COUNT(*) AS Count_used
FROM customer_churn 
WHERE ChurnStatus = 'Active' GROUP BY PreferredPaymentMode ORDER BY Count_used DESC LIMIT 1;

-- 6 --
/* Calculate the total order amount hike from last year for customers who are single 
and prefer mobile phones for ordering. */

SELECT SUM(OrderAmountHikeFromlastYear) AS Total_orderhike_from_lastyear
FROM customer_churn WHERE MaritalStatus = 'Single' AND PreferredLoginDevice = 'Mobile Phone';

SELECT SUM(OrderAmountHikeFromlastYear) AS Total_orderhike_from_lastyear
FROM customer_churn WHERE MaritalStatus = 'Single' AND PreferredOrderCat = 'Mobile Phone';

-- 7 --
/* Find the average number of devices registered among customers who used UPI as 
their preferred payment mode. */

SELECT AVG(NumberOfDeviceRegistered) AS Avg_devices FROM customer_churn 
WHERE PreferredPaymentMode = 'UPI';

-- 8 --
-- Determine the city tier with the highest number of customers. --

SELECT CityTier,COUNT(*) AS customer_count FROM customer_churn GROUP BY CityTier ORDER BY customer_count
DESC LIMIT 1;

-- 9 --
-- Identify the gender that utilized the highest number of coupons.--

SELECT Gender,SUM(CouponUsed) AS Total_coupon_used FROM customer_churn GROUP BY Gender ORDER BY Total_coupon_used
DESC LIMIT 1;

-- 10 --
/* List the number of customers and the maximum hours spent on the app in each 
preferred order category.*/

SELECT PreferredOrderCat,COUNT(DISTINCT CustomerID) AS Number_of_customers,MAX(HoursSpendOnApp) AS Max_hours_spent
FROM customer_churn GROUP BY PreferredOrderCat ORDER BY PreferredOrderCat;

-- 11 --
/* Calculate the total order count for customers who prefer using credit cards and 
have the maximum satisfaction score. */

SELECT SUM(OrderCount) AS total_order_count FROM customer_churn WHERE 
  PreferredPaymentMode = 'Credit Card' AND
  SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn 
  WHERE PreferredPaymentMode = 'Credit Card');
  
-- 12 --
-- What is the average satisfaction score of customers who have complained? --

SELECT AVG(SatisfactionScore) AS average_satisfaction_score FROM customer_churn WHERE
 ComplaintReceived ='YES';
 
-- 13 --
/* List the preferred order category among customers who used more than 5 
coupons. */

SELECT PreferredOrderCat AS Order_category,COUNT(*) AS customer_count FROM customer_churn WHERE 
CouponUsed >5
GROUP BY PreferredOrderCat ORDER BY customer_count DESC;

-- 14 --
/* List the top 3 preferred order categories with the highest average cashback 
amount.*/

SELECT PreferredOrderCat,AVG(CashbackAmount) AS average_cashback FROM customer_churn
GROUP BY PreferredOrderCat ORDER BY average_cashback DESC LIMIT 3;

-- 15 --
/* Find the preferred payment modes of customers whose average tenure is 10 
months and have placed more than 500 orders. */

SELECT PreferredPaymentMode, COUNT(*) AS Customer_count FROM customer_churn
WHERE Tenure = 10 AND OrderCount > 500
GROUP BY PreferredPaymentMode ORDER BY customer_count DESC;

-- 16 --
/* Categorize customers based on their distance from the warehouse to home such 
as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km, 
'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the 
churn status breakdown for each distance category. */

SELECT 
    CASE 
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS distance,
    ChurnStatus,
    COUNT(*) AS customers
FROM customer_churn
GROUP BY distance, ChurnStatus
ORDER BY 
    MIN(WarehouseToHome), 
    ChurnStatus DESC;
    
-- 17 --
/* List the customer’s order details who are married, live in City Tier-1, and their 
order counts are more than the average number of orders placed by all 
customers. */

SELECT CustomerID,OrderCount,PreferredOrderCat,PreferredPaymentMode,CashbackAmount
FROM customer_churn WHERE 
    MaritalStatus = 'Married'AND 
    CityTier = 1 AND 
    OrderCount > (
        SELECT AVG(OrderCount) 
        FROM customer_churn
    )
ORDER BY OrderCount DESC;

-- 18 --

-- a --

/*➢  Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the 
following data: */

CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ReturnDate DATE NOT NULL,
    RefundAmount DECIMAL(10, 2) NOT NULL
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES 
    (1001, 50022, '2023-01-01', 2130.00),
    (1002, 50316, '2023-01-23', 2000.00),
    (1003, 51099, '2023-02-14', 2290.00),
    (1004, 52321, '2023-03-08', 2510.00),
    (1005, 52928, '2023-03-20', 3000.00),
    (1006, 53749, '2023-04-17', 1740.00),
    (1007, 54206, '2023-04-21', 3250.00),
    (1008, 54838, '2023-04-30', 1990.00);

DESC customer_returns;
SELECT * FROM customer_returns;

-- b --

/*Display the return details along with the customer details of those who have 
churned and have made complaints.*/

SELECT 
    customer_returns.ReturnID,
    customer_returns.ReturnDate,
    customer_returns.RefundAmount,
    customer_churn.CustomerID,
    customer_churn.CityTier,
    customer_churn.PreferredPaymentMode
FROM 
    customer_returns
JOIN 
    customer_churn ON customer_returns.CustomerID = customer_churn.CustomerID
WHERE 
    customer_churn.ChurnStatus = 'Churned'
    AND customer_churn.ComplaintReceived = 'Yes'
ORDER BY 
   customer_returns.RefundAmount DESC;

