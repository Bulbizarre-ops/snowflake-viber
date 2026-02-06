-- --------------------------------------------------------------------------------------------------------------------
-- 04_object_hash.sql
--
-- Démo des deux méthodes de calcul du content_hash : OBJECT_DELETE (majuscules) vs EXCLUDE (recommandé).
-- Prérequis : 03_generation.sql. Lecture seule (SELECT).
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OBJECT_HASH_004;
use schema demo;
use warehouse SNOW_VIBER_WH;

-- Méthode 1 : OBJECT_DELETE (compatible toutes versions, CASE-SENSITIVE → majuscules)
select
    order_id,
    line_item_id,
    sha2(
        object_delete(
            object_construct(*),
            'SOURCE_SYSTEM',
            'EXTRACTED_AT',
            'LOADED_AT',
            'BATCH_ID',
            'FILE_NAME',
            'ROW_NUMBER_IN_FILE'
        )::varchar
    ) as content_hash_v1
from raw_orders
limit 5;

-- Méthode 2 : EXCLUDE (recommandée, déclarative)
select
    order_id,
    line_item_id,
    sha2(
        object_construct(* exclude (
            source_system,
            extracted_at,
            loaded_at,
            batch_id,
            file_name,
            row_number_in_file
        ))::varchar
    ) as content_hash_v2
from raw_orders
limit 5;
