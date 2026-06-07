-- BigQuery DDL: raw.fraud_signals
-- Source: Hive raw.fraud_signals (Avro schema: fraud_signals-v5.avsc)
-- Category: avro_net_new (absent from live Hive metastore)
-- Partition: STRING signal_date → derived partition_date DATE

CREATE TABLE IF NOT EXISTS `${PROJECT_US}.${DATASET_RAW}.fraud_signals`
(
    customer_id    STRING,
    signal_type    STRING,
    score          FLOAT64,
    risk_band      STRING,
    reason_codes   ARRAY<STRING>,
    signal_ts      TIMESTAMP,
    vendor         STRING,
    signal_date    STRING,
    partition_date DATE
)
PARTITION BY partition_date;
