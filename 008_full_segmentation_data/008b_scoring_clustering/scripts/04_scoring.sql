-- ============================================================================
-- 04_scoring.sql
-- Calcul des scores sur les 4 axes comportementaux (A, B, C, D)
-- ============================================================================
-- Auteur: Aymeric Veyron
-- Prérequis: 03_questionnaire_reponses.sql exécuté
-- ============================================================================

USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;

-- ============================================================================
-- GRILLE DE SCORING
-- ============================================================================
-- Chaque réponse à chaque question contribue +1 à certains axes
-- 
-- Axe A = Analytique (besoin de comprendre avant d'agir)
-- Axe B = Réactif (orienté action immédiate)
-- Axe C = Collectif (importance du groupe)
-- Axe D = Intuitif (décision au feeling)
-- ============================================================================

CREATE OR REPLACE TABLE PERSONAS_SCORES AS
SELECT 
    persona_id,
    
    -- ========================================================================
    -- AXE A - ANALYTIQUE
    -- ========================================================================
    (CASE WHEN q1_frigo = 'B' THEN 1 WHEN q1_frigo = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q2_reunion = 'A' THEN 1 WHEN q2_reunion = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q3_serie = 'A' THEN 1 WHEN q3_serie = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q4_meteo = 'A' THEN 1 WHEN q4_meteo = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q5_rapport = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q6_gps = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q7_stagiaire = 'A' THEN 1 WHEN q7_stagiaire = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q8_jeu = 'A' THEN 1 WHEN q8_jeu = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q9_fournisseur = 'A' THEN 1 WHEN q9_fournisseur = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q11_phrase = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q12_process = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q13_film = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q14_alarme = 'A' THEN 1 WHEN q14_alarme = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q15_dashboard = 'A' THEN 1 WHEN q15_dashboard = 'B' THEN 1 ELSE 0 END) 
    AS axe_a,
    
    -- ========================================================================
    -- AXE B - RÉACTIF
    -- ========================================================================
    (CASE WHEN q1_frigo = 'A' THEN 1 WHEN q1_frigo = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q2_reunion = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q3_serie = 'B' THEN 1 WHEN q3_serie = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q4_meteo = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q5_rapport = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q6_gps = 'A' THEN 1 WHEN q6_gps = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q7_stagiaire = 'B' THEN 1 WHEN q7_stagiaire = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q8_jeu = 'B' THEN 1 WHEN q8_jeu = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q9_fournisseur = 'C' THEN 1 WHEN q9_fournisseur = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q11_phrase = 'B' THEN 1 WHEN q11_phrase = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q12_process = 'A' THEN 1 WHEN q12_process = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q13_film = 'B' THEN 1 WHEN q13_film = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q14_alarme = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q15_dashboard = 'B' THEN 1 WHEN q15_dashboard = 'D' THEN 1 ELSE 0 END) 
    AS axe_b,
    
    -- ========================================================================
    -- AXE C - COLLECTIF
    -- ========================================================================
    (CASE WHEN q1_frigo = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q2_reunion = 'A' THEN 1 WHEN q2_reunion = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q3_serie = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q4_meteo = 'C' THEN 1 WHEN q4_meteo = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q5_rapport = 'A' THEN 1 WHEN q5_rapport = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q6_gps = 'B' THEN 1 WHEN q6_gps = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q7_stagiaire = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q8_jeu = 'A' THEN 1 ELSE 0 END) +
    (CASE WHEN q9_fournisseur = 'A' THEN 1 WHEN q9_fournisseur = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q11_phrase = 'A' THEN 1 WHEN q11_phrase = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q12_process = 'C' THEN 1 WHEN q12_process = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q13_film = 'A' THEN 1 WHEN q13_film = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q14_alarme = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q15_dashboard = 'A' THEN 1 WHEN q15_dashboard = 'C' THEN 1 ELSE 0 END) 
    AS axe_c,
    
    -- ========================================================================
    -- AXE D - INTUITIF
    -- ========================================================================
    (CASE WHEN q1_frigo = 'A' THEN 1 WHEN q1_frigo = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q2_reunion = 'B' THEN 1 WHEN q2_reunion = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q3_serie = 'B' THEN 1 WHEN q3_serie = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q4_meteo = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q5_rapport = 'A' THEN 1 WHEN q5_rapport = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q6_gps = 'C' THEN 1 WHEN q6_gps = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q7_stagiaire = 'B' THEN 1 WHEN q7_stagiaire = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q8_jeu = 'B' THEN 1 WHEN q8_jeu = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q9_fournisseur = 'B' THEN 1 WHEN q9_fournisseur = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q11_phrase = 'A' THEN 1 WHEN q11_phrase = 'B' THEN 1 ELSE 0 END) +
    (CASE WHEN q12_process = 'B' THEN 1 WHEN q12_process = 'C' THEN 1 ELSE 0 END) +
    (CASE WHEN q13_film = 'B' THEN 1 WHEN q13_film = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q14_alarme = 'B' THEN 1 WHEN q14_alarme = 'D' THEN 1 ELSE 0 END) +
    (CASE WHEN q15_dashboard = 'C' THEN 1 WHEN q15_dashboard = 'D' THEN 1 ELSE 0 END) 
    AS axe_d,
    
    -- ========================================================================
    -- TYPE DÉCIDEUR (extrait de Q10 - variable cible)
    -- ========================================================================
    CASE q10_decision
        WHEN 'A' THEN 'Décideur autonome'
        WHEN 'B' THEN 'Non-décideur'
        WHEN 'C' THEN 'Décideur contraint'
        WHEN 'D' THEN 'Décideur partiel'
    END AS type_decideur
    
FROM PERSONAS_REPONSES_QUESTIONNAIRE;

-- ============================================================================
-- Statistiques descriptives des scores
-- ============================================================================

SELECT 
    'Axe A (Analytique)' AS axe,
    MIN(axe_a) AS min,
    ROUND(AVG(axe_a), 1) AS moyenne,
    MEDIAN(axe_a) AS mediane,
    MAX(axe_a) AS max,
    ROUND(STDDEV(axe_a), 2) AS ecart_type
FROM PERSONAS_SCORES
UNION ALL
SELECT 'Axe B (Réactif)', MIN(axe_b), ROUND(AVG(axe_b), 1), MEDIAN(axe_b), MAX(axe_b), ROUND(STDDEV(axe_b), 2)
FROM PERSONAS_SCORES
UNION ALL
SELECT 'Axe C (Collectif)', MIN(axe_c), ROUND(AVG(axe_c), 1), MEDIAN(axe_c), MAX(axe_c), ROUND(STDDEV(axe_c), 2)
FROM PERSONAS_SCORES
UNION ALL
SELECT 'Axe D (Intuitif)', MIN(axe_d), ROUND(AVG(axe_d), 1), MEDIAN(axe_d), MAX(axe_d), ROUND(STDDEV(axe_d), 2)
FROM PERSONAS_SCORES;

-- ============================================================================
-- Profil moyen par archétype
-- ============================================================================

SELECT 
    a.nom AS archetype,
    COUNT(*) AS n,
    ROUND(AVG(s.axe_a), 1) AS moy_a,
    ROUND(AVG(s.axe_b), 1) AS moy_b,
    ROUND(AVG(s.axe_c), 1) AS moy_c,
    ROUND(AVG(s.axe_d), 1) AS moy_d
FROM PERSONAS_SCORES s
JOIN PERSONAS_DATA_PME p ON s.persona_id = p.id
JOIN ARCHETYPES_PSYCHOGRAPHIQUES a ON p.archetype_id = a.id
GROUP BY a.nom
ORDER BY n DESC;

-- ============================================================================
-- Profil moyen par type de décideur
-- ============================================================================

SELECT 
    type_decideur,
    COUNT(*) AS n,
    ROUND(AVG(axe_a), 1) AS moy_a,
    ROUND(AVG(axe_b), 1) AS moy_b,
    ROUND(AVG(axe_c), 1) AS moy_c,
    ROUND(AVG(axe_d), 1) AS moy_d
FROM PERSONAS_SCORES
WHERE type_decideur IS NOT NULL
GROUP BY type_decideur
ORDER BY n DESC;

-- ============================================================================
-- Création vue consolidée pour l'analyse
-- ============================================================================

CREATE OR REPLACE VIEW V_PERSONAS_COMPLET AS
SELECT 
    s.persona_id,
    s.axe_a, s.axe_b, s.axe_c, s.axe_d,
    s.type_decideur,
    p.prenom, p.nom, p.genre, p.age, p.region, p.secteur,
    p.taille_entreprise, p.nb_salaries, p.poste, p.entreprise_nom,
    a.nom AS archetype
FROM PERSONAS_SCORES s
JOIN PERSONAS_DATA_PME p ON s.persona_id = p.id
JOIN ARCHETYPES_PSYCHOGRAPHIQUES a ON p.archetype_id = a.id;

-- Vérification
SELECT * FROM V_PERSONAS_COMPLET LIMIT 5;
