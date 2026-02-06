# guide de démarrage : object-hash et déduplication

ce dossier contient le code source de l'article **"object-hash : la déduplication future-proof"**.
il démontre le pattern object-hash (OBJECT_CONSTRUCT + EXCLUDE + SHA2) pour dédupliquer des tables larges sans maintenir une liste de colonnes à la main.

## prérequis

- compte Snowflake avec accès à **Cortex** (CORTEX.COMPLETE pour la génération de notes).
- optionnel : [Snowflake CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config) pour lancer les scripts en ligne de commande.

## comment lancer le code ?

### option A : copier-coller (Snowsight)

1. connectez-vous à Snowsight.
2. ouvrez une worksheet SQL.
3. exécutez les scripts du dossier `scripts/` **dans l'ordre** :
   - `01_setup.sql` — base, schéma, warehouse
   - `02_reference_data.sql` — données de référence (Cortex + JSON) et création de la table `raw_orders`
   - `03_generation.sql` — génération de 5 000 commandes + second batch avec doublons
   - `04_object_hash.sql` — démo des deux méthodes de hash (OBJECT_DELETE vs EXCLUDE)
   - `05_deduplication.sql` — table `orders_deduplicated` (hash + LAG pour garder les changements réels)
   - `06_analysis.sql` — comparaison avant/après, stats, vue réutilisable

### option B : CLI

```bash
snow sql -f scripts/01_setup.sql
snow sql -f scripts/02_reference_data.sql
snow sql -f scripts/03_generation.sql
snow sql -f scripts/04_object_hash.sql
snow sql -f scripts/05_deduplication.sql
snow sql -f scripts/06_analysis.sql
```

## structure du code

- **01_setup.sql** : database SNOW_VIBER_OBJECT_HASH_004, schema demo, warehouse xsmall.
- **02_reference_data.sql** : notes clients (CORTEX.COMPLETE), données de référence (produits, clients, villes), création de la table `raw_orders`.
- **03_generation.sql** : insertion de 5 000 commandes (lot 1) puis ~1 500 lignes reprises avec doublons et changements de statut (lot 2).
- **04_object_hash.sql** : comparaison OBJECT_DELETE (majuscules) vs OBJECT_CONSTRUCT(* EXCLUDE ...).
- **05_deduplication.sql** : calcul du content_hash, LAG par grain (order_id, line_item_id), table `orders_deduplicated`.
- **06_analysis.sql** : stats avant/après, répartition première version vs modification détectée, vue `v_orders_with_content_hash`.

## nettoyage (optionnel)

pour supprimer tous les objets de la démo :

```sql
drop database if exists SNOW_VIBER_OBJECT_HASH_004;
```

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — L'excellence Snowflake, sans le bullshit._
