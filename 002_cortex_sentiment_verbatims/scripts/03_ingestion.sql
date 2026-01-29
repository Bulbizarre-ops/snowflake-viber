-- --------------------------------------------------------------------------------------------------------------------
-- 03_ingestion.sql
-- 
-- Ce script ingère les verbatims dans le lakehouse natif (internal stage + directory table).
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_MOBALPA_002.RAW_DATA;
USE WAREHOUSE SNOW_VIBER_MOBALPA_WH;

-- 1. Export des verbatims techniciens vers le stage interne
COPY INTO @verbatims_lake/techniciens/2026_01/
FROM verbatim_techniciens
FILE_FORMAT = (TYPE = CSV COMPRESSION = GZIP FIELD_OPTIONALLY_ENCLOSED_BY = '"')
HEADER = TRUE
OVERWRITE = TRUE;

-- 2. Export des retours clients vers le stage interne
COPY INTO @verbatims_lake/clients/2026_01/
FROM verbatim_clients
FILE_FORMAT = (TYPE = CSV COMPRESSION = GZIP FIELD_OPTIONALLY_ENCLOSED_BY = '"')
HEADER = TRUE
OVERWRITE = TRUE;

-- 3. Indexation des fichiers
ALTER STAGE verbatims_lake REFRESH;

-- Vérification : lister les fichiers indexés
SELECT 
    RELATIVE_PATH,
    SIZE as taille_bytes,
    LAST_MODIFIED,
    SPLIT_PART(RELATIVE_PATH, '/', 1) as source_type
FROM DIRECTORY(@verbatims_lake)
ORDER BY LAST_MODIFIED DESC;
