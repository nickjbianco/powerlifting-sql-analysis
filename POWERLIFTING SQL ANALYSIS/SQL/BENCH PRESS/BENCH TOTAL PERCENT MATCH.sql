WITH
total_lifters AS (
-- Returns the total amount of lifters per weight class and sex
	SELECT
		sex, weight_class,
		COUNT(*) AS total_lifters
	FROM bench_press
	GROUP BY weight_class, sex
), 
matching_counts AS (
-- Returns the amount of lifters with top bench presses and top totals
	SELECT
		b.sex, b.weight_class, 
		COUNT(*) AS matching_lifters
	FROM bench_press b
	JOIN total t
	ON b.first_name = t.first_name
	AND b.last_name = t.last_name
	AND b.sex = t.sex
	AND b.weight_class = t.weight_class
	GROUP BY b.weight_class, b.sex
), 
matching_percentage AS (
-- Returns the percentage of lifters who have top bench presses and totals per weight class and sex
	SELECT 
		t.sex, t.weight_class, 
		ROUND(matching_lifters/total_lifters::numeric * 100, 2) AS percent_match
	FROM total_lifters t
	INNER JOIN matching_counts m
	ON t.sex = m.sex 
	AND t.weight_class = m.weight_class
	ORDER BY t.weight_class, t.sex
)

-- Returns the final table accounting for the fact some categories have 0 lifters with totals
SELECT 
	t.sex, t.weight_class, 
	CASE 
		WHEN percent_match IS NULL THEN 0 ELSE percent_match
	END AS percent_match
FROM total_lifters t
LEFT JOIN matching_percentage m
ON t.sex = m.sex 
AND t.weight_class = m.weight_class
ORDER BY t.weight_class, t.sex