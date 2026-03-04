# guide de démarrage : données synthétiques RH

ce dossier contient le code source de l'article **"[piste rouge] données synthétiques RH. le guide sans filtre."**

il vous permet de générer 500 salariés fictifs statistiquement cohérents — distributions CSP contrôlées, corrélations âge/ancienneté/salaire garanties, coût zéro — et de produire les 7 rubriques d'un bilan social légal.

## pré-requis

vous avez besoin d'un compte Snowflake. Si vous n'en avez pas :
👉 **[créer un compte d'essai gratuit ($400 de crédits)](https://signup.snowflake.com/)**

aucune carte de crédit requise. choisissez l'édition "Enterprise" et le cloud provider de votre choix.

## comment lancer le code ?

### option A : la méthode "copier-coller" (débutant / rapide)

1. connectez-vous à votre interface Snowflake (Snowsight).
2. ouvrez une nouvelle **worksheet SQL**.
3. copiez et exécutez les fichiers du dossier `scripts/` **dans l'ordre** :
   - `01_setup.sql` — crée la database et les 3 schémas
   - `02_tables_reference.sql` — charge les référentiels pondérés (postes, prénoms, établissements)
   - `03_generation_salaries.sql` — génère les 500 salariés avec GENERATOR + HASH
   - `04_indicateurs_bilan_social.sql` — calcule les 7 rubriques légales

### option B : la méthode "pro" (CLI)

```bash
snow sql -f scripts/01_setup.sql
snow sql -f scripts/02_tables_reference.sql
snow sql -f scripts/03_generation_salaries.sql
snow sql -f scripts/04_indicateurs_bilan_social.sql
```

## structure du code

- **01_setup.sql** : crée `SNOW_VIBER_BILAN_007` avec 3 schémas (REFERENTIEL, GENERATION, INDICATEURS) et le warehouse XSmall.
- **02_tables_reference.sql** : charge les tables de référence pondérées — postes par CSP (20% cadres / 50% ETAM / 30% ouvriers), prénoms multiculturels, établissements, formations, motifs de départ.
- **03_generation_salaries.sql** : génère 500 lignes avec `TABLE(GENERATOR(ROWCOUNT => 500))`, tire les attributs avec `MOD(ABS(HASH(...)), N)`, et force les corrélations métier (ancienneté ≤ âge - 22).
- **04_indicateurs_bilan_social.sql** : produit les vues pour les 7 rubriques légales (emploi, rémunérations, hygiène/sécurité, conditions de travail, formation, relations professionnelles, conditions de vie).

## résultats attendus

après exécution sur une instance vierge :

| indicateur | valeur |
|------------|--------|
| effectif actif | ~449 |
| femmes | ~43.7% |
| cadres | ~20.5% |
| âge moyen | ~41 ans |
| ancienneté moyenne | ~10 ans |
| salaire moyen | ~48 000 € |
| rapport D9/D1 | ~2.71 |

les légers écarts par rapport aux cibles (ex: 43.7% vs 45% femmes) sont normaux sur 500 lignes avec HASH. à 5 000 lignes, les écarts descendent sous 0.3%.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — l'excellence Snowflake, sans le bullshit._
