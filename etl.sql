vi inf.sql

DROP DATABASE IF EXISTS POS;
CREATE DATABASE POS;
USE POS;
CREATE TABLE Product (
        id SERIAL PRIMARY KEY,
        name VARCHAR(128) NOT NULL,
        currentPrice DECIMAL(6,2),
        availableQuantity INTEGER
)ENGINE=InnoDB;
CREATE TABLE City (
        zip DECIMAL(5) ZEROFILL PRIMARY KEY,
        city VARCHAR(32) NOT NULL,
        state VARCHAR(4) NOT NULL
)ENGINE=InnoDB;
CREATE TABLE PriceHistory (
        id SERIAL PRIMARY KEY,
        oldPrice DECIMAL(6,2),
        newPrice DECIMAL(6,2),
        ts TIMESTAMP,
        product_id BIGINT UNSIGNED,
        FOREIGN KEY (product_id) REFERENCES Product(id)
)ENGINE=InnoDB;
CREATE TABLE Customer (
        id SERIAL PRIMARY KEY,
        firstName VARCHAR(32),
        lastName VARCHAR(30),
        email VARCHAR(128),
        address1 VARCHAR(100),
        address2 VARCHAR(50),
        phone VARCHAR(32),
        birthdate DATE,
        zip DECIMAL(5) ZEROFILL,
        FOREIGN KEY (zip) REFERENCES City(zip)
)ENGINE=InnoDB;
CREATE TABLE `Order` (
        id SERIAL PRIMARY KEY,
        datePlaced Date,
        dateShipped Date,
        customer_id BIGINT UNSIGNED,
        FOREIGN KEY (customer_id) REFERENCES Customer(id)
)ENGINE=InnoDB;
CREATE TABLE Orderline (
        order_id BIGINT UNSIGNED,
        product_id BIGINT UNSIGNED,
        quantity INTEGER,
        PRIMARY KEY (order_id, product_id),
        FOREIGN KEY (order_id) REFERENCES `Order`(id),
        FOREIGN KEY (product_id) REFERENCES Product(id)
)ENGINE=InnoDB;

vi etl.sql

further affirm that I have not and will not provide this code to any person, platform, or repository,
without the express written permission of Dr. Gomillion. I understand that any violation of these
standards will have serious repercussions. */

SOURCE inf.sql; /*referencing the previous sql script for database creation and table schema*/

LOAD DATA LOCAL INFILE 'products.csv'
INTO TABLE Product /*populating the table Product with the data of product.csv*/
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES /*to ignore the first line which is the  header of product.csv*/
(ID,Name,@currentPrice,availableQuantity)
SET currentPrice = NULLIF(REPLACE(REPLACE(@currentPrice,'$',''),',',''),''); /*replace the $ sign in the price column with null*/

LOAD DATA LOCAL INFILE 'customers.csv'
INTO TABLE City
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(@ID, @FN, @LN, @CT, @ST, @ZP, @s1, @s2, @EM, @BD)
SET
    city = @CT,
    state = @ST,
    zip = @ZP;
	
LOAD DATA LOCAL INFILE 'customers.csv'
INTO TABLE Customer
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(id,firstName, lastName,@city,@state,zip, address1, @address2,email,@birthdate)
SET phone=NULL,
    address2=NULLIF(@address2,''),
    birthdate = NULLIF(STR_TO_DATE(@birthdate, '%m/%d/%Y'), '0000/00/00');

LOAD DATA LOCAL INFILE 'orders.csv'
INTO TABLE `Order`
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(@OID,@CID,@ordered,@shipped)
SET
    id=@OID,
    customer_id=@CID,
    datePlaced = STR_TO_DATE(@ordered, '%Y-%m-%d'),
    dateShipped = NULLIF(NULLIF(@shipped,'Cancelled'),'0000-00-00');

CREATE TABLE temp (
        order_id BIGINT,
        product_id BIGINT
);

LOAD DATA LOCAL INFILE 'orderlines.csv'
INTO TABLE temp
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@OID,@PID)
SET
    order_id = @OID,
    product_id = @PID;

INSERT INTO Orderline ( order_id, product_id, quantity)
SELECT order_id, product_id, COUNT(*)
FROM temp
GROUP BY order_id, product_id;

DROP TABLE temp;

34.235.144.83
	
	
further affirm that I have not and will not provide this code to any person, platform, or repository,
without the express written permission of Dr. Gomillion. I understand that any violation of these
standards will have serious repercussions. */

SOURCE inf.sql; /*referencing the previous sql script for database creation and table schema*/

LOAD DATA LOCAL INFILE 'products.csv'
INTO TABLE Product /*populating the table Product with the data of product.csv*/
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES /*to ignore the first line which is the  header of product.csv*/
(ID,Name,@currentPrice,availableQuantity)
SET currentPrice = NULLIF(REPLACE(REPLACE(@currentPrice,'$',''),',',''),''); /*replace the $ sign in the price column with null*/

LOAD DATA LOCAL INFILE 'customers.csv'
INTO TABLE City
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(@ID, @FN, @LN, @CT, @ST, @ZP, @s1, @s2, @EM, @BD)
SET
    city = @CT,
    state = @ST,
    zip = @ZP;
	
LOAD DATA LOCAL INFILE 'customers.csv'
INTO TABLE Customer
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(id,firstName, lastName,@city,@state,zip, address1, @address2,email,@birthdate)
SET phone=NULL,
    address2=NULLIF(@address2,''),
    birthdate = NULLIF(STR_TO_DATE(@birthdate, '%m/%d/%Y'), '0000/00/00');

LOAD DATA LOCAL INFILE 'orders.csv'
INTO TABLE `Order`
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(@OID,@CID,@ordered,@shipped)
SET
    id=@OID,
    customer_id=@CID,
    datePlaced = STR_TO_DATE(@ordered, '%Y-%m-%d'),
    dateShipped = NULLIF(NULLIF(@shipped,'Cancelled'),'0000-00-00');

CREATE TABLE temp (
        order_id BIGINT,
        product_id BIGINT
);

LOAD DATA LOCAL INFILE 'orderlines.csv'
INTO TABLE temp
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@OID,@PID)
SET
    order_id = @OID,
    product_id = @PID;

INSERT INTO Orderline ( order_id, product_id, quantity)
SELECT order_id, product_id, COUNT(*)
FROM temp
GROUP BY order_id, product_id;

DROP TABLE temp;

34.235.144.83
	
vi views.sql

SOURCE etl.sql;

CREATE OR REPLACE VIEW v_customers AS 
SELECT
lastName AS "Last Name",
firstName AS "First Name"
FROM Customer
ORDER BY lastName,firstName;

CREATE OR REPLACE VIEW v_customers2 AS
SELECT
id AS "customer_number",
firstName AS "first_name",
lastName AS "last_name",
CONCAT_WS(", ",Customer.address1,IFNULL(address2,NULL)) AS "addr1",
CONCAT(City.city,", ",City.state,"   ",City.zip) AS "addr2"
FROM Customer LEFT JOIN City on Customer.zip = City.zip
ORDER BY Customer.zip;

CREATE OR REPLACE VIEW v_ProductBuyers AS
SELECT
Product.id AS "productID",
name AS "productName",
GROUP_CONCAT(DISTINCT(CONCAT(Customer.id," ", Customer.firstName," ", Customer.lastName))
ORDER BY Customer.id separator ",") AS customers
FROM Product LEFT JOIN Orderline ON Product.id = Orderline.product_id
LEFT JOIN `Order` ON Orderline.order_id=`Order`.id
LEFT JOIN Customer ON `Order`.customer_id = Customer.id
GROUP BY productID,productName
ORDER BY productID;

CREATE OR REPLACE VIEW v_CustomerPurchases AS
SELECT
    Customer.id AS "customer number",
    Customer.firstName AS "fn",
    Customer.lastName AS "ln",
    GROUP_CONCAT(DISTINCT(CONCAT(Product.id," ", Product.name)) ORDER BY Product.id SEPARATOR "|") AS products
FROM Customer
LEFT JOIN `Order` ON Customer.id = `Order`.customer_id
LEFT JOIN Orderline ON `Order`.id = Orderline.order_id
LEFT JOIN Product ON Orderline.product_id = Product.id
GROUP BY Customer.id, Customer.firstName, Customer.lastName
ORDER BY Customer.lastName, Customer.firstName;

CREATE TABLE mv_ProductBuyers AS
SELECT * FROM v_ProductBuyers;

CREATE TABLE mv_CustomerPurchases AS
SELECT * FROM v_CustomerPurchases;

CREATE INDEX idx_CustomerEmail ON Customer(email);

CREATE INDEX idx_ProductName ON Product(name);

vi proc.sql

SOURCE views.sql;

ALTER TABLE Orderline
ADD COLUMN unitPrice DECIMAL(6,2);

ALTER TABLE Orderline
ADD COLUMN lineTotal DECIMAL(8,2) GENERATED ALWAYS AS (quantity * unitPrice) VIRTUAL;

ALTER TABLE `Order`
ADD COLUMN orderTotal DECIMAL(8,2);

ALTER TABLE Customer
DROP COLUMN phone;

ALTER TABLE PriceHistory
MODIFY COLUMN ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP();

DELIMITER //
CREATE PROCEDURE proc_FillUnitPrice()
BEGIN
        -- DECLARE newPrice DECIMAL(6,2);
        -- SELECT currentPrice INTO newPrice FROM Product WHERE Orderline.product_id = Product.id;
        UPDATE Orderline
        SET unitPrice = (SELECT currentPrice FROM Product WHERE Orderline.product_id = Product.id)
        WHERE unitPrice IS NULL;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE proc_FillOrderTotal()
BEGIN
        UPDATE `Order`
        SET orderTotal = (SELECT SUM(Orderline.lineTotal) FROM Orderline WHERE Orderline.order_id=`Order`.id)
        WHERE orderTotal IS NULL;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE proc_RefreshMV()
BEGIN
        START TRANSACTION;
        DELETE FROM mv_ProductBuyers;
        INSERT INTO mv_ProductBuyers (productID, productName, customers)
        SELECT productID, productName, customers FROM v_ProductBuyers;
-- Refresh mv_CustomerPurchases by deleting old data and inserting fresh data from v_CustomerPurchases
        DELETE FROM mv_CustomerPurchases;
        INSERT INTO mv_CustomerPurchases (`customer number`,fn,`ln`, products)
        SELECT `customer number`,fn,`ln`, products FROM v_CustomerPurchases;
        COMMIT;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE proc_AddItem(IN orderID INT,IN productID INT,IN Quantity INT)
BEGIN
        DECLARE price DECIMAL(6,2);
        SELECT currentPrice INTO price FROM Product WHERE Product.id = productID;
        INSERT INTO Orderline (order_id, product_id, quantity, unitPrice) VALUES (orderID, productID, Quantity, price);
        UPDATE `Order`
        SET orderTotal = orderTotal + (price * quantity)
        WHERE `Order`.id = orderID;
        UPDATE Product
        SET availableQuantity = availableQuantity - quantity
        WHERE Product.id = productID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE proc_SalesReport(IN startDate DATE, IN endDate DATE, IN productID INT)
BEGIN
        SELECT
        Orderline.product_id AS 'Product ID',
        SUM(Orderline.quantity) AS 'Quantity Sold',
        SUM(Orderline.unitPrice * Orderline.quantity) AS 'Total Sales Amount'
        FROM Orderline
        JOIN `Order` ON Orderline.order_id = `Order`.id
        WHERE Orderline.product_id = productID
        AND `Order`.datePlaced  BETWEEN startDate AND endDate
        GROUP BY Orderline.product_id;
END //
DELIMITER ;

CREATE PROCEDURE proc_UpdatePrice(IN productID INT, IN price DECIMAL(6,2))
BEGIN
        DECLARE oldPrice DECIMAL(6,2);
        SELECT currentPrice INTO oldPrice FROM Product WHERE Product.id = productID;
        UPDATE Product
        SET currentPrice = price WHERE Product.id = productID;
        INSERT INTO PriceHistory (id, oldPrice, newPrice, ts) VALUES (productID, oldPrice, Price, NOW());
END //
DELIMITER ;

trig.sql

SOURCE proc.sql;

CALL proc_FillUnitPrice();
CALL proc_FillOrderTotal();

CREATE TABLE SalesTax (
    zip_code DECIMAL(5) ZEROFILL PRIMARY KEY,   -- ZIP code as the primary key
    taxRate DECIMAL(8, 5) NOT NULL      -- Tax rate represented as a decimal to allow for fraction
)ENGINE=InnoDB;

LOAD DATA LOCAL INFILE 'TAXRATES.csv'
INTO TABLE SalesTax
COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(@State, @ZipCode, @TaxRegionName, @EstimatedCombinedRate, @StateRate, @EstimatedCountyRate, @EstimatedCityRate, @EstimatedSpecialRate, @RiskLevel)
SET
    zip_code=@ZipCode,
    taxRate=@EstimatedCombinedRate;
	ALTER TABLE `Order`
CHANGE COLUMN orderTotal subtotal DECIMAL(8, 2),    -- Rename 'orderTotal' to 'subtotal'
ADD COLUMN salesTax DECIMAL(5, 2) DEFAULT 0.00, -- New 'salesTax' column
ADD COLUMN total DECIMAL(8, 2) AS (subtotal + salesTax) VIRTUAL; -- Virtual 'total' column

DELIMITER //

CREATE OR REPLACE TRIGGER Insert_NewPrice
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
        IF OLD.currentPrice != NEW.currentPrice THEN
        -- Insert the old and new prices into the PriceHistory table
        INSERT INTO PriceHistory (product_id, oldPrice, newPrice, ts)
        VALUES (NEW.id, OLD.currentPrice, NEW.currentPrice, NOW());
    END IF;
END //

CREATE OR REPLACE TRIGGER Before_Insert_Orderline
BEFORE INSERT ON Orderline
FOR EACH ROW
BEGIN
        SET NEW.unitPrice = (SELECT currentPrice FROM Product WHERE Product.id = NEW.product_id);
        IF NEW.quantity IS NULL THEN SET NEW.quantity=1;
        END IF;
        -- Checking if the new quantity is more than available and raising an error, if not then updating the quantity
        IF (NEW.quantity > (SELECT availableQuantity FROM Product WHERE Product.id = NEW.product_id))
                THEN SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT= 'Product quantity not enough';
        ELSE
                UPDATE Product SET availableQuantity = availableQuantity - NEW.quantity WHERE Product.id = NEW.product_id;
        END IF;
END //

CREATE OR REPLACE TRIGGER After_Insert_Orderline
AFTER INSERT ON Orderline
FOR EACH ROW
BEGIN
        UPDATE `Order`
        SET subtotal= (SELECT SUM(quantity*unitPrice) FROM Orderline WHERE order_id=NEW.order_id)
        WHERE `Order`.id=NEW.order_id;
        -- sales tax updation whenever new orderline is inserted
        UPDATE `Order`
                SET salesTax = ROUND(subtotal * (SELECT SalesTax.taxRate FROM SalesTax
                                        WHERE SalesTax.zip_code = (SELECT Customer.zip
                                                FROM Customer WHERE Customer.id = (SELECT `Order`.customer_id
                                                        FROM `Order` WHERE `Order`.id = NEW.order_id))), 2)
                WHERE id = NEW.order_id;
 -- Call the procedure to update CustomerPurchasesSummary for the affected customer
    CALL UpdateCustomerPurchases(
        (SELECT customer_id FROM `Order` WHERE id = NEW.order_id)
    );
 -- Call the procedure to update ProductBuyersSummary for the affected product
    CALL UpdateProductBuyers(NEW.product_id);

END //

CREATE OR REPLACE TRIGGER After_Update_Orderline
AFTER UPDATE ON Orderline
FOR EACH ROW
        BEGIN
                UPDATE `Order`
                SET subtotal = (SELECT SUM(quantity * unitPrice) FROM Orderline WHERE order_id = NEW.order_id)
                WHERE `Order`.id = NEW.order_id;
                -- sales tax updation whenever new orderline is updated
                UPDATE `Order`
                SET salesTax = ROUND(subtotal * (SELECT SalesTax.taxRate FROM SalesTax
                        WHERE SalesTax.zip_code= (SELECT Customer.zip FROM Customer WHERE Customer.id =( SELECT `Order`.customer_id
                        FROM `Order` WHERE `Order`.id=NEW.order_id))),2) WHERE id=NEW.order_id;
-- If the order or product changed, update the affected rows in both summary tables
                IF OLD.order_id!=NEW.order_id OR OLD.product_id!=NEW.product_id THEN
                        IF OLD.order_id!=NEW.order_id THEN
                                CALL UpdateCustomerPurchases((SELECT customer_id FROM `Order` WHERE id = OLD.order_id));
                                CALL UpdateCustomerPurchases((SELECT customer_id FROM `Order` WHERE id = NEW.order_id));
                        END IF;
                        IF OLD.product_id!=NEW.product_id THEN
                                CALL UpdateProductBuyers(OLD.product_id);
								CALL UpdateProductBuyers(NEW.product_id);
                        ELSE
                                CALL UpdateProductBuyers(NEW.product_id);
                        END IF;
                END IF;
END //

CREATE OR REPLACE TRIGGER After_Delete_Orderline
AFTER DELETE ON Orderline
FOR EACH ROW
        BEGIN
                UPDATE `Order`
                SET subtotal = subtotal - (OLD.quantity * OLD.unitPrice)
                WHERE id = OLD.order_id;
                -- sales tax updation whenever an orderline is deleted
                UPDATE `Order`
                SET salesTax = ROUND(subtotal * (SELECT SalesTax.taxRate FROM SalesTax
                        WHERE SalesTax.zip_code= (SELECT Customer.zip FROM Customer WHERE Customer.id =( SELECT `Order`.customer_id
                        FROM `Order` WHERE `Order`.id=OLD.order_id))),2) WHERE id=OLD.order_id;
 -- Update CustomerPurchasesSummary for the affected customer
    CALL UpdateCustomerPurchases(
        (SELECT customer_id FROM `Order` WHERE id = OLD.order_id)
    );
	
    -- Update ProductBuyersSummary for the affected product
    CALL UpdateProductBuyers(OLD.product_id);

END //

CREATE OR REPLACE TRIGGER Before_Update_Orderline
BEFORE UPDATE ON Orderline
FOR EACH ROW
        BEGIN
                DECLARE available_qty INT;
                DECLARE qty_diff INT;
                SELECT availableQuantity INTO available_qty FROM Product WHERE Product.id = NEW.product_id;
                SET qty_diff = NEW.quantity - OLD.quantity;
                IF available_qty < qty_diff THEN
                        SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT="Not enough product quantity available for updation";
                ELSE
                        UPDATE Product
                        SET availableQuantity = availableQuantity - qty_diff
                        WHERE Product.id = NEW.product_id;
                END IF;
END //

CREATE OR REPLACE TRIGGER Before_Delete_Orderline
BEFORE DELETE ON Orderline
FOR EACH ROW
        BEGIN
                        UPDATE Product
                        SET availableQuantity = availableQuantity + OLD.quantity
                        WHERE Product.id = OLD.product_id;
END //
CREATE PROCEDURE UpdateCustomerPurchases(IN CustomerID INT)
BEGIN
    DECLARE productList TEXT;

    -- Generate the updated product list for the customer
    SELECT GROUP_CONCAT(DISTINCT(CONCAT(Product.id, ' ', Product.name)) ORDER BY Product.id SEPARATOR '|')
    INTO productList
    FROM Customer
    LEFT JOIN `Order` ON Customer.id = `Order`.customer_id
    LEFT JOIN Orderline ON `Order`.id = Orderline.order_id
    LEFT JOIN Product ON Orderline.product_id = Product.id
    WHERE Customer.id = CustomerID
    GROUP BY Customer.id;
	
	  -- Update the summary table with the new product list
    UPDATE mv_CustomerPurchases
    SET products = productList
    WHERE "customer number" = CustomerID;
END //

CREATE PROCEDURE UpdateProductBuyers(IN PID INT)
BEGIN
    DECLARE customerList TEXT;
    -- Generate the updated customer list for the product
    SELECT GROUP_CONCAT(DISTINCT(CONCAT(Customer.id, ' ', Customer.firstName, ' ', Customer.lastName)) ORDER BY Customer.id SEPARATOR ',')
    INTO customerList
    FROM Product
    LEFT JOIN Orderline ON Product.id = Orderline.product_id
    LEFT JOIN `Order` ON Orderline.order_id = `Order`.id
    LEFT JOIN Customer ON `Order`.customer_id = Customer.id
    WHERE Product.id = PID
    GROUP BY Product.id;

    -- Update the summary table with the new customer list
    UPDATE mv_ProductBuyers
    SET customers = customerList
	  WHERE productID = PID;

END //

DELIMITER ;