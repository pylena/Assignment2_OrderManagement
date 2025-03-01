CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
--product table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY, --auto
    Name VARCHAR(255) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL ,
    StockQuantity INT NOT NULL 
);

--Userid
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY, --auto increment
    UserID INT NOT NULL,
    OrderDate DATETIME2 DEFAULT GETDATE() ,
    Status VARCHAR(255) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

--order deatails table

CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY, --auto increment
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL ,
    SubTotal DECIMAL(10,2) NOT NULL ,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);

-- -- inser dummy data to test
-- Insert Users
INSERT INTO Users (Name, Email, PasswordHash) VALUES
('Alice Johnson', 'alice@example.com', 'hashed_password1'),
('Bob Smith', 'bob@example.com', 'hashed_password2'),
('Charlie Brown', 'charlie@example.com', 'hashed_password3');

-- Insert Products
INSERT INTO Products (Name, Category, Price, StockQuantity) VALUES
('Laptop', 'Electronics', 1200.99, 10),
('Smartphone', 'Electronics', 699.50, 15),
('Wireless Headphones', 'Accessories', 150.75, 25),
('Coffee Maker', 'Home Appliances', 85.99, 8),
('Running Shoes', 'Sportswear', 95.00, 20);

-- Insert Orders
INSERT INTO Orders (UserID, OrderDate, Status) VALUES
(1, '2025-02-28 10:30:00', 'Pending'),
(2, '2025-02-28 12:45:00', 'Shipped'),
(3, '2025-02-28 15:20:00', 'Delivered');

-- Insert OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, SubTotal) VALUES
(1, 1, 1, 1200.99),  -- Alice buys 1 Laptop
(1, 3, 2, 301.50),   -- Alice buys 2 Wireless Headphones
(2, 2, 1, 699.50),   -- Bob buys 1 Smartphone
(2, 5, 1, 95.00),    -- Bob buys 1 Pair of Running Shoes
(3, 4, 3, 257.97);   -- Charlie buys 3 Coffee Makers

-- Query
-- Retrieve all orders along with user details using JOINs.
Select OrderID , u.Name
FROM Orders o
join Users u on o.UserID = u.UserID

--Get the total sales per product category using GROUP BY.
SELECT p.Category, 
       SUM(od.SubTotal) AS Total
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.Category

--Find the top 3 customers based on total spending.
SELECT u.Name AS Customer, 
       SUM(od.SubTotal) AS Total 
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Users u ON o.UserID = u.UserID
GROUP BY u.UserID, u.Name
ORDER BY Total DESC
LIMIT 3; -- to retrive top 3

-- Write a stored procedure to insert a new order and update stock quantity.
CREATE PROCEDURE InsertOrder
    @UserID INT,                   -- as arguments
    @Status VARCHAR(255),           -- 
    @ProductID INT,                 -- 
    @Quantity INT                   -- 
AS
BEGIN
    -- Step 1: Insert new order into Orders table
    DECLARE @OrderID INT;

    -- Insert the new order into Orders
    INSERT INTO Orders (UserID, OrderDate, Status)
    VALUES (@UserID, GETDATE(), @Status);

    SET @OrderID = SCOPE_IDENTITY();

    UPDATE Products
    SET StockQuantity = StockQuantity - @Quantity
    WHERE ProductID = @ProductID;

    
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
    VALUES (@OrderID, @ProductID, @Quantity);

    -- Return the OrderID as output
    SELECT @OrderID AS NewOrderID;
END;
--test:
EXEC InsertOrder
    @UserID = 1, 
    @Status = 'Pending', 
    @ProductID = 101, 
    @Quantity = 2;

select * from OrderDetails
select * from Orders

--- Create a trigger to automatically update stock when an order is placed.
CREATE TRIGGER trg_UpdateStock
ON OrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update stock quantity based on ordered quantity
    UPDATE P
    SET P.StockQuantity = P.StockQuantity - I.Quantity
    FROM Products P
    INNER JOIN inserted I ON P.ProductID = I.ProductID;

    
    UPDATE Products
    SET StockQuantity = 0
    WHERE StockQuantity < 0;
END;

--test the trigger
SELECT * FROM Products;
INSERT INTO Orders (UserID, OrderDate, Status)
VALUES ( 1, GETDATE(), 'Pending');

INSERT INTO OrderDetails ( OrderID, ProductID, Quantity, SubTotal)
VALUES ( 1, 1, 20, 19.98);

--Use Common Table Expressions (CTE) to list products that have never been ordered.
--create proudect never been order to test
INSERT INTO Products (Name, Category, Price, StockQuantity) VALUES
('watch', 'A', 20, 1)
WITH UnorderedProducts AS (
    SELECT P.ProductID, P.Name, P.Category
    FROM Products P
    LEFT JOIN OrderDetails OD ON P.ProductID = OD.ProductID
    WHERE OD.ProductID IS NULL  -- Products that have no matching order
)
SELECT * FROM UnorderedProducts;

--Query Optimization
--Create indexes on frequently searched columns.
--on prouduct categoey for fast filltering
CREATE INDEX IDX_Products_Category ON Products(Category);
-- on order ID for fast search
CREATE INDEX IDX_OrderDetails_OrderID ON OrderDetails(OrderID);

-- Use EXPLAIN/Execution Plan to analyze and improve slow queries.
EXPLAIN ANALYZE
SELECT Category, SUM(Quantity * Price) AS TotalSales
FROM OrderDetails OD
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.Category
HAVING SUM(Quantity * Price) > 1000;
