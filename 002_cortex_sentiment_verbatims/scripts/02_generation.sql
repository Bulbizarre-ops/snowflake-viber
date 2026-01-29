-- --------------------------------------------------------------------------------------------------------------------
-- 02_generation.sql
-- 
-- Ce script génère des verbatims oraux réalistes via Snowflake Cortex AI.
-- Les textes simulés sont volontairement imparfaits (langage oral, hésitations, répétitions).
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_MOBALPA_002.RAW_DATA;
USE WAREHOUSE SNOW_VIBER_MOBALPA_WH;

-- 1. Génération des rapports techniciens
CREATE OR REPLACE TABLE verbatim_techniciens AS
WITH prompts AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SEQ4()) as chantier_id,
        'montgermont_' || LPAD(SEQ4()::STRING, 4, '0') as chantier_ref,
        CASE 
            WHEN UNIFORM(1, 10, RANDOM()) <= 3 THEN 'cuisine complète'
            WHEN UNIFORM(1, 10, RANDOM()) <= 6 THEN 'aménagement placard'
            ELSE 'rénovation partielle'
        END as type_chantier
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
)
SELECT 
    chantier_id,
    chantier_ref,
    type_chantier,
    SNOWFLAKE.CORTEX.AI_COMPLETE(
        'mistral-large2',
        'Tu es un technicien poseur de cuisine Mobalpa donnant un rapport oral transcrit automatiquement. '
        || 'Génère un transcript brut (80-120 mots) sur le chantier "' || chantier_ref || '" de type "' || type_chantier || '". '
        || 'IMPORTANT : simule les imperfections d''un vrai oral : '
        || 'répétitions, hésitations (euh, ben), phrases inachevées, fautes de syntaxe. '
        || 'Inclus 1-2 problèmes techniques concrets (ajustement, alignement, découpe). '
        || 'Ton : parlé, spontané, sans relecture.'
    ) as rapport_technicien,
    CURRENT_TIMESTAMP() as date_collecte
FROM prompts;

-- Vérification : afficher 3 exemples
SELECT chantier_ref, LEFT(rapport_technicien, 150) || '...' as extrait 
FROM verbatim_techniciens 
LIMIT 3;

-- 2. Génération des retours clients
CREATE OR REPLACE TABLE verbatim_clients AS
SELECT 
    t.chantier_id,
    t.chantier_ref,
    t.type_chantier,
    SNOWFLAKE.CORTEX.AI_COMPLETE(
        'mistral-large2',
        'Tu es un client Mobalpa répondant à une enquête de satisfaction par téléphone (transcript audio). '
        || 'Installation : "' || t.type_chantier || '". '
        || 'IMPORTANT : simule un vrai oral transcrit : hésitations, répétitions, phrases incomplètes. '
        || 'Ton retour (60-100 mots) mentionne : qualité produit, poseur, et 1-2 points d''amélioration. '
        || 'Ton : spontané, langage courant.'
    ) as retour_client,
    CURRENT_TIMESTAMP() as date_collecte
FROM verbatim_techniciens t;

-- Vérification : afficher 3 exemples
SELECT chantier_ref, LEFT(retour_client, 150) || '...' as extrait 
FROM verbatim_clients 
LIMIT 3;
