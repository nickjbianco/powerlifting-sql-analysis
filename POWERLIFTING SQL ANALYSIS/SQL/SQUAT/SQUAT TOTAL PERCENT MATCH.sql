WITH
squat_counts AS (
-- Returns the number of top squatters per sex and weight class
	SELECT 	
		sex, weight_class, 
		COUNT(*) AS total_lifters
	FROM squat
	GROUP BY sex, weight_class
	ORDER BY weight_class, sex
), 
matching_counts AS (
-- Returns the number of lifters by sex and weight class who have top 30 squats and totals
	SELECT
		s.sex, s.weight_class, 
		COUNT(*) AS matching_lifters
	FROM squat s
	INNER JOIN total t
	ON s.first_name = t.first_name
	AND s.last_name = t.last_name
	AND s.weight_class = t.weight_class
	GROUP BY s.sex, s.weight_class
)
-- Returns the matching percent of top 30 squatters who also have top 30 totals by sex and weight class
SELECT 
	s.sex, s.weight_class, 
	ROUND((matching_lifters/total_lifters::numeric * 100), 2) AS percent_match
FROM squat_counts s
INNER JOIN matching_counts m
ON s.sex = m.sex AND s.weight_class = m.weight_class
ORDER BY weight_class, sex