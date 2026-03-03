#  Swiggy Sales Analysis – SQL Data Analytics Project  

## 📌 Project Overview  
This project performs end-to-end sales analysis on Swiggy food delivery data using SQL.  
The objective was to transform raw transactional data into a clean, analytics-ready structure using dimensional modelling and generate meaningful business insights.

The project simulates a real-world Data Analyst workflow:
Data Cleaning → Data Validation → Star Schema Modelling → KPI Development → Business Insights

## 🧹 Data Cleaning & Validation  

The raw table `swiggy_data` contained food delivery records across states, cities, restaurants, cuisines, dishes, pricing, and ratings.

Data quality steps performed:

- Null value checks on critical fields  
- Blank/empty string validation  
- Duplicate detection using grouping logic  
- Duplicate removal using `ROW_NUMBER()` window function  

These steps ensured accuracy and reliability before analysis.

---

## 🏗️ Dimensional Modelling (Star Schema)

To optimize analytical queries and reporting performance, the dataset was transformed into a Star Schema.

### Dimension Tables
- `dim_date` (Year, Month, Quarter, Week)
- `dim_location` (State, City, Location)
- `dim_restaurant`
- `dim_category` (Cuisine)
- `dim_dish`

### Fact Table
- `fact_swiggy_orders`
  - Price_INR
  - Rating
  - Rating_Count
  - Foreign keys referencing all dimensions

This structure improves query efficiency, reduces redundancy, and supports scalable analytics.

---

## 📊 KPI Development & Business Analysis  

After modelling, the following metrics were generated:

### Core KPIs
- Total Orders  
- Total Revenue (INR Million)  
- Average Dish Price  
- Average Rating  

### Analytical Insights
- Monthly, Quarterly & Year-wise order trends  
- Day-of-week ordering patterns  
- Top 10 cities by order volume  
- Revenue contribution by state  
- Top-performing restaurants  
- Most ordered dishes & cuisine performance  
- Customer spending segmentation (Under 100 to 500+)  
- Ratings distribution analysis (1–5 scale)

---

## 🛠️ Tech Stack  
SQL | Joins | Aggregations | Window Functions | Dimensional Modelling  

---

## 🎯 Key Outcomes  

- Built a clean, analytics-ready data model from raw data  
- Applied data warehousing concepts (Star Schema)  
- Generated business-driven KPIs using SQL  
- Strengthened analytical and problem-solving skills  
