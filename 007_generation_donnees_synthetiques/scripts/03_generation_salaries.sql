-- ============================================================================
-- 03_generation_salaries.sql
-- Génération de 500 salariés avec GENERATOR et jointures pondérées
-- Démonstration : distributions réalistes sans appel LLM
-- ============================================================================

USE DATABASE SNOW_VIBER_BILAN_007;
USE SCHEMA GENERATION;

-- ============================================================================
-- TABLE PRINCIPALE : SALARIÉS
-- Génération de 500 employés avec distributions contrôlées
-- ============================================================================

-- Pourquoi UNIFORM ne fonctionne pas ici ?
-- UNIFORM(min, max, RANDOM()) exige des constantes pour min/max
-- Pour un tirage dans une table de N lignes : MOD(ABS(hash), N) + 1

CREATE OR REPLACE TABLE salaries AS
WITH 
-- Génération de 500 lignes de base avec identifiants uniques
base AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SEQ4()) AS id_salarie,
        -- Hash unique pour chaque salarié (déterministe)
        ABS(HASH(SEQ4() || 'salt_employe')) AS hash_base
    FROM TABLE(GENERATOR(ROWCOUNT => 500))
),

-- Comptage des tables de référence pour le MOD
counts AS (
    SELECT 
        (SELECT COUNT(*) FROM REFERENTIEL.ref_prenoms WHERE genre = 'H') AS nb_prenoms_h,
        (SELECT COUNT(*) FROM REFERENTIEL.ref_prenoms WHERE genre = 'F') AS nb_prenoms_f,
        (SELECT COUNT(*) FROM REFERENTIEL.ref_noms) AS nb_noms,
        (SELECT COUNT(*) FROM REFERENTIEL.ref_postes_pondere) AS nb_postes,
        (SELECT COUNT(*) FROM REFERENTIEL.ref_etablissements_pondere) AS nb_etab,
        (SELECT COUNT(*) FROM REFERENTIEL.ref_types_contrat_pondere) AS nb_contrats
),

-- Attribution du genre (45% femmes / 55% hommes - réalité française)
avec_genre AS (
    SELECT 
        b.*,
        CASE 
            WHEN MOD(ABS(HASH(b.id_salarie || 'genre')), 100) < 45 THEN 'F'
            ELSE 'H'
        END AS genre
    FROM base b
),

-- Numérotation des prénoms par genre pour le tirage
prenoms_h AS (
    SELECT prenom, ROW_NUMBER() OVER (ORDER BY prenom) AS rn
    FROM REFERENTIEL.ref_prenoms WHERE genre = 'H'
),
prenoms_f AS (
    SELECT prenom, ROW_NUMBER() OVER (ORDER BY prenom) AS rn
    FROM REFERENTIEL.ref_prenoms WHERE genre = 'F'
),
noms_num AS (
    SELECT nom, ROW_NUMBER() OVER (ORDER BY nom) AS rn
    FROM REFERENTIEL.ref_noms
),
postes_num AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id_poste, poids) AS rn
    FROM REFERENTIEL.ref_postes_pondere
),
etab_num AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id_etablissement) AS rn
    FROM REFERENTIEL.ref_etablissements_pondere
),
contrats_num AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id_contrat) AS rn
    FROM REFERENTIEL.ref_types_contrat_pondere
),

-- Jointure avec toutes les références
enrichi AS (
    SELECT 
        g.id_salarie,
        g.genre,
        
        -- Prénom selon le genre
        COALESCE(ph.prenom, pf.prenom) AS prenom,
        
        -- Nom de famille
        n.nom,
        
        -- Poste (pondéré par CSP)
        p.id_poste,
        p.libelle_poste,
        p.categorie_csp,
        p.salaire_min,
        p.salaire_max,
        
        -- Établissement (pondéré par effectif cible)
        e.id_etablissement,
        e.nom_etablissement,
        e.ville,
        
        -- Type de contrat
        c.libelle AS type_contrat,
        
        -- Âge : distribution réaliste 22-62 ans
        -- Formule : base 22 ans + distribution skewed vers 30-45
        22 + MOD(ABS(HASH(g.id_salarie || 'age1')), 20) 
           + MOD(ABS(HASH(g.id_salarie || 'age2')), 15)
           + MOD(ABS(HASH(g.id_salarie || 'age3')), 6) AS age,
        
        -- Pour calcul ultérieur
        g.hash_base
        
    FROM avec_genre g
    CROSS JOIN counts cnt
    
    -- Jointure prénom homme
    LEFT JOIN prenoms_h ph 
        ON g.genre = 'H' 
        AND ph.rn = MOD(ABS(HASH(g.id_salarie || 'prenom')), cnt.nb_prenoms_h) + 1
    
    -- Jointure prénom femme
    LEFT JOIN prenoms_f pf 
        ON g.genre = 'F' 
        AND pf.rn = MOD(ABS(HASH(g.id_salarie || 'prenom')), cnt.nb_prenoms_f) + 1
    
    -- Jointure nom
    JOIN noms_num n 
        ON n.rn = MOD(ABS(HASH(g.id_salarie || 'nom')), cnt.nb_noms) + 1
    
    -- Jointure poste (table pondérée)
    JOIN postes_num p 
        ON p.rn = MOD(ABS(HASH(g.id_salarie || 'poste')), cnt.nb_postes) + 1
    
    -- Jointure établissement (table pondérée)
    JOIN etab_num e 
        ON e.rn = MOD(ABS(HASH(g.id_salarie || 'etab')), cnt.nb_etab) + 1
    
    -- Jointure type de contrat (table pondérée)
    JOIN contrats_num c 
        ON c.rn = MOD(ABS(HASH(g.id_salarie || 'contrat')), cnt.nb_contrats) + 1
)

-- Calculs dérivés
SELECT 
    id_salarie,
    prenom,
    nom,
    prenom || ' ' || nom AS nom_complet,
    genre,
    age,
    DATEADD('year', -age, CURRENT_DATE()) AS date_naissance,
    
    -- Ancienneté corrélée à l'âge (max = age - 22)
    LEAST(
        MOD(ABS(HASH(id_salarie || 'anciennete')), GREATEST(age - 21, 1)),
        age - 22
    ) AS anciennete_annees,
    
    id_poste,
    libelle_poste,
    categorie_csp,
    type_contrat,
    
    id_etablissement,
    nom_etablissement,
    ville,
    
    -- Salaire calculé : base + coefficient ancienneté + aléa ±10%
    ROUND(
        (salaire_min + (salaire_max - salaire_min) * 
            (MOD(ABS(HASH(id_salarie || 'salaire')), 100) / 100.0)
        ) * (1 + (MOD(ABS(HASH(id_salarie || 'anciennete')), GREATEST(age - 21, 1)) * 0.02))
          * (0.95 + MOD(ABS(HASH(id_salarie || 'alea')), 10) / 100.0)
    , -2) AS salaire_annuel_brut,
    
    -- Date d'entrée calculée à partir de l'ancienneté
    DATEADD('year', 
        -LEAST(MOD(ABS(HASH(id_salarie || 'anciennete')), GREATEST(age - 21, 1)), age - 22),
        DATEADD('month', -MOD(ABS(HASH(id_salarie || 'mois_entree')), 12), CURRENT_DATE())
    ) AS date_entree,
    
    -- Temps de travail (95% temps plein)
    CASE 
        WHEN MOD(ABS(HASH(id_salarie || 'temps')), 100) < 95 THEN 1.0
        WHEN MOD(ABS(HASH(id_salarie || 'temps')), 100) < 98 THEN 0.8
        ELSE 0.5
    END AS quotite_travail,
    
    -- Statut actif/sorti (90% actifs)
    CASE 
        WHEN MOD(ABS(HASH(id_salarie || 'actif')), 100) < 90 THEN 'ACTIF'
        ELSE 'SORTI'
    END AS statut

FROM enrichi;

-- ============================================================================
-- TABLE DES DÉPARTS (pour les salariés sortis)
-- ============================================================================
CREATE OR REPLACE TABLE departs AS
WITH motifs_num AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id_motif) AS rn
    FROM REFERENTIEL.ref_motifs_depart_pondere
),
cnt AS (
    SELECT COUNT(*) AS nb FROM motifs_num
)
SELECT 
    s.id_salarie,
    s.nom_complet,
    m.libelle_motif,
    m.categorie AS categorie_depart,
    -- Date de sortie : entre date d'entrée et aujourd'hui
    DATEADD('day', 
        MOD(ABS(HASH(s.id_salarie || 'sortie')), 
            DATEDIFF('day', s.date_entree, CURRENT_DATE())),
        s.date_entree
    ) AS date_sortie
FROM salaries s
CROSS JOIN cnt
JOIN motifs_num m 
    ON m.rn = MOD(ABS(HASH(s.id_salarie || 'motif')), cnt.nb) + 1
WHERE s.statut = 'SORTI';

-- ============================================================================
-- TABLE DES FORMATIONS SUIVIES
-- Moyenne 1.5 formation par salarié actif
-- ============================================================================
CREATE OR REPLACE TABLE formations_suivies AS
WITH 
-- Générer 0 à 3 formations par salarié
formations_possibles AS (
    SELECT 
        s.id_salarie,
        f.value::INT AS num_formation
    FROM salaries s,
    LATERAL FLATTEN(ARRAY_CONSTRUCT(1, 2, 3)) f
    WHERE s.statut = 'ACTIF'
      AND MOD(ABS(HASH(s.id_salarie || 'nb_formations')), 100) >= 
          CASE f.value::INT 
              WHEN 1 THEN 0   -- 100% ont au moins une chance
              WHEN 2 THEN 50  -- 50% ont une 2e formation
              WHEN 3 THEN 80  -- 20% ont une 3e formation
          END
),
formations_num AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id_formation) AS rn
    FROM REFERENTIEL.ref_formations_pondere
),
cnt AS (
    SELECT COUNT(*) AS nb FROM formations_num
)
SELECT 
    fp.id_salarie,
    f.id_formation,
    f.libelle_formation,
    f.domaine,
    f.duree_heures,
    f.cout_moyen AS cout_formation,
    -- Date formation dans les 2 dernières années
    DATEADD('day', 
        -MOD(ABS(HASH(fp.id_salarie || fp.num_formation || 'date_form')), 730),
        CURRENT_DATE()
    ) AS date_formation,
    YEAR(DATEADD('day', 
        -MOD(ABS(HASH(fp.id_salarie || fp.num_formation || 'date_form')), 730),
        CURRENT_DATE()
    )) AS annee_formation
FROM formations_possibles fp
CROSS JOIN cnt
JOIN formations_num f 
    ON f.rn = MOD(ABS(HASH(fp.id_salarie || fp.num_formation || 'formation')), cnt.nb) + 1;

-- ============================================================================
-- TABLE DES ABSENCES (pour conditions de travail)
-- ============================================================================
CREATE OR REPLACE TABLE absences AS
WITH types_absence AS (
    SELECT * FROM (VALUES 
        ('Maladie', 60),
        ('Accident du travail', 10),
        ('Maternité', 15),
        ('Paternité', 10),
        ('Congé sans solde', 5)
    ) AS t(type_absence, poids)
),
types_num AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY type_absence) AS rn
    FROM types_absence,
    LATERAL FLATTEN(SPLIT(REPEAT(',', poids - 1), ','))
),
cnt AS (SELECT COUNT(*) AS nb FROM types_num),
-- 30% des salariés ont eu une absence
salaries_absents AS (
    SELECT *
    FROM salaries
    WHERE statut = 'ACTIF'
      AND MOD(ABS(HASH(id_salarie || 'absence')), 100) < 30
)
SELECT 
    sa.id_salarie,
    ta.type_absence,
    -- Durée absence : 1 à 60 jours selon type
    CASE ta.type_absence
        WHEN 'Maternité' THEN 112
        WHEN 'Paternité' THEN 28
        ELSE MOD(ABS(HASH(sa.id_salarie || 'duree_abs')), 45) + 1
    END AS duree_jours,
    -- Date dans l'année
    DATEADD('day', 
        -MOD(ABS(HASH(sa.id_salarie || 'date_abs')), 365),
        CURRENT_DATE()
    ) AS date_debut_absence,
    YEAR(DATEADD('day', 
        -MOD(ABS(HASH(sa.id_salarie || 'date_abs')), 365),
        CURRENT_DATE()
    )) AS annee_absence
FROM salaries_absents sa
CROSS JOIN cnt
JOIN types_num ta 
    ON ta.rn = MOD(ABS(HASH(sa.id_salarie || 'type_abs')), cnt.nb) + 1;

-- ============================================================================
-- VÉRIFICATIONS DES DISTRIBUTIONS GÉNÉRÉES
-- ============================================================================

-- Distribution par genre
SELECT 'Genre' AS indicateur, 
       genre, 
       COUNT(*) AS effectif,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM salaries
GROUP BY genre;

-- Distribution par CSP
SELECT 'CSP' AS indicateur,
       categorie_csp, 
       COUNT(*) AS effectif,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM salaries
GROUP BY categorie_csp
ORDER BY effectif DESC;

-- Distribution par établissement
SELECT 'Établissement' AS indicateur,
       nom_etablissement, 
       COUNT(*) AS effectif,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM salaries
GROUP BY nom_etablissement
ORDER BY effectif DESC;

-- Pyramide des âges
SELECT 'Âge' AS indicateur,
       FLOOR(age / 10) * 10 || '-' || (FLOOR(age / 10) * 10 + 9) AS tranche_age,
       COUNT(*) AS effectif
FROM salaries
GROUP BY FLOOR(age / 10)
ORDER BY FLOOR(age / 10);

-- Statistiques salaires par CSP
SELECT 'Salaires' AS indicateur,
       categorie_csp,
       ROUND(AVG(salaire_annuel_brut), 0) AS salaire_moyen,
       MIN(salaire_annuel_brut) AS salaire_min,
       MAX(salaire_annuel_brut) AS salaire_max
FROM salaries
GROUP BY categorie_csp
ORDER BY salaire_moyen DESC;
