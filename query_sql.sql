WITH tb AS (
    SELECT MAX(DATE(data)) AS data
    FROM calendario
    WHERE YEAR(DATE(data)) = 2022
)
SELECT 
    YEAR(DATE(ca.data)) AS ano,
    MONTH(DATE(ca.data)) AS mes,
    CAST(ca.type AS INTEGER) AS tipo_plano,
    COUNT(DISTINCT ca.id) AS customers
FROM customers_acumulados ca
INNER JOIN tb ON DATE(ca.data) = tb.data
WHERE YEAR(DATE(ca.data)) >= 2022
  AND MONTH(DATE(ca.data)) = 5
GROUP BY 1, 2, 3
ORDER BY 1, 2;
