-- Q1: 1NF - split comma-separated Products into rows (MySQL 8+ CTE)
WITH RECURSIVE split_products AS (
  SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
    CASE
      WHEN LOCATE(',', Products) = 0 THEN NULL
      ELSE TRIM(SUBSTRING(Products, LOCATE(',', Products) + 1))
    END AS rest
  FROM ProductDetail
  UNION ALL
  SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS Product,
    CASE
      WHEN rest IS NULL OR LOCATE(',', rest) = 0 THEN NULL
      ELSE TRIM(SUBSTRING(rest, LOCATE(',', rest) + 1))
    END AS rest
  FROM split_products
  WHERE rest IS NOT NULL
)
SELECT OrderID, CustomerName, Product
FROM split_products
ORDER BY OrderID, Product;

-- Q2: 2NF - decompose into Orders and OrderItems
CREATE TABLE IF NOT EXISTS Orders (
  OrderID INT PRIMARY KEY,
  CustomerName VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS OrderItems (
  OrderItemID BIGINT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT NOT NULL,
  Product VARCHAR(100) NOT NULL,
  Quantity INT NOT NULL,
  CONSTRAINT fk_orderitems_order
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- populate Orders from OrderDetails
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails
ON DUPLICATE KEY UPDATE CustomerName = VALUES(CustomerName);

-- populate OrderItems from OrderDetails
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;


