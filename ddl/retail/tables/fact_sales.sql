-- BigQuery DDL: retail.fact_sales
-- Source: Hive retail.fact_sales (acme-analytics/hive/03-retail-tables.hql)
-- AC-7: unit_price NUMERIC, line_total NUMERIC, sale_date DATE partition, cluster customer_sk
-- Partition: DATE sale_date (direct passthrough)
-- Clustering: CLUSTERED BY (customer_sk) INTO 8 BUCKETS → CLUSTER BY customer_sk

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RETAIL}.fact_sales`
(
    invoice_no     STRING,
    customer_sk    INT64,
    product_sk     INT64,
    quantity       INT64,
    unit_price     NUMERIC(10,2),
    line_total     NUMERIC(14,2),
    country        STRING,
    invoice_ts     TIMESTAMP,
    sale_date      DATE
)
PARTITION BY sale_date
CLUSTER BY customer_sk;
