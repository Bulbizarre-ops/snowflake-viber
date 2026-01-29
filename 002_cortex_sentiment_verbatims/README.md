# guide de démarrage : cortex ai & verbatims terrain

ce dossier contient le code source de l'article **"[piste rouge] cortex ai : l'analyse de sentiment zero-shot face à la réalité du chantier"**.
il vous permet de simuler des verbatims oraux, de les ingérer dans un lakehouse natif, puis d'analyser les écarts technicien/client avec snowflake cortex ai.

## pré-requis

- un compte Snowflake avec **Cortex AI** activé. si vous n'en avez pas :
👉 **[créer un compte d'essai gratuit ($400 de crédits)](https://signup.snowflake.com/)**

- un rôle autorisé à appeler les fonctions cortex (ai_complete, sentiment, extract_answer)

## comment lancer le code ?

vous avez deux options selon votre niveau de confort.

### option A : la méthode "copier-coller" (débutant / rapide)

pas besoin d'installer quoi que ce soit sur votre ordinateur.

1. connectez-vous à votre interface Snowflake (Snowsight).
2. ouvrez une nouvelle **worksheet SQL**.
3. copiez le contenu des fichiers du dossier `scripts/` dans l'ordre :
   - `01_setup.sql` (infrastructure)
   - `02_generation.sql` (verbatims via cortex)
   - `03_ingestion.sql` (lakehouse natif)
   - `04_analysis.sql` (sentiment & extraction)
   - `05_actions.sql` (écarts & actions)
4. exécutez les blocs un par un avec le bouton "run" (ou CMD+Enter).

### option B : la méthode "pro" (CLI)

si vous avez installé [Snowflake CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config) ou si vous utilisez un IDE configuré.

clonez ce repo et lancez les scripts séquentiellement :

```bash
snow sql -f scripts/01_setup.sql
snow sql -f scripts/02_generation.sql
snow sql -f scripts/03_ingestion.sql
snow sql -f scripts/04_analysis.sql
snow sql -f scripts/05_actions.sql
```

## structure du code

- **01_setup.sql** : crée la database, le schema, le warehouse et le stage interne.
- **02_generation.sql** : génère des verbatims oraux réalistes avec `SNOWFLAKE.CORTEX.AI_COMPLETE`.
- **03_ingestion.sql** : copie les données dans le stage interne et indexe le directory table.
- **04_analysis.sql** : calcule le sentiment et extrait les problèmes détectés.
- **05_actions.sql** : croise les perceptions et propose des actions prioritaires.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) - L'excellence Snowflake, sans le bullshit._
