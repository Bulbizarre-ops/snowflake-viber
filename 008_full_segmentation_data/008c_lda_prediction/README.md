# guide de démarrage : lda, sous-segmentation et marketing automation

ce dossier contient le code source de l'article **"[piste noire] 3 questions pour prédire un décideur : lda, sous-segmentation et marketing automation"**.

il vous permet de prédire le type de décideur (autonome, contraint, partiel, non-décideur) à partir de 3 questions comportementales avec 72% d'accuracy, et de découvrir les sous-profils actionnables à l'intérieur de chaque type.

épisode 3/3 du pipeline de segmentation.

## pré-requis

vous avez besoin des données et scores produits aux épisodes 1 et 2 (dossiers `008a_generation_personas` et `008b_scoring_clustering`).

pour le notebook Python : `scikit-learn`, `pandas`, `matplotlib`, `seaborn`.

## où est le code ?

le code de cet épisode se trouve dans le notebook partagé avec l'épisode 2 :

👉 **[`008b_scoring_clustering/scripts/05_analyse_complete.ipynb`](../008b_scoring_clustering/scripts/05_analyse_complete.ipynb)**

exécutez les sections **LDA**, **importance des questions** et **sous-segmentation** (épisode 3).

## structure du notebook (sections épisode 3)

- **LDA** : `LinearDiscriminantAnalysis` sur les 4 axes ABCD, validation croisée à 5 plis, accuracy ~72%.
- **matrice de confusion** : identification des erreurs tolérables (A/D) vs critiques (B/A).
- **importance des questions (leave-one-out)** : classement des 14 questions par impact sur l'accuracy. Q5, Q12, Q1 arrivent en tête.
- **courbe performance vs nombre de questions** : 3 questions capturent 90%+ de la performance maximale.
- **sous-segmentation** : K-Means à l'intérieur de chaque type de décideur. 4 sous-profils dans le décideur contraint, 2 dans le décideur partiel.

## résultats attendus

| indicateur | valeur |
|------------|--------|
| accuracy LDA (full) | ~72% |
| accuracy cross-validation (5-fold) | ~70% ± 4% |
| questions pour 90%+ performance | 3 |
| sous-segments actionnables | 8 |
| séquences email distinctes | 8 |

---

_code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — l'excellence Snowflake, sans le bullshit._
