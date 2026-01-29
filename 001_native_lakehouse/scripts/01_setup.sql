-- --------------------------------------------------------------------------------------------------------------------
-- 01_setup.sql
-- 
-- Ce script prépare l'environnement pour le Native Lakehouse.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 1. Création de la Database (Le conteneur logique)
CREATE DATABASE IF NOT EXISTS SNOW_VIBER_LAKEHOUSE_001;
USE DATABASE SNOW_VIBER_LAKEHOUSE_001;

-- 2. Création du Schema (L'organisation)
CREATE SCHEMA IF NOT EXISTS RAW_DATA;
USE SCHEMA RAW_DATA;

-- 3. Création du Warehouse (La puissance de calcul)
-- XSMALL est suffisant pour cette démo. Auto-suspend à 60s pour économiser les crédits.
CREATE WAREHOUSE IF NOT EXISTS SNOW_VIBER_WH 
    WAREHOUSE_SIZE = 'XSMALL' 
    AUTO_SUSPEND = 60 
    AUTO_RESUME = TRUE;
USE WAREHOUSE SNOW_VIBER_WH;

-- Validation
SELECT current_database(), current_schema(), current_warehouse();
