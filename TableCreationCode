-- Create table and them import the data
-- Here I manually created each row and column for each table before importing the raw data into them

-- tables include city,city_name,sales and products

create table city(
city_id int,
city_name varchar(100),
population int,
estimated_rent int,
city_rank int);

create table customer(
customer_id int,
customer_name varchar(100),
city_id int);

create table sales(
sales_id int,
sale_date date,
product_id int,
customer_id int,
toatl int,
rating int);

create table product(
product_id int,
product_name varchar(225),
price int);


select *
from sales;

-- Learning how alter works
alter table sales
rename column toatl to total;

-- making of primary and foreign keys
alter table city
add primary key(city_id);

alter table customer
add primary key(customer_id);

alter table product
add primary key(product_id);

alter table customers
add constraint fk_city foreign key (city_id) references city(city_id);

alter table sales
add constraint fk_products foreign key (product_id) references product(product_id);

alter table sales
add constraint fk_customer foreign key (customer_id) references customers(customer_id);

alter table customer
rename to customers;
-- end of success

-- Importing of data
-- first import the parent data where there is primary key that is city and product
