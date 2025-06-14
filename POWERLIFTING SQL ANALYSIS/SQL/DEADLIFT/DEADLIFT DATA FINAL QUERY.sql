WITH 
avg_by_sex_weight AS (
-- Returns average deadlift by sex and weight class
	SELECT 
		sex, weight_class, 
		ROUND(AVG(deadlift), 2) AS avg_deadlift
	FROM deadlift
	GROUP BY sex, weight_class
	ORDER BY weight_class, sex
), 
poundage_diff AS (
-- Returns the weight differene between sex's average respective deadlift in the same weight class
	SELECT
		sex, weight_class, avg_deadlift,
		avg_deadlift - LAG(avg_deadlift) OVER(PARTITION BY weight_class ORDER BY avg_deadlift) AS weight_diff
	FROM avg_by_sex_weight
), 
total_average AS (
-- Returns the average deadlift per weight class with combined sexes
	SELECT
		weight_class, 
		ROUND(AVG(deadlift), 2) AS overall_avg
	FROM deadlift
	GROUP BY weight_class
), 
percent_diff AS (
-- Returns the percentage difference by weight class between the average deadlift between the sexes
	SELECT 
		pd.sex, pd.weight_class, weight_diff, avg_deadlift,
		ROUND(weight_diff/overall_avg * 100, 2) AS percent_diff
	FROM poundage_diff pd
	INNER JOIN total_average ta
	ON pd.weight_class = ta.weight_class
), 
non_shw_ratio AS (
-- Returns the strength to bodyweight ratio without the superheavy weights
	SELECT 
		sex, weight_class, avg_deadlift, weight_diff, percent_diff, 
		ROUND((avg_deadlift/weight_class::numeric), 2) AS strength_ratio
	FROM percent_diff
	WHERE weight_class != 'SHW'
), 
shw_avg_bodyweight AS (
-- Returns the average bodyweight by sex of the superheavy weights
	SELECT 
		weight_class, sex, 
		AVG(bodyweight) AS avg_bodyweight
	FROM deadlift
	GROUP BY weight_class, sex
	HAVING weight_class = 'SHW'
), 
shw_ratio AS (
-- Returns the strength to bodyweight ratio for the superheavy weights respective to sex
	SELECT 
		pd.sex, pd.weight_class, avg_deadlift, weight_diff, percent_diff,
		ROUND((avg_deadlift/avg_bodyweight), 2) AS strength_ratio
	FROM percent_diff pd
	INNER JOIN shw_avg_bodyweight sab
	ON pd.sex = sab.sex AND pd.weight_class = sab.weight_class
), 
weight_data AS (
-- Returns the average deadlift, weight & percentage difference and strength to bodyweight ratio
-- by sex and weigh class
	SELECT * FROM non_shw_ratio
	UNION ALL 
	SELECT * FROM shw_ratio
), 
age_data AS (
-- Returns the youngest, oldest and average age by sex and weight class
	SELECT 
		sex, weight_class, 
		MIN(age) AS youngest, 
		MAX(age) AS oldest, 
		ROUND(AVG(age), 2) AS average_age
	FROM deadlift
	GROUP BY weight_class, sex
	ORDER BY weight_class, sex
)
-- Returns all age & weight data from the combined tables
SELECT
	wd.sex, wd.weight_class, avg_deadlift, 
	weight_diff, percent_diff, strength_ratio, 
	youngest, oldest, average_age
FROM weight_data wd
INNER JOIN age_data ad
ON wd.sex = ad.sex AND wd.weight_class = ad.weight_class