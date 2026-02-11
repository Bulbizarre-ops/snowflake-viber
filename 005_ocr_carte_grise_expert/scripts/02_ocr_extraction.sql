-- --------------------------------------------------------------------------------------------------------------------
-- 02_ocr_extraction.sql
--
-- OCR + extraction structurée de cartes grises avec AI_PARSE_DOCUMENT et AI_EXTRACT.
-- Cas d'usage : société d'expert en assurance.
-- Prérequis : déposer au moins un fichier (PDF/PNG) sur le stage documents_cartes_grises (PUT ou Snowsight).
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OCR_005;
use schema raw_data;
use warehouse SNOW_VIBER_WH;

-- =============================================================================
-- 1. OCR : extraction du texte brut (mode OCR)
-- =============================================================================
-- Pour un document scanné ou photo de carte grise, le mode OCR extrait le texte
-- sans préserver la mise en page. Idéal pour formulaires type carte grise.

create or replace table extraction_ocr_raw as
select
    relative_path as fichier,
    to_varchar(
        ai_parse_document(
            to_file('@documents_cartes_grises', relative_path),
            {'mode': 'OCR'}
        )
    ) as contenu_ocr_json
from directory(@documents_cartes_grises)
where relative_path rlike '\\.(pdf|png|jpg|jpeg|tiff|tif)$';

-- Aperçu du texte extrait (champ content du JSON)
select
    fichier,
    parse_json(contenu_ocr_json):content::varchar as texte_extrait
from extraction_ocr_raw
limit 3;

-- =============================================================================
-- 2. Extraction structurée : champs métier pour l'expert assurance
-- =============================================================================
-- AI_EXTRACT pose des questions en langage naturel et renvoie un JSON structuré.
-- On matérialise dans une table (jamais de vue sur Cortex : coût 100x).

create or replace table extraction_cartes_grises as
select
    relative_path as fichier,
    ai_extract(
        file => to_file('@documents_cartes_grises', relative_path),
        responseFormat => {
            'immatriculation': 'Quel est le numéro d''immatriculation du véhicule (format AA-123-AA) ?',
            'nom_titulaire': 'Quel est le nom du titulaire du certificat d''immatriculation ?',
            'prenom_titulaire': 'Quel est le prénom du titulaire ?',
            'adresse': 'Quelle est l''adresse du titulaire ?',
            'marque': 'Quelle est la marque du véhicule ?',
            'genre': 'Quel est le genre (VP, VU, etc.) ?',
            'date_immat': 'Quelle est la date de première immatriculation du véhicule ?'
        }
    ) as reponse_extract
from directory(@documents_cartes_grises)
where relative_path rlike '\\.(pdf|png|jpg|jpeg|tiff|tif)$';

-- Dénormalisation pour exploitation (éviter de reparser le JSON à chaque requête)
create or replace table cartes_grises_exploitables as
select
    fichier,
    reponse_extract:response:immatriculation::varchar as immatriculation,
    reponse_extract:response:nom_titulaire::varchar as nom_titulaire,
    reponse_extract:response:prenom_titulaire::varchar as prenom_titulaire,
    reponse_extract:response:adresse::varchar as adresse,
    reponse_extract:response:marque::varchar as marque,
    reponse_extract:response:genre::varchar as genre,
    reponse_extract:response:date_immat::varchar as date_premiere_immat
from extraction_cartes_grises;

-- Résultat exploitable par l'expert
select * from cartes_grises_exploitables;
