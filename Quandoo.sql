-- total reservations
SELECT COUNT(RESERVATION_ID) AS TOTAL_RESERVATIONS
FROM RESERVATIONS;

-- reservation status
SELECT RESERVATION_STATUS,
	COUNT(RESERVATION_STATUS) AS RES_COUNT
FROM RESERVATIONS
GROUP BY 1
ORDER BY 2 DESC;

-- marketing channel
SELECT MARKETING_CHANNEL,
	COUNT(MARKETING_CHANNEL) AS CHANNEL_COUNT
FROM RESERVATIONS
GROUP BY 1
ORDER BY 2 DESC;

-- Identify the most important cities
SELECT M.CITY,
	ROUND(SUM(R.REVENUE)::numeric,
		2) AS TOTAL_REVENUE
FROM MERCHANTS M
JOIN RESERVATIONS R ON M.MERCHANT_ID = R.MERCHANT_ID
GROUP BY M.CITY
ORDER BY TOTAL_REVENUE DESC
LIMIT 5;

-- Month to Month revenue 
WITH
  monthly_revenue AS (
  SELECT
    DATE_TRUNC('month', CAST(reservation_created_date AS TIMESTAMP)) AS month,
    country,
    SUM(revenue) OVER (PARTITION BY country, DATE_TRUNC('month', CAST(reservation_created_date AS TIMESTAMP))
    ORDER BY
      reservation_created_date) AS running_total_revenue
  FROM
    reservations )
SELECT
  month,
  country,
  CAST(MAX(running_total_revenue) AS numeric(10,
      2)) AS monthly_running_total_revenue,
  CAST( (MAX(running_total_revenue) - LAG(MAX(running_total_revenue)) OVER (PARTITION BY country ORDER BY month)) / NULLIF(LAG(MAX(running_total_revenue)) OVER (PARTITION BY country ORDER BY month), 0) * 100 AS numeric(10,
      2) ) AS percentage_change
FROM
  monthly_revenue
GROUP BY
  1,
  2
ORDER BY
  2,
  1;
