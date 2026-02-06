-- --------------------------------------------------------------------------------------------------------------------
-- 02_reference_data.sql
--
-- Données de référence (Cortex AI pour les notes, JSON pour produits/clients) et création de la table raw_orders.
-- Prérequis : 01_setup.sql. Idempotent.
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OBJECT_HASH_004;
use schema demo;
use warehouse SNOW_VIBER_WH;

-- Notes clients variées (un seul appel Cortex)
create or replace temporary table ref_notes as
with raw_notes as (
    select snowflake.cortex.complete(
        'mistral-large2',
        'Génère exactement 20 notes de livraison e-commerce en français, séparées par des points-virgules. Notes courtes (max 10 mots). Exemples : "Laisser chez le gardien", "Code porte 4521", "Livrer après 18h". Réponds UNIQUEMENT les notes séparées par des points-virgules, rien d autre.'
    ) as notes_raw
)
select
    trim(n.value::varchar) as note,
    n.index as idx
from raw_notes,
lateral flatten(input => split(notes_raw, ';')) n
where trim(n.value::varchar) != '';

-- Données de référence (produits tech, clients français)
create or replace temporary table ref_data as
select parse_json('{
    "prenoms": ["Marie","Thomas","Camille","Lucas","Emma","Hugo","Léa","Nathan","Chloé","Maxime","Julie","Antoine","Sarah","Alexandre","Laura","Nicolas","Manon","Pierre","Anaïs","Julien"],
    "noms": ["Martin","Bernard","Dubois","Thomas","Robert","Richard","Petit","Durand","Leroy","Moreau","Simon","Laurent","Lefebvre","Michel","Garcia","David","Bertrand","Roux","Vincent","Fournier"],
    "produits": [
        {"sku":"SKU-LAPTOP-PRO","nom":"MacBook Pro 16 pouces","prix":2499.00},
        {"sku":"SKU-LAPTOP-AIR","nom":"MacBook Air M3","prix":1299.00},
        {"sku":"SKU-MONITOR-4K","nom":"Écran Dell 27 pouces 4K","prix":549.00},
        {"sku":"SKU-MONITOR-UW","nom":"Écran LG UltraWide 34 pouces","prix":799.00},
        {"sku":"SKU-KEYBOARD-MECH","nom":"Clavier Mécanique Logitech MX","prix":179.00},
        {"sku":"SKU-KEYBOARD-MAGIC","nom":"Magic Keyboard Apple","prix":149.00},
        {"sku":"SKU-MOUSE-MX","nom":"Souris Logitech MX Master 3","prix":99.00},
        {"sku":"SKU-MOUSE-MAGIC","nom":"Magic Mouse Apple","prix":85.00},
        {"sku":"SKU-HEADSET-PRO","nom":"Casque Sony WH-1000XM5","prix":379.00},
        {"sku":"SKU-HEADSET-AIRPODS","nom":"AirPods Pro 2","prix":279.00},
        {"sku":"SKU-WEBCAM-4K","nom":"Webcam Logitech Brio 4K","prix":199.00},
        {"sku":"SKU-DOCK-TB","nom":"Station Thunderbolt CalDigit","prix":349.00},
        {"sku":"SKU-SSD-EXT","nom":"SSD Samsung T7 1To","prix":129.00},
        {"sku":"SKU-HUB-USB","nom":"Hub USB-C Anker 7-en-1","prix":59.00},
        {"sku":"SKU-CHARGER-GAN","nom":"Chargeur GaN 100W Anker","prix":79.00}
    ],
    "villes": ["Paris 75001","Lyon 69001","Marseille 13001","Toulouse 31000","Nice 06000","Nantes 44000","Strasbourg 67000","Montpellier 34000","Bordeaux 33000","Lille 59000","Rennes 35000","Reims 51100","Le Havre 76600","Saint-Étienne 42000","Toulon 83000"],
    "statuts": ["PENDING","CONFIRMED","SHIPPED","DELIVERED","CANCELLED"]
}') as data;

-- Table cible (wide table : 20+ colonnes, dont métadonnées à exclure du hash)
create or replace table raw_orders (
    order_id            varchar(50),
    line_item_id        varchar(50),
    customer_id         varchar(50),
    customer_email      varchar(255),
    customer_first_name varchar(100),
    customer_last_name  varchar(100),
    customer_phone      varchar(20),
    product_sku         varchar(50),
    product_name        varchar(255),
    quantity            number(10,0),
    unit_price          number(10,2),
    discount_percent    number(5,2),
    total_price         number(12,2),
    currency            varchar(3),
    shipping_method     varchar(50),
    shipping_address    varchar(500),
    shipping_city       varchar(100),
    billing_address     varchar(500),
    payment_method      varchar(50),
    order_status        varchar(30),
    notes               varchar(1000),
    source_system       varchar(50),
    extracted_at        timestamp_ntz,
    loaded_at           timestamp_ntz default current_timestamp(),
    batch_id            varchar(100),
    file_name           varchar(255),
    row_number_in_file  number(10,0)
);
