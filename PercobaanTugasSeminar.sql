CREATE DATABASE restaurant_reviews;

CREATE TABLE restaurant (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    description TEXT
);

restaurant_id INTEGER REFERENCES restaurant(id) ON DELETE CASCADE

CREATE TABLE review (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE NOT NULL,
    FOREIGN KEY (restaurant_id)
        REFERENCES restaurant(id)
        ON DELETE CASCADE
);

INSERT INTO restaurant (name, street_address, description)
VALUES
('Warung Nusantara', 'Jl. Merdeka No. 10', 'Restaurant yang menyajikan berbagai makanan khas Indonesia.'),
('Sakura Ramen', 'Jl. Sudirman No. 25', 'Restaurant Jepang dengan berbagai pilihan ramen dan makanan Jepang.'),
('Burger Corner', 'Jl. Diponegoro No. 15', 'Restaurant yang menyajikan burger dan makanan cepat saji.'),
('Pasta House', 'Jl. Ahmad Yani No. 30', 'Restaurant dengan berbagai pilihan pasta dan makanan Italia.');

SELECT * FROM restaurant;

INSERT INTO review 
(restaurant_id, user_name, rating, review_text, review_date)
VALUES
(1, 'Andi', 5, 'Makanannya enak dan porsinya cukup besar.', '2026-09-01'),
(1, 'Sinta', 4, 'Rasanya enak dan tempatnya nyaman.', '2026-09-03'),
(2, 'Budi', 5, 'Ramen sangat enak dan kuahnya gurih.', '2026-09-02'),
(2, 'Rina', 4, 'Pelayanan cukup cepat dan makanannya enak.', '2026-09-05'),
(3, 'Doni', 3, 'Burger cukup enak tetapi agak mahal.', '2026-09-04'),
(3, 'Maya', 5, 'Burgernya enak dan porsinya pas.', '2026-09-06'),
(4, 'Fajar', 4, 'Pasta memiliki rasa yang cukup autentik.', '2026-09-07');

SELECT * FROM review;

INSERT INTO restaurant 
(name, street_address, description)
VALUES
('Coffee Garden', 'Jl. Pemuda No. 45', 'Cafe dan restaurant dengan suasana taman yang nyaman.');

SELECT * FROM restaurant;

INSERT INTO review
(restaurant_id, user_name, rating, review_text, review_date)
VALUES
(
    (SELECT id FROM restaurant WHERE name = 'Coffee Garden'),
    'Nadia',
    5,
    'Tempatnya nyaman dan makanannya enak.',
    '2026-09-08'
);

SELECT * FROM review WHERE restaurant_id = 1;

SELECT * FROM review WHERE rating >= 4;

SELECT
    r.name AS restaurant_name,
    r.street_address,
    rv.user_name,
    rv.rating,
    rv.review_text,
    rv.review_date
FROM restaurant AS r
JOIN review AS rv
    ON r.id = rv.restaurant_id
ORDER BY r.id, rv.review_date;

UPDATE restaurant 
SET description = 'Restaurant dengan berbagai makanan khas Indonesia dan suasana yang nyaman.'
WHERE name = 'Warung Nusantara';

SELECT * FROM restaurant WHERE name = 'Warung Nusantara';

UPDATE review SET rating = 4 WHERE id = 5;

SELECT * FROM review WHERE id = 5;

DELETE FROM review WHERE id = 6;

SELECT * FROM review;

DELETE FROM restaurant WHERE name = 'Coffee Garden';

SELECT * FROM review;

SELECT * FROM restaurant;

SELECT
    r.id,
    r.name,
    AVG(rv.rating) AS average_rating
FROM restaurant AS r
JOIN review AS rv
    ON r.id = rv.restaurant_id
GROUP BY r.id, r.name
ORDER BY average_rating DESC
LIMIT 1;

SELECT
    r.id,
    r.name,
    COUNT(rv.id) AS total_reviews
FROM restaurant AS r
LEFT JOIN review AS rv
    ON r.id = rv.restaurant_id
GROUP BY r.id, r.name
ORDER BY total_reviews DESC;

SELECT
    restaurant_name,
    user_name,
    rating,
    review_text,
    review_date
FROM (
    SELECT
        r.name AS restaurant_name,
        rv.user_name,
        rv.rating,
        rv.review_text,
        rv.review_date,
        ROW_NUMBER() OVER (
            PARTITION BY r.id
            ORDER BY rv.review_date DESC
        ) AS rn
    FROM restaurant AS r
    JOIN review AS rv
        ON r.id = rv.restaurant_id
) AS latest_reviews
WHERE rn = 1;

CREATE TABLE menu (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (restaurant_id)
        REFERENCES restaurant(id)
        ON DELETE CASCADE
);

INSERT INTO menu (restaurant_id, item_name, price)
VALUES
-- Warung Nusantara
(1, 'Nasi Goreng', 25000),
(1, 'Ayam Bakar', 30000),
(1, 'Soto Ayam', 22000),

-- Sakura Ramen
(2, 'Chicken Ramen', 40000),
(2, 'Beef Ramen', 45000),
(2, 'Gyoza', 25000),

-- Burger Corner
(3, 'Classic Burger', 35000),
(3, 'Cheese Burger', 40000),
(3, 'French Fries', 20000),

-- Pasta House
(4, 'Spaghetti Carbonara', 45000),
(4, 'Fettuccine Alfredo', 48000),
(4, 'Lasagna', 50000);

SELECT
    r.name AS restaurant_name,
    m.item_name,
    m.price,
    AVG(rv.rating) AS average_rating
FROM restaurant AS r
JOIN menu AS m
    ON r.id = m.restaurant_id
LEFT JOIN review AS rv
    ON r.id = rv.restaurant_id
GROUP BY
    r.id,
    r.name,
    m.id,
    m.item_name,
    m.price
ORDER BY r.name, m.id;

