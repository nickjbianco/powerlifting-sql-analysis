WITH
sex_weight_avg AS (
-- Returns the average bench press weight by sex and weight class
	SELECT 
		sex, weight_class, 
		ROUND(AVG(bench_press), 2) AS avg_bench
	FROM bench_press
	GROUP BY sex, weight_class
	ORDER BY weight_class, sex
), 
poundage_diff AS (
-- Returns the weight difference in lbs per weight class between the sexes
	SELECT 
		sex, weight_class, avg_bench,
		avg_bench - LAG(avg_bench) OVER(PARTITION BY weight_class ORDER BY avg_bench) AS weight_diff
	FROM sex_weight_avg
), 
overall_avg AS (
-- Returns the average overall bench press per weight class for combined sexes
	SELECT
		weight_class, 
		AVG(bench_press) AS avg_total_bench
	FROM bench_press
	GROUP BY weight_class
), 
percent_diff AS (
-- Returns the percent difference between the bench presses per weight class within the 2 sexes
	SELECT 
		pd.sex, pd.weight_class, avg_bench, weight_diff, 
		ROUND((weight_diff/avg_total_bench * 100), 2) AS percent_diff
	FROM poundage_diff pd
	INNER JOIN overall_avg oa
	ON pd.weight_class = oa.weight_class
), 
non_shw_ratio AS (
-- Returns the strength to bodyweight bench press strength ratio by sex and weight class without the superheavy weights
	SELECT 
		sex, weight_class, avg_bench, weight_diff, percent_diff, 
		ROUND((avg_bench/weight_class::numeric), 2) AS strength_ratio
	FROM percent_diff
	WHERE weight_class != 'SHW'
), 
avg_shw_bodyweight AS (
-- Returns the average bodyweight for a superheavy weight per sex
	SELECT
		sex, weight_class, 
		AVG(bodyweight) AS avg_bodyweight
	FROM bench_press
	GROUP BY sex, weight_class
	HAVING weight_class = 'SHW'
), 
shw_ratio AS (
-- Returns the strength to bodyweight ratio for the superheavy weights by sex 
	SELECT 
		pd.sex, pd.weight_class, avg_bench, weight_diff, percent_diff, 
		ROUND((avg_bench/avg_bodyweight), 2) AS strength_ratio
	FROM percent_diff pd
	INNER JOIN avg_shw_bodyweight ab
	ON pd.sex = ab.sex AND pd.weight_class = ab.weight_class
), 
weight_data AS (
-- Returns all weight data for bench press such as average bench by sex and weight class
-- weight, percentage & strength to bodyweight ratio differences between the sexes in the same weight class
	SELECT * FROM non_shw_ratio
	UNION ALL 
	SELECT * FROM shw_ratio
	ORDER BY weight_class, sex
), 
age_data AS (
-- Returns the youngest, oldest and average age by weight class and gender
	SELECT 
		sex, weight_class, 
		MIN(age) AS youngest, 
		MAX(age) AS oldest, 
		ROUND(AVG(age), 2) AS avg_age
	FROM bench_press
	GROUP BY sex, weight_class
	ORDER BY weight_class, sex
)

-- Returns the final table containing data from both the weight and age tables
SELECT 
	w.sex, w.weight_class, avg_bench, 
	weight_diff, percent_diff, strength_ratio, 
	youngest, oldest, avg_age
FROM weight_data w
INNER JOIN age_data a
ON w.sex = a.sex AND w.weight_class = a.weight_class