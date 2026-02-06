-- --------------------------------------------------------------------------------------------------------------------
-- 05_deduplication.sql
--
-- Table orders_deduplicated : hash par ligne, LAG par grain (order_id, line_item_id), conservation des changements réels.
-- Prérequis : 03_generation.sql. Idempotent (CREATE OR REPLACE TABLE).
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OBJECT_HASH_004;
use schema demo;
use warehouse SNOW_VIBER_WH;

create or replace table orders_deduplicated as
with hashed_orders as (
    select
        *,
        sha2(
            object_construct(* exclude (
                source_system,
                extracted_at,
                loaded_at,
                batch_id,
                file_name,
                row_number_in_file
            ))::varchar
        ) as content_hash
    from raw_orders
),
with_previous as (
    select
        *,
        lag(content_hash) over (
            partition by order_id, line_item_id
            order by extracted_at
        ) as previous_hash
    from hashed_orders
)
select *
from with_previous
where previous_hash is null
   or previous_hash != content_hash;
