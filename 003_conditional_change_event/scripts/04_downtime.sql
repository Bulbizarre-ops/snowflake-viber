-- --------------------------------------------------------------------------------------------------------------------
-- 04_downtime.sql
-- 
-- Ce script calcule les durées d'arrêt par session (error / maintenance).
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 4. Durées d'arrêt par session (error / maintenance)
select
    id_machine,
    statut,
    id_session,
    min(ts) as debut_arret,
    max(ts) as fin_arret,
    datediff('second', min(ts), max(ts)) as duree_secondes
from v_sessions_etat
where statut in ('error', 'maintenance')
group by id_machine, statut, id_session
order by id_machine, debut_arret;
