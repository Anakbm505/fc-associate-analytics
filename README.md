# FC Associate Productivity & Safety Tracker

An end-to-end SQL analytics project built on a simulated Amazon Robotics Fulfillment Center dataset. This project tracks associate performance and safety records across departments, answering real operational questions a fulfillment center data analyst would run.

---

## Context

Built around the Amazon Wilmington Robotics Fulfillment Center (Pender Commerce Park, NC) — a 3.2 million sq ft facility opening fall 2026. The dataset simulates 50 associates across 6 departments over 90 days of operations (Jan–Apr 2026).

---

## Database

**Tool:** SQLite  
**Tables:**

| Table | Description | Records |
|---|---|---|
| `associates` | Employee roster with department, hire date, and status | 50 |
| `departments` | 6 FC departments across 4 floors | 6 |
| `shifts` | Individual shift records per associate | 1,664 |
| `pick_rates` | Units picked vs target per shift | 1,664 |
| `safety_incidents` | Logged incidents with severity and resolution status | 62 |

---

## Queries

| # | Business Question | Concepts |
|---|---|---|
| 1 | Who are the active associates and where do they work? | INNER JOIN, WHERE, aliasing |
| 2 | Who has safety incidents — and who has a clean record? | LEFT JOIN, NULL handling |
| 3 | Which departments have associates and which don't yet? | RIGHT JOIN, GROUP BY, COUNT |
| 4 | What performance tier is each associate in? | CASE, AVG, CAST, GROUP BY |
| 5 | Which departments are missing pick rate targets? | HAVING, AVG, DISTINCT |
| 6 | Which associates perform above the facility-wide average? | Subquery, HAVING |
| 7 | What does each associate's full performance summary look like? | CTE, WITH clause |
| 8 | How does each associate rank within their department? | RANK, NTILE, PARTITION BY, OVER |
| 9 | Complete associate profile combining all metrics | CTE + JOIN + LEFT JOIN + CASE + RANK + NTILE |

---

## Skills Demonstrated

- INNER, LEFT, and RIGHT JOINs
- CASE statements and conditional logic
- HAVING vs WHERE
- Subqueries
- Common Table Expressions (CTEs)
- Window functions: RANK(), NTILE(), PARTITION BY
- Multi-table data manipulation
- Aggregate functions: AVG, COUNT, ROUND, CAST

---

## Tools

- SQLite / DB Browser for SQLite
- Python (sqlite3) — database setup
- VS Code
- GitHub
