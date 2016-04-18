CREATE DATABASE lunch;

\c lunch

CREATE TABLE users (
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(50),
  city VARCHAR(50),
  email VARCHAR(100)
);

CREATE TABLE mentors (
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(50),
  city VARCHAR(50),
  email VARCHAR(100),
  skills VARCHAR(500)
);

CREATE TABLE meetings (
  id SERIAL4 PRIMARY KEY,
  location VARCHAR(50),
  city VARCHAR(50),
  lunchDate DATE,
  user_id INTEGER,
  mentor_id INTEGER
);

ALTER TABLE users
ADD password VARCHAR(50)


SELECT * FROM dishes;

INSERT INTO dishes (name, image_url) VALUES ('Chicken', 'http://images.wisegeek.com/cooked-chicken.jpg')


CREATE TABLE comments (
  id SERIAL4 PRIMARY KEY,
  body VARCHAR(50) NOT NULL,
  dish_id INTEGER
);
