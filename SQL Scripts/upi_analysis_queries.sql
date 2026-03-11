-- ── Create transactions table ──────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
    txn_id                VARCHAR(15) PRIMARY KEY,
    txn_datetime          TIMESTAMP,
    txn_date              DATE,
    txn_month             INT,
    txn_year              INT,
    txn_hour              INT,
    day_of_week           VARCHAR(10),
    user_id               VARCHAR(10),
    user_city             VARCHAR(30),
    user_city_tier        VARCHAR(10),
    user_age              INT,
    user_gender           VARCHAR(10),
    user_activity_level   VARCHAR(10),
    merchant_id           VARCHAR(10),
    merchant_name         VARCHAR(100),
    merchant_category     VARCHAR(30),
    merchant_city         VARCHAR(30),
    platform_used         VARCHAR(20),
    preferred_platform    VARCHAR(20),
    is_preferred_platform INT,
    payment_mode          VARCHAR(20),
    device_type           VARCHAR(10),
    amount                NUMERIC(12,2),
    status                VARCHAR(10),
    unusual_hour_flag     INT,
    high_amount_flag      INT,
    round_amount_flag     INT,
    velocity_flag         INT,
    fraud_score           INT,
    is_fraud              INT,
    is_weekend            INT,
    time_of_day           VARCHAR(15),
    is_festival_month     INT,
    quarter               INT,
    is_success            INT,
    is_failed             INT,
    is_cross_city         INT,
    age_group             VARCHAR(25)
);

-- ── Create users table ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    user_id                VARCHAR(10) PRIMARY KEY,
    age                    INT,
    gender                 VARCHAR(10),
    city                   VARCHAR(30),
    city_tier              VARCHAR(10),
    preferred_platform     VARCHAR(20),
    activity_level         VARCHAR(10),
    monthly_txn_frequency  INT,
    device_type            VARCHAR(10),
    registration_date      DATE,
    segment                INT,
    segment_name           VARCHAR(30),
    avg_txn_amount         NUMERIC(12,2),
    total_spend            NUMERIC(15,2),
    total_txns             INT,
    platform_loyalty_rate  NUMERIC(5,4),
    avg_spend_per_day      NUMERIC(12,2)
);

-- ── Create merchants table ─────────────────────────────────
CREATE TABLE IF NOT EXISTS merchants (
    merchant_id         VARCHAR(10) PRIMARY KEY,
    merchant_name       VARCHAR(100),
    merchant_category   VARCHAR(30),
    merchant_city       VARCHAR(30),
    merchant_city_tier  VARCHAR(10),
    is_active           INT
);

SELECT 'Tables created successfully' AS status;


--


-- ══════════════════════════════════════════════════════════
-- QUERY 1: EXECUTIVE KPI SUMMARY
-- ══════════════════════════════════════════════════════════
SELECT
    COUNT(*)                                            AS total_transactions,
    COUNT(DISTINCT user_id)                             AS unique_users,
    COUNT(DISTINCT merchant_id)                         AS unique_merchants,
    ROUND(SUM(amount))                                  AS total_value_inr,
    ROUND(AVG(amount))                                  AS avg_txn_amount,
    ROUND(SUM(amount) / 1e7, 2)                         AS total_value_crore,
    ROUND(SUM(CASE WHEN status = 'Success' 
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate_pct,
    ROUND(SUM(CASE WHEN status = 'Failed'  
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failure_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 3) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 
              THEN amount ELSE 0 END))                  AS total_fraud_value_inr,
    MIN(txn_date)                                       AS data_from,
    MAX(txn_date)                                       AS data_to
FROM transactions;

-- ══════════════════════════════════════════════════════════
-- QUERY 2: MONTHLY TREND WITH MONTH-OVER-MONTH GROWTH
-- ══════════════════════════════════════════════════════════
WITH monthly_stats AS (
    SELECT
        txn_year,
        txn_month,
        TO_CHAR(txn_date, 'Mon YYYY')           AS period,
        COUNT(*)                                AS txn_count,
        ROUND(SUM(amount))                      AS total_value,
        ROUND(AVG(amount))                      AS avg_amount,
        SUM(CASE WHEN status = 'Success' 
            THEN 1 ELSE 0 END)                  AS success_count,
        SUM(CASE WHEN is_fraud = 1 
            THEN 1 ELSE 0 END)                  AS fraud_count
    FROM transactions
    GROUP BY txn_year, txn_month, TO_CHAR(txn_date, 'Mon YYYY')
)
SELECT
    period,
    txn_count,
    total_value,
    avg_amount,
    ROUND(success_count * 100.0 / txn_count, 2)     AS success_rate_pct,
    ROUND(fraud_count * 100.0 / txn_count, 3)        AS fraud_rate_pct,
    LAG(txn_count) OVER (ORDER BY txn_year, txn_month) AS prev_month_txns,
    ROUND(
        (txn_count - LAG(txn_count) OVER (ORDER BY txn_year, txn_month))
        * 100.0 /
        NULLIF(LAG(txn_count) OVER (ORDER BY txn_year, txn_month), 0)
    , 2)                                             AS mom_growth_pct,
    SUM(txn_count) OVER (
        ORDER BY txn_year, txn_month
    )                                                AS cumulative_txns,
    ROUND(SUM(total_value) OVER (
        ORDER BY txn_year, txn_month
    ) / 1e7, 2)                                      AS cumulative_value_crore
FROM monthly_stats
ORDER BY txn_year, txn_month;

-- ══════════════════════════════════════════════════════════
-- QUERY 3: PLATFORM PERFORMANCE SCORECARD
-- ══════════════════════════════════════════════════════════
-- ══════════════════════════════════════════════════════════
-- QUERY 3: PLATFORM PERFORMANCE SCORECARD
-- ══════════════════════════════════════════════════════════
WITH platform_stats AS (
    SELECT
        platform_used,
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT user_id)                         AS unique_users,
        ROUND(SUM(amount))                              AS total_value,
        ROUND(AVG(amount), 2)                           AS avg_amount,
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP 
              (ORDER BY amount) AS NUMERIC), 2)         AS median_amount,
        SUM(CASE WHEN status = 'Success' 
            THEN 1 ELSE 0 END)                          AS success_txns,
        SUM(CASE WHEN status = 'Failed'  
            THEN 1 ELSE 0 END)                          AS failed_txns,
        SUM(CASE WHEN is_fraud = 1 
            THEN 1 ELSE 0 END)                          AS fraud_txns,
        SUM(CASE WHEN is_preferred_platform = 1 
            THEN 1 ELSE 0 END)                          AS loyal_txns,
        SUM(CASE WHEN is_cross_city = 1 
            THEN 1 ELSE 0 END)                          AS cross_city_txns
    FROM transactions
    GROUP BY platform_used
)
SELECT
    platform_used,
    total_txns,
    unique_users,
    ROUND(total_value / 1e7, 2)                         AS value_crore,
    avg_amount,
    median_amount,
    ROUND(total_txns * 100.0 / SUM(total_txns) 
          OVER (), 2)                                   AS volume_share_pct,
    ROUND(total_value * 100.0 / SUM(total_value) 
          OVER (), 2)                                   AS value_share_pct,
    ROUND(success_txns * 100.0 / total_txns, 2)         AS success_rate_pct,
    ROUND(failed_txns  * 100.0 / total_txns, 2)         AS failure_rate_pct,
    ROUND(fraud_txns   * 100.0 / total_txns, 3)         AS fraud_rate_pct,
    ROUND(loyal_txns   * 100.0 / total_txns, 2)         AS loyalty_rate_pct,
    ROUND(cross_city_txns * 100.0 / total_txns, 2)      AS cross_city_rate_pct,
    RANK() OVER (ORDER BY total_txns DESC)              AS volume_rank,
    RANK() OVER (ORDER BY avg_amount DESC)              AS avg_ticket_rank
FROM platform_stats
ORDER BY total_txns DESC;

-- ══════════════════════════════════════════════════════════
-- QUERY 4: MERCHANT CATEGORY DEEP DIVE
-- ══════════════════════════════════════════════════════════
WITH category_stats AS (
    SELECT
        merchant_category,
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT user_id)                         AS unique_users,
        COUNT(DISTINCT merchant_id)                     AS unique_merchants,
        ROUND(SUM(amount))                              AS total_value,
        ROUND(AVG(amount), 2)                           AS avg_amount,
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP
              (ORDER BY amount) AS NUMERIC), 2)         AS median_amount,
        ROUND(MAX(amount), 2)                           AS max_amount,
        SUM(CASE WHEN status = 'Failed'
            THEN 1 ELSE 0 END)                          AS failed_txns,
        SUM(CASE WHEN is_fraud = 1
            THEN 1 ELSE 0 END)                          AS fraud_txns,
        SUM(CASE WHEN is_festival_month = 1
            THEN 1 ELSE 0 END)                          AS festival_txns,
        SUM(CASE WHEN is_cross_city = 1
            THEN 1 ELSE 0 END)                          AS cross_city_txns
    FROM transactions
    GROUP BY merchant_category
)
SELECT
    merchant_category,
    total_txns,
    unique_users,
    unique_merchants,
    ROUND(total_value / 1e7, 2)                         AS value_crore,
    avg_amount,
    median_amount,
    max_amount,
    ROUND(total_txns * 100.0 / SUM(total_txns)
          OVER (), 2)                                   AS volume_share_pct,
    ROUND(total_value * 100.0 / SUM(total_value)
          OVER (), 2)                                   AS value_share_pct,
    ROUND(failed_txns * 100.0 / total_txns, 2)          AS failure_rate_pct,
    ROUND(fraud_txns  * 100.0 / total_txns, 3)          AS fraud_rate_pct,
    ROUND(festival_txns * 100.0 / total_txns, 2)        AS festival_txn_pct,
    ROUND(cross_city_txns * 100.0 / total_txns, 2)      AS cross_city_pct,
    RANK() OVER (ORDER BY total_value DESC)             AS value_rank,
    RANK() OVER (ORDER BY total_txns DESC)              AS volume_rank,
    RANK() OVER (ORDER BY avg_amount DESC)              AS avg_ticket_rank
FROM category_stats
ORDER BY total_value DESC;

-- ══════════════════════════════════════════════════════════
-- QUERY 5: USER SEGMENT PERFORMANCE ANALYSIS
-- ══════════════════════════════════════════════════════════
WITH segment_txns AS (
    SELECT
        u.segment_name,
        t.user_id,
        COUNT(*)                                        AS user_txns,
        ROUND(SUM(t.amount))                            AS user_spend,
        ROUND(AVG(t.amount), 2)                         AS user_avg_amount,
        SUM(CASE WHEN t.is_fraud = 1 
            THEN 1 ELSE 0 END)                          AS user_fraud_txns,
        SUM(CASE WHEN t.status = 'Failed' 
            THEN 1 ELSE 0 END)                          AS user_failed_txns,
        COUNT(DISTINCT t.merchant_category)             AS categories_used,
        COUNT(DISTINCT t.platform_used)                 AS platforms_used
    FROM transactions t
    JOIN users u ON t.user_id = u.user_id
    GROUP BY u.segment_name, t.user_id
)
SELECT
    segment_name,
    COUNT(DISTINCT user_id)                             AS total_users,
    ROUND(SUM(user_spend) / 1e7, 2)                     AS total_value_crore,
    ROUND(AVG(user_spend))                              AS avg_spend_per_user,
    ROUND(AVG(user_txns), 1)                            AS avg_txns_per_user,
    ROUND(AVG(user_avg_amount), 2)                      AS avg_txn_amount,
    ROUND(AVG(categories_used), 1)                      AS avg_categories_used,
    ROUND(AVG(platforms_used), 1)                       AS avg_platforms_used,
    ROUND(SUM(user_fraud_txns) * 100.0 / 
          SUM(user_txns), 3)                            AS fraud_rate_pct,
    ROUND(SUM(user_failed_txns) * 100.0 / 
          SUM(user_txns), 2)                            AS failure_rate_pct,
    ROUND(SUM(user_spend) * 100.0 / 
          SUM(SUM(user_spend)) OVER (), 2)              AS value_share_pct,
    RANK() OVER (ORDER BY AVG(user_spend) DESC)         AS spend_rank
FROM segment_txns
GROUP BY segment_name
ORDER BY avg_spend_per_user DESC;

-- ══════════════════════════════════════════════════════════
-- QUERY 6A: FRAUD BY SCORE LEVEL
-- ══════════════════════════════════════════════════════════
SELECT
    fraud_score,
    COUNT(*)                                            AS total_txns,
    SUM(is_fraud)                                       AS fraud_txns,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 3)          AS fraud_rate_pct,
    ROUND(AVG(amount), 2)                               AS avg_amount,
    ROUND(SUM(CASE WHEN is_fraud = 1
          THEN amount ELSE 0 END))                      AS fraud_value_inr
FROM transactions
GROUP BY fraud_score
ORDER BY fraud_score;

-- ══════════════════════════════════════════════════════════
-- QUERY 6B: TOP FRAUD HOURS
-- ══════════════════════════════════════════════════════════
SELECT
    txn_hour,
    COUNT(*)                                            AS total_txns,
    SUM(is_fraud)                                       AS fraud_txns,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 3)          AS fraud_rate_pct,
    ROUND(AVG(CASE WHEN is_fraud = 1
          THEN amount END), 2)                          AS avg_fraud_amount
FROM transactions
GROUP BY txn_hour
ORDER BY fraud_rate_pct DESC
LIMIT 10;

-- ══════════════════════════════════════════════════════════
-- QUERY 6C: FRAUD BY MERCHANT CATEGORY
-- ══════════════════════════════════════════════════════════
SELECT
    merchant_category,
    COUNT(*)                                            AS total_txns,
    SUM(is_fraud)                                       AS fraud_txns,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 3)          AS fraud_rate_pct,
    ROUND(AVG(CASE WHEN is_fraud = 1
          THEN amount END), 2)                          AS avg_fraud_amount,
    ROUND(SUM(CASE WHEN is_fraud = 1
          THEN amount ELSE 0 END))                      AS total_fraud_value
FROM transactions
GROUP BY merchant_category
ORDER BY fraud_rate_pct DESC;

-- ══════════════════════════════════════════════════════════
-- QUERY 7: TOP USER RFM ANALYSIS
-- ══════════════════════════════════════════════════════════
WITH user_rfm AS (
    SELECT
        t.user_id,
        u.segment_name,
        u.city,
        u.city_tier,
        u.preferred_platform,
        u.age,
        COUNT(*)                                        AS frequency,
        ROUND(SUM(t.amount))                            AS monetary,
        ROUND(AVG(t.amount), 2)                         AS avg_amount,
        MAX(t.txn_date)                                 AS last_txn_date,
        MIN(t.txn_date)                                 AS first_txn_date,
        ('2023-12-31'::DATE - MAX(t.txn_date))          AS recency_days,
        COUNT(DISTINCT t.merchant_category)             AS categories_used,
        COUNT(DISTINCT t.platform_used)                 AS platforms_used,
        SUM(CASE WHEN t.is_fraud = 1 
            THEN 1 ELSE 0 END)                          AS fraud_txns
    FROM transactions t
    JOIN users u ON t.user_id = u.user_id
    GROUP BY
        t.user_id, u.segment_name, u.city,
        u.city_tier, u.preferred_platform, u.age
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)       AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)         AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)          AS m_score
    FROM user_rfm
)
SELECT
    user_id,
    segment_name,
    city,
    preferred_platform,
    age,
    recency_days,
    frequency,
    monetary,
    avg_amount,
    categories_used,
    r_score,
    f_score,
    m_score,
    ROUND((r_score + f_score + m_score) / 3.0, 2)      AS rfm_score,
    CASE
        WHEN (r_score + f_score + m_score) >= 13
            THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 10
            THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >= 7
            THEN 'Potential Loyalist'
        WHEN (r_score + f_score + m_score) >= 5
            THEN 'At Risk'
        ELSE 'Lost'
    END                                                 AS rfm_segment,
    RANK() OVER (ORDER BY monetary DESC)                AS spend_rank
FROM rfm_scored
ORDER BY monetary DESC
LIMIT 20;

-- ══════════════════════════════════════════════════════════
-- QUERY 8: CITY WISE PERFORMANCE INTELLIGENCE
-- ══════════════════════════════════════════════════════════
WITH city_stats AS (
    SELECT
        user_city,
        user_city_tier,
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT user_id)                         AS unique_users,
        COUNT(DISTINCT merchant_category)               AS categories_used,
        ROUND(SUM(amount))                              AS total_value,
        ROUND(AVG(amount), 2)                           AS avg_amount,
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP
              (ORDER BY amount) AS NUMERIC), 2)         AS median_amount,
        SUM(CASE WHEN status = 'Failed'
            THEN 1 ELSE 0 END)                          AS failed_txns,
        SUM(CASE WHEN is_fraud = 1
            THEN 1 ELSE 0 END)                          AS fraud_txns,
        SUM(CASE WHEN is_festival_month = 1
            THEN 1 ELSE 0 END)                          AS festival_txns,
        SUM(CASE WHEN is_cross_city = 1
            THEN 1 ELSE 0 END)                          AS cross_city_txns
    FROM transactions
    GROUP BY user_city, user_city_tier
)
SELECT
    user_city,
    user_city_tier,
    total_txns,
    unique_users,
    ROUND(total_value / 1e7, 2)                         AS value_crore,
    avg_amount,
    median_amount,
    ROUND(total_txns * 100.0 /
          SUM(total_txns) OVER (), 2)                   AS volume_share_pct,
    ROUND(total_value * 100.0 /
          SUM(total_value) OVER (), 2)                  AS value_share_pct,
    ROUND(failed_txns * 100.0 / total_txns, 2)          AS failure_rate_pct,
    ROUND(fraud_txns  * 100.0 / total_txns, 3)          AS fraud_rate_pct,
    ROUND(festival_txns * 100.0 / total_txns, 2)        AS festival_txn_pct,
    ROUND(cross_city_txns * 100.0 / total_txns, 2)      AS cross_city_pct,
    ROUND(total_value / NULLIF(unique_users, 0))        AS value_per_user,
    RANK() OVER (ORDER BY total_value DESC)             AS value_rank,
    RANK() OVER (
        PARTITION BY user_city_tier
        ORDER BY total_value DESC)                      AS tier_rank
FROM city_stats
ORDER BY total_value DESC
LIMIT 20;

-- ══════════════════════════════════════════════════════════
-- QUERY 9: USER COHORT RETENTION ANALYSIS
-- ══════════════════════════════════════════════════════════
WITH user_first_txn AS (
    SELECT
        user_id,
        DATE_TRUNC('month', MIN(txn_date))              AS cohort_month
    FROM transactions
    GROUP BY user_id
),
user_activity AS (
    SELECT
        t.user_id,
        DATE_TRUNC('month', t.txn_date)                 AS activity_month
    FROM transactions t
    GROUP BY t.user_id, DATE_TRUNC('month', t.txn_date)
),
cohort_data AS (
    SELECT
        f.user_id,
        f.cohort_month,
        a.activity_month,
        EXTRACT(YEAR FROM AGE(a.activity_month, f.cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(a.activity_month, f.cohort_month)) AS month_number
    FROM user_first_txn f
    JOIN user_activity a ON f.user_id = a.user_id
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_id)                         AS cohort_users
    FROM user_first_txn
    GROUP BY cohort_month
)
SELECT
    TO_CHAR(cd.cohort_month, 'Mon YYYY')                AS cohort,
    cs.cohort_users                                     AS cohort_size,
    cd.month_number,
    COUNT(DISTINCT cd.user_id)                          AS active_users,
    ROUND(COUNT(DISTINCT cd.user_id) * 100.0 /
          cs.cohort_users, 2)                           AS retention_rate_pct
FROM cohort_data cd
JOIN cohort_size cs ON cd.cohort_month = cs.cohort_month
WHERE cd.month_number <= 12
GROUP BY
    cd.cohort_month, cs.cohort_users, cd.month_number
ORDER BY
    cd.cohort_month, cd.month_number
LIMIT 50;

-- ══════════════════════════════════════════════════════════
-- QUERY 10: PAYMENT MODE & DEVICE INTELLIGENCE
-- ══════════════════════════════════════════════════════════
WITH mode_stats AS (
    SELECT
        payment_mode,
        device_type,
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT user_id)                         AS unique_users,
        ROUND(SUM(amount))                              AS total_value,
        ROUND(AVG(amount), 2)                           AS avg_amount,
        ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP
              (ORDER BY amount) AS NUMERIC), 2)         AS median_amount,
        SUM(CASE WHEN status = 'Success'
            THEN 1 ELSE 0 END)                          AS success_txns,
        SUM(CASE WHEN status = 'Failed'
            THEN 1 ELSE 0 END)                          AS failed_txns,
        SUM(CASE WHEN is_fraud = 1
            THEN 1 ELSE 0 END)                          AS fraud_txns
    FROM transactions
    GROUP BY payment_mode, device_type
)
SELECT
    payment_mode,
    device_type,
    total_txns,
    unique_users,
    ROUND(total_value / 1e7, 2)                         AS value_crore,
    avg_amount,
    median_amount,
    ROUND(success_txns * 100.0 / total_txns, 2)         AS success_rate_pct,
    ROUND(failed_txns  * 100.0 / total_txns, 2)         AS failure_rate_pct,
    ROUND(fraud_txns   * 100.0 / total_txns, 3)         AS fraud_rate_pct,
    ROUND(total_txns * 100.0 /
          SUM(total_txns) OVER (), 2)                   AS volume_share_pct,
    RANK() OVER (
        PARTITION BY payment_mode
        ORDER BY total_txns DESC)                       AS device_rank_in_mode,
    RANK() OVER (
        PARTITION BY device_type
        ORDER BY total_txns DESC)                       AS mode_rank_in_device
FROM mode_stats
ORDER BY payment_mode, total_txns DESC;

-- ══════════════════════════════════════════════════════════
-- QUERY 11: ADVANCED WINDOW FUNCTIONS — RUNNING TOTALS
-- ══════════════════════════════════════════════════════════
WITH daily_stats AS (
    SELECT
        txn_date,
        txn_year,
        txn_month,
        COUNT(*)                                        AS daily_txns,
        ROUND(SUM(amount))                              AS daily_value,
        ROUND(AVG(amount), 2)                           AS daily_avg_amount,
        SUM(CASE WHEN is_fraud = 1
            THEN 1 ELSE 0 END)                          AS daily_fraud
    FROM transactions
    GROUP BY txn_date, txn_year, txn_month
)
SELECT
    txn_date,
    txn_year,
    txn_month,
    daily_txns,
    daily_value,
    daily_avg_amount,
    daily_fraud,
    -- 7 day moving average
    ROUND(AVG(daily_txns) OVER (
        ORDER BY txn_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 0)                                               AS txn_7day_ma,
    ROUND(AVG(daily_value) OVER (
        ORDER BY txn_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 0)                                               AS value_7day_ma,
    -- 30 day moving average
    ROUND(AVG(daily_txns) OVER (
        ORDER BY txn_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 0)                                               AS txn_30day_ma,
    -- Cumulative totals
    SUM(daily_txns) OVER (
        ORDER BY txn_date
    )                                                   AS cumulative_txns,
    ROUND(SUM(daily_value) OVER (
        ORDER BY txn_date
    ) / 1e7, 2)                                         AS cumulative_value_crore,
    -- Day over day growth
    daily_txns - LAG(daily_txns) OVER (
        ORDER BY txn_date
    )                                                   AS dod_txn_change,
    ROUND((daily_txns - LAG(daily_txns) OVER (
        ORDER BY txn_date)) * 100.0 /
        NULLIF(LAG(daily_txns) OVER (
        ORDER BY txn_date), 0), 2)                      AS dod_growth_pct,
    -- Month running total
    SUM(daily_txns) OVER (
        PARTITION BY txn_year, txn_month
        ORDER BY txn_date
    )                                                   AS month_running_total,
    -- Rank day within month by volume
    RANK() OVER (
        PARTITION BY txn_year, txn_month
        ORDER BY daily_txns DESC
    )                                                   AS day_rank_in_month
FROM daily_stats
ORDER BY txn_date
LIMIT 30;

-- ══════════════════════════════════════════════════════════
-- QUERY 12: MERCHANT PERFORMANCE & QUALITY SCORE
-- ══════════════════════════════════════════════════════════
WITH merchant_stats AS (
    SELECT
        t.merchant_id,
        m.merchant_name,
        m.merchant_category,
        m.merchant_city,
        m.merchant_city_tier,
        m.is_active,
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT t.user_id)                       AS unique_users,
        ROUND(SUM(t.amount))                            AS total_revenue,
        ROUND(AVG(t.amount), 2)                         AS avg_txn_amount,
        SUM(CASE WHEN t.status = 'Failed'
            THEN 1 ELSE 0 END)                          AS failed_txns,
        SUM(CASE WHEN t.is_fraud = 1
            THEN 1 ELSE 0 END)                          AS fraud_txns,
        MIN(t.txn_date)                                 AS first_txn_date,
        MAX(t.txn_date)                                 AS last_txn_date,
        COUNT(DISTINCT DATE_TRUNC('month', t.txn_date)) AS active_months
    FROM transactions t
    JOIN merchants m ON t.merchant_id = m.merchant_id
    GROUP BY
        t.merchant_id, m.merchant_name, m.merchant_category,
        m.merchant_city, m.merchant_city_tier, m.is_active
),
merchant_scored AS (
    SELECT
        *,
        ROUND(failed_txns * 100.0 / total_txns, 2)     AS failure_rate,
        ROUND(fraud_txns  * 100.0 / total_txns, 3)     AS fraud_rate,
        ROUND(total_revenue / NULLIF(unique_users,0))   AS revenue_per_user,
        -- Quality score components (each out of 25)
        CASE
            WHEN ROUND(failed_txns*100.0/total_txns,2) < 3  THEN 25
            WHEN ROUND(failed_txns*100.0/total_txns,2) < 5  THEN 20
            WHEN ROUND(failed_txns*100.0/total_txns,2) < 8  THEN 15
            ELSE 10
        END                                             AS failure_score,
        CASE
            WHEN fraud_txns = 0 THEN 25
            WHEN ROUND(fraud_txns*100.0/total_txns,3) < 0.05 THEN 20
            WHEN ROUND(fraud_txns*100.0/total_txns,3) < 0.1  THEN 15
            ELSE 10
        END                                             AS fraud_score,
        CASE
            WHEN unique_users >= 200 THEN 25
            WHEN unique_users >= 100 THEN 20
            WHEN unique_users >= 50  THEN 15
            ELSE 10
        END                                             AS reach_score,
        CASE
            WHEN active_months >= 20 THEN 25
            WHEN active_months >= 15 THEN 20
            WHEN active_months >= 10 THEN 15
            ELSE 10
        END                                             AS consistency_score
    FROM merchant_stats
)
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    merchant_city,
    merchant_city_tier,
    total_txns,
    unique_users,
    ROUND(total_revenue/1e5, 2)                         AS revenue_lakhs,
    avg_txn_amount,
    failure_rate,
    fraud_rate,
    active_months,
    failure_score,
    fraud_score,
    reach_score,
    consistency_score,
    (failure_score + fraud_score +
     reach_score + consistency_score)                   AS quality_score,
    RANK() OVER (
        ORDER BY (failure_score + fraud_score +
                  reach_score + consistency_score) DESC,
        total_revenue DESC
    )                                                   AS quality_rank,
    RANK() OVER (
        PARTITION BY merchant_category
        ORDER BY total_revenue DESC
    )                                                   AS category_rank
FROM merchant_scored
ORDER BY quality_score DESC, total_revenue DESC
LIMIT 20;

-- ══════════════════════════════════════════════════════════
-- QUERY 13: FESTIVAL VS NON-FESTIVAL SPENDING ANALYSIS
-- ══════════════════════════════════════════════════════════
WITH festival_base AS (
    SELECT
        is_festival_month,
        merchant_category,
        platform_used,
        user_city_tier,
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT user_id)                         AS unique_users,
        ROUND(SUM(amount))                              AS total_value,
        ROUND(AVG(amount), 2)                           AS avg_amount,
        SUM(CASE WHEN status = 'Failed'
            THEN 1 ELSE 0 END)                          AS failed_txns,
        SUM(CASE WHEN is_fraud = 1
            THEN 1 ELSE 0 END)                          AS fraud_txns
    FROM transactions
    GROUP BY
        is_festival_month, merchant_category,
        platform_used, user_city_tier
),
category_festival AS (
    SELECT
        merchant_category,
        SUM(CASE WHEN is_festival_month = 1
            THEN total_txns ELSE 0 END)                 AS festival_txns,
        SUM(CASE WHEN is_festival_month = 0
            THEN total_txns ELSE 0 END)                 AS non_festival_txns,
        SUM(CASE WHEN is_festival_month = 1
            THEN total_value ELSE 0 END)                AS festival_value,
        SUM(CASE WHEN is_festival_month = 0
            THEN total_value ELSE 0 END)                AS non_festival_value,
        ROUND(AVG(CASE WHEN is_festival_month = 1
            THEN avg_amount END), 2)                    AS festival_avg_amount,
        ROUND(AVG(CASE WHEN is_festival_month = 0
            THEN avg_amount END), 2)                    AS non_festival_avg_amount
    FROM festival_base
    GROUP BY merchant_category
)
SELECT
    merchant_category,
    festival_txns,
    non_festival_txns,
    ROUND(festival_value / 1e5, 2)                      AS festival_value_lakhs,
    ROUND(non_festival_value / 1e5, 2)                  AS non_festival_value_lakhs,
    festival_avg_amount,
    non_festival_avg_amount,
    ROUND((festival_avg_amount - non_festival_avg_amount)
          * 100.0 /
          NULLIF(non_festival_avg_amount, 0), 2)        AS avg_amount_lift_pct,
    ROUND(festival_txns * 100.0 /
          NULLIF(festival_txns + non_festival_txns,0),2) AS festival_txn_share_pct,
    ROUND(festival_value * 100.0 /
          NULLIF(festival_value + non_festival_value,0),2) AS festival_value_share_pct,
    RANK() OVER (
        ORDER BY (festival_avg_amount - non_festival_avg_amount) DESC
    )                                                   AS festival_lift_rank
FROM category_festival
ORDER BY festival_lift_rank;

-- ══════════════════════════════════════════════════════════
-- QUERY 14: USER VELOCITY & ANOMALY DETECTION
-- ══════════════════════════════════════════════════════════
WITH user_daily AS (
    SELECT
        user_id,
        txn_date,
        COUNT(*)                                        AS daily_txns,
        ROUND(SUM(amount))                              AS daily_spend,
        SUM(is_fraud)                                   AS daily_fraud,
        SUM(unusual_hour_flag)                          AS unusual_hour_txns,
        COUNT(DISTINCT merchant_category)               AS categories_in_day,
        COUNT(DISTINCT platform_used)                   AS platforms_in_day
    FROM transactions
    GROUP BY user_id, txn_date
),
user_baseline AS (
    SELECT
        user_id,
        ROUND(AVG(daily_txns), 2)                       AS avg_daily_txns,
        ROUND(AVG(daily_spend), 2)                       AS avg_daily_spend,
        ROUND(STDDEV(daily_txns), 2)                    AS stddev_daily_txns,
        ROUND(STDDEV(daily_spend), 2)                   AS stddev_daily_spend,
        MAX(daily_txns)                                 AS max_daily_txns,
        MAX(daily_spend)                                AS max_daily_spend
    FROM user_daily
    GROUP BY user_id
),
anomaly_flags AS (
    SELECT
        ud.user_id,
        ud.txn_date,
        ud.daily_txns,
        ud.daily_spend,
        ud.unusual_hour_txns,
        ud.categories_in_day,
        ud.platforms_in_day,
        ub.avg_daily_txns,
        ub.avg_daily_spend,
        ub.stddev_daily_txns,
        ub.stddev_daily_spend,
        -- Z-score for transaction count
        ROUND(
            (ud.daily_txns - ub.avg_daily_txns) /
            NULLIF(ub.stddev_daily_txns, 0)
        , 2)                                            AS txn_zscore,
        -- Z-score for spend amount
        ROUND(
            (ud.daily_spend - ub.avg_daily_spend) /
            NULLIF(ub.stddev_daily_spend, 0)
        , 2)                                            AS spend_zscore,
        -- Anomaly flag if zscore > 2
        CASE
            WHEN (ud.daily_txns - ub.avg_daily_txns) /
                 NULLIF(ub.stddev_daily_txns, 0) > 2
            THEN 1 ELSE 0
        END                                             AS txn_velocity_anomaly,
        CASE
            WHEN (ud.daily_spend - ub.avg_daily_spend) /
                 NULLIF(ub.stddev_daily_spend, 0) > 2
            THEN 1 ELSE 0
        END                                             AS spend_anomaly
    FROM user_daily ud
    JOIN user_baseline ub ON ud.user_id = ub.user_id
)
SELECT
    user_id,
    txn_date,
    daily_txns,
    daily_spend,
    avg_daily_txns,
    avg_daily_spend,
    txn_zscore,
    spend_zscore,
    unusual_hour_txns,
    categories_in_day,
    platforms_in_day,
    txn_velocity_anomaly,
    spend_anomaly,
    CASE
        WHEN txn_velocity_anomaly = 1
         AND spend_anomaly = 1
        THEN 'HIGH RISK'
        WHEN txn_velocity_anomaly = 1
          OR spend_anomaly = 1
        THEN 'MEDIUM RISK'
        WHEN unusual_hour_txns > 0
        THEN 'LOW RISK'
        ELSE 'NORMAL'
    END                                                 AS risk_label
FROM anomaly_flags
WHERE txn_velocity_anomaly = 1
   OR spend_anomaly = 1
   OR unusual_hour_txns > 0
ORDER BY spend_zscore DESC NULLS LAST
LIMIT 25;

-- ══════════════════════════════════════════════════════════
-- QUERY 15: COMPLETE EXECUTIVE SUMMARY
-- ══════════════════════════════════════════════════════════
WITH overall AS (
    SELECT
        COUNT(*)                                        AS total_txns,
        COUNT(DISTINCT user_id)                         AS total_users,
        COUNT(DISTINCT merchant_id)                     AS total_merchants,
        ROUND(SUM(amount)/1e7, 2)                       AS total_value_crore,
        ROUND(AVG(amount), 2)                           AS avg_txn_amount,
        ROUND(SUM(CASE WHEN status='Success'
              THEN 1 ELSE 0 END)*100.0/COUNT(*),2)      AS success_rate,
        ROUND(SUM(CASE WHEN is_fraud=1
              THEN 1 ELSE 0 END)*100.0/COUNT(*),3)      AS fraud_rate,
        ROUND(SUM(CASE WHEN is_fraud=1
              THEN amount ELSE 0 END)/1e5,2)            AS fraud_value_lakhs
    FROM transactions
),
top_platform AS (
    SELECT platform_used, COUNT(*) AS txns
    FROM transactions
    GROUP BY platform_used
    ORDER BY txns DESC LIMIT 1
),
top_category AS (
    SELECT merchant_category, ROUND(SUM(amount)/1e7,2) AS val
    FROM transactions
    GROUP BY merchant_category
    ORDER BY val DESC LIMIT 1
),
top_city AS (
    SELECT user_city, COUNT(*) AS txns
    FROM transactions
    GROUP BY user_city
    ORDER BY txns DESC LIMIT 1
),
peak_month AS (
    SELECT
        TO_CHAR(txn_date,'Mon YYYY') AS month,
        COUNT(*) AS txns
    FROM transactions
    GROUP BY TO_CHAR(txn_date,'Mon YYYY'),txn_year,txn_month
    ORDER BY txns DESC LIMIT 1
),
segment_leader AS (
    SELECT u.segment_name, ROUND(SUM(t.amount)/1e7,2) AS val
    FROM transactions t
    JOIN users u ON t.user_id = u.user_id
    GROUP BY u.segment_name
    ORDER BY val DESC LIMIT 1
),
fraud_peak AS (
    SELECT merchant_category,
           ROUND(SUM(is_fraud)*100.0/COUNT(*),3) AS fraud_rate
    FROM transactions
    GROUP BY merchant_category
    ORDER BY fraud_rate DESC LIMIT 1
),
yoy AS (
    SELECT
        ROUND(SUM(CASE WHEN txn_year=2022
              THEN amount ELSE 0 END)/1e7,2)            AS val_2022,
        ROUND(SUM(CASE WHEN txn_year=2023
              THEN amount ELSE 0 END)/1e7,2)            AS val_2023,
        COUNT(CASE WHEN txn_year=2022 THEN 1 END)       AS txns_2022,
        COUNT(CASE WHEN txn_year=2023 THEN 1 END)       AS txns_2023
    FROM transactions
)
SELECT
    '== OVERALL KPIs =='                                AS section,
    'Total Transactions'                                AS metric,
    o.total_txns::TEXT                                  AS value
FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Total Users',
    o.total_users::TEXT FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Total Merchants',
    o.total_merchants::TEXT FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Total Value (Crore)',
    '₹' || o.total_value_crore::TEXT FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Avg Transaction Amount',
    '₹' || o.avg_txn_amount::TEXT FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Success Rate',
    o.success_rate::TEXT || '%' FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Fraud Rate',
    o.fraud_rate::TEXT || '%' FROM overall o
UNION ALL SELECT '== OVERALL KPIs ==','Fraud Value (Lakhs)',
    '₹' || o.fraud_value_lakhs::TEXT FROM overall o
UNION ALL SELECT '== PLATFORM ==','Market Leader',
    p.platform_used FROM top_platform p
UNION ALL SELECT '== CATEGORY ==','Highest Value Category',
    c.merchant_category || ' (₹' || c.val::TEXT || ' Cr)'
    FROM top_category c
UNION ALL SELECT '== GEOGRAPHY ==','Top City by Volume',
    t.user_city FROM top_city t
UNION ALL SELECT '== TIME ==','Peak Month',
    pk.month FROM peak_month pk
UNION ALL SELECT '== SEGMENT ==','Highest Value Segment',
    s.segment_name || ' (₹' || s.val::TEXT || ' Cr)'
    FROM segment_leader s
UNION ALL SELECT '== FRAUD ==','Highest Risk Category',
    f.merchant_category || ' (' || f.fraud_rate::TEXT || '%)'
    FROM fraud_peak f
UNION ALL SELECT '== YOY ==','2022 Total Value',
    '₹' || y.val_2022::TEXT || ' Cr' FROM yoy y
UNION ALL SELECT '== YOY ==','2023 Total Value',
    '₹' || y.val_2023::TEXT || ' Cr' FROM yoy y
UNION ALL SELECT '== YOY ==','2022 Transactions',
    y.txns_2022::TEXT FROM yoy y
UNION ALL SELECT '== YOY ==','2023 Transactions',
    y.txns_2023::TEXT FROM yoy y;
