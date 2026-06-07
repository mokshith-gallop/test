-- BigQuery DDL: regional_eu.fact_shipments_eu
-- Source: Hive regional.fact_shipments_eu (acme-edge/hive/regional-additional-tables.hql)
-- Partition: DATE ship_date (direct passthrough)

CREATE TABLE IF NOT EXISTS `${PROJECT_EU}.${DATASET_REGIONAL}.fact_shipments_eu`
(
    shipment_id     STRING,
    order_id        STRING,
    customer_id     STRING,
    carrier         STRING,
    tracking_no     STRING,
    shipped_at      TIMESTAMP,
    delivered_at    TIMESTAMP,
    country_from    STRING,
    country_to      STRING,
    sla_hours       INT64,
    ship_date       DATE
)
PARTITION BY ship_date;
