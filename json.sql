further affirm that I have not and will not provide this code to any person, platform, or repository,
without the express written permission of Dr. Gomillion. I understand that any violation of these
standards will have serious repercussions. */

SOURCE views.sql

SELECT JSON_ARRAYAGG(
           JSON_OBJECT(
               'Customer Name', CONCAT(c.FirstName, ' ', c.LastName),
               'Full Address', CONCAT(
                   c.Address1,
                   IF(c.Address2 IS NOT NULL AND c.Address2 <> '', CONCAT('\n', c.Address2), ''),
                   CONCAT('\n', c1.City, ', ', c1.State, ' ', c1.Zip)
               )
           )
       ) AS JSON_Array
FROM Customer c
JOIN City c1 ON c.Zip = c1.Zip
INTO OUTFILE '/var/lib/mysql/POS/cust1.json'
FIELDS TERMINATED BY ''
ESCAPED BY ''
;

SELECT 
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'ProductID', p.id,
            'Product Name', p.name,
            'Current Price', p.currentPrice,
            'Customers', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'CustomerID', c.id,
                        'Customer Name', CONCAT(c.firstName, ' ', c.lastName)
                    )
                )
                FROM Customer c
                JOIN `Order` o ON o.customer_id = c.id
                JOIN Orderline ol ON ol.order_id = o.id
                WHERE ol.product_id = p.id
            )
        )
    ) AS JSON_Array
FROM 
    Product p
INTO OUTFILE '/var/lib/mysql/POS/prod.json'
FIELDS TERMINATED BY '' 
ESCAPED BY ''
;


SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'orderId', o.id,
        'datePlaced', o.datePlaced,
        'dateShipped', o.dateShipped,
        'buyer', JSON_OBJECT(
            'customerId', c.id,
            'name', CONCAT(c.firstName, ' ', c.lastName),
            'email', c.email
        ),
        'products', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'productId', p.id,
                    'name', p.name,
                    'quantity', ol.quantity,
                    'currentPrice', p.currentPrice
                )
            )
            FROM Orderline ol
            JOIN Product p ON ol.product_id = p.id
            WHERE ol.order_id = o.id
        )
    )
) AS JSON_ARRAY
FROM `Order` o
JOIN Customer c ON o.customer_id = c.id
INTO OUTFILE 'ord.json'

SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'Customer Name', CONCAT(c.FirstName, ' ', c.LastName),
        'Full Address', CONCAT('\n',
            c.Address1,
            IF(c.Address2 IS NOT NULL AND c.Address2 <> '', CONCAT('\n', c.Address2), ''),
            CONCAT('\n', c1.City, ', ', c1.State, ' ', c1.Zip)
        ),
        'Orders', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'Order Total', (
                        SELECT SUM(ol2.quantity * p2.currentPrice)
                        FROM Orderline ol2
                        JOIN Product p2 ON ol2.product_id = p2.id
                        WHERE ol2.order_id = o.id
                    ),
                    'Order Date', o.datePlaced,
                    'Shipping Date', o.dateShipped,
                    'Items', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'Product ID', p.id,
                                'Quantity', ol.quantity,
                                'Product Name', p.name
                            )
                        )
                        FROM Orderline ol
                        JOIN Product p ON ol.product_id = p.id
                        WHERE ol.order_id = o.id
                    )
                )
            )
            FROM `Order` o
            WHERE o.customer_id = c.id
        )
    )
) AS JSON_Array
FROM Customer c
JOIN City c1 ON c.Zip = c1.Zip
INTO OUTFILE '/var/lib/mysql/POS/cust2.json'
FIELDS TERMINATED BY ''
ESCAPED BY ''

-- QUESTION:For each product, what is its sales history, including the order details and revenue from each sale?
-- The final JSON output, saved as `custom.json`, provides a complete summary of each product along with its related sales records
SELECT 
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'productId', p.id,
            'productName', p.name,
            'currentPrice', p.currentPrice,
            'salesHistory', salesHistory.salesHistory
        )
    ) AS products
FROM Product p
JOIN (
    SELECT 
        ol.product_id,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'orderId', o.id,
                'orderDate', o.datePlaced,
                'quantity', ol.quantity,
                'totalPrice', ol.quantity * p.currentPrice
            )
        ) AS salesHistory
    FROM Orderline ol
    JOIN `Order` o ON ol.order_id = o.id
    JOIN Product p ON ol.product_id = p.id
    GROUP BY ol.product_id
) AS salesHistory ON p.id = salesHistory.product_id
INTO OUTFILE '/var/lib/mysql/POS/custom.json';
