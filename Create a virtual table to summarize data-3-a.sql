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








