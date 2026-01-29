-- --------------------------------------------------------------------------------------------------------------------
-- 05_security.sql
-- 
-- Ce script applique le modèle de sécurité (RBAC).
-- Démonstration du principe de moindre privilège.
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_LAKEHOUSE_001.RAW_DATA;

-- 1. Création du Rôle d'écriture
CREATE OR REPLACE ROLE SNOW_VIBER_LAKEHOUSE_WRITER_ROLE;

-- 2. Application des permissions
-- Note : Sur un internal stage, READ est requis pour avoir le droit WRITE (pour vérifier les métadonnées avant écriture)
GRANT READ, WRITE ON STAGE raw_lake TO ROLE SNOW_VIBER_LAKEHOUSE_WRITER_ROLE;

-- Accès contextuels nécessaires
GRANT USAGE ON DATABASE SNOW_VIBER_LAKEHOUSE_001 TO ROLE SNOW_VIBER_LAKEHOUSE_WRITER_ROLE;
GRANT USAGE ON SCHEMA RAW_DATA TO ROLE SNOW_VIBER_LAKEHOUSE_WRITER_ROLE;
GRANT USAGE ON WAREHOUSE SNOW_VIBER_WH TO ROLE SNOW_VIBER_LAKEHOUSE_WRITER_ROLE;

-- 3. Test (Simulation changement de casquette)
-- USE ROLE SNOW_VIBER_LAKEHOUSE_WRITER_ROLE;
-- ... vos opérations ...
-- USE ROLE ACCOUNTADMIN;
