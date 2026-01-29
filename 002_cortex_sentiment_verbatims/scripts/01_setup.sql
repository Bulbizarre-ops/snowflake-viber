-- --------------------------------------------------------------------------------------------------------------------
-- 01_setup.sql
-- 
-- Ce script prépare l'environnement pour l'analyse de verbatims avec Cortex AI.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 1. Création du Warehouse (compute pour l'IA)
CREATE WAREHOUSE IF NOT EXISTS SNOW_VIBER_MOBALPA_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'warehouse dédié aux analyses IA Mobalpa';
USE WAREHOUSE SNOW_VIBER_MOBALPA_WH;

-- 2. Création de la Database et du Schema
CREATE DATABASE IF NOT EXISTS SNOW_VIBER_MOBALPA_002;
USE DATABASE SNOW_VIBER_MOBALPA_002;

CREATE SCHEMA IF NOT EXISTS RAW_DATA
    COMMENT = 'données brutes : verbatims techniciens et clients';
USE SCHEMA RAW_DATA;

-- 3. Création du Stage interne (Lakehouse natif)
CREATE OR REPLACE STAGE verbatims_lake
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'stockage interne des rapports techniciens et retours clients';

-- Validation
SELECT current_database(), current_schema(), current_warehouse();
