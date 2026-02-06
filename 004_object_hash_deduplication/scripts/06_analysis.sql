-- --------------------------------------------------------------------------------------------------------------------
-- 06_analysis.sql
--
-- Comparaison avant/après déduplication, répartition, exemples de changements, vue réutilisable.
-- Prérequis : 05_deduplication.sql. Idempotent.
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OBJECT_HASH_004;
use schema demo;
use warehouse SNOW_VIBER_WH;

-- Comparaison avant/après
select
    'avant déduplication' as etape,
    count(*) as nb_lignes,
    count(distinct order_id || '-' || line_item_id) as nb_order_lines
from raw_orders
union all
select
    'après déduplication' as etape,
    count(*) as nb_lignes,
    count(distinct order_id || '-' || line_item_id) as nb_order_lines
from orders_deduplicated;

-- Répartition par type de conservation
select
    case
        when previous_hash is null then '🆕 première version'
        else '🔄 modification détectée'
    end as raison_conservation,
    count(*) as nb_lignes,
    round(count(*) * 100.0 / sum(count(*)) over (), 1) as pct
from orders_deduplicated
group by 1
order by 1;

-- Exemple de changements détectés
select
    order_id,
    line_item_id,
    order_status,
    extracted_at,
    case when previous_hash is null then '🆕 première version' else '🔄 modification détectée' end as raison
from orders_deduplicated
where order_id in (
    select order_id
    from orders_deduplicated
    group by order_id
    having count(*) > 1
)
order by order_id, extracted_at
limit 20;

-- Vue réutilisable pour pipeline (hash calculé sur raw_orders)
create or replace view v_orders_with_content_hash as
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
from raw_orders;
