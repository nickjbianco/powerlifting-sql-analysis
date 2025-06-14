# Powerlifting All-Time Raw Data Analysis (SQL, Excel, Tableau)

This project is a full-scale analysis of the top 30-35 all-time top raw (no knee wraps) powerlifters, segmented by sex and weight class. The goal was to explore trends in strength performance, age distribution, and bodyweight-adjusted outputs across four lift categories: squat, bench press, deadlift, and total (sum total of the squat, bench and deadlift per lifter per competition).

The project was developed independently using over 500 lines of advanced SQL, with final data compiled in Excel and presented visually through Tableau dashboards.

## Data Source

The raw data was sourced from [OpenPowerlifting.org](https://www.openpowerlifting.org/), a free and open-source database of powerlifting meet results.

Only the top 30-35 raw (no wraps) lifters of all time were included per lift (squat, bench press, deadlift, and total), segmented by sex and weight class. Data was filtered and cleaned using SQL before final analysis.

## Project Objectives

- Analyze the top 30–35 raw lifters of all time for each lift and weight class by sex.
- Compare absolute and relative performance (strength-to-bodyweight ratio) between male and female lifters.
- Calculate weight and percentage differences in lift performance between sexes per weight class.
- Identify age trends: youngest, oldest, and average age per lift, sex, and weight class.
- Evaluate crossover dominance: how many top squat, bench press, or deadlift performers also had top totals.

## Dataset Overview

- Lifters were selected based on top 30-35 all-time rankings for raw (no wraps) performances.
- Includes male and female lifters across standard weight classes: 132, 148, 165, 181, 198, 220, and Superheavyweight (SHW). Male only weight class: 242, 275, 308
- Data was cleaned and normalized to address:
  - Inconsistent casing of names
  - Weight class mismatches across federations (e.g., 135 → 132, 222 → 220)
  - Non-integer or malformed age values
  - Superheavyweight classes originally labeled as "308+" for men or "220+" for women.

## Technical Stack

- SQL (PostgreSQL syntax)
- Excel (for dataset consolidation and output validation)
- Tableau (for final visual analysis)

## SQL Techniques Used

- Common Table Expressions (CTEs)
- Window functions (`LAG`)
- Aggregations (`AVG`, `MIN`, `MAX`, `COUNT`)
- Conditional logic
- `JOIN`, `UNION`, and subqueries

## File Structure

powerlifting-sql-analysis/

- sql
  - bench_press
    - BENCH PRESS DATA FINAL QUERY.sql
    - BENCH TOTAL PERCENT MATCH.sql
  - squat
    - SQUAT FINAL QUERY.sql
    - SQUAT TOTAL PERCENT MATCH.sql
  - deadlift
    - DEADLIFT DATA FINAL QUERY.sql
    - DEADLIFT TOTAL PERCENT MATCH.sql
  - total
    - TOTAL_DATA_QUERY.sql
  - cleaning
    - DATA CLEANING.sql
- data
  - MASTER DATA SHEET.xlsx

## Sample Insights

- In lighter weight classes, strength-to-bodyweight ratios were higher, especially for female lifters.
- Gender performance gaps (absolute and percent) increased in higher weight classes particularly in the bench press, but disparaties were much closer than expected in the lighter weight classes for the squat and deadlift.
- SHW lifters had the highest absolute strength but lowest relative strength ratios.
- Most top squat and deadlift performers were also top total lifters, while the bench press showed less crossover.
- Age range was much larger than expected with lifters from either sex in their 40s and 50s across all lifts and weight classes. The bench press showed the highest average age.

## Author

Nicholas J. Bianco  
Email: nickjbianco25@gmail.com  
Cell: 201.264.6780
Portfolio: https://github.com/nickjbianco  
LinkedIn: https://www.linkedin.com/public-profile/settings?trk=d_flagship3_profile_self_view_public_profile
