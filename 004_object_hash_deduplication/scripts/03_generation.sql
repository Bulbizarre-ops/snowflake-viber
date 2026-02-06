-- --------------------------------------------------------------------------------------------------------------------
-- 03_generation.sql
--
-- Génération de 5 000 commandes (lot 1) puis second batch avec doublons et changements de statut (lot 2).
-- Prérequis : 02_reference_data.sql.
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OBJECT_HASH_004;
use schema demo;
use warehouse SNOW_VIBER_WH;

-- Lot 1 : 5 000 commandes (extraction du 15 janvier)
insert into raw_orders
with
ref as (select data from ref_data),
base_orders as (
    select
        row_number() over (order by seq4()) as rn,
        'ORD-' || lpad(seq4()::varchar, 6, '0') as order_id,
        'LI-' || lpad(uniform(1, 3, random())::varchar, 3, '0') as line_item_id,
        'CUST-' || lpad((seq4() % 500 + 1)::varchar, 5, '0') as customer_id,
        uniform(0, 19, random()) as idx_prenom,
        uniform(0, 19, random()) as idx_nom,
        uniform(0, 14, random()) as idx_produit,
        uniform(0, 14, random()) as idx_ville,
        uniform(0, 4, random()) as idx_statut,
        uniform(0, 19, random()) as idx_note,
        uniform(1, 10, random()) as has_note,
        uniform(1, 5, random()) as qty,
        uniform(0, 20, random()) as discount,
        seq4() as row_num
    from table(generator(rowcount => 5000))
)
select
    b.order_id,
    b.line_item_id,
    b.customer_id,
    lower(r.data:prenoms[b.idx_prenom]::varchar) || '.' || lower(r.data:noms[b.idx_nom]::varchar) || '@email.fr' as customer_email,
    r.data:prenoms[b.idx_prenom]::varchar as customer_first_name,
    r.data:noms[b.idx_nom]::varchar as customer_last_name,
    '06' || lpad(uniform(10000000, 99999999, random())::varchar, 8, '0') as customer_phone,
    r.data:produits[b.idx_produit]:sku::varchar as product_sku,
    r.data:produits[b.idx_produit]:nom::varchar as product_name,
    b.qty as quantity,
    r.data:produits[b.idx_produit]:prix::number(10,2) as unit_price,
    b.discount as discount_percent,
    round(b.qty * r.data:produits[b.idx_produit]:prix::number(10,2) * (1 - b.discount/100), 2) as total_price,
    'EUR' as currency,
    case uniform(1, 3, random()) when 1 then 'EXPRESS' when 2 then 'STANDARD' else 'RELAY' end as shipping_method,
    uniform(1, 200, random())::varchar || ' rue ' || case uniform(1, 5, random()) when 1 then 'de la Paix' when 2 then 'Victor Hugo' when 3 then 'des Lilas' when 4 then 'du Commerce' else 'de la République' end as shipping_address,
    r.data:villes[b.idx_ville]::varchar as shipping_city,
    uniform(1, 200, random())::varchar || ' rue ' || case uniform(1, 5, random()) when 1 then 'de la Paix' when 2 then 'Victor Hugo' when 3 then 'des Lilas' when 4 then 'du Commerce' else 'de la République' end as billing_address,
    case uniform(1, 4, random()) when 1 then 'CB' when 2 then 'PAYPAL' when 3 then 'VIREMENT' else 'APPLE_PAY' end as payment_method,
    r.data:statuts[b.idx_statut]::varchar as order_status,
    case when b.has_note = 1 then n.note else null end as notes,
    'ERP_LEGACY' as source_system,
    '2025-01-15 08:00:00'::timestamp_ntz as extracted_at,
    current_timestamp() as loaded_at,
    'BATCH-20250115-001' as batch_id,
    'orders_20250115.csv' as file_name,
    b.row_num as row_number_in_file
from base_orders b
cross join ref r
left join ref_notes n on n.idx = b.idx_note;

-- Lot 2 : ~30 % des commandes reprises, 50 % avec statut modifié
insert into raw_orders
with existing_orders as (
    select * from raw_orders
    where uniform(1, 100, random()) <= 30
),
modified as (
    select
        order_id, line_item_id, customer_id, customer_email, customer_first_name, customer_last_name, customer_phone,
        product_sku, product_name, quantity, unit_price, discount_percent, total_price, currency,
        shipping_method, shipping_address, shipping_city, billing_address, payment_method,
        case
            when uniform(1, 100, random()) <= 50 then
                case order_status
                    when 'PENDING' then 'CONFIRMED'
                    when 'CONFIRMED' then 'SHIPPED'
                    when 'SHIPPED' then 'DELIVERED'
                    else order_status
                end
            else order_status
        end as order_status,
        notes,
        'ERP_LEGACY' as source_system,
        '2025-01-16 08:00:00'::timestamp_ntz as extracted_at,
        current_timestamp() as loaded_at,
        'BATCH-20250116-001' as batch_id,
        'orders_20250116.csv' as file_name,
        row_number() over (order by order_id) as row_number_in_file
    from existing_orders
)
select * from modified;

select 'total raw_orders' as etape, count(*) as nb from raw_orders;
