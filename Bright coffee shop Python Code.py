Importing Libraries


[ ]
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
Upload the File


[ ]
df = pd.read_csv("/content/Bright Coffee Shop Sales.csv", sep=";")

[ ]
display(df)
Data Cleaning


[ ]
df.columns

[ ]
df.info()

[ ]
#checking for duplicates
df.duplicated().sum()

[ ]
# Convert 'transaction_time' and 'transaction_date' to datetime format
df['transaction_time'] = pd.to_datetime(df['transaction_time'])
df['transaction_date'] = pd.to_datetime(df['transaction_date'])

[ ]
# Convert 'unit_price' to float, fixing any comma issues (e.g., '3,1' → 3.1)
df['unit_price'] = df['unit_price'].replace(',', '.', regex=True).astype(float)

[ ]
# Fill missing values (example: replacing NaNs with 0 or mode values)
df.fillna(value={"transaction_qty": 0, "unit_price": df['unit_price'].median()}, inplace=True)

[ ]
# Check for missing values
print(df.isnull())

[ ]
#checking for duplicates
df.duplicated().sum()

[ ]
# Create 'transaction_time_bucket' with 30-minute intervals (or modify for 1 hour)
df['transaction_time_bucket'] = df['transaction_time'].dt.floor('1h')

[ ]
# Compute 'total_amount'
df['total_amount'] = df['unit_price'] * df['transaction_qty']

[ ]
# Aggregate revenue by product type
product_revenue = df.groupby('product_type')['total_amount'].sum().reset_index()
product_revenue = product_revenue.sort_values(by='total_amount', ascending=False)

# Plot bar chart
plt.figure(figsize=(10, 5))
sns.barplot(x='total_amount', y='product_type', data=product_revenue, palette='pastel')
plt.xlabel("Total Revenue (R)", fontsize=12)
plt.ylabel("Product Type", fontsize=12)
plt.title("Top Revenue-Generating Products", fontsize=14, fontweight='bold')
plt.show()


[ ]
#time bucket
def categorize_time_of_day(hour):
    if 6 <= hour <= 9:
        return 'Early Morning'
    elif 10 <= hour <= 13:
        return 'Mid-Morning'
    elif 14 <= hour <= 17:
        return 'Afternoon'
    elif 18 <= hour <= 20:
        return 'Evening'
    else:
        return 'Unknown'

[ ]
# Aggregate sales by transaction time buckets
time_bucket_sales = df.groupby('transaction_time_bucket')['total_amount'].sum().reset_index()

# Plot line chart
plt.figure(figsize=(12, 6))
sns.lineplot(x='transaction_time_bucket', y='total_amount', data=time_bucket_sales, marker='o', color="darkblue")
plt.xticks(rotation=45)
plt.xlabel("Transaction Time Bucket")
plt.ylabel("Total Sales")
plt.title("Sales Performance by Time Interval")
plt.show()


[ ]
# Apply the function to create the 'time_of_day' column
df['time_of_day'] = df['transaction_time'].dt.hour.apply(categorize_time_of_day)

# Group sales by 'time_of_day' instead of 'transaction_time_bucket'
time_bucket_sales = df.groupby('time_of_day')['total_amount'].sum().reset_index()

# Sort categories in logical order
time_bucket_sales['time_of_day'] = pd.Categorical(
    time_bucket_sales['time_of_day'],
    categories=["Early Morning", "Mid-Morning", "Afternoon", "Evening"],
    ordered=True
)

time_bucket_sales = time_bucket_sales.sort_values('time_of_day')

# Graph
plt.figure(figsize=(10, 5))
sns.lineplot(x='time_of_day', y='total_amount', data=time_bucket_sales, marker='o', color='orange', linewidth=2)

plt.xlabel("Time of Day")
plt.ylabel("Total Sales")
plt.title("Sales Performance Across Different Time Periods" ,fontsize=14, fontweight='bold')

plt.xticks(rotation=45)  # Rotate labels for better readability
plt.show()


[ ]
# graph
plt.figure(figsize=(10, 5))
sns.barplot(x='time_of_day', y='total_amount', data=time_bucket_sales, palette="deep")

plt.xlabel("Time of Day")
plt.ylabel("Total Sales")
plt.title("Sales Performance Across Different Time Periods")
plt.show()

[ ]
# Group sales by store_location and compute total revenue
store_sales = df.groupby('store_location')['total_amount'].sum().reset_index()

# Sort by revenue in descending order
store_sales = store_sales.sort_values(by='total_amount', ascending=False)


plt.figure(figsize=(12, 6))
sns.barplot(x='store_location', y='total_amount', data=store_sales, palette="magma")

plt.xlabel("Store Location")
plt.ylabel("Total Sales")
plt.title("Total Sales by Store Location")
plt.xticks(rotation=45)
plt.show()



[ ]
import calendar  # Import the calendar module

# Convert 'transaction_date' to datetime format if not already done
df['transaction_date'] = pd.to_datetime(df['transaction_date'])

# Extract full month name
df['month'] = df['transaction_date'].dt.month.apply(lambda x: calendar.month_name[x])


monthly_sales = df.groupby('month')['total_amount'].sum().reset_index()

# Convert 'month' to categorical type for correct chronological ordering
monthly_sales['month'] = pd.Categorical(
    monthly_sales['month'],
    categories=[
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ],
    ordered=True
)

# Sort properly
monthly_sales = monthly_sales.sort_values(by="month")


plt.figure(figsize=(12, 6))
sns.lineplot(x='month', y='total_amount', data=monthly_sales, marker='o', color="green")

plt.xlabel("Month")
plt.ylabel("Total Sales")
plt.title("Total Sales Trend by Month")
plt.xticks(rotation=45)
plt.show()




[ ]
total_number_transaction = df['transaction_id'].count()
print(total_number_transaction)
149116

[ ]


# Define a nude & coffee color palette
nude_coffee_colors = ['#E3C8A8', '#D2B49A', '#A67B5B', '#8C624A', '#603E31']

# Pie chart visualization
plt.figure(figsize=(6, 6))
plt.pie(store_sales['total_amount'], labels=store_sales['store_location'], autopct='%1.1f%%',
        colors=nude_coffee_colors, startangle=140)

plt.title("☕ Total Sales by Store Location")
plt.show()


