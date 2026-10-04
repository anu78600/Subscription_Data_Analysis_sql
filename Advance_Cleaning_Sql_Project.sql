Drop Table subscription_prj;

Create Table subscription_prj(
		subscription_id Text,
		customer_id Text,
		customer_email Text,
		country Text,
		plan Text,
		monthly_price Text,
		status Text,
		start_date Text,
		end_date Text,
		payment_method Text,
		updated_at Text,
		internal_notes Text

);
-- Using text constraint to import the data into the table, because that data is unstructured and unclean this is the safest way to do that, after importing
-- can clean using sql queries.

Select * From subscription_prj;

DROP TABLE IF EXISTS subscription_clean;

CREATE TABLE subscription_clean (
    subscription_id VARCHAR(20),
    customer_id     VARCHAR(20),
    customer_email  VARCHAR(100),
    country         VARCHAR(30),
    plan            VARCHAR(20),
    monthly_price   NUMERIC(6,2),
    status          VARCHAR(20),
    start_date      DATE,
    end_date        DATE,
    payment_method  VARCHAR(20),
    updated_at      TIMESTAMP,
    internal_notes  VARCHAR(100)
);

-- Insterting the proper values without extra space and with proper date and proper time and proper decimal formate.

INSERT INTO subscription_clean
SELECT
    TRIM(subscription_id),
    TRIM(customer_id),
    NULLIF(TRIM(customer_email), ''),
    NULLIF(TRIM(country), ''),
    NULLIF(TRIM(plan), ''),

    -- price: only cast if it looks like a number
    CASE WHEN TRIM(monthly_price) ~ '^-?\d+(\.\d+)?$'
         THEN TRIM(monthly_price)::NUMERIC(6,2)
    END,

    NULLIF(TRIM(status), ''),

    -- start_date: two formats in your file
    CASE
        WHEN TRIM(start_date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(TRIM(start_date), 'YYYY-MM-DD')
        WHEN TRIM(start_date) ~ '^\d{2}/\d{2}/\d{4}$'
            THEN TO_DATE(TRIM(start_date), 'DD/MM/YYYY')
    END,

    -- end_date: same logic
    CASE
        WHEN TRIM(end_date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(TRIM(end_date), 'YYYY-MM-DD')
        WHEN TRIM(end_date) ~ '^\d{2}/\d{2}/\d{4}$'
            THEN TO_DATE(TRIM(end_date), 'DD/MM/YYYY')
    END,

    NULLIF(TRIM(payment_method), ''),

    CASE WHEN TRIM(updated_at) ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
         THEN TRIM(updated_at)::TIMESTAMP
    END,

    NULLIF(TRIM(internal_notes), '')
FROM subscription_prj;

Select * From subscription_clean;

-- Checking all the values are filled or not.
Select count(*) From subscription_clean;

-- Joining the subscription_clean table and subscription_prj table.

Select r.subscription_id, r.start_date, r.monthly_price
From subscription_prj r
Join subscription_clean c
ON c.subscription_id = Trim(r.subscription_id)
Where (r.start_date IS NOT NULL AND TRIM(r.start_date) <> '' AND c.start_date IS NULL)
   OR (r.monthly_price IS NOT NULL AND c.monthly_price IS NULL);

--- Conforming the data types of the columns

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'subscription_clean'
ORDER BY ordinal_position;

--- Checking the data types of the raw column of the tables

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'subscription_prj'
ORDER BY ordinal_position;


-- end date before start date (now possible because both are DATE)
SELECT * FROM subscription_clean WHERE end_date < start_date;

-- Fixing the error where end date and start date is contradictory.
Update subscription_clean
Set start_date = end_date,
	end_date = start_date
Where end_date < start_date;

-- start dates in the future
SELECT * FROM subscription_clean WHERE start_date > CURRENT_DATE;

-- Fixing where strat date is grater than current date.
Update subscription_clean
Set start_date = Null
Where start_date > current_date;
---

Select * From subscription_clean;
-- Identifying the error in the letter case
SELECT '[' || plan || ']' AS plan_visible, COUNT(*) AS total
FROM subscription_clean
GROUP BY plan
ORDER BY plan;

-- fixing the letter case 

UPDATE subscription_clean
SET plan = INITCAP(TRIM(plan));

Select * From subscription_clean;


-- Identifying the error in the letter case in status column
SELECT '[' || status || ']' AS status_visible, COUNT(*) AS total
FROM subscription_clean
GROUP BY status
ORDER BY status;

-- Fixing this using trim to remove extra space from start and end, and initcap to use formate "Basic" first later is capital and others are small

Update subscription_clean
Set status = INitcap(Trim(status));

Update subscription_clean
Set status = 'Cancelled'
where status = 'Canceled';

Select * From subscription_clean;

-- Fixing the errors in the country column. full form and spacing and letter case 

Select '[' || country || ']' AS country_visual, Count(*) AS total
From subscription_clean
Group by country
order by country;

Update subscription_clean
Set country = 'Germany'
Where country = 'DE';

Update subscription_clean
Set country = 'Ireland'
Where country = 'IE';

Update subscription_clean
Set country = 'Italy'
Where country = 'IT';

Update subscription_clean
Set country = 'United Kingdom'
Where country = 'U.K.';

Update subscription_clean
Set country = 'United Kingdom'
Where country = 'Uk';

Update subscription_clean
Set country = Initcap(Trim(country));


-------

Select * From subscription_clean;

-- Now fixing the values of the payment method where iether it is blank or null or na.

Update subscription_clean
Set payment_method = 'Unknown'
Where payment_method IS NULL OR Upper(Trim(payment_method)) IN ('NA','N/A','','Null','NULL','null');

-- fixing the letter case in the email id.

Update subscription_clean
Set customer_email = Lower(Trim(customer_email));

Update subscription_clean
Set customer_email = 'Unknown'
Where customer_email IS NULL;


-- finding the error in the end_date column

SELECT subscription_id, status, start_date, end_date, updated_at
FROM subscription_clean
WHERE status = 'Cancelled' AND end_date IS NULL;
----------
UPDATE subscription_clean
SET dq_note = COALESCE(dq_note || '; ', '') || 'cancelled but end_date missing'
WHERE status = 'Cancelled' AND end_date IS NULL;
----------
SELECT subscription_id, status, start_date, end_date, updated_at
FROM subscription_clean
WHERE status = 'Active' AND end_date IS Not NULL;

-- Adding one new column to add notes what steps i do because these are my assumption based.

ALTER TABLE subscription_clean ADD COLUMN IF NOT EXISTS dq_note VARCHAR(200);

UPDATE subscription_clean
SET dq_note = COALESCE(dq_note || '; ', '') || 'status changed active to cancelled (end_date already passed)'
WHERE status = 'Active'
  AND end_date IS NOT NULL
  AND end_date <= CURRENT_DATE;

Update subscription_clean
Set status = 'Cancelled'
Where status = 'Active'
	And end_date IS Not NULL
	And end_date <= Current_Date;

------
Select * From subscription_clean;