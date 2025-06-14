
	WITH 
	avg_by_sex_weight AS (
	-- Returns average total by sex and weight class
		SELECT 
			sex, weight_class, 
			ROUND(AVG(total), 2) AS avg_total
		FROM total
		GROUP BY sex, weight_class
		ORDER BY weight_class
	), 
	poundage_diff AS (
	-- Returns the difference in poundage between same weight class totals between genders
		SELECT 
			sex, weight_class, 
			avg_total - LAG(avg_total) OVER(PARTITION BY weight_class ORDER BY avg_total) AS weight_diff
		FROM avg_by_sex_weight
	), 
	overall_avg AS (
	-- Return average total by weight class combined sexes 
		SELECT 
			weight_class, 
			ROUND(AVG(total), 2) AS overall_avg
		FROM total
		GROUP BY weight_class
		ORDER BY weight_class
	),
	percent_diff_by_weightclass AS (
	-- Returns the percent difference between the average 
		SELECT 
			pd.sex, pd.weight_class, pd.weight_diff, overall_avg,
			ROUND(pd.weight_diff / oa.overall_avg * 100, 2) AS percent_diff
		FROM poundage_diff pd
		INNER JOIN overall_avg oa
	ON pd.weight_class = oa.weight_class 
	), 
	non_shw_strength_ratio AS (
	-- Strength to bodyweight ratio by sex and weight class
		SELECT 
			sex, weight_class, avg_total, 
			ROUND((avg_total / weight_class::numeric), 2) AS strength_ratio
		FROM avg_by_sex_weight
		WHERE weight_class != 'SHW'
	), 
	avg_shw_bodyweight AS (
	-- Returns the average superheavy weight bodyweight by sex
		SELECT  
			sex, weight_class, 
			ROUND(AVG(bodyweight), 2) AS avg_bodyweight
		FROM total
		GROUP BY sex, weight_class
		HAVING weight_class = 'SHW'
	), 
	shw_avg_total_bodyweight AS (
	-- Returns shw average bodyweight, total by sex, and the weight difference in total
		SELECT 
			asw.sex, asw.weight_class, avg_total, avg_bodyweight, weight_diff
		FROM avg_by_sex_weight asw
		INNER JOIN avg_shw_bodyweight asb
		ON asw.sex = asb.sex AND asw.weight_class = asb.weight_class
		INNER JOIN poundage_diff pd
		ON asb.sex = pd.sex AND asb.weight_class = pd.weight_class
	), 
	shw_strength_ratio AS (
	-- Returns strength to bodyweight ratio for the super heavies
		SELECT 
			sex, weight_class, avg_total, 
			ROUND((avg_total / avg_bodyweight), 2) AS strength_bodyweight_ratio
		FROM shw_avg_total_bodyweight
	), 
	all_strength_ratio AS (
	-- Returns all strength to bodyweight ratios
		SELECT * FROM non_shw_strength_ratio
		UNION ALL
		SELECT * FROM shw_strength_ratio
		ORDER BY weight_class, sex
	), 
	total_weight_data AS (
	-- Returns a table of average totals by sex and weight class with the difference in weight (lbs) & percent
	-- for men and women in the same weight class and their respective strength to bodyweight ratios
		SELECT 
			pdw.sex, pdw.weight_class, avg_total, weight_diff, percent_diff, strength_ratio 
		FROM percent_diff_by_weightclass pdw
		INNER JOIN all_strength_ratio asr
		ON pdw.sex = asr.sex AND pdw.weight_class = asr.weight_class
	), 
	total_age_data AS (
	-- Returns a table of the youngest, oldest and average age by sex and weight class
		SELECT 
			sex, weight_class, 
			MIN(age) AS youngest, 
			MAX(age) AS oldest, 
			ROUND(AVG(age), 2) AS avg_age
		FROM total
		GROUP BY sex, weight_class
		ORDER BY weight_class, sex
	)
	
	-- Final query returning all data:
	-- avg total by sex and weight class
	-- The weight & percent difference between the totals of the 2 sexes per weight class
	-- The strengh to bodyweight ratios by sex and weight class
	-- Youngest, oldest and average age by sex and weight class
	SELECT 
		tw.sex, tw.weight_class, avg_total, 
		weight_diff, percent_diff, strength_ratio, 
		youngest, oldest, avg_age
	FROM total_weight_data tw
	INNER JOIN total_age_data ta
	ON tw.sex = ta.sex AND tw.weight_class = ta.weight_class




