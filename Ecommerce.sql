CREATE DATABASE ecommerce_db;
USE ecommerce_db;
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(50),
    city VARCHAR(50),
    registration_date DATE 
);
ALTER TABLE customers
ADD COLUMN state VARCHAR(50) AFTER city;

CREATE TABLE categories(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    quantity INT,
    order_id INT,
    product_id INT,
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);

SHOW TABLES;
DESCRIBE customers;
DESCRIBE orders;
DESCRIBE products;
DESCRIBE categories;
DESCRIBE order_details;

INSERT INTO categories
VALUES
(1,'Electronics'),
(2,'Fashion'),
(3,'Home Appliances'),
(4,'Books'),
(5,'Sports');

INSERT INTO customers
VALUES
(1,'Arpita Khadd','Female','Kolhapur','Maharashtra','2025-01-15'),
(2,'Rahul Sharma','Male','Pune','Maharashtra','2025-02-10'),
(3,'Priya Patel','Female','Ahmedabad','Gujarat','2025-02-18'),
(4,'Amit Kumar','Male','Delhi','Delhi','2025-03-05'),
(5,'Sneha Joshi','Female','Mumbai','Maharashtra','2025-03-20'),
(6,'Rohan Verma','Male','Bangalore','Karnataka','2025-04-12'),
(7,'Neha Singh','Female','Lucknow','Uttar Pradesh','2025-04-25'),
(8,'Karan Mehta','Male','Jaipur','Rajasthan','2025-05-02'),
(9,'Pooja Gupta','Female','Indore','Madhya Pradesh','2025-05-10'),
(10,'Vikas Patil','Male','Nagpur','Maharashtra','2025-05-15');

INSERT INTO products
VALUES
(101,'Laptop',1,55000),
(102,'Smartphone',1,30000),
(103,'Headphones',1,2500),
(104,'T-Shirt',2,800),
(105,'Jeans',2,1500),
(106,'Microwave',3,12000),
(107,'Mixer Grinder',3,3500),
(108,'SQL Book',4,600),
(109,'Python Book',4,750),
(110,'Cricket Bat',5,2500);

INSERT INTO orders
VALUES
(1001,1,'2025-06-01',57500),
(1002,2,'2025-06-02',30000),
(1003,3,'2025-06-03',3300),
(1004,4,'2025-06-04',12000),
(1005,5,'2025-06-05',1400),
(1006,6,'2025-06-06',2500),
(1007,7,'2025-06-07',55750),
(1008,8,'2025-06-08',3500),
(1009,9,'2025-06-09',600),
(1010,10,'2025-06-10',2500);

INSERT INTO order_details
VALUES
(1,1,1001,101),
(2,1,1001,103),
(3,1,1002,102),
(4,1,1003,104),
(5,1,1003,105),
(6,1,1004,106),
(7,1,1005,104),
(8,1,1005,108),
(9,1,1006,110),
(10,1,1007,101),
(11,1,1007,109),
(12,1,1008,107),
(13,1,1009,108),
(14,1,1010,110);

SELECT * FROM customers;
SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_details;

#TOTAL SPENDING
SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_spend
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_spend DESC;

#TOTAL_ORDERS
SELECT customer_name,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

#Total units sold
SELECT product_name,
       SUM(quantity) AS units_sold
FROM productS p
JOIN order_details od
ON p.product_id = od.product_id
GROUP BY product_name
ORDER BY units_sold DESC;

#REVINUE
SELECT category_name,
	 SUM(price*quantity) AS revinue
FROM products p
JOIN order_details od
ON p.product_id = od.product_id

JOIN categories c
ON p.category_id = c.category_id
GROUP BY category_name
ORDER BY revinue DESC;

#TOP 3 SPENDING CUSTOMERS
SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_spend
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_spend DESC LIMIT 3;    #LIMIT 1 OFFSET 1 FOR SECOND HIGHEST LIMIT RETURNS ROWS AND OFFSET SKIPS ROWS

#CUSTOMER RANK
SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_spent,
    RANK() OVER(
        ORDER BY SUM(o.total_amount) DESC
    ) AS customer_rank
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

#Average Of Order Value (AOV)
SELECT
    SUM(total_amount) AS total_revenue,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) / COUNT(order_id) AS AOV
FROM orders;

#Category Contribution %
SELECT
    c.category_name,
    SUM(p.price * od.quantity) AS revenue,
    (        SUM(p.price * od.quantity)
        /
        (   SELECT SUM(p2.price * od2.quantity)
            FROM products p2
            JOIN order_details od2
            ON p2.product_id = od2.product_id  )
    ) * 100 AS contribution_percentage
FROM products p
JOIN order_details od
ON p.product_id = od.product_id
JOIN categories c
ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY contribution_percentage DESC;