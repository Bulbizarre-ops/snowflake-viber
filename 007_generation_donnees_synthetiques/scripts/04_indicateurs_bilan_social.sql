-- ============================================================================
-- 04_indicateurs_bilan_social.sql
-- Calcul des 7 rubriques légales du bilan social
-- Articles L2312-28 à L2312-35 du Code du travail
-- ============================================================================

USE DATABASE SNOW_VIBER_BILAN_007;
USE SCHEMA INDICATEURS;

-- ============================================================================
-- RUBRIQUE 1 : EMPLOI
-- Effectifs, embauches, départs, promotions, chômage
-- ============================================================================

CREATE OR REPLACE VIEW v_emploi_effectifs AS
SELECT 
    'Effectif total' AS indicateur,
    COUNT(*) AS valeur,
    NULL AS detail
FROM GENERATION.salaries
WHERE statut = 'ACTIF'

UNION ALL

SELECT 
    'Effectif par genre',
    COUNT(*),
    genre
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY genre

UNION ALL

SELECT 
    'Effectif par CSP',
    COUNT(*),
    categorie_csp
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY categorie_csp

UNION ALL

SELECT 
    'Effectif par établissement',
    COUNT(*),
    nom_etablissement
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY nom_etablissement

UNION ALL

SELECT 
    'Effectif par type contrat',
    COUNT(*),
    type_contrat
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY type_contrat

UNION ALL

SELECT 
    'Effectif temps partiel',
    COUNT(*),
    quotite_travail::VARCHAR
FROM GENERATION.salaries
WHERE statut = 'ACTIF' AND quotite_travail < 1
GROUP BY quotite_travail;

-- Pyramide des âges
CREATE OR REPLACE VIEW v_emploi_pyramide_ages AS
SELECT 
    genre,
    CASE 
        WHEN age < 25 THEN 'Moins de 25 ans'
        WHEN age < 35 THEN '25-34 ans'
        WHEN age < 45 THEN '35-44 ans'
        WHEN age < 55 THEN '45-54 ans'
        ELSE '55 ans et plus'
    END AS tranche_age,
    COUNT(*) AS effectif
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY genre, 
    CASE 
        WHEN age < 25 THEN 'Moins de 25 ans'
        WHEN age < 35 THEN '25-34 ans'
        WHEN age < 45 THEN '35-44 ans'
        WHEN age < 55 THEN '45-54 ans'
        ELSE '55 ans et plus'
    END
ORDER BY genre, tranche_age;

-- Ancienneté
CREATE OR REPLACE VIEW v_emploi_anciennete AS
SELECT 
    CASE 
        WHEN anciennete_annees < 2 THEN 'Moins de 2 ans'
        WHEN anciennete_annees < 5 THEN '2-4 ans'
        WHEN anciennete_annees < 10 THEN '5-9 ans'
        WHEN anciennete_annees < 20 THEN '10-19 ans'
        ELSE '20 ans et plus'
    END AS tranche_anciennete,
    COUNT(*) AS effectif,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY 
    CASE 
        WHEN anciennete_annees < 2 THEN 'Moins de 2 ans'
        WHEN anciennete_annees < 5 THEN '2-4 ans'
        WHEN anciennete_annees < 10 THEN '5-9 ans'
        WHEN anciennete_annees < 20 THEN '10-19 ans'
        ELSE '20 ans et plus'
    END
ORDER BY tranche_anciennete;

-- Turnover
CREATE OR REPLACE VIEW v_emploi_turnover AS
SELECT 
    YEAR(date_sortie) AS annee,
    categorie_depart,
    libelle_motif,
    COUNT(*) AS nb_departs
FROM GENERATION.departs
GROUP BY YEAR(date_sortie), categorie_depart, libelle_motif
ORDER BY annee DESC, nb_departs DESC;

-- ============================================================================
-- RUBRIQUE 2 : RÉMUNÉRATIONS ET CHARGES ACCESSOIRES
-- Masse salariale, salaires moyens, hiérarchie des rémunérations
-- ============================================================================

CREATE OR REPLACE VIEW v_remunerations AS
SELECT 
    'Masse salariale totale' AS indicateur,
    SUM(salaire_annuel_brut) AS valeur,
    NULL AS detail
FROM GENERATION.salaries
WHERE statut = 'ACTIF'

UNION ALL

SELECT 
    'Salaire moyen',
    ROUND(AVG(salaire_annuel_brut), 0),
    NULL
FROM GENERATION.salaries
WHERE statut = 'ACTIF'

UNION ALL

SELECT 
    'Salaire médian',
    MEDIAN(salaire_annuel_brut),
    NULL
FROM GENERATION.salaries
WHERE statut = 'ACTIF'

UNION ALL

SELECT 
    'Salaire moyen par CSP',
    ROUND(AVG(salaire_annuel_brut), 0),
    categorie_csp
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY categorie_csp

UNION ALL

SELECT 
    'Salaire moyen par genre',
    ROUND(AVG(salaire_annuel_brut), 0),
    genre
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY genre;

-- Écarts de rémunération H/F par CSP
CREATE OR REPLACE VIEW v_remunerations_egalite_hf AS
SELECT 
    categorie_csp,
    ROUND(AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END), 0) AS salaire_moyen_h,
    ROUND(AVG(CASE WHEN genre = 'F' THEN salaire_annuel_brut END), 0) AS salaire_moyen_f,
    ROUND(
        (AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END) - 
         AVG(CASE WHEN genre = 'F' THEN salaire_annuel_brut END)) /
        AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END) * 100
    , 1) AS ecart_pct
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY categorie_csp
ORDER BY categorie_csp;

-- Hiérarchie des rémunérations (rapport D10/D1)
CREATE OR REPLACE VIEW v_remunerations_hierarchie AS
SELECT 
    PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY salaire_annuel_brut) AS decile_1,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY salaire_annuel_brut) AS decile_9,
    ROUND(
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY salaire_annuel_brut) /
        PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY salaire_annuel_brut)
    , 2) AS rapport_d9_d1
FROM GENERATION.salaries
WHERE statut = 'ACTIF';

-- ============================================================================
-- RUBRIQUE 3 : CONDITIONS D'HYGIÈNE ET DE SÉCURITÉ
-- Accidents du travail, maladies professionnelles
-- ============================================================================

CREATE OR REPLACE VIEW v_hygiene_securite AS
SELECT 
    annee_absence AS annee,
    type_absence,
    COUNT(*) AS nb_cas,
    SUM(duree_jours) AS jours_perdus,
    ROUND(AVG(duree_jours), 1) AS duree_moyenne
FROM GENERATION.absences
WHERE type_absence IN ('Accident du travail', 'Maladie')
GROUP BY annee_absence, type_absence
ORDER BY annee DESC, type_absence;

-- Taux de fréquence et gravité (simulés)
CREATE OR REPLACE VIEW v_accidents_indicateurs AS
SELECT 
    annee_absence AS annee,
    COUNT(*) AS nb_accidents,
    -- Taux de fréquence = (nb accidents / heures travaillées) x 1 000 000
    -- Estimation : 1600h/an/salarié
    ROUND(COUNT(*) * 1000000.0 / (
        (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 1600
    ), 2) AS taux_frequence,
    -- Taux de gravité = (jours perdus / heures travaillées) x 1000
    ROUND(SUM(duree_jours) * 1000.0 / (
        (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 1600
    ), 2) AS taux_gravite
FROM GENERATION.absences
WHERE type_absence = 'Accident du travail'
GROUP BY annee_absence;

-- ============================================================================
-- RUBRIQUE 4 : AUTRES CONDITIONS DE TRAVAIL
-- Durée du travail, absentéisme, organisation du temps
-- ============================================================================

CREATE OR REPLACE VIEW v_conditions_travail AS
SELECT 
    'Temps plein' AS indicateur,
    COUNT(*) AS effectif,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage
FROM GENERATION.salaries
WHERE statut = 'ACTIF' AND quotite_travail = 1

UNION ALL

SELECT 
    'Temps partiel 80%',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)
FROM GENERATION.salaries
WHERE statut = 'ACTIF' AND quotite_travail = 0.8

UNION ALL

SELECT 
    'Mi-temps',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)
FROM GENERATION.salaries
WHERE statut = 'ACTIF' AND quotite_travail = 0.5;

-- Absentéisme global
CREATE OR REPLACE VIEW v_absenteisme AS
SELECT 
    annee_absence AS annee,
    type_absence,
    COUNT(DISTINCT id_salarie) AS nb_salaries_concernes,
    SUM(duree_jours) AS jours_absence,
    -- Taux d'absentéisme = jours absence / jours travaillés théoriques
    ROUND(SUM(duree_jours) * 100.0 / (
        (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 220
    ), 2) AS taux_absenteisme
FROM GENERATION.absences
GROUP BY annee_absence, type_absence
ORDER BY annee DESC, jours_absence DESC;

-- ============================================================================
-- RUBRIQUE 5 : FORMATION PROFESSIONNELLE
-- Investissement formation, stagiaires, heures de formation
-- ============================================================================

CREATE OR REPLACE VIEW v_formation AS
SELECT 
    annee_formation AS annee,
    COUNT(DISTINCT id_salarie) AS salaries_formes,
    COUNT(*) AS nb_formations,
    SUM(duree_heures) AS heures_formation,
    SUM(cout_formation) AS budget_formation,
    ROUND(AVG(duree_heures), 1) AS duree_moyenne_formation
FROM GENERATION.formations_suivies
GROUP BY annee_formation
ORDER BY annee DESC;

-- Formations par domaine
CREATE OR REPLACE VIEW v_formation_par_domaine AS
SELECT 
    annee_formation AS annee,
    domaine,
    COUNT(*) AS nb_formations,
    SUM(duree_heures) AS heures,
    SUM(cout_formation) AS cout_total
FROM GENERATION.formations_suivies
GROUP BY annee_formation, domaine
ORDER BY annee DESC, heures DESC;

-- Taux d'accès à la formation par CSP
CREATE OR REPLACE VIEW v_formation_acces_csp AS
SELECT 
    s.categorie_csp,
    COUNT(DISTINCT s.id_salarie) AS effectif_csp,
    COUNT(DISTINCT f.id_salarie) AS salaries_formes,
    ROUND(COUNT(DISTINCT f.id_salarie) * 100.0 / COUNT(DISTINCT s.id_salarie), 1) AS taux_acces_formation
FROM GENERATION.salaries s
LEFT JOIN GENERATION.formations_suivies f ON s.id_salarie = f.id_salarie
WHERE s.statut = 'ACTIF'
GROUP BY s.categorie_csp
ORDER BY s.categorie_csp;

-- ============================================================================
-- RUBRIQUE 6 : RELATIONS PROFESSIONNELLES
-- (Indicateurs simulés - pas de données syndicales générées)
-- ============================================================================

CREATE OR REPLACE VIEW v_relations_professionnelles AS
SELECT 
    'Effectif éligible CSE' AS indicateur,
    COUNT(*) AS valeur,
    'Salariés avec >= 3 mois ancienneté' AS definition
FROM GENERATION.salaries
WHERE statut = 'ACTIF' 
  AND anciennete_annees >= 0.25

UNION ALL

SELECT 
    'Représentants du personnel estimés',
    CEIL(COUNT(*) / 50.0),
    '1 titulaire par tranche de 50 salariés'
FROM GENERATION.salaries
WHERE statut = 'ACTIF';

-- ============================================================================
-- RUBRIQUE 7 : AUTRES CONDITIONS DE VIE RELEVANT DE L'ENTREPRISE
-- (Indicateurs simulés - pas de données sociales générées)
-- ============================================================================

CREATE OR REPLACE VIEW v_conditions_vie AS
SELECT 
    'Budget activités sociales estimé' AS indicateur,
    ROUND(SUM(salaire_annuel_brut) * 0.003, 0) AS valeur,
    '0.3% de la masse salariale' AS definition
FROM GENERATION.salaries
WHERE statut = 'ACTIF';

-- ============================================================================
-- VUE SYNTHÉTIQUE : TABLEAU DE BORD BILAN SOCIAL
-- ============================================================================

CREATE OR REPLACE VIEW v_synthese_bilan_social AS

-- Rubrique 1 : Emploi
SELECT 1 AS rubrique, 'EMPLOI' AS libelle_rubrique, 
       'Effectif total' AS indicateur,
       COUNT(*)::VARCHAR AS valeur
FROM GENERATION.salaries WHERE statut = 'ACTIF'

UNION ALL
SELECT 1, 'EMPLOI', 'Femmes', 
       COUNT(*) || ' (' || ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF'), 1) || '%)'
FROM GENERATION.salaries WHERE statut = 'ACTIF' AND genre = 'F'

UNION ALL
SELECT 1, 'EMPLOI', 'Cadres',
       COUNT(*) || ' (' || ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF'), 1) || '%)'
FROM GENERATION.salaries WHERE statut = 'ACTIF' AND categorie_csp = 'CADRE'

UNION ALL
SELECT 1, 'EMPLOI', 'Âge moyen',
       ROUND(AVG(age), 1) || ' ans'
FROM GENERATION.salaries WHERE statut = 'ACTIF'

UNION ALL
SELECT 1, 'EMPLOI', 'Ancienneté moyenne',
       ROUND(AVG(anciennete_annees), 1) || ' ans'
FROM GENERATION.salaries WHERE statut = 'ACTIF'

UNION ALL
SELECT 1, 'EMPLOI', 'Départs (année en cours)',
       COUNT(*)::VARCHAR
FROM GENERATION.departs WHERE YEAR(date_sortie) = YEAR(CURRENT_DATE())

-- Rubrique 2 : Rémunérations
UNION ALL
SELECT 2, 'RÉMUNÉRATIONS', 'Masse salariale',
       TO_CHAR(SUM(salaire_annuel_brut), '999,999,999') || ' €'
FROM GENERATION.salaries WHERE statut = 'ACTIF'

UNION ALL
SELECT 2, 'RÉMUNÉRATIONS', 'Salaire moyen',
       TO_CHAR(ROUND(AVG(salaire_annuel_brut), 0), '999,999') || ' €'
FROM GENERATION.salaries WHERE statut = 'ACTIF'

UNION ALL
SELECT 2, 'RÉMUNÉRATIONS', 'Rapport D9/D1',
       ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY salaire_annuel_brut) /
             PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY salaire_annuel_brut), 2)::VARCHAR
FROM GENERATION.salaries WHERE statut = 'ACTIF'

-- Rubrique 3 : Hygiène et sécurité
UNION ALL
SELECT 3, 'HYGIÈNE ET SÉCURITÉ', 'Accidents du travail',
       COUNT(*)::VARCHAR
FROM GENERATION.absences WHERE type_absence = 'Accident du travail' AND annee_absence = YEAR(CURRENT_DATE())

UNION ALL
SELECT 3, 'HYGIÈNE ET SÉCURITÉ', 'Jours perdus (AT)',
       COALESCE(SUM(duree_jours), 0)::VARCHAR || ' jours'
FROM GENERATION.absences WHERE type_absence = 'Accident du travail' AND annee_absence = YEAR(CURRENT_DATE())

-- Rubrique 4 : Conditions de travail
UNION ALL
SELECT 4, 'CONDITIONS DE TRAVAIL', 'Temps partiel',
       COUNT(*) || ' (' || ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF'), 1) || '%)'
FROM GENERATION.salaries WHERE statut = 'ACTIF' AND quotite_travail < 1

UNION ALL
SELECT 4, 'CONDITIONS DE TRAVAIL', 'Taux absentéisme global',
       ROUND(SUM(duree_jours) * 100.0 / ((SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 220), 2) || '%'
FROM GENERATION.absences WHERE annee_absence = YEAR(CURRENT_DATE())

-- Rubrique 5 : Formation
UNION ALL
SELECT 5, 'FORMATION', 'Salariés formés',
       COUNT(DISTINCT id_salarie)::VARCHAR
FROM GENERATION.formations_suivies WHERE annee_formation = YEAR(CURRENT_DATE())

UNION ALL
SELECT 5, 'FORMATION', 'Heures de formation',
       COALESCE(SUM(duree_heures), 0)::VARCHAR || ' h'
FROM GENERATION.formations_suivies WHERE annee_formation = YEAR(CURRENT_DATE())

UNION ALL
SELECT 5, 'FORMATION', 'Budget formation',
       TO_CHAR(COALESCE(SUM(cout_formation), 0), '999,999') || ' €'
FROM GENERATION.formations_suivies WHERE annee_formation = YEAR(CURRENT_DATE())

-- Rubrique 6 : Relations professionnelles
UNION ALL
SELECT 6, 'RELATIONS PROFESSIONNELLES', 'Représentants estimés',
       CEIL((SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') / 50.0)::VARCHAR

-- Rubrique 7 : Conditions de vie
UNION ALL
SELECT 7, 'CONDITIONS DE VIE', 'Budget social estimé',
       TO_CHAR(ROUND((SELECT SUM(salaire_annuel_brut) * 0.003 FROM GENERATION.salaries WHERE statut = 'ACTIF'), 0), '999,999') || ' €'

ORDER BY rubrique, indicateur;

-- ============================================================================
-- REQUÊTE FINALE : AFFICHAGE DU BILAN SOCIAL COMPLET
-- ============================================================================
SELECT * FROM v_synthese_bilan_social;
