
WITH 
avg_sex_weight AS (
-- Returns average squat by sex and weight_class
	SELECT 
		sex, weight_class, 
		ROUND(AVG(squat), 2) AS avg_squat
	FROM squat
	GROUP BY sex, weight_class
	ORDER BY weight_class
), 
poundage_diff AS (
-- Returns the weight difference between the average male & female squat respectively per weight class
	SELECT 
		sex, weight_class, avg_squat, 
		avg_squat - LAG(avg_squat) OVER(PARTITION BY weight_class ORDER BY avg_squat) AS weight_diff
	FROM avg_sex_weight
), 
weight_class_avg AS (
-- Returns overall weight class average squat combined sexes
	SELECT
		weight_class, 
		ROUND(AVG(squat), 2) AS avg_total_squat
	FROM squat
	GROUP BY weight_class
	ORDER BY weight_class
), 
squat_weight_data AS (
-- Returns the average squat per sex and weight class with the weight & percent difference between the sexes in the same class
	SELECT 
		sex, pd.weight_class, avg_squat, weight_diff, 
		ROUND((weight_diff/avg_total_squat * 100), 2) AS percent_diff
	FROM poundage_diff pd
	INNER JOIN weight_class_avg wca
	ON pd.weight_class = wca.weight_class
), 
age_data AS (
-- Returns youngest, oldest and average age by sex and weight class
	SELECT
		sex, weight_class, 
		MIN(age) AS youngest,
		MAX(age) AS oldest,
		ROUND(AVG(age), 2) AS avg_age
	FROM squat
	GROUP BY sex, weight_class
), 
age_weight_data AS (
-- Returns combination of the squat weight and age tables
	SELECT
	 	swd.sex, swd.weight_class, 
		avg_squat, weight_diff, percent_diff, 
		youngest, oldest, avg_age
	FROM squat_weight_data swd
	INNER JOIN age_data ad
	ON swd.sex = ad.sex AND swd.weight_class = ad.weight_class
), 
non_shw_ratio AS (
-- Returns non SHW strength to bodyweight squat ratio
	SELECT 
		sex, weight_class, avg_squat,
		ROUND((avg_squat/weight_class::numeric), 2) AS strength_ratio
	FROM age_weight_data
	WHERE weight_class != 'SHW'
	ORDER BY weight_class, sex
), 
shw_avg_bodyweight AS (
-- Returns average bodyweight of the super heavyweight by sex
	SELECT 
		sex, weight_class, 
		ROUND(AVG(bodyweight), 2) AS avg_bodyweight
	FROM squat
	GROUP BY sex, weight_class
	HAVING weight_class = 'SHW'
), 
shw_strength_ratio AS (
-- Returns the strength to bodyweight ratio for the squat with the superheavy weights
	SELECT 
		s.sex, s.weight_class, avg_squat, 
		ROUND((avg_squat/avg_bodyweight), 2) AS strength_ratio
	FROM shw_avg_bodyweight s
	INNER JOIN avg_sex_weight a
	ON a.sex = s.sex AND a.weight_class = s.weight_class
), 
all_ratios AS (
-- Returns the strength to bodyweight ratios for the squat for all weight classes by sex
	SELECT * FROM non_shw_ratio
	UNION ALL 
	SELECT * FROM shw_strength_ratio
	ORDER BY weight_class, sex
)
-- Final query that returns an all inclusive table of all squat weight and age information by sex and weight class
	SELECT 
		awd.sex, awd.weight_class, 
		awd.avg_squat, weight_diff, percent_diff, 
		youngest, oldest, avg_age, strength_ratio
	FROM age_weight_data awd
	INNER JOIN all_ratios ar
	ON awd.sex = ar.sex AND awd.weight_class = ar.weight_class
	ORDER BY weight_class, sex


