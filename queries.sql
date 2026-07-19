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
