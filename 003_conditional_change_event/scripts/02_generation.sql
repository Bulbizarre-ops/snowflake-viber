-- --------------------------------------------------------------------------------------------------------------------
-- 02_generation.sql
-- 
-- Ce script génère une télémétrie simulée pour une ensacheuse industrielle.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 2. Génération de télémétrie simulée (ensacheuse : vitesse, pression, statut, timestamp)
-- Séquences simulées : on -> error -> on -> maintenance -> on (périodes de panne)
create or replace table telemetrie_ensacheuse as
select
    'ENS-01' as id_machine,
    dateadd(second, seq4() * 10, '2026-01-15 08:00:00'::timestamp_ntz) as ts,
    uniform(80, 120, random())::number(5,2) as vitesse,
    uniform(2.0, 3.5, random())::number(4,2) as pression,
    case
        when seq4() between 0 and 4 then 'on'
        when seq4() between 5 and 7 then 'error'
        when seq4() between 8 and 14 then 'on'
        when seq4() between 15 and 17 then 'maintenance'
        else 'on'
    end as statut
from table(generator(rowcount => 200));
