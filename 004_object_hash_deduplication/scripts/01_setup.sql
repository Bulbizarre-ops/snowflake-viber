-- --------------------------------------------------------------------------------------------------------------------
-- 01_setup.sql
--
-- Contexte pour la démo object-hash : base, schéma, warehouse.
-- Idempotent (CREATE OR REPLACE / IF NOT EXISTS).
-- --------------------------------------------------------------------------------------------------------------------

create database if not exists SNOW_VIBER_OBJECT_HASH_004;
use database SNOW_VIBER_OBJECT_HASH_004;

create schema if not exists demo;
use schema demo;

create warehouse if not exists SNOW_VIBER_WH
    warehouse_size = 'xsmall'
    auto_suspend = 60
    auto_resume = true;
use warehouse SNOW_VIBER_WH;
