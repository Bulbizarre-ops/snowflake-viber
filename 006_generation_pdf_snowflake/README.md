# guide de démarrage : génération de pdf dans snowflake

ce dossier contient le code source de l'article **"générer des pdf dans snowflake : udf python, copy files, et après ?"**.
il démontre la **génération de PDF** à partir de données en table : **udf Python (fpdf)** + **COPY FILES** vers un stage. les pdf produits peuvent servir d'**input** au pipeline ocr (005_cortex_ocr_ai_extract).

**cas d'usage :** similis cartes grises pour démo, attestations, certificats de domicile, rappels en début d'année — même pattern, mise en page adaptée.

## prérequis

- compte Snowflake avec exécution de **udf Python** (runtime 3.12).
- optionnel : [Snowflake CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config) pour lancer les scripts en ligne de commande.

## comment lancer le code ?

### option A : copier-coller (Snowsight)

1. connectez-vous à Snowsight.
2. ouvrez une worksheet SQL.
3. exécutez les scripts du dossier `scripts/` **dans l'ordre** :
   - `01_setup.sql` — base, schéma, warehouse, stage (réutilise SNOW_VIBER_OCR_005 pour enchaînement avec 005)
   - `02_generation_donnees.sql` — tables de référence + ~100 lignes réalistes (simili_cartes_grises_data)
   - `03_generation_pdf.sql` — udf Python (fpdf) + COPY FILES vers le stage

### option B : CLI

```bash
snow sql -f scripts/01_setup.sql
snow sql -f scripts/02_generation_donnees.sql
snow sql -f scripts/03_generation_pdf.sql
```

## enchaînement avec 005 (ocr)

les pdf générés sont déposés sur le stage `documents_cartes_grises`. pour extraire les champs via ocr (AI_PARSE_DOCUMENT, AI_EXTRACT), exécutez ensuite les scripts de **005_cortex_ocr_ai_extract** :

```bash
# depuis 005_cortex_ocr_ai_extract/scripts/
snow sql -f 02_ocr_extraction.sql
snow sql -f 03_controles_et_stats.sql
```

## structure du code

- **01_setup.sql** : database SNOW_VIBER_OCR_005, schema raw_data, warehouse xsmall, stage documents_cartes_grises (chiffrement SNOWFLAKE_SSE pour compatibilité 005).
- **02_generation_donnees.sql** : tables de référence (noms, prénoms, villes, marques, etc.) + génération de 100 lignes via GENERATOR + RANDOM → table `simili_cartes_grises_data`.
- **03_generation_pdf.sql** : udf `create_simili_carte_grise_pdf` (une partition = un pdf), COPY FILES vers le stage.

## nettoyage (optionnel)

pour supprimer tous les objets de la démo :

```sql
drop database if exists SNOW_VIBER_OCR_005;
```

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — L'excellence Snowflake, sans le bullshit._
