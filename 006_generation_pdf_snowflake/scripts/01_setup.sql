-- --------------------------------------------------------------------------------------------------------------------
-- 01_setup.sql
--
-- Environnement pour la génération de PDF (base, schéma, warehouse, stage).
-- Réutilise la même base que 005 (OCR cartes grises) pour permettre l'enchaînement :
-- 006 génère les PDF → 005 extrait les champs via OCR.
-- Idempotent (CREATE IF NOT EXISTS / CREATE OR REPLACE).
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

-- 2. Stage pour les documents (cartes grises PDF)
-- SNOWFLAKE_SSE requis si les PDF servent ensuite à AI_PARSE_DOCUMENT / AI_EXTRACT (005).
create or replace stage SNOW_VIBER_OCR_005.raw_data.documents_cartes_grises
    encryption = (type = 'SNOWFLAKE_SSE')
    directory = (enable = true)
    comment = 'dépôt des cartes grises (génération 006 ou upload manuel pour OCR 005)';

-- Validation
select current_database(), current_schema(), current_warehouse();
show stages like 'documents_cartes_grises';
