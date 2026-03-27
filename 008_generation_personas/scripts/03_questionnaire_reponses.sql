-- ============================================================================
-- 03_questionnaire_reponses.sql
-- Simulation des réponses au questionnaire comportemental avec bruit
-- ============================================================================
-- Auteur: Aymeric Veyron
-- Prérequis: 01_archetypes.sql et 02_generation_personas.sql exécutés
-- ============================================================================

USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;

-- Création de la table des réponses
CREATE OR REPLACE TABLE PERSONAS_REPONSES_QUESTIONNAIRE (
    persona_id INT PRIMARY KEY,
    q1_frigo VARCHAR(1),      -- Frigo dimanche soir
    q2_reunion VARCHAR(1),    -- Réunion data lundi
    q3_serie VARCHAR(1),      -- Série préférée
    q4_meteo VARCHAR(1),      -- Parapluie 40%
    q5_rapport VARCHAR(1),    -- Chiffre bizarre
    q6_gps VARCHAR(1),        -- Rapport au GPS
    q7_stagiaire VARCHAR(1),  -- Stagiaire Excel
    q8_jeu VARCHAR(1),        -- Jeu de société
    q9_fournisseur VARCHAR(1),-- Choix fournisseur
    q10_decision VARCHAR(1),  -- Idée coûteuse (VARIABLE CIBLE)
    q11_phrase VARCHAR(1),    -- Phrase déjà dite
    q12_process VARCHAR(1),   -- Process échoué
    q13_film VARCHAR(1),      -- Film de chevet
    q14_alarme VARCHAR(1),    -- Alarme 2h du matin
    q15_dashboard VARCHAR(1)  -- Dashboard idéal
);

-- ============================================================================
-- Génération des réponses avec LLM + bruit contextuel
-- ============================================================================

INSERT INTO PERSONAS_REPONSES_QUESTIONNAIRE
WITH persona_data AS (
    -- Enrichissement des personas avec contexte de réponse (BRUIT)
    SELECT 
        p.*, 
        a.nom AS archetype_nom, 
        a.phrase_identite AS archetype_phrase, 
        a.rapport_data, 
        a.pression_ressentie,
        
        -- Ajout d'humeur aléatoire (BRUIT RÉALISTE)
        ARRAY_CONSTRUCT(
            'irrité après un appel client difficile',
            'détendu, bon week-end derrière lui',
            'anxieux car deadline vendredi',
            'enthousiaste après une bonne nouvelle commerciale',
            'blasé, lundi matin pluvieux',
            'pressé, 3 réunions qui s''enchaînent',
            'distrait, problème perso en tête',
            'confiant après un succès récent',
            'sur la défensive après une critique',
            'curieux, vient de lire un article inspirant'
        )[UNIFORM(0, 9, RANDOM())]::VARCHAR AS humeur,
        
        -- Ajout de niveau de fatigue (BRUIT RÉALISTE)
        ARRAY_CONSTRUCT(
            'très fatigué (4h de sommeil, semaine intense)',
            'fatigué (accumulation de fin de mois)',
            'correct (6h de sommeil)',
            'en forme (8h de sommeil, sport cette semaine)',
            'épuisé (insomnie, stress)',
            'moyennement reposé',
            'un peu vaseux (digestion lourde)',
            'alerte mais tendu'
        )[UNIFORM(0, 7, RANDOM())]::VARCHAR AS fatigue,
        
        -- Contexte de réponse
        ARRAY_CONSTRUCT(
            'répond entre deux emails',
            'répond dans le train',
            'répond pendant sa pause café',
            'répond le soir chez lui',
            'répond en salle d''attente',
            'répond vite avant une réunion',
            'répond calmement à son bureau'
        )[UNIFORM(0, 6, RANDOM())]::VARCHAR AS contexte_reponse
        
    FROM PERSONAS_DATA_PME p
    JOIN ARCHETYPES_PSYCHOGRAPHIQUES a ON p.archetype_id = a.id
),
with_responses AS (
    SELECT 
        pd.id AS persona_id,
        SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet',
'Tu es ' || pd.prenom || ' ' || pd.nom || ', ' || pd.age || ' ans, ' || pd.poste || ' chez ' || pd.entreprise_nom || ' (' || pd.secteur || ', ' || pd.region || ').

TON ÉTAT ACTUEL (influence tes réponses):
- Humeur: ' || pd.humeur || '
- Fatigue: ' || pd.fatigue || '
- Contexte: ' || pd.contexte_reponse || '

TON PROFIL DE FOND:
- Archétype: ' || pd.archetype_nom || ' ("' || pd.archetype_phrase || '")
- Rapport à la data: ' || pd.rapport_data || '
- Tes défauts: ' || pd.defaut_1 || ' / ' || pd.defaut_2 || '

CONSIGNE: Réponds comme ce persona DANS CET ÉTAT. Ta fatigue et ton humeur peuvent te faire:
- Répondre plus vite/impulsivement si pressé ou fatigué
- Être moins cohérent que ton archétype de base
- Choisir parfois une réponse qui ne te ressemble pas à 100%

Q1-Frigo dimanche: A=improvise omelette B=consulte notes C=suit recette D=commande sushis
Q2-Réunion data: A="Enfin" B="Encore?" C="Mes chiffres vont tenir?" D="Je prépare mes contre-arguments"
Q3-Série: A=Columbo B=MacGyver C=Sherlock D=Ted Lasso
Q4-Météo 40%: A=prend parapluie B=ne prend pas C=calcule horaires D=demande collègue
Q5-Marge -3pts: A=en parle à équipe B=creuse seul 2h C=attend mois prochain D=appelle comptable
Q6-GPS: A=suit à la lettre B=regarde puis fait à sa façon C=lance si perdu D=connaît tout de mémoire
Q7-Stagiaire Excel: A=vérifie hypothèses B=dit intéressant et range C=convoque client D=montre au DAF
Q8-Jeu: A=Cluedo B=Time''s Up C=Puissance4 D=Pictionary
Q9-Fournisseur: A=demande références B=choisit le connu C=comparatif 6 critères D=prend le risque
Q10-Idée coûteuse: A=valide seul si budget B=monte argumentaire C=teste petit d''abord D=dépend montant
Q11-Phrase dite: A="toujours fait comme ça" B="aurais dû suivre instinct" C="j''ai les chiffres mais..." D="on verra, on s''adaptera"
Q12-Process échoué: A=analyse pourquoi B=change immédiatement C=réunion collective D=bonne idée mal exécutée
Q13-Film: A=Moneyball B=Bronzés C=Social Network D=Intouchables
Q14-Alarme 2h: A=évalue urgence B=coupe son C=appelle responsable D=stress jusqu''au matin
Q15-Dashboard: A=3 chiffres temps réel B=tendance 3 mois C=indicateurs équipe partagés D=répond aux questions du moment

Réponds UNIQUEMENT en JSON:
{"q1":"X","q2":"X","q3":"X","q4":"X","q5":"X","q6":"X","q7":"X","q8":"X","q9":"X","q10":"X","q11":"X","q12":"X","q13":"X","q14":"X","q15":"X"}'
        ) AS llm_response
    FROM persona_data pd
)
SELECT 
    persona_id,
    UPPER(TRY_PARSE_JSON(llm_response):q1::VARCHAR) AS q1_frigo,
    UPPER(TRY_PARSE_JSON(llm_response):q2::VARCHAR) AS q2_reunion,
    UPPER(TRY_PARSE_JSON(llm_response):q3::VARCHAR) AS q3_serie,
    UPPER(TRY_PARSE_JSON(llm_response):q4::VARCHAR) AS q4_meteo,
    UPPER(TRY_PARSE_JSON(llm_response):q5::VARCHAR) AS q5_rapport,
    UPPER(TRY_PARSE_JSON(llm_response):q6::VARCHAR) AS q6_gps,
    UPPER(TRY_PARSE_JSON(llm_response):q7::VARCHAR) AS q7_stagiaire,
    UPPER(TRY_PARSE_JSON(llm_response):q8::VARCHAR) AS q8_jeu,
    UPPER(TRY_PARSE_JSON(llm_response):q9::VARCHAR) AS q9_fournisseur,
    UPPER(TRY_PARSE_JSON(llm_response):q10::VARCHAR) AS q10_decision,
    UPPER(TRY_PARSE_JSON(llm_response):q11::VARCHAR) AS q11_phrase,
    UPPER(TRY_PARSE_JSON(llm_response):q12::VARCHAR) AS q12_process,
    UPPER(TRY_PARSE_JSON(llm_response):q13::VARCHAR) AS q13_film,
    UPPER(TRY_PARSE_JSON(llm_response):q14::VARCHAR) AS q14_alarme,
    UPPER(TRY_PARSE_JSON(llm_response):q15::VARCHAR) AS q15_dashboard
FROM with_responses;

-- ============================================================================
-- Vérifications
-- ============================================================================

-- Distribution Q10 (variable cible)
SELECT 
    q10_decision,
    CASE q10_decision
        WHEN 'A' THEN 'Décideur autonome'
        WHEN 'B' THEN 'Non-décideur'
        WHEN 'C' THEN 'Décideur contraint'
        WHEN 'D' THEN 'Décideur partiel'
    END AS type_decideur,
    COUNT(*) AS nb,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM PERSONAS_REPONSES_QUESTIONNAIRE
GROUP BY q10_decision
ORDER BY nb DESC;

-- Distribution par question
SELECT 'Q1' AS question, q1_frigo AS reponse, COUNT(*) AS nb FROM PERSONAS_REPONSES_QUESTIONNAIRE GROUP BY q1_frigo
UNION ALL
SELECT 'Q5', q5_rapport, COUNT(*) FROM PERSONAS_REPONSES_QUESTIONNAIRE GROUP BY q5_rapport
UNION ALL
SELECT 'Q12', q12_process, COUNT(*) FROM PERSONAS_REPONSES_QUESTIONNAIRE GROUP BY q12_process
ORDER BY question, reponse;

-- Exemple de réponses complètes
SELECT * FROM PERSONAS_REPONSES_QUESTIONNAIRE LIMIT 5;
