-- --------------------------------------------------------------------------------------------------------------------
-- 03_sessions.sql
-- 
-- Ce script construit les sessions d'état via conditional_change_event.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 3. Sessions d'état avec conditional_change_event
-- Chaque changement de statut (par machine, dans l'ordre du temps) incrémente le compteur = une session
create or replace view v_sessions_etat as
select
    id_machine,
    ts,
    statut,
    conditional_change_event(statut)
        over (partition by id_machine order by ts) as id_session
from telemetrie_ensacheuse;
