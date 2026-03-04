-- ============================================================================
-- 01_setup.sql
-- Création de l'environnement pour la génération de données synthétiques
-- Article : génération de données synthétiques pour le bilan social
-- ============================================================================

-- Base de données dédiée
CREATE DATABASE IF NOT EXISTS SNOW_VIBER_BILAN_007;
USE DATABASE SNOW_VIBER_BILAN_007;

-- Schémas fonctionnels
CREATE SCHEMA IF NOT EXISTS REFERENTIEL;   -- Tables de référence métier
CREATE SCHEMA IF NOT EXISTS GENERATION;     -- Données générées
CREATE SCHEMA IF NOT EXISTS INDICATEURS;    -- Vues et calculs bilan social

-- Commentaires pour la documentation
COMMENT ON DATABASE SNOW_VIBER_BILAN_007 IS 
    'Démo génération données synthétiques RH - Article SnowflakeViber 007';

COMMENT ON SCHEMA REFERENTIEL IS 
    'Tables de référence : postes, établissements, grilles salariales';

COMMENT ON SCHEMA GENERATION IS 
    'Données synthétiques générées : salariés, contrats, formations';

COMMENT ON SCHEMA INDICATEURS IS 
    'Calculs des 7 rubriques du bilan social';
