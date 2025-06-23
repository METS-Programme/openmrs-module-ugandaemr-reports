DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_etl;

CREATE PROCEDURE sp_mamba_data_processing_etl(IN etl_incremental_mode INT)

BEGIN
    -- add base folder SP here if any --

    CALL sp_data_processing_derived_transfers();
    CALL sp_data_processing_derived_non_suppressed();
    CALL sp_data_processing_derived_hiv_art_card();
    CALL sp_data_processing_derived_IIT();
    CALL sp_data_processing_derived_hts();
    CALL sp_data_processing_derived_anc();

END //

DELIMITER ;


    -- $END