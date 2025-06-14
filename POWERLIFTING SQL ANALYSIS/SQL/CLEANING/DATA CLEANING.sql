-- Data Cleaning

-- Lower cases all first and last names for all 4 tables so they can be joined on later
UPDATE total
SET first_name = LOWER(first_name),
    last_name = LOWER(last_name)

UPDATE squat
SET first_name = LOWER(first_name),
    last_name = LOWER(last_name)

UPDATE bench_press
SET first_name = LOWER(first_name),
    last_name = LOWER(last_name)

UPDATE deadlift
SET first_name = LOWER(first_name),
    last_name = LOWER(last_name)

-- The superheavy weight class is denoted as 'SHW'. This is denoted as 308+ for men and 220+ for women.
-- This approached standardizes the approach to make caluclations and anylysis easier. 
UPDATE total
SET weight_class = 'SHW'
WHERE weight_class LIKE '%+%'

UPDATE squat
SET weight_class = 'SHW'
WHERE weight_class LIKE '%+%'

UPDATE bench_press
SET weight_class = 'SHW'
WHERE weight_class LIKE '%+%'

UPDATE deadlift
SET weight_class = 'SHW'
WHERE weight_class LIKE '%+%'

-- Different powerlifting federations differ slighlty in the weight class by +/- 2 lbs or so, which is a neglible amount
-- for performance but not for the analysis. All weight classes need to be standardized to the internationally recognized classes
UPDATE total
SET weight_class = CASE
    WHEN weight_class IN ('135', '136', '137') THEN '132'
    WHEN weight_class = '152' THEN '148'
    WHEN weight_class IN ('163', '167') THEN '165'
    WHEN weight_class = '200' THEN '198'
    WHEN weight_class = '222' THEN '220'
    ELSE weight_class
END

UPDATE squat
SET weight_class = CASE
    WHEN weight_class IN ('135', '136', '137') THEN '132'
    WHEN weight_class = '152' THEN '148'
    WHEN weight_class IN ('163', '167') THEN '165'
    WHEN weight_class = '200' THEN '198'
    WHEN weight_class = '222' THEN '220'
    ELSE weight_class
END

UPDATE bench_press
SET weight_class = CASE
    WHEN weight_class IN ('135', '136', '137') THEN '132'
    WHEN weight_class = '152' THEN '148'
    WHEN weight_class IN ('163', '167') THEN '165'
    WHEN weight_class = '200' THEN '198'
    WHEN weight_class = '222' THEN '220'
    ELSE weight_class
END

UPDATE deadlift
SET weight_class = CASE
    WHEN weight_class IN ('135', '136', '137') THEN '132'
    WHEN weight_class = '152' THEN '148'
    WHEN weight_class IN ('163', '167') THEN '165'
    WHEN weight_class = '200' THEN '198'
    WHEN weight_class = '222' THEN '220'
    ELSE weight_class
END;
