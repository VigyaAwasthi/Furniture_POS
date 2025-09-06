# POS ETL Project (Relational → NoSQL)

**Author:** Vigya Awasthi  
**Student / Project:** POS (furniture) ETL pipeline — relational schema, ETL loaders, stored procedures, triggers, materialized views, JSON exports to support a NoSQL view.

---

## What this repo contains

```
pos-etl-project/
├─ sql/
│  ├─ etl-nakli.sql        # ETL + schema + views + procedures + triggers (from upload)
│  └─ json.sql             # JSON-export queries to produce documents for NoSQL ingestion
├─ docs/
│  ├─ flowchart.png        # Visual flowchart (generated)
│  └─ course_reflection.md  # Reflection (converted)
├─ docker-compose.yml      # Optional: spin up MariaDB + MongoDB locally for testing
├─ run_etl.sh              # Helper script to run SQL ETL against a MySQL/MariaDB instance
├─ .github/workflows/ci.yml# Example CI: run SQL import against mariadb service (template)
├─ LICENSE                 # MIT License (change as needed)
└─ README.md
```

---

## High-level architecture / data flow

1. **Raw CSV files** (`products.csv`, `customers.csv`, `orders.csv`, `orderlines.csv`, `TAXRATES.csv`)  
   ↓ _LOAD DATA LOCAL INFILE / ETL transformations_  
2. **Relational schema (MySQL / MariaDB)**: tables `Product`, `Customer`, `Order`, `Orderline`, `City`, `PriceHistory`, etc.  
   - Stored procedures and triggers keep derived columns (`subtotal`, `salesTax`, `total`) and summary tables / materialized views up to date.  
   ↓ _JSON export queries (json.sql)_  
3. **NoSQL view (MongoDB)**: `mongoimport` the generated JSON files to collections for fast document-focused queries / reporting.

(See `docs/flowchart.png` for a visual diagram.)

---

## Quick start — run locally (recommended: Docker Compose)

**Prerequisites**
- Docker & Docker Compose (recommended) or a local MariaDB/MySQL instance and MongoDB.
- Place the raw CSV files (`products.csv`, `customers.csv`, `orders.csv`, `orderlines.csv`, `TAXRATES.csv`) into `data/csv/` before running ETL, or adjust `run_etl.sh`.

**1) With Docker Compose (simplest test environment)**
```bash
# from repo root
docker-compose up -d
# give mariadb a few seconds to initialize (or watch logs)
./run_etl.sh
# after ETL succeeded, JSON files will be created inside the mariadb container's configured OUTFILE directory.
# Copy them out or adjust json.sql OUTFILE path to a mounted volume and use mongoimport to bring them into MongoDB:
# example:
# mongoimport --uri mongodb://localhost:27017/pos --collection products --file output/products.json --jsonArray
```

**2) With local MariaDB / MySQL client**
```bash
# start your DB and create a user with FILE privileges if you need OUTFILE capability
mysql -u root -p < sql/etl-nakli.sql
# run the JSON export queries (they use INTO OUTFILE; edit paths in json.sql if needed)
mysql -u root -p < sql/json.sql
```

---

## Step-by-step: push to GitHub (exact commands)

```bash
git init
git add .
git commit -m "Initial: POS ETL pipeline, schema and ETL scripts"
# create a GitHub repo on github.com (or use the CLI: gh repo create)
git remote add origin git@github.com:<your-username>/pos-etl-project.git
git branch -M main
git push -u origin main
```

If you want a one-liner (after creating the repo on GitHub):
```bash
git push -u git@github.com:<your-username>/pos-etl-project.git main
```

---

## Notes on the uploaded SQL (important — read before publishing)

The SQL files you uploaded contain an academic honor code block which states that they **should not be shared without written permission** from the course instructor. **Before you push this repository public**, confirm that you have permission to publish these files. If you *do not* have permission, either:

- Make the repo **private**, or
- Remove/replace the honor-code protected content (ask me and I can prepare a redacted copy), or
- Contact the instructor to obtain written permission.

---

## Tips to make the GitHub repo *extremely impressive*

- Add a short demo GIF (showing the ETL run + simple query) in `docs/` and reference it in the README.
- Add an `architecture.md` with an ERD (diagram generated using dbdiagram.io or draw.io) and include an SVG.
- Add tests: small SQL unit tests (example queries with expected counts) and a CI workflow using GitHub Actions that spins up MariaDB and runs the ETL → verifies expected row counts.
- Add a `data-preview/` folder with small sample CSVs (1–5 rows) so reviewers can reproduce quickly.
- Include `usage` examples showing important queries (e.g., sales by product, top customers).
- Provide a `LICENSE` and a short `CITATION.md` describing how to reference your work.

---

## Helpful files in this repo
- `sql/etl-nakli.sql` — your main ETL, schema, views, procs, triggers.
- `sql/json.sql` — JSON export queries for NoSQL ingestion (NOTE: uses `INTO OUTFILE`; adjust paths/permissions when running).
- `docker-compose.yml` — optional local testbed (MariaDB + MongoDB).
- `run_etl.sh` — convenience script to run the ETL and copy exported JSONs to `output/`.

---

## Want me to:
- ✨ Remove or redact the honor-code statement before making the repo public? (I can create a "public" cleaned version.)
- 🖼️ Produce a prettier ERD SVG (I can generate one from the SQL schema)?
- 🔁 Create a demo GitHub Actions workflow that runs the ETL and validates results automatically?

Reply with which of the above you'd like me to do next and I'll update the repo files.

---

---

## Showcase

Here is the high-level ERD:

![ERD](docs/erd.svg)

Example flow demo:

![Demo GIF](docs/demo.gif)

Run `./demo.sh` to test quickly with sample CSV data (included in `data/csv/`).

Example queries after ETL load:
```sql
-- Top customers by spending
SELECT c.name, SUM(o.total) as total_spent
FROM Customer c JOIN Orders o ON c.id=o.customerId
GROUP BY c.name ORDER BY total_spent DESC;
```
