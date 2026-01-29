-- --------------------------------------------------------------------------------------------------------------------
-- 04_exploration.sql
-- 
-- Ce script montre la puissance du Directory Table.
-- On requête les métadonnées des fichiers comme une simple table SQL.
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_LAKEHOUSE_001.RAW_DATA;

-- 1. Exploration standard (comme un 'ls -la' mais en SQL)
SELECT 
    RELATIVE_PATH, 
    SIZE as size_bytes,
    LAST_MODIFIED,
    MD5
FROM DIRECTORY(@raw_lake)
WHERE RELATIVE_PATH LIKE 'events/%'
ORDER BY LAST_MODIFIED DESC;

-- 2. Génération d'URL d'accès sécurisé (Pre-signed URL)
-- Permet de télécharger un fichier spécifique sans donner accès au stage entier.
SELECT 
    RELATIVE_PATH,
    GET_PRESIGNED_URL(@raw_lake, RELATIVE_PATH) as download_link
FROM DIRECTORY(@raw_lake)
LIMIT 5;
