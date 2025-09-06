# POS ETL Project (Relational → NoSQL)

**Author:** Vigya Awasthi  
**Student / Project:** POS (furniture) ETL pipeline — relational schema, ETL loaders, stored procedures, triggers, materialized views, JSON exports to support a NoSQL view.

---

## What this repo contains

```
pos-etl-project/
├─ sql/
│  ├─ etl.sql        # ETL + schema + views + procedures + triggers 
│  └─ json.sql             # JSON-export queries to produce documents for NoSQL ingestion
├─ docs/
│  ├─ flowchart.png        # Visual flowchart 
├─ docker-compose.yml      # Optional: spin up MariaDB + MongoDB locally for testing
├─ run_etl.sh              # Helper script to run SQL ETL against a MySQL/MariaDB instance
├─ .github/workflows/ci.yml# Example CI: run SQL import against mariadb service 
├─ LICENSE                 # MIT License 
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
mysql -u root -p < sql/etl.sql
# run the JSON export queries (they use INTO OUTFILE; edit paths in json.sql if needed)
mysql -u root -p < sql/json.sql
```

---

## Helpful files in this repo
- `sql/etl.sql` — your main ETL, schema, views, procs, triggers.
- `sql/json.sql` — JSON export queries for NoSQL ingestion (NOTE: uses `INTO OUTFILE`; adjust paths/permissions when running).
- `docker-compose.yml` — optional local testbed (MariaDB + MongoDB).
- `run_etl.sh` — convenience script to run the ETL and copy exported JSONs to `output/`.

---

---

## Showcase

Here is the high-level ERD:

![ERD](docs/https://github.com/VigyaAwasthi/Furniture_POS/blob/main/erd.svg)

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
