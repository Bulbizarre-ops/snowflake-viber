# dossiers publics snowflakeviber

ce dossier regroupe les contenus **déployables** de la newsletter snowflakeviber.
chaque sous-dossier correspond à un article, avec un README et des scripts prêts à exécuter.

## liste des dossiers

- **001_native_lakehouse** : lakehouse natif (internal stage, directory table, sécurité).
- **002_cortex_sentiment_verbatims** : génération de verbatims + analyse de sentiment avec cortex ai.
- **003_conditional_change_event** : sessionisation d'états machine et calcul du mttr.
- **004_object_hash_deduplication** : object-hash (OBJECT_CONSTRUCT + EXCLUDE + SHA2) pour dédupliquer sans maintenir une liste de colonnes.
- **005_cortex_ocr_ai_extract** : ocr cartes grises avec cortex ai (AI_PARSE_DOCUMENT, AI_EXTRACT) — cas d'usage expert assurance.
- **006_generation_pdf_snowflake** : génération de pdf depuis des données en table (udf Python fpdf + COPY FILES) — enchaînement possible avec 005 pour ocr.

## comment utiliser

1. entrez dans le dossier de l'article.
2. lisez le README pour les prérequis.
3. exécutez les scripts dans l'ordre indiqué.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) - L'excellence Snowflake, sans le bullshit._
