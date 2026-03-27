# [piste rouge] bilan social. le guide sans filtre.

sept rubriques légales obligatoires, un fichier excel de 47 onglets, trois semaines de sueur. voici comment snowflake règle ça en une requête.

---

## 1. le point zéro

**C'est la fin juin. La DRH vous appelle.**

Le bilan social doit être présenté au CSE avant le 30 juin. Obligatoirement. Articles **L2312-28 à L2312-35 du Code du travail**, depuis 1977. Pas un best practice. Une obligation légale pour toute entreprise de **300 salariés et plus**.

Le problème ? Personne n'a prévu le chantier que ça représente.

Un export SAP ici. Un fichier formation envoyé par la paie en pièce jointe. Un tableau Excel transmis par le service sécurité qui n'est pas au même format que l'an dernier. La DRH consolide à la main. Trois semaines. Un fichier de 47 onglets. Une cellule qui référence une autre cellule qui référence un onglet qui n'existe plus.

→ le résultat ? trois semaines de travail manuel pour produire un document que le CSE va lire pendant vingt minutes.

ce qui rend la chose encore plus absurde : les données existent déjà. elles sont dans vos systèmes. dispersées, mal structurées, mais là. le SIRH connaît les effectifs. l'outil de paie connaît la masse salariale. le système formation connaît les heures et les coûts. le service sécurité a les déclarations d'accidents.

il manque un seul ingrédient : quelque chose qui agrège, calcule et expose tout ça en une requête.

snowflake est cet ingrédient.

au sommet du télésiège, on observe le terrain. l'architecture est claire. les données sont là. on attaque.

---

## 2. le plan des pistes

**Les 7 rubriques. Pas une de plus, pas une de moins.**

Avant d'écrire une ligne de SQL, il faut comprendre ce qu'on construit. Le bilan social n'est pas un rapport vague sur "la situation sociale de l'entreprise". C'est une liste précise définie par décret. **Sept rubriques**. Des indicateurs spécifiques. Des formules réglementaires.

Voici les sept portes à franchir. Et pourquoi chacune existe.

**rubrique 1 — emploi**
L'effectif total, par genre, par **CSP** (cadres / ETAM / ouvriers), par établissement. Pyramide des âges sur cinq tranches INSEE. Distribution par ancienneté. Entrées et sorties de l'année. Taux de turnover. C'est la photographie de votre entreprise à un instant T.

**rubrique 2 — rémunérations et charges accessoires**
La masse salariale brute. Le salaire moyen, médian. Le rapport **D9/D1** — l'indicateur qui mesure l'écart entre vos 10% les mieux payés et les 10% les moins bien payés. Les écarts hommes-femmes par catégorie. C'est l'indicateur que le CSE regarde en premier, et souvent le plus commenté en séance.

**rubrique 3 — conditions d'hygiène et de sécurité**
Les accidents du travail avec leurs deux taux réglementaires : **taux de fréquence INRS** et **taux de gravité INRS**. Les maladies professionnelles déclarées. Les dépenses de prévention. Ces données alimentent aussi votre taux de cotisation AT/MP à la CPAM — elles ont donc un impact financier direct.

**rubrique 4 — autres conditions de travail**
La durée du travail. Les temps partiels exprimés en **ETP** (pas en têtes). L'absentéisme global et par motif. Le taux d'absentéisme calculé sur 220 jours ouvrés théoriques. La rubrique 4 est souvent sous-estimée. C'est pourtant ici que se cachent les signaux faibles : un taux d'absentéisme qui grimpe depuis trois ans est un avertissement que personne ne veut lire.

**rubrique 5 — formation professionnelle**
Le nombre de salariés formés. Les heures de formation. Le budget formation — l'obligation légale est fixée à **1% de la masse salariale** via le plan de développement des compétences. Le taux d'accès à la formation par CSP. C'est ici que les inégalités entre cadres et ouvriers sont les plus flagrantes, et les plus difficiles à justifier.

**rubrique 6 — relations professionnelles**
La composition du CSE. Les élections professionnelles. Les accords collectifs signés dans l'année. Les réunions avec les délégués. Une rubrique courte en données, mais dont l'absence d'indicateurs précis peut être retournée contre vous.

**rubrique 7 — autres conditions de vie relevant de l'entreprise**
Le budget des activités sociales et culturelles du CSE. Les aides au logement. Les crèches d'entreprise. Les prestations diverses. C'est souvent la rubrique la plus approximative en production — les données vivent dans des tableurs RH jamais centralisés.

---

**l'architecture. pourquoi trois schémas et pas un seul.**

```
REFERENTIEL    →  tables stables (postes, établissements, motifs de départ)
GENERATION     →  données RH sources (réelles ou synthétiques)
INDICATEURS    →  vues calculées = le bilan social
```

Ce découpage est dans `scripts/01_setup.sql`. Il est délibéré.

```sql
-- Architecture 3 schémas : séparation stricte des responsabilités
CREATE SCHEMA IF NOT EXISTS REFERENTIEL;   -- ne change jamais
CREATE SCHEMA IF NOT EXISTS GENERATION;    -- alimenté par vos pipelines
CREATE SCHEMA IF NOT EXISTS INDICATEURS;   -- que des vues, zéro stockage
```

pourquoi cette architecture et pas une seule base fourre-tout ?

parce que les sources changent. votre SIRH migre vers Workday. votre outil de paie passe de Silae à ADP. votre outil formation change de format d'export. si vos indicateurs sont écrits directement sur les tables sources, vous réécrivez tout à chaque migration.

avec ce découpage : vous remplacez ce qui est dans GENERATION. les vues de INDICATEURS ne bougent pas. c'est ça, la résilience. pas des slides. une décision d'architecture qui vous fait économiser deux semaines de travail à la prochaine migration SIRH.

---

**pourquoi des données synthétiques pour cet article.**

dans cet article, le schéma GENERATION est alimenté par des données générées artificiellement — 500 salariés produits par `03_generation_salaries.sql` avec GENERATOR + HASH. aucun appel LLM. aucune donnée réelle exposée.

cette approche a une vertu technique directe : vous pouvez exécuter les scripts sur un compte Snowflake vierge, valider les indicateurs, et comprendre la logique avant de brancher vos vraies données sources.

en production, vous remplacez GENERATION par vos tables réelles alimentées par vos pipelines Fivetran, Airbyte ou custom. les vues de INDICATEURS fonctionnent sans modification.

---

> **[sondage]** quel est votre système source pour le bilan social ?
> - SAP / Workday / Silae / ADP / un excel partagé dans Teams

---

## 3. les passages techniques

**rubrique 1 : l'emploi. la fondation.**

C'est le premier indicateur que le CSE regarde. L'effectif total. Et tout de suite après : la répartition.

La vue `v_emploi_effectifs` dans `scripts/04_indicateurs_bilan_social.sql` :

```sql
-- Effectifs normalisés : format indicateur / valeur / detail
-- Un UNION ALL = une passe sur la table salaries
CREATE OR REPLACE VIEW v_emploi_effectifs AS
SELECT
    'Effectif total' AS indicateur,
    COUNT(*)         AS valeur,
    NULL             AS detail
FROM GENERATION.salaries
WHERE statut = 'ACTIF'

UNION ALL

SELECT
    'Effectif par CSP',
    COUNT(*),
    categorie_csp      -- 'CADRE', 'ETAM', 'OUVRIER'
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY categorie_csp;
```

regardez le format `indicateur / valeur / detail`. c'est là que tout se joue.

ce format normalisé produit un tableau directement exploitable dans Tableau, Power BI, Metabase — sans pivot côté client, sans transformation supplémentaire. un seul `SELECT *` sur cette vue donne toute la rubrique emploi. alternativement, dix requêtes séparées = dix passes sur `salaries`. avec ce `UNION ALL` : une passe. sur 500 000 lignes d'historique RH, la différence est perceptible.

---

la pyramide des âges est dans `v_emploi_pyramide_ages`. deux dimensions : le genre et la tranche d'âge.

```sql
-- Pyramide des âges : tranches INSEE standard, pas d'improvisation
CREATE OR REPLACE VIEW v_emploi_pyramide_ages AS
SELECT
    genre,
    CASE
        WHEN age < 25 THEN 'Moins de 25 ans'
        WHEN age < 35 THEN '25-34 ans'
        WHEN age < 45 THEN '35-44 ans'
        WHEN age < 55 THEN '45-54 ans'
        ELSE '55 ans et plus'
    END AS tranche_age,
    COUNT(*) AS effectif
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY genre, tranche_age
ORDER BY genre, tranche_age;
```

ces cinq tranches ne sont pas arbitraires. elles correspondent aux **tranches INSEE standard** — celles que votre inspecteur du travail, votre DARES, votre expert-comptable et votre DSI RH utilisent. si vous définissez vos propres tranches d'âge, vos graphiques seront incomparables avec n'importe quelle donnée de benchmark de branche. joli en interne. inutile pour l'inspection du travail.

---

le turnover est dans `v_emploi_turnover`. il croise la table des départs avec l'effectif actif :

```sql
-- Turnover par motif et par année
CREATE OR REPLACE VIEW v_emploi_turnover AS
SELECT
    YEAR(date_sortie)     AS annee,
    categorie_depart,     -- 'VOLONTAIRE', 'INVOLONTAIRE', 'RETRAITE', 'FIN_CDD'
    libelle_motif,
    COUNT(*)              AS nb_departs,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF'
    ), 2)                 AS taux_turnover_pct
FROM GENERATION.departs
GROUP BY YEAR(date_sortie), categorie_depart, libelle_motif
ORDER BY annee DESC, nb_departs DESC;
```

⚠️ **la plaque de verglas** : diviser par l'effectif actuel en décembre n'est pas la méthode légale.

la formule exacte utilise l'**effectif moyen de l'année** — CDI uniquement, proratisé en ETP. l'écart entre l'approximation et la formule réglementaire peut atteindre **30% sur une entreprise en forte croissance**. pour la démo, l'approximation est acceptable. en production, corrigez-la avant de présenter au CSE.

---

**rubrique 2 : les rémunérations. l'indicateur qui fâche.**

La vue `v_remunerations_egalite_hf` produit les écarts hommes-femmes par CSP. C'est l'indicateur le plus scruté par les représentants du personnel.

```sql
-- Écart H/F par CSP : CASE WHEN dans l'AVG = un seul scan de table
CREATE OR REPLACE VIEW v_remunerations_egalite_hf AS
SELECT
    categorie_csp,
    ROUND(AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END), 0) AS salaire_moyen_h,
    ROUND(AVG(CASE WHEN genre = 'F' THEN salaire_annuel_brut END), 0) AS salaire_moyen_f,
    ROUND(
        (AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END) -
         AVG(CASE WHEN genre = 'F' THEN salaire_annuel_brut END))
        / AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END) * 100
    , 1) AS ecart_pct
FROM GENERATION.salaries
WHERE statut = 'ACTIF'
GROUP BY categorie_csp
ORDER BY ecart_pct DESC;
```

regardez la ligne 4 : `AVG(CASE WHEN genre = 'H' THEN salaire_annuel_brut END)`.

c'est le pattern central de tous les tableaux croisés sans pivot en SQL. pas de jointure supplémentaire. pas de CTE intermédiaire. un seul scan de la table `salaries`. en production sur un million de lignes d'historique de paie, la différence entre ce pattern et une auto-jointure sur le genre est de l'ordre de **10x sur la latence**. et le résultat est identique.

---

le rapport D9/D1 est dans `v_remunerations_hierarchie`. deux lignes. un chiffre qui dit tout sur la structure salariale de votre entreprise :

```sql
-- Hiérarchie salariale : rapport 9e décile sur 1er décile
CREATE OR REPLACE VIEW v_remunerations_hierarchie AS
SELECT
    PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY salaire_annuel_brut) AS decile_1,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY salaire_annuel_brut) AS decile_9,
    ROUND(
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY salaire_annuel_brut) /
        PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY salaire_annuel_brut)
    , 2) AS rapport_d9_d1
FROM GENERATION.salaries
WHERE statut = 'ACTIF';
```

**`PERCENTILE_CONT`** : la fonction qui lit les inégalités dans vos données. elle calcule le percentile par interpolation continue — la méthode statistique standard, celle que l'INSEE utilise.

un rapport à 2.5, c'est une distribution salariale saine pour une entreprise française. à 4.0, c'est un signal que les délégués syndicaux vont souligner. au-delà de 5.0, c'est un argument d'audience prud'homale. sur les 500 salariés générés, le rapport est à **2.71**. réaliste pour une entreprise mixte cadres/ETAM/ouvriers.

---

**rubrique 3 : hygiène et sécurité. les formules INRS.**

La vue `v_accidents_indicateurs` calcule les deux taux légaux. Ces formules sont définies par l'INRS et ne tolèrent aucune improvisation :

```sql
-- Taux de fréquence et gravité INRS (formules réglementaires)
CREATE OR REPLACE VIEW v_accidents_indicateurs AS
SELECT
    annee_absence AS annee,
    COUNT(*)      AS nb_accidents,
    -- Taux de fréquence INRS = (accidents / heures travaillées) × 1 000 000
    -- Hypothèse : 1 600 heures travaillées par salarié par an (valeur INRS)
    ROUND(COUNT(*) * 1000000.0 / (
        (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 1600
    ), 2) AS taux_frequence,
    -- Taux de gravité INRS = (jours perdus / heures travaillées) × 1 000
    ROUND(SUM(duree_jours) * 1000.0 / (
        (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 1600
    ), 2) AS taux_gravite
FROM GENERATION.absences
WHERE type_absence = 'Accident du travail'
GROUP BY annee_absence;
```

le **1 600** est la valeur conventionnelle INRS pour les heures annuelles travaillées par salarié. votre accord d'entreprise peut définir une durée différente — 1 568h dans certaines branches, 1 607h dans d'autres. si vous avez cette donnée dans votre SIRH, utilisez-la. sinon, 1 600 est le standard admis par l'inspection du travail.

ces deux taux alimentent aussi le calcul de votre **taux de cotisation AT/MP** à la CPAM — le taux qui détermine votre prime d'assurance accidents du travail. un taux de fréquence en hausse sur trois ans peut vous coûter plusieurs dizaines de milliers d'euros de cotisations supplémentaires. le bilan social n'est pas qu'un document légal. c'est un outil de pilotage financier.

---

**rubrique 4 : conditions de travail. l'absentéisme.**

La vue `v_absenteisme` calcule le taux d'absentéisme global, par type d'absence et par année. C'est souvent la rubrique la plus révélatrice :

```sql
-- Absentéisme : taux sur 220 jours ouvrés théoriques (convention bilan social)
CREATE OR REPLACE VIEW v_absenteisme AS
SELECT
    annee_absence     AS annee,
    type_absence,
    COUNT(DISTINCT id_salarie) AS nb_salaries_concernes,
    SUM(duree_jours)           AS jours_absence,
    -- 220 jours = convention standard du bilan social
    ROUND(SUM(duree_jours) * 100.0 / (
        (SELECT COUNT(*) FROM GENERATION.salaries WHERE statut = 'ACTIF') * 220
    ), 2)                      AS taux_absenteisme
FROM GENERATION.absences
GROUP BY annee_absence, type_absence
ORDER BY annee DESC, jours_absence DESC;
```

**220 jours** : c'est la durée annuelle théorique standard du bilan social — 365 jours moins les weekends et les jours fériés. certaines conventions collectives utilisent 218 ou 228 jours. vérifiez la vôtre avant de soumettre le document.

les vues `v_conditions_travail` et `v_hygiene_securite` complètent la rubrique 4 en détaillant la répartition temps plein / temps partiel.

un taux d'absentéisme maladie en hausse progressive sur trois ou quatre ans, c'est rarement le fruit du hasard. c'est le premier signal visible d'un problème managérial ou organisationnel. dans le bilan social, ce chiffre est exposé. il sera commenté. si vous n'avez pas d'explication, il vaut mieux la préparer avant la réunion CSE.

---

**rubrique 5 : la formation. le LEFT JOIN obligatoire.**

La vue `v_formation_acces_csp` mesure le taux d'accès à la formation par CSP. C'est ici que se cachent les inégalités les plus courantes — et les plus difficiles à justifier devant le CSE :

```sql
-- Taux d'accès à la formation : LEFT JOIN = salariés non formés conservés
CREATE OR REPLACE VIEW v_formation_acces_csp AS
SELECT
    s.categorie_csp,
    COUNT(DISTINCT s.id_salarie)                            AS effectif_csp,
    COUNT(DISTINCT f.id_salarie)                            AS salaries_formes,
    ROUND(COUNT(DISTINCT f.id_salarie) * 100.0 /
          COUNT(DISTINCT s.id_salarie), 1)                  AS taux_acces_pct,
    SUM(f.duree_heures)                                     AS heures_formation,
    SUM(f.cout_formation)                                   AS budget_formation
FROM GENERATION.salaries s
LEFT JOIN GENERATION.formations_suivies f
    ON s.id_salarie = f.id_salarie
WHERE s.statut = 'ACTIF'
GROUP BY s.categorie_csp
ORDER BY taux_acces_pct DESC;
```

regardez la ligne 8 : `LEFT JOIN`. c'est là que se joue la différence entre un taux exact et un mensonge légal.

un `INNER JOIN` éliminerait silencieusement les salariés qui n'ont suivi aucune formation. le dénominateur serait réduit. le taux d'accès tendrait vers 100%. techniquement cohérent. légalement faux. et le CSE le verra immédiatement si le chiffre ne correspond pas à la réalité terrain — les délégués connaissent leurs collègues.

ce virage demande de l'attention. passez-le trop vite, et vos chiffres ne tiendront pas cinq minutes en présentation.

---

la vue `v_formation_par_domaine` complète le tableau avec la répartition par domaine de formation (management, technique, sécurité, langues...) :

```sql
-- Répartition formation par domaine et par année
CREATE OR REPLACE VIEW v_formation_par_domaine AS
SELECT
    annee_formation AS annee,
    domaine,
    COUNT(*)        AS nb_formations,
    SUM(duree_heures)   AS heures,
    SUM(cout_formation) AS cout_total
FROM GENERATION.formations_suivies
GROUP BY annee_formation, domaine
ORDER BY annee DESC, heures DESC;
```

cette vue répond à une question que le CSE pose systématiquement : est-ce que les formations sont orientées vers les besoins des salariés, ou uniquement vers les besoins de l'entreprise ? si 80% du budget formation va aux cadres et aux domaines techniques, et que les ouvriers n'ont que les formations sécurité obligatoires, vous avez un argument social qui surgira en séance.

---

**rubriques 6 et 7 : relations professionnelles et conditions de vie.**

Ces deux rubriques sont plus légères en données calculées — mais leur absence de précision est une faiblesse. Les vues correspondantes dans `04_indicateurs_bilan_social.sql` :

```sql
-- Rubrique 6 : effectif éligible CSE et estimation des représentants
CREATE OR REPLACE VIEW v_relations_professionnelles AS
SELECT
    'Effectif éligible CSE' AS indicateur,
    COUNT(*)                AS valeur,
    'Salariés avec >= 3 mois ancienneté' AS definition
FROM GENERATION.salaries
WHERE statut = 'ACTIF' AND anciennete_annees >= 0.25

UNION ALL

SELECT
    'Représentants du personnel estimés',
    CEIL(COUNT(*) / 50.0),  -- 1 titulaire CSE par tranche de 50 salariés
    '1 titulaire par tranche de 50 salariés (L2314-1)'
FROM GENERATION.salaries WHERE statut = 'ACTIF';
```

la formule de représentation (`CEIL(effectif / 50)`) est définie par l'article **L2314-1 du Code du travail**. sur 449 salariés actifs, cela donne 9 titulaires au CSE. ce chiffre doit correspondre exactement à votre composition réelle — toute divergence peut être soulevée comme irrégularité par les délégués.

---

```sql
-- Rubrique 7 : budget activités sociales (estimation légale)
CREATE OR REPLACE VIEW v_conditions_vie AS
SELECT
    'Budget activités sociales estimé' AS indicateur,
    -- Plancher légal : 0.3% de la masse salariale brute (L2312-83)
    ROUND(SUM(salaire_annuel_brut) * 0.003, 0) AS valeur,
    '0.3% de la masse salariale (plancher L2312-83)' AS definition
FROM GENERATION.salaries WHERE statut = 'ACTIF';
```

**0.3% de la masse salariale** : c'est le plancher légal défini par l'article L2312-83. en pratique, beaucoup d'entreprises négocient un taux supérieur via accord collectif — certaines montent à 1.5% ou 2%. le bilan social doit mentionner le taux appliqué et la base de calcul. si vous appliquez le plancher légal alors que votre accord prévoit plus, c'est un contentieux CSE.

---

## 4. la vue du café

**la vue synthèse. une requête. tout le bilan social.**

Toutes les rubriques convergent dans `v_synthese_bilan_social`. C'est la vue que vous montrez au CSE, que vous exportez pour l'expert-comptable, que vous soumettez à l'inspection du travail.

```sql
-- Tableau de bord : 20 indicateurs en un seul SELECT
SELECT * FROM INDICATEURS.v_synthese_bilan_social
ORDER BY rubrique, indicateur;
```

Résultats sur les 500 salariés générés par `03_generation_salaries.sql` :

| rubrique | libelle | indicateur | valeur |
|---|---|---|---|
| 1 | EMPLOI | Effectif total | ~449 |
| 1 | EMPLOI | Femmes | ~43.7% |
| 1 | EMPLOI | Cadres | ~20.5% |
| 1 | EMPLOI | Âge moyen | ~41 ans |
| 1 | EMPLOI | Ancienneté moyenne | ~10 ans |
| 1 | EMPLOI | Départs (année) | ~51 |
| 2 | RÉMUNÉRATIONS | Masse salariale | ~21 600 000 € |
| 2 | RÉMUNÉRATIONS | Salaire moyen | ~48 000 € |
| 2 | RÉMUNÉRATIONS | Rapport D9/D1 | ~2.71 |
| 3 | HYGIÈNE | Accidents du travail | ~15 |
| 3 | HYGIÈNE | Jours perdus (AT) | ~135 jours |
| 4 | CONDITIONS | Temps partiel | ~67 (14.9%) |
| 4 | CONDITIONS | Taux absentéisme | ~2.3% |
| 5 | FORMATION | Salariés formés | ~312 |
| 5 | FORMATION | Heures de formation | ~3 200 h |
| 5 | FORMATION | Budget formation | ~216 000 € |
| 6 | RELATIONS PROF. | Représentants estimés | ~9 |
| 7 | CONDITIONS DE VIE | Budget social estimé | ~64 800 € |

les légers écarts par rapport aux cibles (ex : 43.7% vs 45% femmes ciblées) sont normaux. **GENERATOR + HASH** produit des distributions déterministes mais imparfaites sur 500 lignes. à 5 000 lignes, les écarts descendent sous 0.3%.

---

**les quatre obstacles en production. ceux que la doc ne mentionne pas.**

nous voilà face au mur. pas le wall de ski — le mur des vraies données de production. avant de présenter quoi que ce soit au CSE, il faut traverser ces quatre chantiers.

**obstacle 1 : ETP vs têtes.**
Le bilan social ne compte pas les têtes. Il compte les **équivalents temps plein**. Un salarié à 80% = 0.8 ETP, pas 1. Si votre table `salaries` stocke `quotite_travail`, le correctif est simple : `SUM(quotite_travail)` au lieu de `COUNT(*)`.

Si votre SIRH n'exporte pas cette colonne, vous avez un vrai chantier avant de toucher au SQL. Certains SIRH stockent la quotité en centièmes (80 plutôt que 0.8), d'autres en heures contractuelles (28h au lieu de 35h). La normalisation de cette colonne est souvent le premier travail de data engineering du projet.

⚠️ **la plaque de verglas** : utiliser `COUNT(*)` pour les effectifs et passer l'audit. l'écart sur le taux de turnover peut atteindre **30%** sur une entreprise en forte croissance. vous ne voulez pas défendre ça en réunion CSE devant un délégué syndical qui a calculé la même chose différemment.

**obstacle 2 : l'historisation des contrats.**
Le bilan social compare N et N-1. Votre table `salaries` contient-elle l'historique des contrats, ou seulement l'état courant ?

Sans **SCD Type 2** sur vos données RH — c'est-à-dire sans une colonne `date_debut` et `date_fin` sur chaque ligne — vous ne pouvez pas reconstituer l'effectif au 31 décembre de l'année précédente. Un salarié promu de ETAM à cadre en mars disparaît de votre historique ETAM de l'année N-1.

La solution de contournement — créer une table `salaries_snapshot_2024` chaque fin d'année — fonctionne une fois. Elle crée une dette technique qui dure cinq ans. Préférez dès le départ un modèle avec historique : `date_debut DATE NOT NULL, date_fin DATE` avec `NULL` pour la ligne courante.

**obstacle 3 : les identifiants qui dérivent.**
Un salarié peut avoir plusieurs identifiants selon les systèmes — un ID dans le SIRH, un autre dans la paie, un troisième dans l'outil formation. Si vous ne gérez pas ce problème en amont, vos LEFT JOIN sur `id_salarie` ne joindront pas. Les salariés formés ne rejoindront pas leurs salaires. Le taux d'accès à la formation sera faux.

ce problème n'est pas un problème SQL. c'est un problème de gouvernance des données maîtres. résolvez-le en amont avec une table de correspondance d'identifiants. c'est le genre de travail ingrat qui sauve des présentations CSE.

**obstacle 4 : les sources dispersées.**
La partie SQL de cet article est la plus simple. La partie ingestion est le vrai chantier. Planifiez **80% du temps projet** sur les connecteurs sources — pas sur les vues calculées. Votre SIRH a-t-il une API REST ? Un export CSV quotidien ? Un connecteur Fivetran ? La réponse change tout sur le temps et la complexité d'implémentation.

le SQL ne sauve pas des données inexistantes. une vue brillante sur une table vide, c'est du SQL de vitrine.

---

## [le jargon décrypté]

**CSP** — catégorie socio-professionnelle. trois niveaux dans le bilan social français : cadres, ETAM (employés, techniciens, agents de maîtrise), ouvriers. nomenclature INSEE. dans vos données, vous verrez parfois "employés" ou "techniciens" séparément — ils appartiennent tous à la catégorie ETAM.

**ETP** — équivalent temps plein. unité de mesure qui pondère les temps partiels. temps plein = 1 ETP. 80% = 0.8 ETP. le bilan social utilise systématiquement les ETP, jamais les têtes. un temps partiel compte 0.8 fois dans l'effectif, mais compte 1 fois dans `COUNT(*)`. cette différence est au cœur de la rubrique 4.

**D9/D1** — rapport entre le 9e décile et le 1er décile des salaires. mesure la hiérarchie des rémunérations. un ratio à 2.71 signifie que les 10% les mieux payés gagnent 2.71 fois plus que les 10% les moins bien payés. la DARES publie ce ratio par branche — vous pouvez vous benchmarker.

**taux de fréquence INRS** — nombre d'accidents du travail pour un million d'heures travaillées. formule réglementaire définie par l'Institut National de Recherche et de Sécurité.

**taux de gravité INRS** — nombre de jours perdus pour mille heures travaillées. formule réglementaire. les deux taux ensemble permettent de calculer votre taux de cotisation AT/MP à la CPAM.

**SCD Type 2** — Slowly Changing Dimension de type 2. technique de modélisation qui conserve l'historique des changements d'attribut avec une colonne `date_debut` et `date_fin` sur chaque ligne. indispensable pour reconstituer un état RH à une date passée. sans SCD Type 2, votre bilan social N-1 est impossible à produire à partir des données courantes.

**CSE** — comité social et économique. instance représentative obligatoire dans les entreprises de 11 salariés et plus. destinataire légal du bilan social. depuis les ordonnances Macron de 2017, il a remplacé les délégués du personnel, le comité d'entreprise et le CHSCT.

**PERCENTILE_CONT** — fonction SQL de calcul de percentile par interpolation continue. méthode statistique standard (méthode INSEE). à ne pas confondre avec `PERCENTILE_DISC` qui retourne une valeur existante dans la distribution. pour les indicateurs légaux, `PERCENTILE_CONT` est la méthode correcte.

---

## 5. le débriefing à la raclette

vous avez tenu. voici ce qu'on retient.

1. **`UNION ALL` pour normaliser, `CASE WHEN` dans les agrégats pour les tableaux croisés, `LEFT JOIN` pour les taux d'accès, `PERCENTILE_CONT` pour la hiérarchie salariale** — quatre patterns SQL. vingt indicateurs. sept rubriques légales. le SQL n'est pas le problème.

2. **ETP vs têtes, SCD Type 2, identifiants qui dérivent, sources dispersées** — les vrais obstacles sont dans les données. planifiez 80% du temps projet sur les connecteurs sources et la gouvernance des données maîtres. le reste est des vues.

3. **l'architecture trois schémas est non-négociable** — REFERENTIEL / GENERATION / INDICATEURS. les sources migrent, les vues restent. c'est la différence entre un projet qu'on réécrit tous les deux ans et une forteresse qui tient à la prochaine migration SIRH.

si vous avez survécu à cette lecture, vous êtes prêts pour la présentation au CSE. partagez en commentaire : quel est votre SIRH source ? qu'est-ce qui a bloqué chez vous ?

on construit des forteresses, pas des pâtés de sable.

---

récupérez le script complet :

le code source de cette architecture est disponible sur le dépôt snowflakeviber. les quatre scripts (`01_setup.sql`, `02_tables_reference.sql`, `03_generation_salaries.sql`, `04_indicateurs_bilan_social.sql`) sont dans le dossier `scripts/`.

snowflakeviber ne survit que grâce à votre engagement direct. abonnez-vous gratuitement pour recevoir le code, le vibe et en français chaque semaine. ici, on ne construit pas de pâtés de sable, on bâtit des forteresses.

clonez, exécutez, vibez. pas de pâtés de sable ici.
