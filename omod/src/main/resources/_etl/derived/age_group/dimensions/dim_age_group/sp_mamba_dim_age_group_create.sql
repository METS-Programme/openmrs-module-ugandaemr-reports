-- $BEGIN
CREATE TABLE IF NOT EXISTS mamba_dim_age_category (
                                        age_category_id   INT AUTO_INCREMENT PRIMARY KEY,
                                        code              VARCHAR(50)  NOT NULL UNIQUE,
                                        name              VARCHAR(100) NOT NULL,
                                        description       TEXT,
                                        version           VARCHAR(20)  DEFAULT 'v1',
                                        effective_from    DATE NULL,
                                        effective_to      DATE NULL,
                                        is_active         TINYINT(1)   NOT NULL DEFAULT 1,
                                        created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARSET = UTF8MB4;

CREATE TABLE IF NOT EXISTS mamba_dim_age_group (
                                     age_group_id     INT AUTO_INCREMENT PRIMARY KEY,
                                     age_category_id  INT NOT NULL,
                                     code             VARCHAR(50),
                                     label            VARCHAR(100) NOT NULL,
                                     min_age_days     INT NOT NULL,
                                     max_age_days     INT NOT NULL,
                                     sort_order       INT NOT NULL,
                                     is_active        TINYINT(1)   NOT NULL DEFAULT 1,
                                     created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                     CONSTRAINT fk_mamba_age_category
                                         FOREIGN KEY (age_category_id)
                                             REFERENCES mamba_dim_age_category (age_category_id)
) CHARSET = UTF8MB4;

-- $END
