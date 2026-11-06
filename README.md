# Olist E-Commerce Data Warehouse (SQL Server)

An end-to-end ETL pipeline and star-schema data warehouse built on the Brazilian E-Commerce Public Dataset by Olist (~99K orders, 2016-2018), using SQL Server 2022 Express.

## Architecture

CSV files -> `stg` schema (raw, all-text) -> cleaning & transformation -> `dw` schema (star schema) -> analytical views

**Fact table:** `dw.FactOrderItems` (grain: one row per item within an order)
**Dimensions:** `DimDate`, `DimCustomer` (one row per real person, via `customer_unique_id`), `DimProduct`, `DimSeller`
**Helper:** `BridgeCustomer` maps each `customer_id` to its `CustomerKey`

## Tools
SQL Server 2022 Express, SSMS, T-SQL (BULK INSERT, CTEs, window functions, stored procedures, transactions)

## Pipeline Steps
1. **Extract/Load:** raw CSVs loaded into staging tables (all columns as text) with `BULK INSERT`
2. **Validate:** row counts checked after every load (e.g. orders 99,441, order_items 112,650)
3. **Clean & Model:** type conversion with `TRY_CAST`, empty strings to `NULL`, whitespace/case normalization, surrogate keys
4. **Automate:** `EXEC dw.usp_LoadStarSchema` rebuilds the whole warehouse in one transaction with a row-count check and rollback on failure
5. **Analyze:** views `dw.vw_MonthlySales` and `dw.vw_TopCategories`

## Data Quality Decisions
| Issue | Decision |
|---|---|
| Empty date strings | Converted to `NULL` |
| 8 orders marked `delivered` with no delivery date | Flagged with `IsDataIssue = 1`, not deleted |
| 610 products with no category | Assigned category `unknown` |
| 2 categories missing English translation (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`) | Translated manually |
| Dataset edge months (Sep-Dec 2016, Sep 2018) incomplete | Excluded from trend analysis |

## Validation
- Fact table: 112,650 rows; total item revenue 13,591,643.70 BRL
- Pipeline is idempotent: re-running produces identical results

## Key Insights
- Monthly revenue grew roughly 6x during 2017, peaking in November 2017 (likely Black Friday) at ~1.0M BRL, then stabilized around 850-990K BRL per month in 2018.
- Health & Beauty led revenue (~1.26M BRL), followed by Watches & Gifts (~1.20M BRL), which ranks 2nd despite selling about half the units of Bed, Bath & Table, reflecting a much higher average item price.

## How to Run
1. Place the CSV files in `C:\OlistData`
2. Run the scripts in order (01 to 05)
3. `EXEC dw.usp_LoadStarSchema;`
