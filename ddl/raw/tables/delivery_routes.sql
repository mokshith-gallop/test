-- BigQuery DDL: raw.delivery_routes
-- Source: Hive raw.delivery_routes (acme-lake/hive/05-additional-raw-feeds.hql)
-- Partition: STRING date_ts → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.delivery_routes`
(
    route_id       STRING,
    driver_id      STRING,
    vehicle_id     STRING,
    planned_stops  INT64,
    actual_stops   INT64,
    miles_driven   NUMERIC(8,2),
    fuel_used      NUMERIC(8,2),
    start_ts       TIMESTAMP,
    end_ts         TIMESTAMP,
    date_ts        STRING,
    partition_date DATE
)
PARTITION BY partition_date;
