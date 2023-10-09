WITH 
EducationMinMax AS (
    SELECT MIN(value) AS min_education, MAX(value) AS max_education
    FROM educational_attainment_v2
    WHERE year BETWEEN 2010 AND 2022
),
EqualityMinMax AS (
    SELECT MIN(value) AS min_equality, MAX(value) AS max_equality
    FROM equality_v2
    WHERE year BETWEEN 2010 AND 2022
),
UnemploymentMinMax AS (
    SELECT MIN(value) AS min_unemployment, MAX(value) AS max_unemployment
    FROM unemployment_v2
    WHERE year BETWEEN 2010 AND 2022
),
BusinessMinMax AS (
    SELECT 
        MIN(f.value) AS min_business_female,
        MIN(m.value) AS min_business_men,
        MAX(f.value) AS max_business_female,
        MAX(m.value) AS max_business_men
    FROM time_business_female_v2 f
    JOIN time_business_men_v2 m ON f.economy = m.economy AND f.year = m.year
    WHERE f.year BETWEEN 2010 AND 2022
),
EducationAvg AS (
    SELECT economy, AVG(value) AS avg_education
    FROM educational_attainment_v2
    WHERE year BETWEEN 2010 AND 2022
    GROUP BY economy
),
EqualityAvg AS (
    SELECT economy, AVG(value) AS avg_equality
    FROM equality_v2
    WHERE year BETWEEN 2010 AND 2022
    GROUP BY economy
),
BusinessAvg AS (
    SELECT 
        e.economy,
        AVG(e.value) AS avg_business_female,
        AVG(m.value) AS avg_business_men,
        AVG(m.value - e.value) AS business_gender_gap
    FROM 
        time_business_female_v2 e
    JOIN 
        time_business_men_v2 m ON e.economy = m.economy AND e.year = m.year
    WHERE 
        e.year BETWEEN 2010 AND 2022
    GROUP BY 
        e.economy
),
UnemploymentAvg AS (
    SELECT economy, AVG(value) AS avg_unemployment
    FROM unemployment_v2
    WHERE year BETWEEN 2010 AND 2022
    GROUP BY economy
),
FinalData AS (
    SELECT 
        c.name,
        ROUND((e.avg_education - em.min_education) / (em.max_education - em.min_education) * 100, 1) AS normalized_education,
        ROUND((eq.avg_equality - eqm.min_equality) / (eqm.max_equality - eqm.min_equality) * 100, 1) AS normalized_equality,
        ROUND((u.avg_unemployment - um.min_unemployment) / (um.max_unemployment - um.min_unemployment) * 100, 1) AS normalized_unemployment,
        ROUND((b.avg_business_female - bm.min_business_female) / (bm.max_business_female - bm.min_business_female) * 100, 1) AS normalized_business_female,
        ROUND((b.avg_business_men - bm.min_business_men) / (bm.max_business_men - bm.min_business_men) * 100, 1) AS normalized_business_men,
        ROUND((b.business_gender_gap - bm.min_business_men + bm.max_business_female) / (bm.max_business_men - bm.min_business_female) * 100, 1) AS normalized_business_gender_gap
    FROM 
        country_info c
    LEFT JOIN EducationAvg e ON c.id = e.economy
    LEFT JOIN EqualityAvg eq ON c.id = eq.economy
    LEFT JOIN BusinessAvg b ON c.id = b.economy
    LEFT JOIN UnemploymentAvg u ON c.id = u.economy
    CROSS JOIN EducationMinMax em
    CROSS JOIN EqualityMinMax eqm
    CROSS JOIN UnemploymentMinMax um
    CROSS JOIN BusinessMinMax bm
)

SELECT 
    name,
    normalized_education,
    normalized_equality,
    normalized_unemployment,
    normalized_business_female,
    normalized_business_men,
    normalized_business_gender_gap,
    ROUND((COALESCE(normalized_education, 0) + COALESCE(normalized_equality, 0) + COALESCE(normalized_business_female, 0) + COALESCE(normalized_business_men, 0) + COALESCE(normalized_unemployment, 0) + COALESCE(normalized_business_gender_gap, 0)) / 6, 1) AS "Grade on 100"
FROM 
    FinalData
WHERE 
    normalized_education IS NOT NULL 
    AND normalized_equality IS NOT NULL 
    AND normalized_business_female IS NOT NULL 
    AND normalized_business_men IS NOT NULL 
    AND normalized_unemployment IS NOT NULL
    AND normalized_business_gender_gap IS NOT NULL;
