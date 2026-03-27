-- ============================================================================
-- 01_archetypes.sql
-- Création de la table des archétypes psychographiques
-- ============================================================================
-- Auteur: Aymeric Veyron
-- Prérequis: Base de données et schéma existants
-- ============================================================================

-- Configuration (adapter selon votre environnement)
USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;

-- Création de la table des archétypes
CREATE OR REPLACE TABLE ARCHETYPES_PSYCHOGRAPHIQUES (
    id INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    phrase_identite VARCHAR(500),
    rapport_data VARCHAR(500),
    pression_ressentie VARCHAR(500),
    ressenti_quotidien VARCHAR(1000),
    declencheur_ouverture_livre VARCHAR(500),
    declencheur_fermeture_livre VARCHAR(500),
    declencheur_achat_prestation VARCHAR(500),
    formule_conversion VARCHAR(500),
    profils_reels_typiques VARCHAR(500),
    variables_generation VARCHAR(500)
);

-- Insertion des 7 archétypes
INSERT INTO ARCHETYPES_PSYCHOGRAPHIQUES VALUES
(1, 'Le Pilote à Vue', 
 'Je sais que quelque chose ne va pas, mais je ne sais pas quoi mesurer.',
 'Sceptique bienveillant. Ne rejette pas la data mais n''y croit pas encore pour lui.',
 'Inconfort diffus, chronique. Nuits difficiles sans raison précise identifiable.',
 'Il prend des décisions importantes avec des informations incomplètes. Il a l''intuition qu''il laisse de l''argent sur la table mais ne peut pas le prouver.',
 'Un titre de chapitre qui nomme exactement son problème. Il cherche une validation, pas une formation.',
 'Un graphique trop complexe dans les 3 premières pages. Une formule Excel à plus de 3 étapes.',
 'Un pair qui lui dit j''ai fait ça en deux jours et j''ai économisé X€.',
 'Preuve avant prescription. Il faut qu''il calcule lui-même un premier chiffre avec ses propres données.',
 'Dirigeant de commerce multi-sites, gérant de franchise, responsable d''une agence de services locaux.',
 'secteur (15+), taille entreprise (3-80 salariés), âge (35-60), niveau excel (basique à intermédiaire)'),

(2, 'Le Pompier Épuisé',
 'Je n''ai pas le temps de prendre du recul, j''éteins des incendies depuis 3 ans.',
 'Neutre à résistant. Il sait qu''il devrait mesurer. Mais chaque heure passée sur Excel est une heure de moins sur le vrai travail.',
 'Urgence perçue quasi-permanente. Jamais de crise franche, mais jamais de souffle.',
 'Ses équipes viennent le chercher en permanence. Il est le goulot d''étranglement de sa propre entreprise.',
 'La promesse d''un plan d''action express cette semaine. Il ne lira pas de bout en bout.',
 'Tout ce qui ressemble à un projet. Un délai de mise en œuvre > 2 semaines.',
 'Un moment de crise avec un impact financier chiffrable et immédiat.',
 'Rapidité + autonomie future. Il veut apprendre à pêcher, pas dépendre d''un prestataire.',
 'Responsable exploitation transport, chef d''atelier en industrie légère.',
 'pression saisonnière, taille équipe managée, type d''outil déjà en place'),

(3, 'Le Contrôleur Frustré',
 'J''ai les données, mais personne ne les utilise vraiment.',
 'Convaincu, parfois évangéliste en interne. Il souffre d''être en avance sur son organisation.',
 'Inconfort diffus mais très précis — c''est la frustration de voir du potentiel gâché.',
 'Il produit des tableaux que personne ne lit. Il est coincé entre la data qu''il maîtrise et le management qui n''en veut pas.',
 'La promesse d''un langage business pour envelopper ses chiffres.',
 'Trop de basics qu''il connaît déjà. Un ton trop condescendant envers les profils techniques.',
 'Il cherche un allié externe qui légitime ses recommandations internes.',
 'Co-construction visible. Il veut être reconnu comme expert, pas comme client passif.',
 'Contrôleur de gestion PME, responsable marketing avec accès CRM.',
 'niveau de séniorité, relation au dirigeant, outils maîtrisés'),

(4, 'Le Converti Récent',
 'J''ai eu mon déclic, maintenant je veux aller vite.',
 'Curieux → Convaincu en transition rapide. Vient de vivre une expérience transformante.',
 'Enthousiasme + urgence auto-imposée. Il veut capitaliser sur l''élan.',
 'Il parle de data à ses équipes, qui ne comprennent pas encore. Il a le risque du trop, trop vite.',
 'La structure en 20 cas d''usage priorisables. Il veut un backlog de projets data concrets.',
 'Si le livre ne lui donne pas d''ordre de priorité clair.',
 'Il veut un accompagnement au passage à l''échelle.',
 'Roadmap personnalisée. Ce profil est le plus prêt à investir significativement.',
 'Dirigeant qui revient d''un séminaire BPI, d''un club de dirigeants.',
 'déclencheur du déclic, ambition, budget disponible estimé'),

(5, 'Le Gardien du Temple',
 'On a toujours fait comme ça, et ça marche.',
 'Sceptique résistant. Hostile parce qu''il a vu trop de projets transformation digitale échouer.',
 'Confort relatif teinté d''inquiétude sourde face aux changements du marché.',
 'Son expérience terrain vaut de l''or. Sa résistance est rationnelle.',
 'La promesse de techniques pragmatiques. Pas la data — la promesse de résultat business.',
 'Le premier chapitre trop convaincu par avance. Il détecte la propagande data.',
 'Un concurrent qui le dépasse de façon visible. Une perte de client majeur.',
 'Preuve par l''exemple du secteur exact. Un cas client dans son métier précis.',
 'Dirigeant fondateur 50+, chef d''atelier expérimenté, gérant artisanal.',
 'âge et ancienneté, expérience passée avec des projets tech'),

(6, 'L''Humaniste des Équipes',
 'Je veux bien utiliser la data, mais pas pour fliquer mes équipes.',
 'Curieux mais éthiquement vigilant. Il croit au potentiel mais craint l''instrumentalisation.',
 'Inconfort lié à la gestion humaine — turnover, démotivation.',
 'Il doit prendre des décisions difficiles en s''appuyant sur des impressions subjectives.',
 'La tonalité bienveillante et les exemples où la data améliore la vie des équipes.',
 'Un exemple où la data sert à sanctionner ou à exclure.',
 'Un problème RH concret avec des conséquences financières visibles.',
 'Cadrage éthique explicite + co-construction avec les équipes.',
 'DRH ou RRH de PME, responsable d''équipe en structure sociale.',
 'taille de l''équipe managée, type de structure, rapport au management participatif'),

(7, 'Le Stratège en Construction',
 'Je veux professionnaliser ma boîte avant de lever des fonds ou de céder.',
 'Convaincu stratégiquement. La data est un actif qui valorise l''entreprise.',
 'Urgence liée à un horizon temporel précis (levée, cession, transmission).',
 'Il prend conscience que ses processus sont trop informels pour passer à l''échelle.',
 'La partie Aller plus loin. Il est intéressé par la trajectoire globale.',
 'Si le livre ne lui donne pas de vision systémique.',
 'Un audit data/maturité avant une levée ou une cession.',
 'Diagnostic + roadmap + livrables présentables à des tiers.',
 'Dirigeant en croissance rapide, entrepreneur qui prépare une cession.',
 'horizon temporel, maturité actuelle, nombre d''associés');

-- Vérification
SELECT id, nom, LEFT(phrase_identite, 60) AS phrase 
FROM ARCHETYPES_PSYCHOGRAPHIQUES 
ORDER BY id;
