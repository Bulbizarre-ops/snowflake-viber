# guide de démarrage : Snowflake native lakehouse

ce dossier contient le code source de l'article **"le grand saut : lakehouse natif"**.
il vous permet de déployer en quelques minutes une architecture lakehouse complète utilisant le stockage interne Snowflake.

## pré-requis

vous avez besoin d'un compte Snowflake. Si vous n'en avez pas :
👉 **[créer un compte d'essai gratuit ($400 de crédits)](https://signup.snowflake.com/)**

aucune carte de crédit n'est requise. choisissez l'édition "Enterprise" (pour tester toutes les features) et le cloud provider de votre choix (AWS/Azure/GCP, cela n'a pas d'importance pour ce tutoriel car nous n'utilisons pas leur stockage).

## comment lancer le code ?

vous avez deux options selon votre niveau de confort.

### option A : la méthode "copier-coller" (débutant / rapide)

pas besoin d'installer quoi que ce soit sur votre ordinateur.

1. connectez-vous à votre interface Snowflake (Snowsight).
2. ouvrez une nouvelle **worksheet SQL**.
3. copiez le contenu des fichiers du dossier `scripts/` dans l'ordre :
   - `01_setup.sql` (infrastructure)
   - `02_storage.sql` (le lac)
   - `03_ingestion.sql` (simulation de données)
   - `04_exploration.sql` (requêtes)
   - `05_security.sql` (droits d'accès)
4. exécutez les blocs un par un avec le bouton "run" (ou CMD+Enter).

### option B : la méthode "pro" (CLI)

si vous avez installé [Snowflake CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config) ou si vous utilisez un IDE configuré.

clonez ce repo et lancez les scripts séquentiellement :

```bash
snow sql -f scripts/01_setup.sql
snow sql -f scripts/02_storage.sql
snow sql -f scripts/03_ingestion.sql
# ... etc
```

## structure du code

- **01_setup.sql** : crée la database, le schema et le warehouse (xsmall).
- **02_storage.sql** : crée l'`INTERNAL STAGE` avec encryption et directory table activés.
- **03_ingestion.sql** : génère de la fausse donnée et simule une ingestion via un `COPY INTO`.
- **04_exploration.sql** : montre comment requêter le `DIRECTORY` pour voir vos fichiers.
- **05_security.sql** : Met en place un rôle RBAC avec les privilèges minimaux.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) - L'excellence Snowflake, sans le bullshit._
