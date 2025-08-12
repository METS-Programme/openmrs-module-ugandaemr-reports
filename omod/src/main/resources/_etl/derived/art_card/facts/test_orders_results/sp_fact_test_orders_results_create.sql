-- $BEGIN
CREATE TABLE mamba_fact_test_orders_results
(
    id        INT AUTO_INCREMENT,
    test_orders_id INT NOT NULL,
    encounter_id INT NULL,
    encounter_datetime DATE NULL,
    client_id INT NULL,
    test_concept_id  INT NOT NULL,
    test_parameter        VARCHAR(255) NULL,
    test_value        TEXT NULL,

        PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_test_orders_client_id_index ON mamba_fact_test_orders_results (client_id);
CREATE INDEX
    mamba_fact_test_orders_order_id_index ON mamba_fact_test_orders_results (id);

CREATE INDEX
    mamba_fact_test_orders_test_order_results_id_index ON mamba_fact_test_orders_results (test_orders_id);


-- $END

