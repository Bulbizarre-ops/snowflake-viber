-- ============================================================================
-- 02_generation_personas.sql
-- Génération de personas synthétiques avec Snowflake Cortex LLM
-- ============================================================================
-- Auteur: Aymeric Veyron
-- Prérequis: 01_archetypes.sql exécuté, accès à Snowflake Cortex
-- ============================================================================

USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;

-- Création de la table des personas
CREATE OR REPLACE TABLE PERSONAS_DATA_PME (
    id INT,
    archetype_id INT,
    prenom VARCHAR(100),
    nom VARCHAR(100),
    genre VARCHAR(20),
    age INT,
    region VARCHAR(100),
    secteur VARCHAR(200),
    taille_entreprise VARCHAR(50),
    nb_salaries INT,
    poste VARCHAR(200),
    entreprise_nom VARCHAR(200),
    niveau_maturite_digitale INT,
    phrase_identite VARCHAR(1000),
    quotidien VARCHAR(2000),
    qualite_1 VARCHAR(500),
    qualite_2 VARCHAR(500),
    defaut_1 VARCHAR(500),
    defaut_2 VARCHAR(500),
    declencheur_recent VARCHAR(500),
    cas_usage_prefere VARCHAR(1000),
    objection_principale VARCHAR(500),
    recommandation_ami VARCHAR(1000),
    langue_maternelle VARCHAR(100),
    parcours_atypique VARCHAR(500)
);

-- ============================================================================
-- Génération de 200 personas avec distributions réalistes
-- ============================================================================

INSERT INTO PERSONAS_DATA_PME
WITH base_params AS (
    -- Génération des paramètres aléatoires pour chaque persona
    SELECT 
        seq4() + 1 AS id,
        UNIFORM(1, 100, RANDOM()) AS rand_arch,
        UNIFORM(1, 100, RANDOM()) AS rand_genre,
        UNIFORM(1, 100, RANDOM()) AS rand_age_bucket,
        UNIFORM(0, 15, RANDOM()) AS rand_region,
        UNIFORM(0, 19, RANDOM()) AS rand_secteur,
        UNIFORM(1, 100, RANDOM()) AS rand_taille,
        UNIFORM(0, 14, RANDOM()) AS rand_poste,
        UNIFORM(0, 4, RANDOM()) AS niveau_maturite,
        UNIFORM(0, 14, RANDOM()) AS rand_declencheur,
        UNIFORM(1, 100, RANDOM()) AS rand_prenom_type,
        UNIFORM(0, 39, RANDOM()) AS rand_prenom,
        UNIFORM(0, 39, RANDOM()) AS rand_nom,
        UNIFORM(3, 250, RANDOM()) AS rand_sal
    FROM TABLE(GENERATOR(ROWCOUNT => 200))
),
params AS (
    SELECT 
        id,
        -- Distribution archétypes (pondérée selon fréquence réaliste)
        CASE 
            WHEN rand_arch <= 25 THEN 1  -- Pilote à Vue 25%
            WHEN rand_arch <= 45 THEN 2  -- Pompier Épuisé 20%
            WHEN rand_arch <= 60 THEN 3  -- Contrôleur Frustré 15%
            WHEN rand_arch <= 75 THEN 4  -- Converti Récent 15%
            WHEN rand_arch <= 87 THEN 5  -- Gardien du Temple 12%
            WHEN rand_arch <= 95 THEN 6  -- Humaniste 8%
            ELSE 7                        -- Stratège 5%
        END AS archetype_id,
        
        -- Distribution genre (40% F, 58% H, 2% NB)
        CASE 
            WHEN rand_genre <= 40 THEN 'Femme' 
            WHEN rand_genre <= 98 THEN 'Homme' 
            ELSE 'Non-binaire' 
        END AS genre,
        
        -- Distribution âge par tranches
        CASE 
            WHEN rand_age_bucket <= 20 THEN 28 + MOD(rand_sal, 8)   -- 28-35 ans (20%)
            WHEN rand_age_bucket <= 55 THEN 36 + MOD(rand_sal, 13)  -- 36-48 ans (35%)
            WHEN rand_age_bucket <= 85 THEN 49 + MOD(rand_sal, 10)  -- 49-58 ans (30%)
            ELSE 59 + MOD(rand_sal, 7)                              -- 59-65 ans (15%)
        END AS age,
        
        -- Régions françaises (16 régions + DOM-TOM)
        ARRAY_CONSTRUCT(
            'Île-de-France', 'Auvergne-Rhône-Alpes', 'Nouvelle-Aquitaine', 
            'Occitanie', 'Hauts-de-France', 'Grand Est', 'Provence-Alpes-Côte d''Azur',
            'Pays de la Loire', 'Bretagne', 'Normandie', 'Bourgogne-Franche-Comté',
            'Centre-Val de Loire', 'La Réunion', 'Martinique', 'Guadeloupe', 'Guyane'
        )[rand_region]::VARCHAR AS region,
        
        -- Secteurs d'activité (20 secteurs)
        ARRAY_CONSTRUCT(
            'Commerce de détail', 'Transport routier', 'Industrie légère',
            'Restauration / hôtellerie', 'Artisanat BTP', 'Services B2B',
            'RH / recrutement', 'Logistique / entrepôt', 'Énergie / ENR',
            'Agriculture / agroalimentaire', 'Immobilier / gestion locative', 
            'Distribution alimentaire', 'E-commerce hybride', 'Santé / médico-social', 
            'Nettoyage / facilities', 'Sécurité privée', 'Auto / mobilité', 
            'Tourisme / loisirs', 'Imprimerie / communication', 'Commerce de gros / négoce'
        )[rand_secteur]::VARCHAR AS secteur,
        
        -- Taille entreprise (distribution réaliste PME)
        CASE 
            WHEN rand_taille <= 30 THEN 'TPE (3-10 salariés)'      -- 30%
            WHEN rand_taille <= 75 THEN 'Petite PME (11-50 salariés)'  -- 45%
            WHEN rand_taille <= 95 THEN 'PME moyenne (51-150 salariés)' -- 20%
            ELSE 'PME haute (151-250 salariés)'                    -- 5%
        END AS taille_entreprise,
        
        -- Nombre de salariés (cohérent avec la taille)
        CASE 
            WHEN rand_taille <= 30 THEN 3 + MOD(rand_sal, 8)
            WHEN rand_taille <= 75 THEN 11 + MOD(rand_sal, 40)
            WHEN rand_taille <= 95 THEN 51 + MOD(rand_sal, 100)
            ELSE 151 + MOD(rand_sal, 100)
        END AS nb_salaries,
        
        -- Postes (15 postes types)
        ARRAY_CONSTRUCT(
            'Dirigeant-fondateur', 'Gérant associé', 'Repreneur',
            'Co-gérant familial', 'DAF / RAF', 'Responsable commercial',
            'DRH / RRH', 'Directeur d''exploitation', 'Chef d''atelier',
            'Responsable marketing', 'Contrôleur de gestion', 'Responsable logistique',
            'Manager de proximité', 'Assistante de direction data', 
            'Alternant transformation digitale'
        )[rand_poste]::VARCHAR AS poste,
        
        niveau_maturite,
        
        -- Déclencheurs d'intérêt (15 déclencheurs)
        ARRAY_CONSTRUCT(
            'Perte client important sans explication',
            'Hausse des coûts inexpliquée', 
            'Discussion club dirigeants',
            'Formation France Num / BPI / CCI', 
            'Recrutement raté',
            'Concurrent qui utilise la data', 
            'Audit révélant écart marge',
            'Départ collaborateur clé', 
            'Croissance créant chaos',
            'Trésorerie difficile sans raison', 
            'Obligation réglementaire',
            'Conseil expert-comptable', 
            'Retour salon pro',
            'Article LinkedIn', 
            'Pression donneur d''ordre'
        )[rand_declencheur]::VARCHAR AS declencheur,
        
        -- Prénoms (70% franco-français, 30% diversifiés)
        CASE WHEN rand_prenom_type <= 70 THEN
            ARRAY_CONSTRUCT(
                'Jean', 'Pierre', 'Philippe', 'Michel', 'François', 'Laurent', 
                'Stéphane', 'Christophe', 'Nicolas', 'Thierry',
                'Marie', 'Sophie', 'Nathalie', 'Isabelle', 'Catherine', 
                'Valérie', 'Christine', 'Sandrine', 'Céline', 'Aurélie',
                'Thomas', 'Julien', 'Maxime', 'Alexandre', 'Antoine', 
                'Romain', 'Florian', 'Kevin', 'Jérôme', 'Sébastien',
                'Julie', 'Émilie', 'Marine', 'Pauline', 'Charlotte', 
                'Camille', 'Laura', 'Manon', 'Léa', 'Anaïs'
            )[rand_prenom]::VARCHAR
        ELSE
            ARRAY_CONSTRUCT(
                'Mohamed', 'Karim', 'Rachid', 'Youssef', 'Ahmed', 
                'Fatima', 'Samira', 'Leila', 'Amina', 'Khadija',
                'Antonio', 'Carlos', 'Manuel', 'Maria', 'Ana', 
                'Paulo', 'João', 'Pedro', 'Nguyen', 'Tran',
                'Mamadou', 'Oumar', 'Amadou', 'Bintou', 'Aïssatou', 
                'Thierno', 'Ibrahima', 'Seydou', 'Mariama', 'Awa',
                'Wei', 'Li', 'Chen', 'Mei', 'Xin', 
                'Piotr', 'Anna', 'Marta', 'Giovanni', 'Rosa'
            )[rand_prenom]::VARCHAR
        END AS prenom,
        
        -- Noms de famille diversifiés
        ARRAY_CONSTRUCT(
            'Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 
            'Richard', 'Petit', 'Durand', 'Leroy', 'Moreau',
            'Simon', 'Laurent', 'Lefebvre', 'Michel', 'Garcia', 
            'Da Silva', 'Ferreira', 'Nguyen', 'Diallo', 'Traoré',
            'Ben Ahmed', 'El Fassi', 'Konaté', 'Sanchez', 'Rodriguez', 
            'Chen', 'Wang', 'Nowak', 'Rossi', 'Müller',
            'Girard', 'André', 'Mercier', 'Dupont', 'Lambert', 
            'Bonnet', 'François', 'Martinez', 'Legrand', 'Garnier'
        )[rand_nom]::VARCHAR AS nom
    FROM base_params
),
-- Jointure avec archétypes pour enrichir le prompt
generated AS (
    SELECT p.*, a.nom AS archetype_nom, a.phrase_identite AS archetype_phrase
    FROM params p
    JOIN ARCHETYPES_PSYCHOGRAPHIQUES a ON p.archetype_id = a.id
),
-- Appel LLM pour générer les champs qualitatifs
with_llm AS (
    SELECT g.*,
        SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet', 
            'Génère UN persona pour le livre "Data & PME". Réponds UNIQUEMENT en JSON valide.

PERSONA:
- ' || g.prenom || ' ' || g.nom || ', ' || g.genre || ', ' || g.age || ' ans
- ' || g.region || ', ' || g.secteur || ', ' || g.taille_entreprise || ' (' || g.nb_salaries || ' sal.)
- Poste: ' || g.poste || '
- Archétype: ' || g.archetype_nom || ' ("' || g.archetype_phrase || '")
- Maturité digitale: ' || g.niveau_maturite || '/4
- Déclencheur: ' || g.declencheur || '

JSON attendu:
{"entreprise_nom":"nom fictif","phrase_identite":"phrase en JE oral","quotidien":"3 lignes concrètes","qualite_1":"illustrée","qualite_2":"illustrée","defaut_1":"illustré","defaut_2":"illustré","cas_usage_prefere":"titre + pourquoi","objection_principale":"avant achat prestation","recommandation_ami":"comment il l expliquerait","langue_maternelle":"français ou autre","parcours_atypique":"null ou description"}'
        ) AS llm_response
    FROM generated g
)
SELECT 
    id, archetype_id, prenom, nom, genre, age, region, secteur, 
    taille_entreprise, nb_salaries, poste,
    TRY_PARSE_JSON(llm_response):entreprise_nom::VARCHAR AS entreprise_nom,
    niveau_maturite AS niveau_maturite_digitale,
    TRY_PARSE_JSON(llm_response):phrase_identite::VARCHAR AS phrase_identite,
    TRY_PARSE_JSON(llm_response):quotidien::VARCHAR AS quotidien,
    TRY_PARSE_JSON(llm_response):qualite_1::VARCHAR AS qualite_1,
    TRY_PARSE_JSON(llm_response):qualite_2::VARCHAR AS qualite_2,
    TRY_PARSE_JSON(llm_response):defaut_1::VARCHAR AS defaut_1,
    TRY_PARSE_JSON(llm_response):defaut_2::VARCHAR AS defaut_2,
    declencheur AS declencheur_recent,
    TRY_PARSE_JSON(llm_response):cas_usage_prefere::VARCHAR AS cas_usage_prefere,
    TRY_PARSE_JSON(llm_response):objection_principale::VARCHAR AS objection_principale,
    TRY_PARSE_JSON(llm_response):recommandation_ami::VARCHAR AS recommandation_ami,
    TRY_PARSE_JSON(llm_response):langue_maternelle::VARCHAR AS langue_maternelle,
    TRY_PARSE_JSON(llm_response):parcours_atypique::VARCHAR AS parcours_atypique
FROM with_llm;

-- ============================================================================
-- Vérifications
-- ============================================================================

-- Comptage par archétype
SELECT a.nom AS archetype, COUNT(*) AS nb
FROM PERSONAS_DATA_PME p
JOIN ARCHETYPES_PSYCHOGRAPHIQUES a ON p.archetype_id = a.id
GROUP BY a.nom
ORDER BY nb DESC;

-- Distribution par genre
SELECT genre, COUNT(*) AS nb, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM PERSONAS_DATA_PME
GROUP BY genre;

-- Distribution par taille
SELECT taille_entreprise, COUNT(*) AS nb
FROM PERSONAS_DATA_PME
GROUP BY taille_entreprise
ORDER BY nb DESC;

-- Exemple de persona complet
SELECT * FROM PERSONAS_DATA_PME WHERE id = 1;
