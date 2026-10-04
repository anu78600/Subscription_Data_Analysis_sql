# 🧹 Advanced SQL Data Cleaning Project

A practical SQL data-cleaning project built using a messy subscription dataset.

This project was an opportunity for me to move beyond basic SQL queries and understand how SQL can be used to **identify, clean, standardize, validate, and improve real-world messy data**.

> **Learning Note:** This project was advanced for my current SQL level. I used my basic SQL knowledge along with AI assistance to understand and solve the cleaning challenges. The main goal was to learn **how SQL can be applied to data-quality problems**.

---

## 🎯 Project Objective

The goal was to take an unclean subscription dataset and transform it into a more structured and analysis-ready dataset using SQL.

### Key objectives:

* Clean inconsistent and messy values
* Convert columns into appropriate data types
* Standardize dates, text, countries, and statuses
* Handle NULL, blank, and `"N/A"` values
* Identify logical data-quality issues
* Validate the cleaned dataset
* Document assumptions made during cleaning

---

##  Tools Used

* **PostgreSQL**
* **SQL**
* **AI assistance** for understanding advanced cleaning logic
* **CSV** — Raw dataset

---

##  Data Cleaning Workflow

### 1. Import Raw Data

The raw dataset was initially imported with columns stored as `TEXT`.

This approach helped me safely bring the unstructured data into PostgreSQL before applying transformations.

```sql
CREATE TABLE subscription_prj (
    subscription_id TEXT,
    customer_id TEXT,
    customer_email TEXT,
    country TEXT,
    plan TEXT,
    monthly_price TEXT,
    status TEXT,
    start_date TEXT,
    end_date TEXT,
    payment_method TEXT,
    updated_at TEXT,
    internal_notes TEXT
);
```

---

### 2. Create a Clean Table

A separate table was created with appropriate data types such as:

* `NUMERIC` for monthly price
* `DATE` for start and end dates
* `TIMESTAMP` for updated time
* `VARCHAR` for text fields

This helped me understand the importance of **data types in data cleaning**.

---

## 🧹 Cleaning Techniques Used

### Remove Extra Spaces

Used `TRIM()` to remove unwanted spaces from values.

```sql
TRIM(subscription_id)
TRIM(customer_id)
```

### Handle Blank Values

Used `NULLIF()` to convert empty strings into `NULL`.

```sql
NULLIF(TRIM(customer_email), '')
```

### Validate & Convert Prices

Checked whether the value followed a numeric pattern before converting it to `NUMERIC`.

```sql
CASE 
    WHEN TRIM(monthly_price) ~ '^-?\d+(\.\d+)?$'
    THEN TRIM(monthly_price)::NUMERIC(6,2)
END
```

### Convert Multiple Date Formats

The dataset contained dates in different formats, so I handled both formats before converting them into the `DATE` data type.

```sql
YYYY-MM-DD
DD/MM/YYYY
```

### Standardize Text

Used functions such as:

```sql
TRIM()
INITCAP()
LOWER()
UPPER()
```

to standardize inconsistent text values.

---

##  Standardizing Country Values

Different representations of the same country were converted into a consistent format.

Examples:

```text
DE  → Germany
IE  → Ireland
IT  → Italy
U.K. → United Kingdom
Uk  → United Kingdom
```

This helped make the country field more consistent for future analysis.

---

##  Standardizing Status

Inconsistent status values were cleaned and standardized.

For example:

```text
Canceled → Cancelled
```

I also used `INITCAP()` and `TRIM()` to maintain consistent formatting.

---

##  Handling Missing Payment Methods

Blank, `NULL`, `NA`, and `N/A` values were handled and replaced with:

```text
Unknown
```

This gave the column a consistent representation for missing information.

---

## 📧 Cleaning Customer Emails

Email values were standardized using:

```sql
LOWER(TRIM(customer_email))
```

Missing email values were also assigned:

```text
Unknown
```

---

##  Data Quality Checks

I also performed logical checks after cleaning.

### Example checks:

* End date before start date
* Start date in the future
* Cancelled subscription without an end date
* Active subscription with an end date
* Data type validation
* Comparison between raw and cleaned data

For example:

```sql
SELECT *
FROM subscription_clean
WHERE end_date < start_date;
```

The project also includes validation queries comparing the raw and cleaned tables to identify values that could not be converted correctly.

---

##  Business Logic & Assumptions

One important learning from this project was that **data cleaning is not only about fixing formatting**.

Some issues require assumptions or business rules.

For example, subscriptions marked as `Active` but having an `end_date` that has already passed were identified and changed to `Cancelled`.

I also added a `dq_note` column to document assumptions and data-quality decisions rather than silently changing the data.

---

##  What I Learned

This project gave me practical exposure to:

* Cleaning messy data directly with SQL
* Working with raw and cleaned tables
* `TRIM()` and `NULLIF()`
* `CASE WHEN`
* Regular expressions
* Type casting
* Date conversion
* `INITCAP()` and `LOWER()`
* Handling NULL and missing values
* Data-quality validation
* Writing update queries carefully
* Applying basic business rules
* Documenting data-cleaning assumptions

Most importantly, I learned that **SQL can be used not only to query data, but also to prepare messy data for analysis.**

---

## 📁 Project Files

```text
Advanced-SQL-Data-Cleaning/
│
├── subscriptions_raw.csv
├── Advance_Cleaning_Sql_Project.sql
└── README.md
```

---

##  Key Takeaway

This project was a step outside my comfort zone.

I started with **basic SQL knowledge** and used this project to understand how SQL can solve real-world data-quality problems. With the help of AI as a learning assistant, I explored cleaning techniques that were new to me and gained a better understanding of how raw data can be transformed into analysis-ready data.

**Learning → Practicing → Cleaning → Validating → Improving**

---
