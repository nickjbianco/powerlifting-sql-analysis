WITH
total_lifters AS (
-- Returns the total amount of deadlifts per weight class
	SELECT 
		sex, weight_class, 
		COUNT(*) AS total_lifters
	FROM deadlift
	GROUP BY weight_class, sex
), 
matching_counts AS (
-- Returns the amount of lifters that have top deadlifts with top totals
	SELECT
		d.sex, d.weight_class, 
		COUNT(*) AS matching_lifters
	FROM deadlift d
	INNER JOIN total t
	ON d.first_name = t.first_name
	AND d.last_name = t.last_name
	AND d.sex = t.sex 
	AND d.weight_class = t.weight_class
	GROUP BY d.weight_class, d.sex
)
-- Returns the percentage match of top deadlfiters who also have top totals by weight class
SELECT 
	tl.sex, tl.weight_class, 
	ROUND(matching_lifters/total_lifters::numeric*100, 2) AS percent_match
FROM total_lifters tl
INNER JOIN matching_counts mc
ON tl.weight_class = mc.weight_class 
AND tl.sex = mc.sex
ORDER BY tl.weight_class, tl.sex
