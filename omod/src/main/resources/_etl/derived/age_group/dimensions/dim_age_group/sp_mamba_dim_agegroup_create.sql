-- $BEGIN
CREATE TABLE mamba_dim_agegroup
(
    id              INT         NOT NULL AUTO_INCREMENT,
    age             INT         NULL,
    datim_agegroup  VARCHAR(50) NULL,
    datim_age_val   INT         NULL,
    normal_agegroup VARCHAR(50) NULL,
    normal_age_val   INT        NULL,
    moh_age_group VARCHAR(50) NULL,
    moh_age_val   INT        NULL,
    moh_2024_age_group VARCHAR(50) NULL,
    moh_2024_age_val   INT        NULL,
    moh_anc_age_group VARCHAR(50) NULL,
    moh_anc_age_val   INT        NULL,
    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;
-- $END

