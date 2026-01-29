-- --------------------------------------------------------------------------------------------------------------------
-- 04_analysis.sql
-- 
-- Ce script applique l'analyse IA (sentiment + extraction) sur les verbatims.
-- Important : on matérialise en tables pour éviter de relancer l'IA à chaque requête.
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_MOBALPA_002.RAW_DATA;
USE WAREHOUSE SNOW_VIBER_MOBALPA_WH;

-- 1. Analyse des rapports techniciens
CREATE OR REPLACE TABLE analyse_techniciens AS
SELECT 
    chantier_ref,
    type_chantier,
    rapport_technicien,
    SNOWFLAKE.CORTEX.SENTIMENT(rapport_technicien) as sentiment_score,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        rapport_technicien,
        'Quels problèmes techniques ont été rencontrés ?'
    ) as problemes_identifies,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        rapport_technicien,
        'Le problème vient-il du matériel ou de la pose ? Réponds en un mot : MATERIEL ou POSE.'
    ) as type_friction
FROM verbatim_techniciens;

-- Vérification : distribution des sentiments
SELECT 
    type_friction,
    COUNT(*) as nb_cas,
    ROUND(AVG(sentiment_score), 2) as sentiment_moyen
FROM analyse_techniciens
WHERE type_friction IS NOT NULL
GROUP BY type_friction
ORDER BY nb_cas DESC;

-- 2. Analyse des retours clients
CREATE OR REPLACE TABLE analyse_clients AS
SELECT 
    chantier_ref,
    type_chantier,
    retour_client,
    SNOWFLAKE.CORTEX.SENTIMENT(retour_client) as sentiment_score,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        retour_client,
        'Quels points à améliorer le client mentionne-t-il ?'
    ) as ameliorations_attendues,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        retour_client,
        'Le client est-il globalement satisfait ? Réponds OUI ou NON.'
    ) as satisfaction_globale
FROM verbatim_clients;

-- Vérification : taux de satisfaction
SELECT 
    satisfaction_globale,
    COUNT(*) as nb_clients,
    ROUND(AVG(sentiment_score), 2) as sentiment_moyen
FROM analyse_clients
WHERE satisfaction_globale IS NOT NULL
GROUP BY satisfaction_globale
ORDER BY nb_clients DESC;
