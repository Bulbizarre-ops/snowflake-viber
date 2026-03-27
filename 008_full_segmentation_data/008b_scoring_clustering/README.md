# guide de démarrage : scoring sql et clustering k-means sur données comportementales

ce dossier contient le code source de l'article **"[piste noire] scorer et clustériser : acp et k-means pour faire parler la donnée comportementale"**.

il vous permet de transformer les 3 000 réponses brutes générées en épisode 1 en quatre clusters comportementaux interprétables, via un scoring SQL transparent et une ACP + K-Means en Python.

épisode 2/3 du pipeline de segmentation.

## pré-requis

vous avez besoin d'un compte Snowflake avec les données générées à l'épisode 1 (dossier `008a_generation_personas`). si vous partez de zéro :
👉 **[créer un compte d'essai gratuit ($400 de crédits)](https://signup.snowflake.com/)**

pour le notebook Python : `scikit-learn`, `pandas`, `matplotlib`, `seaborn`.

## comment lancer le code ?

### option A : la méthode "copier-coller" (débutant / rapide)

1. connectez-vous à votre interface Snowflake (Snowsight).
2. ouvrez une nouvelle **worksheet SQL**.
3. copiez et exécutez le fichier du dossier `scripts/` :
   - `04_scoring.sql` — calcule les 4 axes ABCD et matérialise la table `personas_scores`

4. ouvrez `scripts/05_analyse_complete.ipynb` dans Jupyter ou VS Code.
5. exécutez les sections **ACP** et **K-Means** (épisode 2).

### option B : la méthode "pro" (CLI)

```bash
snow sql -f scripts/04_scoring.sql
```

puis lancez le notebook via Jupyter :

```bash
jupyter notebook scripts/05_analyse_complete.ipynb
```

## structure du code

- **04_scoring.sql** : calcule les 4 axes comportementaux (Analytique, Réactif, Collectif, Intuitif) via une grille CASE WHEN sur les 14 questions hors Q10. Q10 est isolée comme variable cible. résultat matérialisé en table `personas_scores`.
- **05_analyse_complete.ipynb** : notebook Python complet. épisode 2 — ACP (sklearn PCA, 2 composantes, 95% variance), recherche du k optimal (méthode du coude + score silhouette), K-Means avec k=4, visualisation des clusters et heatmap archétypes ↔ clusters. épisode 3 (LDA) dans le même notebook — voir `008c_lda_prediction/`.

## résultats attendus

après exécution sur les données de l'épisode 1 :

| indicateur | valeur |
|------------|--------|
| personas scorés | 200 |
| axes comportementaux | 4 (A, B, C, D) |
| variance expliquée (PC1+PC2) | ~95% |
| clusters K-Means | 4 |
| score silhouette optimal | k=4 |

les archétypes ne tombent pas un par un dans leur propre cluster. pompier épuisé et pilote à vue partagent le même groupe. c'est attendu et documenté dans l'article.

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — l'excellence Snowflake, sans le bullshit._
