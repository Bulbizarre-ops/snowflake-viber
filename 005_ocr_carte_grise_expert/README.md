# guide de démarrage : ocr cartes grises avec cortex ai

ce dossier contient le code source de l'article **"ai_sql ocr : extraire les cartes grises sans saisir à la main"**.
il démontre l'utilisation de **AI_PARSE_DOCUMENT** (OCR) et **AI_EXTRACT** pour extraire les champs métier de cartes grises. cas d'usage : société d'expert en assurance.

## prérequis

- compte Snowflake avec accès à **Cortex** (AI_PARSE_DOCUMENT, AI_EXTRACT).
- optionnel : [Snowflake CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config) pour lancer les scripts en ligne de commande.

## comment lancer le code ?

### option A : copier-coller (Snowsight)

1. connectez-vous à Snowsight.
2. ouvrez une worksheet SQL.
3. exécutez les scripts du dossier `scripts/` **dans l'ordre** :
   - `01_setup.sql` — base, schéma, warehouse, stage avec chiffrement SNOWFLAKE_SSE
   - **charger des PDF/images sur le stage** via SnowSight : Data → Databases → SNOW_VIBER_OCR_005 → raw_data → Stages → documents_cartes_grises → Upload
   - `02_ocr_extraction.sql` — OCR brut (extraction_ocr_raw), extraction structurée (extraction_cartes_grises), table exploitable (cartes_grises_exploitables)
   - `03_controles_et_stats.sql` — vues et requêtes de stats (taux de complétion par champ, distribution marque/genre, contrôles manquants, échantillon)

### option B : CLI

```bash
snow sql -f scripts/01_setup.sql
# puis charger les PDF/images sur le stage via SnowSight
snow sql -f scripts/02_ocr_extraction.sql
snow sql -f scripts/03_controles_et_stats.sql
```

## structure du code

- **01_setup.sql** : database SNOW_VIBER_OCR_005, schema raw_data, warehouse xsmall, stage avec encryption SNOWFLAKE_SSE (obligatoire pour AI_PARSE_DOCUMENT et AI_EXTRACT).
- **02_ocr_extraction.sql** : extraction OCR brut (mode OCR), extraction structurée avec AI_EXTRACT (questions en langage naturel → JSON), table dénormalisée `cartes_grises_exploitables`.
- **03_controles_et_stats.sql** : vue `v_stats_extraction` (taux de complétion par champ), distribution par marque/genre, vue `v_controles_manquants` (fichiers avec champs manquants), échantillon pour vérification manuelle.

## chargement des documents

après l'exécution de `01_setup.sql`, chargez vos PDF/images sur le stage via SnowSight :
- Data → Databases → SNOW_VIBER_OCR_005 → raw_data → Stages → documents_cartes_grises → Upload
- sélectionnez les fichiers PDF, PNG, JPG, JPEG, TIFF ou TIF à traiter

**important :** le stage doit avoir le chiffrement SNOWFLAKE_SSE (défini dans `01_setup.sql`). sans ça, AI_PARSE_DOCUMENT et AI_EXTRACT refusent le stage.

## nettoyage (optionnel)

pour supprimer tous les objets de la démo :

```sql
drop database if exists SNOW_VIBER_OCR_005;
```

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — L'excellence Snowflake, sans le bullshit._
