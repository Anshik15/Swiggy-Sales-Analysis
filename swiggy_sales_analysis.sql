select * from swiggy_data;


-- Data Validation & Cleaning
-- Null check
select 
    SUM( Case when State is null then 1 else 0 end) as null_state,
    SUM( Case when City is null then 1 else 0 end) as null_city,
    SUM( Case when Order_Date is null then 1 else 0 end) as null_order_date,
    SUM( Case when Restaurant_Name is null then 1 else 0 end) as null_restaurant,
    SUM( Case when Location is null then 1 else 0 end) as null_location,
    SUM( Case when Category is null then 1 else 0 end) as null_Category,
    SUM( Case when Dish_Name is null then 1 else 0 end) as null_dish,
    SUM( Case when Price_INR is null then 1 else 0 end) as null_price,
    SUM( Case when Rating is null then 1 else 0 end) as null_rating,
    SUM( Case when Rating_Count is null then 1 else 0 end) as null_rating_count
From swiggy_data;


-- Blank and Empty Strings
select * from swiggy_data
where State = '' or City ='' or Restaurant_Name = '' or Location = '' or Category=''
or Dish_Name = '' ;

 
-- Duplicate Detection
Select State,
City, Order_Date, Restaurant_Name, Location, Category,Dish_Name, Price_INR,Rating, Rating_Count, count(*) as CT
from swiggy_data
group by State,
City, Order_Date, Restaurant_Name, Location, Category,Dish_Name, Price_INR,Rating, Rating_Count
having count(*) > 1;


-- Delete Duplication
with CTE as (
select *, ROW_NUMBER() over(
    PARTITION BY State,City, Order_Date, Restaurant_Name, Location, Category,Dish_Name, Price_INR,Rating, Rating_Count
    ORDER BY (select null)
) as rn
from swiggy_data
)
DELETE FROM CTE WHERE rn >1;

--Creating Schema
--Dimension table

-- DATE TABLE (dim_date)   
create table dim_date(
    date_id int identity(1,1) primary key,
    Full_Date date,
    Year int,
    Month int,
    Month_Name varchar(20),
    Quarter int,
    Day int,
    Week int
);

-- LOCATION TABLE (dim_location)
Create table dim_location(
    location_id int identity(1,1) Primary key,
    State varchar(100),
    City varchar(100),
    Location varchar(200)
);

-- RESTAURANT TABLE (dim_restaurant)
Create table dim_restaurant(
      restaurant_id int identity(1,1) Primary key,
      Restaurant_Name varchar(200)
);

-- CATEGORY TABLE (dim_category)
Create table dim_category(
      category_id int identity(1,1) Primary Key,
      Category_Name varchar(200)
);

-- DISH TABLE (dim_dish)
Create Table dim_dish(
     dish_id int identity(1,1) Primary Key,
     Dish_Name varchar(200)
);

--FACT TABLE

Create table fact_swiggy_orders (
    order_id int identity(1,1) Primary Key,

    date_id int,
    Price_INR Decimal(10,2),
    Rating Decimal(4,2),
    Rating_count int,

    location_id int,
    restaurant_id int,
    category_id int,
    dish_id int,

    Foreign Key (date_id) References dim_date(date_id),
    Foreign Key (location_id) References dim_location(location_id),
    Foreign Key (restaurant_id) References dim_restaurant(restaurant_id),
    Foreign Key (category_id) References dim_category(category_id),
    Foreign Key (dish_id) References dim_dish(dish_id)

);


--INSERT DATA IN TABLE
--dim_date
Insert Into dim_date (Full_Date,Year,Month,Month_Name,Quarter,Day,Week)
select distinct
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_date),
    DATENAME(month, Order_Date),
    DATEPART(QUARTER, Order_Date),
    DAY(Order_Date),
    DATEPART(week, Order_Date)
from swiggy_data
where Order_Date is not null;

--dim_location
Insert into dim_location (State , City, Location)
select distinct
     State,
     City,
     Location
From swiggy_data;

--dim_restaurant
Insert Into dim_restaurant(Restaurant_Name)
select distinct 
      Restaurant_Name
from swiggy_data;

--dim_category
Insert Into dim_category(Category_Name)
select distinct
       Category
from swiggy_data;

--dim_dish
Insert Into dim_dish(Dish_name)
select distinct 
       Dish_Name
from swiggy_data;


--Fact_Table
Insert Into fact_swiggy_orders
(  
     date_id,
     Price_INR,
     Rating,
     Rating_count,
     location_id,
     restaurant_id,
     category_id,
     dish_id
)

select  
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_count,

    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
from swiggy_data s

join dim_date dd
   on dd.Full_Date = s.Order_Date

join dim_location dl
   on dl.State = s.State
   AND dl.City = s. City
   AND dl.Location = s.Location

join dim_restaurant dr
   on dr.Restaurant_Name = s.Restaurant_Name

join dim_category dc
   on dc.Category_Name = s. Category
  
join dim_dish dsh
   on dsh.Dish_Name = s.Dish_Name ;



select * from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
join dim_location l on f.location_id = l.location_id
join dim_restaurant r on f.restaurant_id = r.restaurant_id
join dim_category c on f.category_id = c.category_id
join dim_dish di on f.dish_id = di.dish_id;

--KPI
-- Total Orders

select count(*) as Total_Orders
from fact_swiggy_orders;

--Total Revenue (INR Million)
select FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000, 'N2') + ' INR Million'  as Total_Revenue
from fact_swiggy_orders;

--Average Dish Price
select FORMAT(AVG(CONVERT(FLOAT,price_INR)), 'N2') + ' INR'  
as Average_Dish_Price
from fact_swiggy_orders;

--Average Reating
Select AVG(Rating)
as Average_Rating
from fact_swiggy_orders;


--Deep-Dive Bussiness Analysis
--Month Order Trends
select
d.year,
d.month,
d.month_name,
count(*) as Total_Orders
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
Group by d.year,d.month, d.month_name
order by count(*) desc;

-- Quaterly Trend
select
d.year,
d.Quarter,
count(*) as Total_Orders
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
Group by d.year,d.Quarter
order by count(*) desc;

-- Yearly Trends
select
d.year,
count(*) as Total_Orders
from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
Group by d.year
order by count(*) desc;

--Orders by Day of Week (Mon-Sun)
select
     DATENAME(WeekDAY, d.full_date) as Day_name,
     COUNT(*) as Total_Orders
FROM fact_swiggy_orders f
Join dim_date d on f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date), DATEPART (WEEKDAY, d.Full_Date)
order by DATEPART(WEEKDAY, d.Full_Date);

--Top 10 Cities by order volume
select  top 10
l.city,
count(*) as Total_orders from fact_swiggy_orders f
join dim_location l
on l.location_id = f.location_id
group by l.city
order by count(*) desc;

--Top 10 Cities by Total Revenue
select  top 10
l.city,
sum(f.price_INR) as Total_Revenue from fact_swiggy_orders f
join dim_location l
on l.location_id = f.location_id
group by l.city
order by count(*) desc;

--Revenue contribution by statesselect  top 10
select 
l.state,
sum(f.price_INR) as Total_Revenue from fact_swiggy_orders f
join dim_location l
on l.location_id = f.location_id
group by l.state
order by count(*) desc;

--Top 10 restaurants by orders
select top 10
r.restaurant_name,
sum(f.price_INR) as Total_Revenue from fact_swiggy_orders f
join dim_restaurant r
on r.restaurant_id = f.restaurant_id
group by r.restaurant_name
order by count(*) desc;

--Top Categories by Order Volume
Select 
    c.Category_Name,
    count(*) as total_orders
from fact_swiggy_orders f
join dim_category c on f.category_id = c.category_id
group by c.Category_Name
order by total_orders desc;

--Most Ordered Dishes
Select
    d.dish_name,
    count(*) as order_count
from fact_swiggy_orders f
join dim_dish d on f.dish_id = d.dish_id
group by d.dish_name
order by order_count desc;

--Cuisine Performance (Orders + Avg Rating)
Select 
    c.Category_Name,
    COUNT(*) as total_orders,
    AVG(f.rating) as avg_rating
from fact_swiggy_orders f
join dim_category c on f.category_id = c.category_id
group by c.Category_Name
order by total_orders desc;

--Total Orders by Price range
Select 
   Case
       When convert (FLOAT, Price_INR) < 100 Then 'Under 100'
       When CONVERT (FLOAT , Price_INR) between 100 and 199 then '100-199'
       When CONVERT (FLOAT, Price_INR) between 200 and 299 then '200-299'
       When CONVERT (FLOAT, Price_INR) between 300 and 499 then '300-499'
       Else '500+'
    End as Price_Range,
    Count(*) as Total_Orders
from fact_swiggy_orders
Group By 
    Case
       When convert (FLOAT, Price_INR) < 100 Then 'Under 100'
       When CONVERT (FLOAT , Price_INR) between 100 and 199 then '100-199'
       When CONVERT (FLOAT, Price_INR) between 200 and 299 then '200-299'
       When CONVERT (FLOAT, Price_INR) between 300 and 499 then '300-499'
       Else '500+'
    End
Order by Total_Orders DESC;


-- Rating Count Distribution (1 - 5)
Select
     rating,
     count(*) as rating_count
from fact_swiggy_orders
Group by Rating
order by Rating desc;