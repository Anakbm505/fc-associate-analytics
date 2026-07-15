SELECT
a.associate_id,
a.full_name,
d.dept_name,
d.floor
FROM associates a
JOIN departments d ON a.department_id = d.department_id
WHERE a.status = 'Active';

Query 2

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