-- --------------------------------------------------------------------------------------------------------------------
-- 05_actions.sql
-- 
-- Ce script croise les perceptions technicien/client et propose des actions prioritaires.
-- --------------------------------------------------------------------------------------------------------------------

USE SCHEMA SNOW_VIBER_MOBALPA_002.RAW_DATA;
USE WAREHOUSE SNOW_VIBER_MOBALPA_WH;

-- 1. Comparaison technicien vs client
CREATE OR REPLACE TABLE ecarts_perception AS
SELECT 
    t.chantier_ref,
    t.type_chantier,
    t.sentiment_score as sentiment_technicien,
    c.sentiment_score as sentiment_client,
    ABS(t.sentiment_score - c.sentiment_score) as ecart_sentiment,
    t.type_friction,
    c.satisfaction_globale,
    CASE 
        WHEN t.sentiment_score > 0 AND c.sentiment_score < -0.3 THEN 'ALERTE_ROUGE'
        WHEN t.sentiment_score > 0.3 AND c.sentiment_score < 0 THEN 'ECART_SIGNIFICATIF'
        WHEN ABS(t.sentiment_score - c.sentiment_score) < 0.2 THEN 'COHERENT'
        ELSE 'VARIABLE'
    END as statut_alignement
FROM analyse_techniciens t
INNER JOIN analyse_clients c ON t.chantier_ref = c.chantier_ref;

-- 2. Vue opérationnelle : actions prioritaires
CREATE OR REPLACE VIEW actions_prioritaires AS
SELECT 
    e.chantier_ref,
    e.type_chantier,
    e.type_friction,
    e.statut_alignement,
    t.problemes_identifies as rapport_technicien,
    c.ameliorations_attendues as retour_client,
    CASE 
        WHEN UPPER(TRIM(e.type_friction::STRING)) LIKE '%MATERIEL%' AND e.statut_alignement = 'ALERTE_ROUGE' 
            THEN 'ACTION_1 : audit qualité produit sur cette référence'
        WHEN UPPER(TRIM(e.type_friction::STRING)) LIKE '%POSE%' AND e.statut_alignement = 'ALERTE_ROUGE' 
            THEN 'ACTION_2 : formation poseur sur ce type de chantier'
        WHEN e.ecart_sentiment > 0.5 
            THEN 'ACTION_3 : améliorer communication client pendant chantier'
        ELSE 'SURVEILLANCE'
    END as action_recommandee
FROM ecarts_perception e
LEFT JOIN analyse_techniciens t ON e.chantier_ref = t.chantier_ref
LEFT JOIN analyse_clients c ON e.chantier_ref = c.chantier_ref
WHERE e.statut_alignement IN ('ALERTE_ROUGE', 'ECART_SIGNIFICATIF')
ORDER BY e.ecart_sentiment DESC;

-- Vérification : top 5 actions
SELECT * FROM actions_prioritaires LIMIT 5;

-- 3. Résumé exécutif
SELECT 
    'TOTAL CHANTIERS ANALYSES' as metrique, COUNT(*)::STRING as valeur 
FROM ecarts_perception
UNION ALL
SELECT 
    'TAUX DE COHERENCE (technicien/client)', 
    CONCAT(ROUND(100.0 * SUM(CASE WHEN statut_alignement = 'COHERENT' THEN 1 ELSE 0 END) / COUNT(*), 1), '%')
FROM ecarts_perception
UNION ALL
SELECT 
    'CHANTIERS EN ALERTE ROUGE',
    SUM(CASE WHEN statut_alignement = 'ALERTE_ROUGE' THEN 1 ELSE 0 END)::STRING
FROM ecarts_perception
UNION ALL
SELECT 
    'ECART MOYEN DE PERCEPTION (sentiment)',
    ROUND(AVG(ecart_sentiment), 2)::STRING
FROM ecarts_perception
UNION ALL
SELECT 
    'PRINCIPALE FRICTION DETECTEE',
    type_friction::STRING
FROM (
    SELECT type_friction, COUNT(*) as nb 
    FROM ecarts_perception 
    WHERE type_friction IS NOT NULL 
    GROUP BY type_friction 
    ORDER BY nb DESC 
    LIMIT 1
);
