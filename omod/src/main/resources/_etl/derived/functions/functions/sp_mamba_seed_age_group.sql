DROP PROCEDURE IF EXISTS sp_mamba_seed_age_group;
DELIMITER //

CREATE PROCEDURE sp_mamba_seed_age_group()
BEGIN
    DECLARE v_cat_id INT;

    /* ------------------------------------------------------------------
       1) Seed Age Categories
       ------------------------------------------------------------------ */
    INSERT INTO mamba_dim_age_category
    (code, name, description, version, effective_from, is_active)
    SELECT * FROM (
                      SELECT 'MOH_105_OPD_DIAG',
                             'MOH 105 OPD Diagnoses Age Groups',
                             'Age/Gender disaggregation for OPD diagnoses in MOH 105 (Section 1A)',
                             'v1', CURDATE(), 1
                      UNION ALL
                      SELECT 'MOH_105_NUTRITION',
                             'MOH 105 Nutrition Age Groups',
                             'Nutrition services age/gender disaggregation in MOH 105',
                             'v1', CURDATE(), 1
                      UNION ALL
                      SELECT 'MOH_MCH',
                             'MOH ANC/Maternity/PNC/FP Age Groups',
                             'MCH age disaggregation used in ANC, maternity, postnatal and FP sections',
                             'v1', CURDATE(), 1
                      UNION ALL
                      SELECT 'GBV',
                             'GBV Services Age Groups',
                             'GBV services age/gender disaggregation',
                             'v1', CURDATE(), 1
                      UNION ALL
                      SELECT 'HTS',
                             'HIV Testing Services Age Groups',
                             'HTS age/gender disaggregation',
                             'v1', CURDATE(), 1
                      UNION ALL
                      SELECT 'SMC',
                             'Safe Male Circumcision Age Groups',
                             'SMC age/gender disaggregation',
                             'v1', CURDATE(), 1
                      UNION ALL
                      SELECT 'HEPATITIS',
                             'Hepatitis Services Age Groups',
                             'Hepatitis age/gender disaggregation',
                             'v1', CURDATE(), 1
                  ) src(code, name, description, version, effective_from, is_active)
    WHERE NOT EXISTS (
        SELECT 1 FROM mamba_dim_age_category c WHERE c.code = src.code
    );

    /* ------------------------------------------------------------------
       2) MOH 105 OPD Diagnoses (ALIGN LABELS TO REPORT DESIGN TOKENS)
          Expected: 0-28d, 29d-4y, 5-9, 10-19, 20+
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code = 'MOH_105_OPD_DIAG'
    LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'D0_28','0-28d',0,28,1,1
                          UNION ALL SELECT v_cat_id,'D29_4Y','29d-4y',29,1824,2,1
                          UNION ALL SELECT v_cat_id,'Y5_9','5-9',1825,3649,3,1
                          /* 10–19 => 3650 .. 7299 (i.e. (20*365)-1) */
                          UNION ALL SELECT v_cat_id,'Y10_19','10-19',3650,7299,4,1
                          /* 20+ => 7300 .. 30000 */
                          UNION ALL SELECT v_cat_id,'Y20P','20+',7300,30000,5,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id = g.age_category_id AND e.code = g.code
        );

        /* If groups already exist, ensure they are updated to the new standard */
        UPDATE mamba_dim_age_group ag
        SET
            ag.label = CASE ag.code
                           WHEN 'D0_28'  THEN '0-28d'
                           WHEN 'D29_4Y' THEN '29d-4y'
                           WHEN 'Y5_9'   THEN '5-9'
                           WHEN 'Y10_19' THEN '10-19'
                           WHEN 'Y20P'   THEN '20+'
                           ELSE ag.label
                END,
            ag.min_age_days = CASE ag.code
                                  WHEN 'Y10_19' THEN 3650
                                  WHEN 'Y20P'   THEN 7300
                                  ELSE ag.min_age_days
                END,
            ag.max_age_days = CASE ag.code
                                  WHEN 'Y10_19' THEN 7299
                                  ELSE ag.max_age_days
                END,
            ag.sort_order = CASE ag.code
                                WHEN 'D0_28'  THEN 1
                                WHEN 'D29_4Y' THEN 2
                                WHEN 'Y5_9'   THEN 3
                                WHEN 'Y10_19' THEN 4
                                WHEN 'Y20P'   THEN 5
                                ELSE ag.sort_order
                END,
            ag.is_active = 1
        WHERE ag.age_category_id = v_cat_id;
    END IF;

    /* ------------------------------------------------------------------
       3) MOH 105 Nutrition
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code='MOH_105_NUTRITION' LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'M0_5','0–5 months',0, (6*30)-1, 1,1
                          UNION ALL SELECT v_cat_id,'M6_23','6–23 months',(6*30), (24*30)-1, 2,1
                          UNION ALL SELECT v_cat_id,'M24_59','24–59 months',(24*30), (60*30)-1, 3,1
                          UNION ALL SELECT v_cat_id,'Y5_9','5–9 years', (5*365), (10*365)-1, 4,1
                          UNION ALL SELECT v_cat_id,'Y10_19','10–19 years', (10*365), (20*365)-1, 5,1
                          UNION ALL SELECT v_cat_id,'Y20_24','20–24 years', (20*365), (25*365)-1, 6,1
                          UNION ALL SELECT v_cat_id,'Y25P','25+ years', (25*365), 30000, 7,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id=g.age_category_id AND e.code=g.code
        );
    END IF;

    /* ------------------------------------------------------------------
       4) GBV
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code='GBV' LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'LT10','<10 yrs',0,(10*365)-1,1,1
                          UNION ALL SELECT v_cat_id,'Y10_14','10–14 yrs',(10*365),(15*365)-1,2,1
                          UNION ALL SELECT v_cat_id,'Y15_19','15–19 yrs',(15*365),(20*365)-1,3,1
                          UNION ALL SELECT v_cat_id,'Y20_24','20–24 yrs',(20*365),(25*365)-1,4,1
                          UNION ALL SELECT v_cat_id,'Y25_29','25–29 yrs',(25*365),(30*365)-1,5,1
                          UNION ALL SELECT v_cat_id,'Y30_34','30–34 yrs',(30*365),(35*365)-1,6,1
                          UNION ALL SELECT v_cat_id,'Y35_39','35–39 yrs',(35*365),(40*365)-1,7,1
                          UNION ALL SELECT v_cat_id,'Y40_44','40–44 yrs',(40*365),(45*365)-1,8,1
                          UNION ALL SELECT v_cat_id,'Y45_49','45–49 yrs',(45*365),(50*365)-1,9,1
                          UNION ALL SELECT v_cat_id,'Y50P','50+ yrs',(50*365),30000,10,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id=g.age_category_id AND e.code=g.code
        );
    END IF;

    /* ------------------------------------------------------------------
       5) MOH MCH
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code='MOH_MCH' LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'LT15','<15 yrs',0,(15*365)-1,1,1
                          UNION ALL SELECT v_cat_id,'Y15_19','15–19 yrs',(15*365),(20*365)-1,2,1
                          UNION ALL SELECT v_cat_id,'Y20_24','20–24 yrs',(20*365),(25*365)-1,3,1
                          UNION ALL SELECT v_cat_id,'Y25_49','25–49 yrs',(25*365),(50*365)-1,4,1
                          UNION ALL SELECT v_cat_id,'Y50P','50+ yrs',(50*365),30000,5,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id=g.age_category_id AND e.code=g.code
        );
    END IF;

    /* ------------------------------------------------------------------
       6) Hepatitis
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code='HEPATITIS' LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'LT10','<10 yrs',0,(10*365)-1,1,1
                          UNION ALL SELECT v_cat_id,'Y10_19','10–19 yrs',(10*365),(20*365)-1,2,1
                          UNION ALL SELECT v_cat_id,'Y20_59','20–59 yrs',(20*365),(60*365)-1,3,1
                          UNION ALL SELECT v_cat_id,'Y60P','60+ yrs',(60*365),30000,4,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id=g.age_category_id AND e.code=g.code
        );
    END IF;

    /* ------------------------------------------------------------------
       7) HTS
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code='HTS' LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'Y0_4','0–4 yrs',0,(5*365)-1,1,1
                          UNION ALL SELECT v_cat_id,'Y5_9','5–9 yrs',(5*365),(10*365)-1,2,1
                          UNION ALL SELECT v_cat_id,'Y10_14','10–14 yrs',(10*365),(15*365)-1,3,1
                          UNION ALL SELECT v_cat_id,'Y15_19','15–19 yrs',(15*365),(20*365)-1,4,1
                          UNION ALL SELECT v_cat_id,'Y20_24','20–24 yrs',(20*365),(25*365)-1,5,1
                          UNION ALL SELECT v_cat_id,'Y25_29','25–29 yrs',(25*365),(30*365)-1,6,1
                          UNION ALL SELECT v_cat_id,'Y30_39','30–39 yrs',(30*365),(40*365)-1,7,1
                          UNION ALL SELECT v_cat_id,'Y40_49','40–49 yrs',(40*365),(50*365)-1,8,1
                          UNION ALL SELECT v_cat_id,'Y50P','50+ yrs',(50*365),30000,9,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id=g.age_category_id AND e.code=g.code
        );
    END IF;

    /* ------------------------------------------------------------------
       8) SMC
       ------------------------------------------------------------------ */
    SELECT age_category_id INTO v_cat_id
    FROM mamba_dim_age_category
    WHERE code='SMC' LIMIT 1;

    IF v_cat_id IS NOT NULL THEN
        INSERT INTO mamba_dim_age_group
        (age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        SELECT * FROM (
                          SELECT v_cat_id,'Y0_4','0–4 yrs',0,(5*365)-1,1,1
                          UNION ALL SELECT v_cat_id,'Y5_9','5–9 yrs',(5*365),(10*365)-1,2,1
                          UNION ALL SELECT v_cat_id,'Y10_14','10–14 yrs',(10*365),(15*365)-1,3,1
                          UNION ALL SELECT v_cat_id,'Y15_19','15–19 yrs',(15*365),(20*365)-1,4,1
                          UNION ALL SELECT v_cat_id,'Y20_24','20–24 yrs',(20*365),(25*365)-1,5,1
                          UNION ALL SELECT v_cat_id,'Y25_29','25–29 yrs',(25*365),(30*365)-1,6,1
                          UNION ALL SELECT v_cat_id,'Y30_39','30–39 yrs',(30*365),(40*365)-1,7,1
                          UNION ALL SELECT v_cat_id,'Y40_49','40–49 yrs',(40*365),(50*365)-1,8,1
                          UNION ALL SELECT v_cat_id,'Y50P','50+ yrs',(50*365),30000,9,1
                      ) g(age_category_id, code, label, min_age_days, max_age_days, sort_order, is_active)
        WHERE NOT EXISTS (
            SELECT 1 FROM mamba_dim_age_group e
            WHERE e.age_category_id=g.age_category_id AND e.code=g.code
        );
    END IF;

END//

DELIMITER ;
