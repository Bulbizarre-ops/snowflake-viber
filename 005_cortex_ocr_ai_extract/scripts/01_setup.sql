-- --------------------------------------------------------------------------------------------------------------------
-- 01_setup.sql
--
-- Environnement pour l'OCR de cartes grises (expert assurance).
-- Stage interne avec chiffrement obligatoire pour AI_PARSE_DOCUMENT / AI_EXTRACT.
-- Après ce script : charger les démo data via SnowSight (Data → Stages → documents_cartes_grises → Upload).
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 1. Contexte (base, schéma, warehouse)
create database if not exists SNOW_VIBER_OCR_005;
use database SNOW_VIBER_OCR_005;
create schema if not exists raw_data;
use schema raw_data;

create warehouse if not exists SNOW_VIBER_WH
    warehouse_size = 'xsmall'
    auto_suspend = 60
    auto_resume = true;
use warehouse SNOW_VIBER_WH;

-- 2. Stage pour les documents (cartes grises PDF/images)
-- AI_PARSE_DOCUMENT et AI_EXTRACT exigent un stage avec chiffrement côté serveur.
create or replace stage SNOW_VIBER_OCR_005.raw_data.documents_cartes_grises
    encryption = (type = 'SNOWFLAKE_SSE')
    directory = (enable = true)
    comment = 'dépôt des cartes grises pour extraction OCR et AI_EXTRACT';

-- Validation
select current_database(), current_schema(), current_warehouse();
show stages like 'documents_cartes_grises';

-- 3. Chargement des démo data : via SnowSight
--    Data → Databases → SNOW_VIBER_OCR_005 → raw_data → Stages → documents_cartes_grises → Upload
--    (sélectionner le dossier demo_data/ ou les PDF à tester)
