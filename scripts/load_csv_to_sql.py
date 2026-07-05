import pandas as pd
from os import getenv
from dotenv import load_dotenv
from mssql_python import connect

load_dotenv()

csv_path = "data/raw/amazon_ecommerce_1M.csv"
chunk_size = 5000

conn = connect(getenv("SQL_CONNECTION_STRING"))
cursor = conn.cursor()

cursor.execute("DELETE FROM stg_amazon_orders")
conn.commit()

insert_sql = """
INSERT INTO stg_amazon_orders (
    user_id,
    product_id,
    category,
    subcategory,
    brand,
    price,
    discount,
    final_price,
    rating,
    review_count,
    stock,
    seller_id,
    seller_rating,
    purchase_date,
    shipping_time_days,
    location,
    device,
    payment_method,
    is_returned,
    delivery_status
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"""

total_loaded = 0

for chunk in pd.read_csv(csv_path, chunksize=chunk_size):
    rows = [tuple(row) for _, row in chunk.iterrows()]

    cursor.executemany(insert_sql, rows)
    conn.commit()

    total_loaded += len(chunk)
    print(f"Loaded {total_loaded} rows...")

cursor.close()
conn.close()

print(f"Finished loading {total_loaded} rows into stg_amazon_orders")