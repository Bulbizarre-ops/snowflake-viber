-- --------------------------------------------------------------------------------------------------------------------
-- 05_mttr.sql
-- 
-- Ce script calcule le MTTR (mean time to repair) par machine.
-- Il est idempotent (peut être rejoué sans erreur).
-- --------------------------------------------------------------------------------------------------------------------

-- 5. MTTR (mean time to repair) — moyenne des durées d'arrêt par machine
select
    id_machine,
    avg(duree_secondes)::number(10,2) as mttr_secondes
from (
    select
        id_machine,
        id_session,
        datediff('second', min(ts), max(ts)) as duree_secondes
    from v_sessions_etat
    where statut in ('error', 'maintenance')
    group by id_machine, id_session
) s
group by id_machine;
