CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Create tables

-- brand table
CREATE TABLE brand (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- product_category table
CREATE TABLE product_category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- product table
CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    brand_id INT,
    category_id INT,
    base_price DECIMAL(10,2),
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id),
    FOREIGN KEY (category_id) REFERENCES product_category(category_id)
);

-- product_image table
CREATE TABLE product_image (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    image_url TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- color table
CREATE TABLE color (
    color_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    hex_value VARCHAR(7)
);

-- size_category table
CREATE TABLE size_category (
    size_category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

-- size_option table
CREATE TABLE size_option (
    size_option_id INT PRIMARY KEY AUTO_INCREMENT,
    size_category_id INT,
    label VARCHAR(10),
    FOREIGN KEY (size_category_id) REFERENCES size_category(size_category_id)
);

-- product_variation table
CREATE TABLE product_variation (
    variation_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    color_id INT,
    size_option_id INT,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (color_id) REFERENCES color(color_id),
    FOREIGN KEY (size_option_id) REFERENCES size_option(size_option_id)
);

-- product_item table
CREATE TABLE product_item (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    variation_id INT,
    price_override DECIMAL(10,2),
    FOREIGN KEY (variation_id) REFERENCES product_variation(variation_id)
);

-- attribute_type table
CREATE TABLE attribute_type (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

-- attribute_category table
CREATE TABLE attribute_category (
    attribute_category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

-- product_attribute table
CREATE TABLE product_attribute (
    attribute_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    attribute_category_id INT,
    attribute_type_id INT,
    name VARCHAR(100),
    value VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (attribute_category_id) REFERENCES attribute_category(attribute_category_id),
    FOREIGN KEY (attribute_type_id) REFERENCES attribute_type(type_id)
);

-- Insert sample data

-- brand
INSERT INTO brand (name) VALUES ('Samsung'), ('Nike'), ('Apple');

-- product_category
INSERT INTO product_category (name, description) 
VALUES ('Smartphones', 'Mobile phones with smart features'),
       ('Footwear', 'Shoes and related products');

-- product
INSERT INTO product (name, brand_id, category_id, base_price)
VALUES ('Galaxy S23', 1, 1, 800.00),
       ('Nike Air Max', 2, 2, 150.00),
       ('iPhone 15', 3, 1, 1200.00);

-- product_image
INSERT INTO product_image (product_id, image_url)
VALUES (1, 'images/galaxy_s23.jpg'),
       (2, 'images/nike_airmax.jpg'),
       (3, 'images/iphone_15.jpg');

-- color
INSERT INTO color (name, hex_value)
VALUES ('Black', '#000000'), ('White', '#FFFFFF'), ('Red', '#FF0000');

-- size_category
INSERT INTO size_category (name)
VALUES ('Clothing Size'), ('Shoe Size');

-- size_option
INSERT INTO size_option (size_category_id, label)
VALUES (1, 'M'), (1, 'L'), (2, '42'), (2, '44');

-- product_variation
INSERT INTO product_variation (product_id, color_id, size_option_id, stock_quantity)
VALUES (1, 1, 1, 50),
       (2, 3, 3, 30),
       (3, 2, 1, 20);

-- product_item
INSERT INTO product_item (variation_id, price_override)
VALUES (1, NULL),
       (2, 140.00),
       (3, NULL);

-- attribute_type
INSERT INTO attribute_type (name)
VALUES ('Text'), ('Number'), ('Boolean');

-- attribute_category
INSERT INTO attribute_category (name)
VALUES ('Technical'), ('Physical');

-- product_attribute
INSERT INTO product_attribute (product_id, attribute_category_id, attribute_type_id, name, value)
VALUES (1, 1, 1, 'Processor', 'Snapdragon 8 Gen 2'),
       (2, 2, 1, 'Material', 'Leather'),
       (3, 1, 1, 'Processor', 'A16 Bionic');

--  users & assign privileges

CREATE USER 'ecom_admin'@'localhost' IDENTIFIED BY 'adminpass';
CREATE USER 'ecom_viewer'@'localhost' IDENTIFIED BY 'viewerpass';

-- Grant privileges
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'ecom_admin'@'localhost';
GRANT SELECT ON ecommerce_db.* TO 'ecom_viewer'@'localhost';

FLUSH PRIVILEGES;



-- INNER JOIN: List products with their brand and category
SELECT p.name AS product_name, b.name AS brand_name, c.name AS category_name
FROM product p
INNER JOIN brand b ON p.brand_id = b.brand_id
INNER JOIN product_category c ON p.category_id = c.category_id;

-- LEFT JOIN: Show all products and their variations (even if none exists)
SELECT p.name, pv.stock_quantity
FROM product p
LEFT JOIN product_variation pv ON p.product_id = pv.product_id;

-- RIGHT JOIN: Show all colors and the products that use them
SELECT c.name AS color, p.name AS product
FROM product_variation pv
RIGHT JOIN color c ON pv.color_id = c.color_id
LEFT JOIN product p ON pv.product_id = p.product_id;

-- GROUP BY: Count products per brand
SELECT b.name AS brand_name, COUNT(p.product_id) AS total_products
FROM brand b
LEFT JOIN product p ON p.brand_id = b.brand_id
GROUP BY b.brand_id;

-- ORDER BY: List products by price descending
SELECT name, base_price
FROM product
ORDER BY base_price DESC;

-- Aggregate: Total stock per product
SELECT p.name, SUM(pv.stock_quantity) AS total_stock
FROM product p
LEFT JOIN product_variation pv ON p.product_id = pv.product_id
GROUP BY p.product_id;
