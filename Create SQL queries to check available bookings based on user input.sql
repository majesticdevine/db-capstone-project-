use littlelemondb5;
CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost AS Cost
FROM Orders
WHERE Quantity > 2;

SELECT * FROM OrdersView;

SELECT c.CustomerID, CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
       o.OrderID, o.TotalCost AS Cost,
       m.Cuisine AS MenuName, m.Starters AS CourseName, m.Drinks AS StarterName
FROM Orders o
JOIN Bookings b ON o.BookingID = b.BookingID
JOIN Customer c ON b.CustomerID = c.CustomerID
JOIN Menu m ON o.OrderID = m.OrderID
JOIN Menu mi ON m.MenuID = mi.MenuID
WHERE o.TotalCost > 150
ORDER BY o.TotalCost
LIMIT 0, 1000;

DESCRIBE Orders;

SELECT m.MenuName
FROM Menus m
WHERE m.MenuID = ANY (
    SELECT o.MenuID
    FROM Orders o
    GROUP BY o.MenuID
    HAVING COUNT(*) > 2
);

DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity
    FROM Orders;
END //

DELIMITER ;

CALL GetMaxQuantity();

DELIMITER //

DELIMITER //

CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
    DELETE FROM Orders WHERE OrderID = order_id;
END //

DELIMITER ;

CALL CancelOrder(123);

DELIMITER //

CREATE PROCEDURE GetOrderDetail(IN customer_id INT)
BEGIN
    IF EXISTS(SELECT * FROM mysql.prepared_statements WHERE name = 'GetOrderDetail') THEN
        DEALLOCATE PREPARE GetOrderDetail;
    END IF;

    PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE CustomerID = ?';
    SET @customer_id = customer_id;
    EXECUTE GetOrderDetail USING @customer_id;
    DEALLOCATE PREPARE GetOrderDetail;
END //

DELIMITER ;

SET @id = 5;
CALL GetOrderDetail(@id);

INSERT INTO Bookings (BookingDate, TableNumber, CustomerID)
VALUES 
    ('2024-02-15', 1, 1),
    ('2024-02-16', 2, 2),
    ('2024-02-17', 3, 3),
    ('2024-02-18', 4, 4),
    ('2024-02-19', 5, 5);
SELECT * FROM Bookings;



