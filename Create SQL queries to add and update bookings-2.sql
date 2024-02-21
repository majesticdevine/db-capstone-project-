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

DELIMITER //

CREATE PROCEDURE CheckBooking(
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    DECLARE table_status VARCHAR(50);

    -- Check if the table is already booked for the specified date
    SELECT CASE
        WHEN EXISTS (
            SELECT * FROM Bookings
            WHERE BookingDate = booking_date AND TableNumber = table_number
        ) THEN 'Booked'
        ELSE 'Available'
    END INTO table_status;

    -- Return the table status
    SELECT table_status AS TableStatus;
END //

DELIMITER ;

CALL CheckBooking('2024-02-15', 1);

DELIMITER //

CREATE PROCEDURE AddValidBooking(
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    DECLARE table_status VARCHAR(50);

    -- Start the transaction
    START TRANSACTION;

    -- Check if the table is already booked for the specified date
    SELECT CASE
        WHEN EXISTS (
            SELECT * FROM Bookings
            WHERE BookingDate = booking_date AND TableNumber = table_number
        ) THEN 'Booked'
        ELSE 'Available'
    END INTO table_status;

    -- If the table is already booked, rollback the transaction
    IF table_status = 'Booked' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Table is already booked for the specified date.';
    ELSE
        -- Insert the new booking record
        INSERT INTO Bookings (BookingDate, TableNumber, CustomerID)
        VALUES (booking_date, table_number, NULL); -- Replace NULL with the actual customer ID

        -- Commit the transaction
        COMMIT;
    END IF;
END //

DELIMITER ;

CALL AddValidBooking('2024-02-15', 1);
--Error Code: 1644. Table is already booked for the specified date.--
SELECT * FROM Bookings;

DELIMITER //

CREATE PROCEDURE AddBooking(
    IN booking_id INT,
    IN customer_id INT,
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNumber)
    VALUES (booking_id, customer_id, booking_date, table_number);
END //

DELIMITER ;

CALL AddBooking(12, 101, '2024-02-15', 5);
INSERT INTO Customer (CustomerID, FirstName, LastName, CustomerName, ContactNumber, Address, Email)
VALUES (7, 'Mark', 'Doe', 'Mark Smith', '1234566590', '133 Main St', 'mark@example.com');
DELIMITER //

CREATE PROCEDURE UpdateBooking(
    IN booking_id INT,
    IN new_booking_date DATE
)
BEGIN
    UPDATE Bookings
    SET BookingDate = new_booking_date
    WHERE BookingID = booking_id;
END //

DELIMITER ;
CALL UpdateBooking(1, '2024-02-20');
SELECT * FROM Bookings WHERE BookingID = 1;
