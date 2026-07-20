SELECT
a.associate_id,
a.full_name,
d.dept_name,
d.floor
FROM associates a
JOIN departments d ON a.department_id = d.department_id
WHERE a.status = 'Active';

Query 2

 Query 2: Associate safety record including clean records
 Business question: Who has incidents and who has a clean record?
 Concepts: LEFT JOIN, NULL handling

SELECT
a.associate_id,
a.full_name,
d.dept_name,
si.incident_date,
si.severity,
si.incident_type
FROM associates a
JOIN departments d ON a.department_id = d.department_id
LEFT JOIN safety_incidents si ON a.associate_id = si.associate_id
WHERE a.status = 'Active'
ORDER BY a.full_name;   


Query 3 
---All departments and associate count including empty departments
-- Business question: Which departments have associates and which don't yet?
--Concepts: RIGHT JOIN, GROUP BY, COUNT, aliasing.


SELECT 
    d.dept_name,
    d.floor,
    COUNT (a.associate_id) AS associate_count
FROM   associates a 
RIGHT JOIN departments d ON a.department_id = d.department_id
GROUP BY d.dept_name, d.floor
ORDER by associate_count DESC; 


  -- Query 4: Associate performance tiers
  -- Business question: What performance tier is each active associate in?
  -- Concepts: CASE, AVG, GROUP BY, JOIN


SELECT 
    a.associate_id, 
    a.full_name,
    d.dept_name,
    ROUND(AVG (pr.rate_per_hour), 2) AS avg_rate,
    
    CASE
          WHEN AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) >= 1.15 THEN 'Elite'
          WHEN AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) >= 0.95 THEN 'On Track'
          WHEN AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) >= 0.80 THEN 'At Risk'
          ELSE 'Below Target'
      END AS performance_tier

FROM associates a 
JOIN departments d ON a.department_id = d.department_id
JOIN pick_rates pr ON a.associate_id = pr.associate_id
WHERE a.status = 'Active'
GROUP BY a.associate_id, a.full_name, d.dept_name
ORDER BY avg_rate DESC;


  -- Query 5: Departments missing pick rate targets
  -- Business question: Which departments are underperforming on average?
  -- Concepts: HAVING, AVG, GROUP BY, JOIN

SELECT 
    d.dept_name,
    ROUND(AVG(CAST(pr.units_picked as FLOAT) / pr.target_units), 2) AS avg_completion_rate, 
    COUNT(DISTINCT a.associate_id) AS associate_count
FROM associates a 
JOIN departments d ON a.department_id = d.department_id
JOIN pick_rates pr ON a.associate_id = pr.associate_id 
WHERE a.status = 'Active'
GROUP BY d.dept_name
HAVING AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) < 1.15
ORDER BY avg_completion_rate ASC;

  -- Query 6: Associates performing above facility-wide average
  -- Business question: Who beats the overall facility average?
  -- Concepts: Subquery, AVG, JOIN

  SELECT 
    a.associate_id,
    a.full_name,
    d.dept_name,
    ROUND(AVG(pr.rate_per_hour), 2) AS avg_rate
 FROM associates a
 JOIN departments d  ON a.department_id = d.department_id
 JOIN pick_rates pr ON a.associate_id = pr.associate_id
 WHERE a.status = 'Active'
 GROUP BY a.associate_id, a.full_name, d.dept_name
 HAVING AVG(pr.rate_per_hour) > (
    SELECT AVG(rate_per_hour)
    FROM pick_rates
 )
ORDER BY avg_rate DESC;


 -- Query 7: Full associate performance summary using CTE
  -- Business question: What does each associate's complete performance look like?
  -- Concepts: CTE, WITH clause, AVG, CASE, JOIN

  WITH performance_summary AS (
    SELECT 
        a.associate_id,
        a.full_name,
        d.dept_name,
        ROUND(AVG(pr.rate_per_hour), 2) AS avg_rate,
        ROUND(AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units), 2) AS avg_completion,
        CASE 
            WHEN AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) >= 1.15 THEN 'Elite'
            WHEN AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) >= .95  THEN 'On Track'
            WHEN AVG(CAST(pr.units_picked AS FLOAT) / pr.target_units) >= .80  THEN 'At Risk'
            ELSE 'Below target'
        END AS performance_tier
    FROM associates a 
    JOIN departments d ON a.department_id = d.department_id
    JOIN pick_rates pr ON a.associate_id = pr.associate_id
    WHERE a.status = 'Active'
    GROUP BY a.associate_id, a.full_name, d.dept_name
  )

 SELECT *
 FROM performance_summary
 ORDER BY avg_rate DESC;


  -- Query 8: Associate ranking and trend within department
  -- Business question: How does each associate rank in their dept and are they trending up or down?
  -- Concepts: Window functions, RANK, LAG, NTILE, OVER, PARTITION BY


  SELECT
      a.associate_id,
      a.full_name,
      d.dept_name,
      ROUND(AVG(pr.rate_per_hour), 2) AS avg_rate,
      RANK() OVER (PARTITION BY d.dept_name ORDER BY AVG(pr.rate_per_hour) DESC) AS dept_rank,
      NTILE(4) OVER (ORDER BY AVG(pr.rate_per_hour) DESC) AS quartile
  FROM associates a
  JOIN departments d ON a.department_id = d.department_id
  JOIN pick_rates pr ON a.associate_id = pr.associate_id
  WHERE a.status = 'Active'
  GROUP BY a.associate_id, a.full_name, d.dept_name
  ORDER BY d.dept_name, dept_rank;