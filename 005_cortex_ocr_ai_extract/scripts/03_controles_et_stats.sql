-- --------------------------------------------------------------------------------------------------------------------
-- 03_controles_et_stats.sql
--
-- Contrôles qualité et statistiques sur l'extraction OCR (cartes grises).
-- Prérequis : 01_setup + chargement des démo data sur le stage (SnowSight) + 02_ocr_extraction exécutés.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OCR_005;
use schema raw_data;
use warehouse SNOW_VIBER_WH;

-- =============================================================================
-- 1. Vue d'ensemble : volume et taux de complétion par champ
-- =============================================================================

create or replace view v_stats_extraction as
select
    count(*) as nb_fichiers,
    count(immatriculation) * 100.0 / nullif(count(*), 0) as pct_immat_rempli,
    count(nom_titulaire) * 100.0 / nullif(count(*), 0) as pct_nom_rempli,
    count(prenom_titulaire) * 100.0 / nullif(count(*), 0) as pct_prenom_rempli,
    count(adresse) * 100.0 / nullif(count(*), 0) as pct_adresse_rempli,
    count(marque) * 100.0 / nullif(count(*), 0) as pct_marque_rempli,
    count(genre) * 100.0 / nullif(count(*), 0) as pct_genre_rempli,
    count(date_premiere_immat) * 100.0 / nullif(count(*), 0) as pct_date_rempli
from cartes_grises_exploitables;

select * from v_stats_extraction;

-- =============================================================================
-- 2. Distribution par marque et par genre
-- =============================================================================

select
    'marque' as dimension,
    marque as valeur,
    count(*) as nb,
    round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from cartes_grises_exploitables
where marque is not null and trim(marque) != ''
group by marque
order by nb desc;

select
    'genre' as dimension,
    genre as valeur,
    count(*) as nb,
    round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from cartes_grises_exploitables
where genre is not null and trim(genre) != ''
group by genre
order by nb desc;

-- =============================================================================
-- 3. Contrôles : fichiers avec champs manquants ou suspects
-- =============================================================================

create or replace view v_controles_manquants as
select
    fichier,
    case when immatriculation is null or trim(immatriculation) = '' then 1 else 0 end as manque_immat,
    case when nom_titulaire is null or trim(nom_titulaire) = '' then 1 else 0 end as manque_nom,
    case when adresse is null or trim(adresse) = '' then 1 else 0 end as manque_adresse,
    case when marque is null or trim(marque) = '' then 1 else 0 end as manque_marque,
    immatriculation,
    nom_titulaire,
    marque
from cartes_grises_exploitables;

-- Fichiers avec au moins un champ métier manquant
select fichier, manque_immat, manque_nom, manque_adresse, manque_marque, immatriculation, nom_titulaire, marque
from v_controles_manquants
where manque_immat + manque_nom + manque_adresse + manque_marque > 0
order by fichier
limit 20;

-- Synthèse des contrôles
select
    count(*) as nb_total,
    sum(case when manque_immat + manque_nom + manque_adresse + manque_marque = 0 then 1 else 0 end) as nb_tous_champs_remplis,
    sum(manque_immat) as nb_manque_immat,
    sum(manque_nom) as nb_manque_nom,
    sum(manque_adresse) as nb_manque_adresse,
    sum(manque_marque) as nb_manque_marque
from v_controles_manquants;

-- =============================================================================
-- 4. Échantillon pour vérification manuelle
-- =============================================================================

select fichier, immatriculation, nom_titulaire, prenom_titulaire, adresse, marque, genre, date_premiere_immat
from cartes_grises_exploitables
sample (10 rows);
