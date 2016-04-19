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

Meeting.create(location: "Aangan Thai", city: "Melbourne", lunchdate: "2016-04-19", user_id: 7, mentor_id: 2)
Meeting.create(location: "Danelis", city: "Sydney", lunchdate: "2016-04-25", user_id: 8, mentor_id: 2)

User.create(name: "Test 1", city: "Sydney", password: "test", skills: "PPC", email: "test1@gmail.com", role: "Mentor")
User.create(name: "Test 2", city: "Melbourne", password: "test", skills: "PPC", email: "test2@gmail.com", role: "User")

CREATE TABLE comments (
  id SERIAL4 PRIMARY KEY,
  body VARCHAR(50) NOT NULL,
  dish_id INTEGER
);
