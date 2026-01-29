-- --------------------------------------------------------------------------------------------------------------------
-- 02_storage.sql
-- 
-- Ce script crée le "Internal Stage" qui va servir de Lakehouse.
-- C'est ici que la différence avec S3 se joue : Directory Table et Encryption native.
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_LAKEHOUSE_001.RAW_DATA;

-- 1. Le Container (Internal Stage)
-- DIRECTORY = (ENABLE = TRUE) : Transforme le stage en système de fichiers indexé.
-- ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') : Cryptage managé par Snowflake (Server Side Encryption).
CREATE OR REPLACE STAGE raw_lake
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Le datalake natif : stockage interne crypté et indexé';

-- Vérification de la création
SHOW STAGES LIKE 'raw_lake';
