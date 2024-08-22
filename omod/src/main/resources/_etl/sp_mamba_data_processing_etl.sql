-- $BEGIN
-- add base folder SP here --
-- CALL sp_data_processing_derived_hts();

CALL sp_mamba_data_processing_flatten();
CALL sp_data_processing_derived_transfers();
CALL sp_data_processing_derived_non_suppressed();
CALL sp_data_processing_derived_hiv_art_card();
CALL sp_data_processing_derived_IIT();
CALL sp_data_processing_derived_hts();
    -- $END