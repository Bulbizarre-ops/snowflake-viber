# guide de démarrage : données synthétiques — 200 personas de dirigeants

ce dossier contient le code source de l'article **"[piste rouge] données synthétiques : 200 personas de dirigeants générés avec snowflake cortex"**.

il vous permet de générer 200 personas PME cohérents avec 7 archétypes psychographiques, de simuler 3 000 réponses à un questionnaire comportemental avec bruit contextuel, et d'isoler la variable cible Q10 pour l'analyse discriminante (épisode 3).

épisode 1/3 du pipeline de segmentation.

## pré-requis

vous avez besoin d'un compte Snowflake avec accès à **Snowflake Cortex** (disponible sur AWS us-east-1, Azure East US 2, et GCP us-central1). Si vous n'en avez pas :
👉 **[créer un compte d'essai gratuit ($400 de crédits)](https://signup.snowflake.com/)**

aucune carte de crédit requise. choisissez l'édition "Enterprise" et le cloud provider de votre choix.

## comment lancer le code ?

### option A : la méthode "copier-coller" (débutant / rapide)

1. connectez-vous à votre interface Snowflake (Snowsight).
2. ouvrez une nouvelle **worksheet SQL**.
3. copiez et exécutez les fichiers du dossier `scripts/` **dans l'ordre** :
   - `01_archetypes.sql` — crée la table des 7 archétypes psychographiques
   - `02_generation_personas.sql` — génère les 200 personas via `CORTEX.COMPLETE`
   - `03_questionnaire_reponses.sql` — simule les 3 000 réponses avec bruit contextuel

### option B : la méthode "pro" (CLI)

```bash
snow sql -f scripts/01_archetypes.sql
snow sql -f scripts/02_generation_personas.sql
snow sql -f scripts/03_questionnaire_reponses.sql
```

## structure du code

- **01_archetypes.sql** : crée la table `archetypes` avec les 7 profils psychographiques (phrase_identite, formule_conversion, rapport_data). ces deux colonnes alimentent directement le prompt de génération LLM.
- **02_generation_personas.sql** : génère 200 personas via `SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet', ...)`. distributions pondérées (pilote à vue 25%, pompier épuisé 20%...), maturité digitale 0-4, `TRY_PARSE_JSON` pour la résilience. résultat matérialisé en table.
- **03_questionnaire_reponses.sql** : simule 15 questions comportementales par persona avec injection de bruit (humeur, fatigue, contexte). Q10 isolée dans sa propre colonne comme variable cible.

## résultats attendus

après exécution sur une instance vierge :

| indicateur | valeur |
|------------|--------|
| personas générés | 200 |
| réponses simulées | 3 000 |
| archétypes couverts | 7 |
| questions par persona | 15 |
| coût Cortex estimé | 3 à 8 € |

les distributions démographiques cibles : 40% F / 58% H / 2% NB, âge médian entre 36 et 48 ans. un écart de ±3-5% par archétype est normal avec `RANDOM()`.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — l'excellence Snowflake, sans le bullshit._
