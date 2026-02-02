# guide de démarrage : conditional_change_event & arrêts machine

ce dossier contient le code source de l'article **"[piste bleue] conditional_change_event : traquer les pannes au sql"**.
il vous permet de simuler un flux de télémétrie, de sessioniser les états machine et de calculer les durées d'arrêt ainsi que le MTTR.

## pré-requis

vous avez besoin d'un compte Snowflake. Si vous n'en avez pas :
👉 **[créer un compte d'essai gratuit ($400 de crédits)](https://signup.snowflake.com/)**

## comment lancer le code ?

vous avez deux options selon votre niveau de confort.

### option A : la méthode "copier-coller" (débutant / rapide)

pas besoin d'installer quoi que ce soit sur votre ordinateur.

1. connectez-vous à votre interface Snowflake (Snowsight).
2. ouvrez une nouvelle **worksheet SQL**.
3. copiez le contenu des fichiers du dossier `scripts/` dans l'ordre :
   - `01_setup.sql` (infrastructure)
   - `02_generation.sql` (télémétrie simulée)
   - `03_sessions.sql` (sessionisation via conditional_change_event)
   - `04_downtime.sql` (durées d'arrêt)
   - `05_mttr.sql` (mttr)
4. exécutez les blocs un par un avec le bouton "run" (ou CMD+Enter).

### option B : la méthode "pro" (CLI)

si vous avez installé [Snowflake CLI](https://docs.snowflake.com/en/user-guide/snowsql-install-config) ou si vous utilisez un IDE configuré.

clonez ce repo et lancez les scripts séquentiellement :

```bash
snow sql -f scripts/01_setup.sql
snow sql -f scripts/02_generation.sql
snow sql -f scripts/03_sessions.sql
snow sql -f scripts/04_downtime.sql
snow sql -f scripts/05_mttr.sql
```

## structure du code

- **01_setup.sql** : crée la database, le schema et le warehouse (xsmall).
- **02_generation.sql** : génère la télémétrie d'une ensacheuse (vitesse, pression, statut).
- **03_sessions.sql** : construit les sessions d'état avec `conditional_change_event`.
- **04_downtime.sql** : calcule les durées d'arrêt par session.
- **05_mttr.sql** : agrège les durées d'arrêt en MTTR par machine.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) - L'excellence Snowflake, sans le bullshit._
