-- --------------------------------------------------------------------------------------------------------------------
-- 01_setup.sql
-- 
-- Ce script prépare l'environnement pour l'analyse des arrêts d'ensacheuse.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 1. Contexte (base, schéma, warehouse)
create database if not exists SNOW_VIBER_MAINTENANCE_003;
use database SNOW_VIBER_MAINTENANCE_003;
create schema if not exists raw_data;
use schema raw_data;

create warehouse if not exists SNOW_VIBER_WH
    warehouse_size = 'xsmall'
    auto_suspend = 60
    auto_resume = true;
use warehouse SNOW_VIBER_WH;
