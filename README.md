# Amazon E-commerce Data Pipeline & Analytics

This project is an end-to-end data engineering and analytics pipeline built with a Kaggle Amazon e-commerce dataset.

The goal of the project is to load raw CSV data into SQL Server, validate the staging data, transform it into a clean reporting table, and create SQL views for business analysis and dashboarding.

## Project Overview

The pipeline follows this structure:

```text
Kaggle CSV
→ Python batch loader
→ SQL Server staging table
→ Data quality checks
→ Clean typed table
→ Stored procedure
→ Pipeline run log
→ Reporting views
→ Optional Power BI dashboard
```

## Tech Stack

- Python
- pandas
- mssql-python
- SQL Server
- T-SQL
- Git / GitHub
- Power BI *(optional future step)*

## Dataset

The dataset used in this project is an Amazon e-commerce dataset from Kaggle.

The raw CSV file is not included in this repository. To run the project locally, download the dataset from Kaggle and place it in:

```text
data/raw/
```

## Data Columns

The raw dataset contains the following fields:

```text
user_id
product_id
category
subcategory
brand
price
discount
final_price
rating
review_count
stock
seller_id
seller_rating
purchase_date
shipping_time_days
location
device
payment_method
is_returned
delivery_status
```

## Project Structure

```text
amazon-ecommerce-data-pipeline/
│
├── data/
│   ├── raw/                   # raw CSV files, ignored by git
│
├── scripts/
│   └── load_csv_to_sql.py      # Python batch loader
│
├── sql/
│   ├── 01_create_staging_table.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_create_clean_tables.sql
│   ├── 04_load_clean_tables.sql
│   └── 05_reporting_views.sql
│
├── .gitignore
└── README.md
```

## Pipeline Steps

### 1. Raw CSV Loading

The Kaggle CSV is loaded into SQL Server using a Python script.

The loader:

- reads the CSV with pandas
- connects to SQL Server using a connection string from `.env`
- loads the data into the staging table in batches
- prints progress while loading

The staging table stores all columns as `VARCHAR` to preserve the raw data exactly as it arrives.

### 2. Staging Table

The staging table is:

```text
stg_amazon_orders
```

This table is used as the raw landing layer.

All columns are stored as text first, because raw data should be validated before being converted into proper data types.

### 3. Data Quality Checks

Before loading into the clean table, several quality checks are performed on the staging data.

Checks include:

- total row count
- missing required values
- empty strings
- type conversion issues
- invalid numeric values
- invalid date values
- invalid rating ranges
- negative prices, stock, shipping days, or review counts
- duplicate-looking transaction records
- consistency between `delivery_status` and `is_returned`

The dataset was found to be largely clean, with no major quality issues detected during the implemented checks.

### 4. Clean Table

Validated data is inserted into:

```text
clean_amazon_orders
```

This table uses proper data types such as:

- `DECIMAL` for prices, discounts, and ratings
- `INT` for counts and shipping days
- `DATE` for purchase dates
- `BIT` for returned orders

The clean table is the trusted source for reporting.

### 5. Stored Procedure

A stored procedure is used to reload the clean table from staging:

```text
usp_InsertCleanAmazonOrders
```

The procedure:

- clears the clean table
- inserts validated and converted data from staging
- applies business rules
- writes a run record into the pipeline log table

### 6. Pipeline Run Log

Pipeline executions are logged in:

```text
pipeline_run_log
```

The log stores:

- procedure name
- run start time
- run finish time
- staging row count
- clean row count
- run status

This makes the project closer to a real-world data pipeline, where pipeline runs are monitored and auditable.

### 7. Reporting Views

The project includes SQL views for analytics and dashboarding:

```text
vw_sales_performance
vw_category_revenue
vw_brand_performance
vw_customer_behavior
vw_return_analysis
vw_seller_performance
vw_pipeline_summary
```

These views support analysis of:

- monthly sales performance
- revenue by category and subcategory
- brand performance
- customer behavior by location, device, and payment method
- return rates
- seller performance
- pipeline execution history

## Example Business Questions

This project can answer questions such as:

- How does revenue change over time?
- Which categories generate the most revenue?
- Which brands have the highest return rates?
- Which devices or payment methods are used most often?
- Which sellers have the highest delay rate?
- Are returned orders consistent with delivery status?
- How many rows were loaded during each pipeline run?

## Current Status

Completed:

- Project repository setup
- SQL Server staging table
- Python batch CSV loader
- Data quality checks
- Clean typed table
- Stored procedure for clean data loading
- Pipeline run logging
- Reporting views

Planned improvements:

- Add Power BI dashboard
- Add screenshots of SQL results and dashboard pages
- Add more advanced data quality logging
- Add dimensional model tables
- Add incremental loading logic

## How to Run Locally

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd amazon-ecommerce-data-pipeline
```

### 2. Create a `.env` file

Create a `.env` file in the project root.

Example:

```env
SQL_CONNECTION_STRING=Server=localhost;Database=amazon_ecommerce_project;Trusted_Connection=yes;TrustServerCertificate=yes;
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Add the raw dataset

Download the Kaggle CSV and place it in:

```text
data/raw/
```

### 5. Run the SQL setup scripts

Run the SQL scripts in order:

```text
01_create_staging_table.sql
02_data_quality_checks.sql
03_create_clean_tables.sql
04_load_clean_tables.sql
05_reporting_views.sql
```

### 6. Run the Python loader

```bash
python scripts/load_csv_to_sql.py
```

### 7. Execute the clean load procedure

In SQL Server:

```sql
EXEC dbo.usp_InsertCleanAmazonOrders;
```

## Notes

The raw dataset and `.env` file are intentionally excluded from GitHub.

This keeps the repository clean and avoids committing local data files or private connection details.
