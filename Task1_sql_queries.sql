
-- Q1: Top 5 districts with the highest number of colleges offering professional courses
SELECT District, COUNT(DISTINCT CollegeName) AS ProfessionalCollegeCount
FROM college_courses
WHERE IsProfessional = 'Professional Course'
GROUP BY District
ORDER BY ProfessionalCollegeCount DESC
LIMIT 5;

-- Q2: Average course duration (in months) for each Course Type and sort descending
SELECT CourseType, ROUND(AVG(CourseDuration), 2) AS AvgDuration
FROM college_courses
GROUP BY CourseType
ORDER BY AvgDuration DESC;

-- Q3: Unique college offering each Course Category
SELECT CourseCategory, COUNT(DISTINCT CollegeName) AS UniqueCollegeCount
FROM college_courses
GROUP BY CourseCategory;

-- Q4: Colleges offering both Post Graduate and Under Graduate courses
SELECT CollegeName
FROM college_courses
WHERE CourseType IN ('Post Graduate Course', 'Under Graduate Course')
GROUP BY CollegeName
HAVING COUNT(DISTINCT CourseType) = 2;

-- Q5: Universities with more than 10 unaided, non-professional courses
SELECT University
FROM college_courses
WHERE Course = 'UnAided' AND IsProfessional = 'Non-Professional Course'
GROUP BY University
HAVING COUNT(*) > 10;

-- Q6: Engineering colleges with at least one course above the average duration
WITH EngAvg AS (
  SELECT AVG(CourseDuration) AS AvgDuration
  FROM college_courses
  WHERE CourseCategory = 'Engineering'
)
SELECT DISTINCT CollegeName
FROM college_courses, EngAvg
WHERE CourseCategory = 'Engineering'
  AND CourseDuration > EngAvg.AvgDuration;


-- Q7: Rank courses within a college based on course duration (longest first)
SELECT CollegeName, CourseName, CourseDuration,
       RANK() OVER (PARTITION BY CollegeName ORDER BY CourseDuration DESC) AS DurationRank
FROM college_courses;

-- Q8: Colleges where longest and shortest course durations differ by more than 24 months
SELECT CollegeName
FROM college_courses
GROUP BY CollegeName
HAVING MAX(CourseDuration) - MIN(CourseDuration) > 24;

-- Q9: Cumulative number of professional courses offered by each university sorted alphabetically
SELECT University, COUNT(*) AS ProfessionalCourseCount
FROM college_courses
WHERE IsProfessional = 'Professional Course'
GROUP BY University
ORDER BY University;

-- Q10: Colleges offering more than one course category (using self-join)
SELECT DISTINCT A.CollegeName
FROM college_courses A
JOIN college_courses B
  ON A.CollegeName = B.CollegeName AND A.CourseCategory <> B.CourseCategory;

-- Q11: Talukas where average course duration is above district average
WITH DistrictAvg AS (
  SELECT District, AVG(CourseDuration) AS DistrictAvg
  FROM college_courses
  GROUP BY District
),
TalukaAvg AS (
  SELECT District, Taluka, AVG(CourseDuration) AS TalukaAvg
  FROM college_courses
  GROUP BY District, Taluka
)
SELECT t.Taluka, t.District, t.TalukaAvg, d.DistrictAvg
FROM TalukaAvg t
JOIN DistrictAvg d ON t.District = d.District
WHERE t.TalukaAvg > d.DistrictAvg;

-- Q12: Classify course duration and count per Course Category
SELECT CourseCategory,
       CASE
         WHEN CourseDuration < 12 THEN 'Short'
         WHEN CourseDuration BETWEEN 12 AND 36 THEN 'Medium'
         ELSE 'Long'
       END AS DurationType,
       COUNT(*) AS CourseCount
FROM college_courses
GROUP BY CourseCategory, DurationType;

-- Q13: Extract course specialization from CourseName
SELECT CourseName,
       TRIM(SUBSTR(CourseName, INSTR(CourseName, '-') + 1)) AS Specialization
FROM college_courses
WHERE CourseName LIKE '%-%';

-- Q14: Count how many courses include the word "Engineering"
SELECT COUNT(*) AS EngineeringCourseCount
FROM college_courses
WHERE CourseName LIKE '%Engineering%';

-- Q15: Unique combinations of CourseName, CourseType, and CourseCategory
SELECT DISTINCT CourseName, CourseType, CourseCategory
FROM college_courses;

-- Q16: All courses not offered by Government colleges
SELECT *
FROM college_courses
WHERE CollegeType <> 'Government';

-- Q17: University with the second-highest number of aided courses
SELECT University, COUNT(*) AS AidedCourseCount
FROM college_courses
WHERE Course = 'Aided'
GROUP BY University
ORDER BY AidedCourseCount DESC
LIMIT 1 OFFSET 1;

-- Q18: Courses with durations above the median
WITH Ordered AS (
  SELECT CourseDuration,
         ROW_NUMBER() OVER (ORDER BY CourseDuration) AS rn,
         COUNT(*) OVER () AS total
  FROM college_courses
),
Median AS (
  SELECT AVG(CourseDuration) AS MedianDuration
  FROM (
    SELECT CourseDuration
    FROM Ordered
    WHERE rn IN ((total + 1) / 2, (total + 2) / 2)
  )
)
SELECT *
FROM college_courses
WHERE CourseDuration > (SELECT MedianDuration FROM Median);


-- Q19: Percentage of unaided courses that are professional, by university 
SELECT University,
       ROUND(100.0 * SUM(CASE WHEN IsProfessional = 'Professional Course' THEN 1 ELSE 0 END) /
                   COUNT(*), 2) AS ProfessionalUnaidedPercentage
FROM college_courses
WHERE Course = 'UnAided'
GROUP BY University;

-- Q20: Top 3 Course Categories with highest average course duration
SELECT CourseCategory, ROUND(AVG(CourseDuration), 2) AS AvgDuration
FROM college_courses
GROUP BY CourseCategory
ORDER BY AvgDuration DESC
LIMIT 3;
