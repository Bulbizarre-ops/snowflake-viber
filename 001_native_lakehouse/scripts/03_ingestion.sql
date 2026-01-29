-- --------------------------------------------------------------------------------------------------------------------
-- 03_ingestion.sql
-- 
-- Ce script simule l'arrivée de fichiers dans le Lakehouse.
-- En production, cela serait fait via un driver, une API, ou Snowpipe.
-- Ici, on utilise la méthode "Unload" interne pour générer des fichiers réels sur le disque du stage.
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_LAKEHOUSE_001.RAW_DATA;
USE WAREHOUSE SNOW_VIBER_WH;

-- 1. Génération de fausses données (1000 lignes)
CREATE OR REPLACE TABLE generator_source AS 
SELECT 
    SEQ4() as id, 
    'user_' || UNIFORM(1, 100, RANDOM()) as user_id, 
    DATEADD(day, -UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) as event_date
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- 2. Déversement dans le lac ("Reverse Ingestion")
-- On écrit physiquement des fichiers CSV compressés dans le stage @raw_lake
COPY INTO @raw_lake/events/2026/01/data_
FROM generator_source
FILE_FORMAT = (TYPE = CSV COMPRESSION = GZIP)
HEADER = TRUE;

-- 3. Mise à jour de l'index
-- En production avec auto_refresh=true c'est automatique.
-- Ici on force le refresh pour que les fichiers soient immédiatement visibles.
ALTER STAGE raw_lake REFRESH;
