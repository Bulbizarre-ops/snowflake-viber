-- --------------------------------------------------------------------------------------------------------------------
-- 02_generation_donnees.sql
--
-- Génère ~100 cartes grises réalistes via tables de référence + GENERATOR + RANDOM.
-- Approche structurée : tables de référence séparées, assemblage par jointures.
-- La table simili_cartes_grises_data sert d'entrée au script 03_generation_pdf.sql.
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OCR_005;
use schema raw_data;
use warehouse SNOW_VIBER_WH;

-- =============================================================================
-- 1. Tables de référence
-- =============================================================================

-- 1.1 Noms de famille (France multiculturelle)
create or replace table ref_noms as
select column1 as nom, row_number() over (order by column1) as id
from values
    ('MARTIN'), ('BERNARD'), ('THOMAS'), ('PETIT'), ('ROBERT'), ('RICHARD'), ('DURAND'), ('DUBOIS'), ('MOREAU'), ('LAURENT'),
    ('SIMON'), ('MICHEL'), ('LEFEVRE'), ('LEROY'), ('ROUX'), ('DAVID'), ('BERTRAND'), ('MOREL'), ('FOURNIER'), ('GIRARD'),
    ('BONNET'), ('DUPONT'), ('LAMBERT'), ('FONTAINE'), ('ROUSSEAU'), ('VINCENT'), ('MULLER'), ('LEFEVRE'), ('FAURE'), ('ANDRE'),
    ('BENALI'), ('BOUZID'), ('KHELIFI'), ('BELKACEM'), ('AMRANI'), ('BOUAZZA'), ('CHERIF'), ('HAMIDI'), ('SAIDI'), ('MANSOURI'),
    ('DA SILVA'), ('FERREIRA'), ('SANTOS'), ('RODRIGUES'), ('PEREIRA'), ('OLIVEIRA'), ('COSTA'), ('GOMES'), ('MARTINS'), ('LOPES'),
    ('DIALLO'), ('TRAORE'), ('DIOP'), ('NDIAYE'), ('CAMARA'), ('KONE'), ('COULIBALY'), ('TOURE'), ('SYLLA'), ('BARRY'),
    ('NGUYEN'), ('TRAN'), ('LE'), ('PHAM'), ('WANG'), ('CHEN'), ('LI'), ('LIU'), ('ZHANG'), ('YANG'),
    ('ROSSI'), ('FERRARI'), ('ESPOSITO'), ('GARCIA'), ('MARTINEZ'), ('LOPEZ'), ('GONZALEZ'), ('FERNANDEZ'), ('SANCHEZ'), ('ROMANO');

-- 1.2 Prénoms (mixte, multiculturel)
create or replace table ref_prenoms as
select column1 as prenom, row_number() over (order by column1) as id
from values
    ('Jean'), ('Pierre'), ('Marie'), ('Sophie'), ('Thomas'), ('Nicolas'), ('Julie'), ('Camille'), ('Antoine'), ('Lucie'),
    ('François'), ('Catherine'), ('Philippe'), ('Isabelle'), ('Alain'), ('Nathalie'), ('Michel'), ('Christine'), ('Patrick'), ('Sylvie'),
    ('Mohamed'), ('Ahmed'), ('Karim'), ('Fatima'), ('Rachid'), ('Samira'), ('Youssef'), ('Leila'), ('Mehdi'), ('Nadia'),
    ('Mamadou'), ('Oumar'), ('Ibrahima'), ('Aminata'), ('Moussa'), ('Mariama'), ('Seydou'), ('Fatoumata'), ('Boubacar'), ('Aissatou'),
    ('Linh'), ('Minh'), ('Thanh'), ('Mai'), ('Duc'), ('Lan'), ('Wei'), ('Mei'), ('Jun'), ('Ying'),
    ('Carlos'), ('Maria'), ('José'), ('Ana'), ('Marco'), ('Lucia'), ('Antonio'), ('Rosa'), ('Paolo'), ('Carla'),
    ('Yanis'), ('Inès'), ('Rayan'), ('Lina'), ('Adam'), ('Sarah'), ('Noah'), ('Jade'), ('Liam'), ('Emma');

-- 1.3 Villes françaises avec codes postaux
create or replace table ref_villes as
select column1 as ville, column2 as code_postal, row_number() over (order by column1) as id
from values
    ('Paris', '75001'), ('Paris', '75010'), ('Paris', '75015'), ('Paris', '75020'),
    ('Lyon', '69001'), ('Lyon', '69003'), ('Lyon', '69007'),
    ('Marseille', '13001'), ('Marseille', '13008'), ('Marseille', '13013'),
    ('Toulouse', '31000'), ('Toulouse', '31400'),
    ('Nice', '06000'), ('Nice', '06300'),
    ('Nantes', '44000'), ('Nantes', '44300'),
    ('Strasbourg', '67000'), ('Strasbourg', '67100'),
    ('Montpellier', '34000'), ('Montpellier', '34080'),
    ('Bordeaux', '33000'), ('Bordeaux', '33100'),
    ('Lille', '59000'), ('Lille', '59800'),
    ('Rennes', '35000'), ('Rennes', '35200'),
    ('Reims', '51100'), ('Le Havre', '76600'), ('Saint-Étienne', '42000'),
    ('Toulon', '83000'), ('Grenoble', '38000'), ('Grenoble', '38100'),
    ('Dijon', '21000'), ('Angers', '49000'), ('Nîmes', '30000'),
    ('Villeurbanne', '69100'), ('Clermont-Ferrand', '63000'), ('Le Mans', '72000'),
    ('Aix-en-Provence', '13100'), ('Brest', '29200'), ('Tours', '37000'),
    ('Amiens', '80000'), ('Limoges', '87000'), ('Perpignan', '66000'),
    ('Metz', '57000'), ('Besançon', '25000'), ('Orléans', '45000'),
    ('Rouen', '76000'), ('Mulhouse', '68100'), ('Caen', '14000'), ('Nancy', '54000'),
    ('Saint-Denis', '93200'), ('Argenteuil', '95100'), ('Montreuil', '93100'),
    ('Créteil', '94000'), ('Vitry-sur-Seine', '94400'), ('Aubervilliers', '93300');

-- 1.4 Types et noms de voies
create or replace table ref_types_voies as
select column1 as type_voie, row_number() over (order by column1) as id
from values
    ('rue'), ('rue'), ('rue'), ('rue'), ('avenue'), ('avenue'),
    ('boulevard'), ('boulevard'), ('place'), ('allée'), ('impasse'), ('chemin'), ('passage');

create or replace table ref_noms_voies as
select column1 as nom_voie, row_number() over (order by column1) as id
from values
    ('de la République'), ('Jean Jaurès'), ('Victor Hugo'), ('de la Liberté'), ('du Général de Gaulle'),
    ('Pasteur'), ('Gambetta'), ('Voltaire'), ('de la Gare'), ('du Maréchal Foch'),
    ('de Paris'), ('de Lyon'), ('Émile Zola'), ('des Lilas'), ('du Commerce'),
    ('de Verdun'), ('Jules Ferry'), ('de la Paix'), ('Saint-Michel'), ('Notre-Dame'),
    ('des Roses'), ('du Moulin'), ('de la Fontaine'), ('du Château'), ('des Champs'),
    ('Aristide Briand'), ('Pierre Curie'), ('Marie Curie'), ('du 8 Mai 1945'), ('du 11 Novembre'),
    ('de Strasbourg'), ('de Marseille'), ('de Bordeaux'), ('de Nantes'), ('de Toulouse'),
    ('des Acacias'), ('des Tilleuls'), ('des Platanes'), ('du Stade'), ('de la Mairie'),
    ('Jean Moulin'), ('Léon Blum'), ('François Mitterrand'), ('Charles de Gaulle'), ('Georges Pompidou');

-- 1.5 Marques automobiles
create or replace table ref_marques as
select column1 as marque, row_number() over (order by column1) as id
from values
    ('RENAULT'), ('RENAULT'), ('RENAULT'), ('PEUGEOT'), ('PEUGEOT'), ('PEUGEOT'),
    ('CITROEN'), ('CITROEN'), ('DACIA'), ('DACIA'),
    ('VOLKSWAGEN'), ('VOLKSWAGEN'), ('TOYOTA'), ('TOYOTA'),
    ('FORD'), ('OPEL'), ('FIAT'), ('MERCEDES'), ('BMW'), ('AUDI'),
    ('NISSAN'), ('HYUNDAI'), ('KIA'), ('SEAT'), ('SKODA');

-- 1.6 Genres de véhicules
create or replace table ref_genres as
select column1 as genre, row_number() over (order by column1) as id
from values
    ('VP'), ('VP'), ('VP'), ('VP'), ('VP'), ('VP'), ('VP'), ('VP'), ('VP'), ('VU');

-- 1.7 Lettres valides pour immatriculation (sans I, O, U)
create or replace table ref_lettres_immat as
select column1 as lettre, row_number() over (order by column1) as id
from values
    ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('J'), ('K'),
    ('L'), ('M'), ('N'), ('P'), ('Q'), ('R'), ('S'), ('T'), ('V'), ('W'),
    ('X'), ('Y'), ('Z');

-- =============================================================================
-- 2. Génération des données (GENERATOR + MOD/ABS/RANDOM)
-- =============================================================================

create or replace table simili_cartes_grises_data as
with generated as (
    select
        seq4() as row_id,
        abs(mod(random(), 100)) + 1 as idx_nom,
        abs(mod(random(), 100)) + 1 as idx_prenom,
        abs(mod(random(), 60)) + 1 as idx_ville,
        abs(mod(random(), 13)) + 1 as idx_type_voie,
        abs(mod(random(), 45)) + 1 as idx_nom_voie,
        abs(mod(random(), 25)) + 1 as idx_marque,
        abs(mod(random(), 10)) + 1 as idx_genre,
        abs(mod(random(), 23)) + 1 as idx_l1,
        abs(mod(random(), 23)) + 1 as idx_l2,
        abs(mod(random(), 23)) + 1 as idx_l3,
        abs(mod(random(), 23)) + 1 as idx_l4,
        lpad((abs(mod(random(), 999)) + 1)::string, 3, '0') as chiffres_immat,
        abs(mod(random(), 150)) + 1 as num_rue,
        dateadd(day, abs(mod(random(), 3652)), '2015-01-01'::date) as date_immat
    from table(generator(rowcount => 100))
)
select
    l1.lettre || l2.lettre || '-' || g.chiffres_immat || '-' || l3.lettre || l4.lettre as immatriculation,
    n.nom as nom_titulaire,
    p.prenom as prenom_titulaire,
    g.num_rue || ' ' || tv.type_voie || ' ' || nv.nom_voie || ' ' || v.code_postal || ' ' || v.ville as adresse,
    m.marque,
    ge.genre,
    to_char(g.date_immat, 'YYYY-MM-DD') as date_premiere_immat
from generated g
join ref_noms n on n.id = g.idx_nom
join ref_prenoms p on p.id = g.idx_prenom
join ref_villes v on v.id = g.idx_ville
join ref_types_voies tv on tv.id = g.idx_type_voie
join ref_noms_voies nv on nv.id = g.idx_nom_voie
join ref_marques m on m.id = g.idx_marque
join ref_genres ge on ge.id = g.idx_genre
join ref_lettres_immat l1 on l1.id = g.idx_l1
join ref_lettres_immat l2 on l2.id = g.idx_l2
join ref_lettres_immat l3 on l3.id = g.idx_l3
join ref_lettres_immat l4 on l4.id = g.idx_l4;

-- Vérification
select count(*) as nb_cartes_grises from simili_cartes_grises_data;
select * from simili_cartes_grises_data limit 5;
