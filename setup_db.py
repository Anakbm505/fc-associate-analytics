import sqlite3
import random
from datetime import date, timedelta

DB_PATH = "fc_analytics.db"
conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

# ── DROP & CREATE TABLES ──────────────────────────────────────────────────────

cur.executescript("""
DROP TABLE IF EXISTS safety_incidents;
DROP TABLE IF EXISTS pick_rates;
DROP TABLE IF EXISTS shifts;
DROP TABLE IF EXISTS associates;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id   INTEGER PRIMARY KEY,
    dept_name       TEXT NOT NULL,
    floor           INTEGER,
    shift_type      TEXT
);

CREATE TABLE associates (
    associate_id    INTEGER PRIMARY KEY,
    full_name       TEXT NOT NULL,
    hire_date       TEXT,
    department_id   INTEGER,
    manager_id      INTEGER,
    status          TEXT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE shifts (
    shift_id        INTEGER PRIMARY KEY,
    associate_id    INTEGER,
    shift_date      TEXT,
    shift_type      TEXT,
    hours_worked    REAL,
    FOREIGN KEY (associate_id) REFERENCES associates(associate_id)
);

CREATE TABLE pick_rates (
    rate_id         INTEGER PRIMARY KEY,
    associate_id    INTEGER,
    shift_id        INTEGER,
    units_picked    INTEGER,
    target_units    INTEGER,
    rate_per_hour   REAL,
    FOREIGN KEY (associate_id) REFERENCES associates(associate_id),
    FOREIGN KEY (shift_id)     REFERENCES shifts(shift_id)
);

CREATE TABLE safety_incidents (
    incident_id     INTEGER PRIMARY KEY,
    associate_id    INTEGER,
    shift_id        INTEGER,
    incident_date   TEXT,
    severity        TEXT,
    incident_type   TEXT,
    resolved        INTEGER,
    FOREIGN KEY (associate_id) REFERENCES associates(associate_id),
    FOREIGN KEY (shift_id)     REFERENCES shifts(shift_id)
);
""")

# ── DEPARTMENTS ───────────────────────────────────────────────────────────────

departments = [
    (1, "Inbound",      1, "AM"),
    (2, "Stow",         2, "AM"),
    (3, "Pick",         3, "PM"),
    (4, "Pack",         3, "PM"),
    (5, "Ship",         4, "Night"),
    (6, "Robotics Ops", 2, "AM"),
]
cur.executemany("INSERT INTO departments VALUES (?,?,?,?)", departments)

# ── ASSOCIATES ────────────────────────────────────────────────────────────────

names = [
    "Jordan Miles",    "Tamika Brooks",   "DeShawn Carter",  "Priya Nair",
    "Marcus Webb",     "Latoya Simmons",  "Chris Delgado",   "Aisha Freeman",
    "Tyler Grant",     "Monique Harris",  "Samuel Rivera",   "Destiny Cole",
    "Brandon Lee",     "Jasmine Thomas",  "Kevin Ortiz",     "Alicia Young",
    "Darius King",     "Renee Flores",    "Anthony Baker",   "Nadia Scott",
    "Jamal Wright",    "Carmen Ross",     "Marcus Allen",    "Tiffany Green",
    "Devon Mitchell",  "Shayla Adams",    "Isaiah Turner",   "Brianna Hall",
    "Elijah Perez",    "Monique Nelson",  "Caleb Hill",      "Yolanda Clark",
    "Omar James",      "Keisha Walker",   "Terrence Moore",  "Vanessa White",
    "Malik Thompson",  "Jasmine Davis",   "Eric Robinson",   "Layla Martin",
    "Aaron Jackson",   "Crystal Lewis",   "Jerome Wilson",   "Nikki Anderson",
    "Deon Taylor",     "Simone Thomas",   "Kendall Brown",   "Aaliyah Johnson",
    "Quinton Evans",   "Brittany Murphy",
]

random.seed(42)
start_date = date(2025, 9, 1)
associates = []
for i, name in enumerate(names, start=1):
    dept_id   = random.choice([1,2,3,4,5,6])
    hire_days = random.randint(0, 200)
    hire_date = (start_date + timedelta(days=hire_days)).isoformat()
    manager   = random.choice([3, 7, 12, 18, 25, 33])
    status    = random.choices(["Active","Active","Active","LOA","Terminated"], k=1)[0]
    associates.append((i, name, hire_date, dept_id, manager, status))

cur.executemany("INSERT INTO associates VALUES (?,?,?,?,?,?)", associates)

# ── SHIFTS ────────────────────────────────────────────────────────────────────

shift_types = ["AM", "PM", "Night"]
shifts      = []
shift_id    = 1
shift_date  = date(2026, 1, 1)

for day_offset in range(90):
    current_date = shift_date + timedelta(days=day_offset)
    if current_date.weekday() in [5, 6]:
        continue
    active_associates = [a[0] for a in associates if a[5] == "Active"]
    for assoc_id in active_associates:
        stype        = random.choice(shift_types)
        hours_worked = round(random.uniform(7.5, 10.5), 1)
        shifts.append((shift_id, assoc_id, current_date.isoformat(), stype, hours_worked))
        shift_id += 1

cur.executemany("INSERT INTO shifts VALUES (?,?,?,?,?)", shifts)

# ── PICK RATES ────────────────────────────────────────────────────────────────

pick_rates = []
for rate_id, (sid, assoc_id, sdate, stype, hours) in enumerate(shifts, start=1):
    target        = random.choice([280, 300, 320, 340])
    performance   = random.choices(
        ["elite","good","okay","poor"],
        weights=[15, 45, 25, 15], k=1
    )[0]
    if performance == "elite":
        picked = random.randint(int(target * 1.15), int(target * 1.35))
    elif performance == "good":
        picked = random.randint(int(target * 0.95), int(target * 1.15))
    elif performance == "okay":
        picked = random.randint(int(target * 0.80), int(target * 0.95))
    else:
        picked = random.randint(int(target * 0.55), int(target * 0.80))
    rate_per_hour = round(picked / hours, 2)
    pick_rates.append((rate_id, assoc_id, sid, picked, target, rate_per_hour))

cur.executemany("INSERT INTO pick_rates VALUES (?,?,?,?,?,?)", pick_rates)

# ── SAFETY INCIDENTS ──────────────────────────────────────────────────────────

severities     = ["Minor", "Moderate", "Serious"]
incident_types = [
    "Slip/Trip", "Ergonomic Strain", "Equipment Contact",
    "Near Miss",  "Forklift Proximity", "Chemical Exposure"
]

safety_incidents = []
incident_id      = 1
incident_pool    = [s for s in shifts if random.random() < 0.04]

for s in incident_pool:
    sid, assoc_id, sdate = s[0], s[1], s[2]
    severity     = random.choices(severities, weights=[60, 30, 10], k=1)[0]
    inc_type     = random.choice(incident_types)
    resolved     = 1 if severity == "Minor" else random.choice([0, 1])
    safety_incidents.append((incident_id, assoc_id, sid, sdate, severity, inc_type, resolved))
    incident_id += 1

cur.executemany("INSERT INTO safety_incidents VALUES (?,?,?,?,?,?,?)", safety_incidents)

conn.commit()
conn.close()

print("Database created: fc_analytics.db")
print(f"  Associates:       {len(associates)}")
print(f"  Shifts:           {len(shifts)}")
print(f"  Pick rate records:{len(pick_rates)}")
print(f"  Safety incidents: {len(safety_incidents)}")
