# Requirement: Sales Data Mart

**Intent:** Build a sales data mart pipeline with sample data.  
**Date created:** 2026-09-21  
**Intent slug:** `new-intent-1c1695ba`  
**Status:** Pending approval

---

## Scope

Build a dbt-based sales data mart with:
- **Fact table grain:** Order-level facts aggregated to order date, customer, and product
- **Core measures:** Total revenue, quantity ordered, order count
- **Dimensions:** Customer, product, order date (time hierarchy)
- **Source:** Sample orders data loaded into DuckDB

---

## Requirements

### R-01: Sales Facts Table (daily customer-product level)

**Statement:**  
Build `fct_sales` fact table with grain = (order_date, customer_id, product). Each row represents one or more orders for a customer's product on a given date.

**Measures:**
- `total_revenue` — sum of order totals (SUM(total))
- `total_quantity` — sum of quantities ordered (SUM(quantity))
- `order_count` — distinct count of orders

**Dimensions:**
- `order_date` — the date of the order
- `customer_id` — unique customer identifier
- `product` — product name

**Acceptance criteria:**
- Table exists and is queryable in DuckDB
- All rows have non-null order_date, customer_id, product
- Measures aggregate correctly to the grain (testable by reconciling against source)
- No duplicate rows at the stated grain

**Provenance:** User request  
**Status:** Pending  

---

### R-02: Customer Dimension

**Statement:**  
Build `dim_customer` dimension table with one row per customer containing customer metadata.

**Columns:**
- `customer_id` — surrogate key
- `customer_name` — derived from sample data (e.g., "Customer_101")
- `created_date` — first order date for the customer

**Acceptance criteria:**
- One row per unique customer_id
- No null customer_id values
- customer_name and created_date are populated

**Provenance:** User request  
**Status:** Pending

---

### R-03: Product Dimension

**Statement:**  
Build `dim_product` dimension table with one row per product.

**Columns:**
- `product_id` — surrogate key (unique per product name)
- `product_name` — product name from orders
- `first_sold_date` — first date the product appeared in orders

**Acceptance criteria:**
- One row per unique product_name
- No duplicate product_names
- first_sold_date is the earliest order_date for each product

**Provenance:** User request  
**Status:** Pending

---

### R-04: Date Dimension

**Statement:**  
Build `dim_date` dimension table with one row per calendar date spanning the order history.

**Columns:**
- `date_key` — integer key (YYYYMMDD format)
- `date` — the calendar date
- `year`, `month`, `day` — time components
- `quarter` — Q1–Q4
- `week_of_year` — ISO week number

**Acceptance criteria:**
- One row per date in the range of min to max order_date
- All dates are present (no gaps)
- Date keys and time components are correctly populated

**Provenance:** User request  
**Status:** Pending

---

## Sample Data

**Source:** `orders.csv` (already committed)

Columns: `order_id`, `customer_id`, `order_date`, `product`, `quantity`, `price`, `total`

10 sample orders spanning 2026-01-15 to 2026-01-24, covering 6 unique customers and 4 products.

**Load strategy:** Full load into DuckDB bronze layer as `stg_orders` (or similar staging table).

---

## Design Pending

- **Data platform target:** DuckDB (confirmed in runtime context)
- **dbt project structure:** Will be decided in design phase (single project or modular)
- **Incremental vs. full refresh:** Currently full refresh; incremental strategy TBD in design
- **Aggregation level for fct_sales:** Confirmed as order_date + customer + product grain

---

## Approvals

- **Approved:** R-01@1, R-02@1, R-03@1, R-04@1
- **Decision:** User approved sales data mart with four-table design (fct_sales, dim_customer, dim_product, dim_date)
- **Source:** Direct user approval
- **UTC timestamp:** 2026-09-21T08:07:00Z

---

## Change History

- **2026-09-21:** Initial capture. R-01 through R-04 defined. Pending approval.
