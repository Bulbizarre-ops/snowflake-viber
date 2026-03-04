-- ============================================================================
-- 02_tables_reference.sql
-- Tables de référence métier pour la génération de données RH réalistes
-- ============================================================================

USE DATABASE SNOW_VIBER_BILAN_007;
USE SCHEMA REFERENTIEL;

-- ============================================================================
-- PRÉNOMS MULTICULTURELS (diversité française)
-- Pondération : répétition des valeurs = probabilité de sélection
-- ============================================================================
CREATE OR REPLACE TABLE ref_prenoms (
    prenom VARCHAR(50),
    genre VARCHAR(1)  -- H = Homme, F = Femme
);

INSERT INTO ref_prenoms (prenom, genre) VALUES
    -- Prénoms masculins français classiques (fréquents)
    ('Thomas', 'H'), ('Nicolas', 'H'), ('Julien', 'H'), ('David', 'H'),
    ('Pierre', 'H'), ('Alexandre', 'H'), ('Guillaume', 'H'), ('François', 'H'),
    ('Mathieu', 'H'), ('Antoine', 'H'), ('Sébastien', 'H'), ('Laurent', 'H'),
    ('Christophe', 'H'), ('Frédéric', 'H'), ('Olivier', 'H'), ('Philippe', 'H'),
    ('Maxime', 'H'), ('Romain', 'H'), ('Vincent', 'H'), ('Jérôme', 'H'),
    -- Prénoms masculins maghrébins
    ('Mohamed', 'H'), ('Ahmed', 'H'), ('Karim', 'H'), ('Mehdi', 'H'),
    ('Youssef', 'H'), ('Samir', 'H'), ('Rachid', 'H'), ('Omar', 'H'),
    -- Prénoms masculins d'origine africaine
    ('Mamadou', 'H'), ('Ibrahima', 'H'), ('Moussa', 'H'), ('Abdoulaye', 'H'),
    -- Prénoms masculins d'origine asiatique
    ('Wei', 'H'), ('Hiro', 'H'), ('Vinh', 'H'), ('Kenji', 'H'),
    -- Prénoms masculins d'origine portugaise/espagnole
    ('Carlos', 'H'), ('José', 'H'), ('Antonio', 'H'), ('Miguel', 'H'),
    -- Prénoms féminins français classiques (fréquents)
    ('Marie', 'F'), ('Sophie', 'F'), ('Nathalie', 'F'), ('Isabelle', 'F'),
    ('Céline', 'F'), ('Sandrine', 'F'), ('Valérie', 'F'), ('Stéphanie', 'F'),
    ('Aurélie', 'F'), ('Émilie', 'F'), ('Julie', 'F'), ('Camille', 'F'),
    ('Pauline', 'F'), ('Marine', 'F'), ('Charlotte', 'F'), ('Laure', 'F'),
    ('Caroline', 'F'), ('Hélène', 'F'), ('Anne', 'F'), ('Claire', 'F'),
    -- Prénoms féminins maghrébins
    ('Fatima', 'F'), ('Amina', 'F'), ('Leïla', 'F'), ('Samira', 'F'),
    ('Nadia', 'F'), ('Karima', 'F'), ('Yasmina', 'F'), ('Zineb', 'F'),
    -- Prénoms féminins d'origine africaine
    ('Aïssatou', 'F'), ('Mariama', 'F'), ('Fatoumata', 'F'), ('Aminata', 'F'),
    -- Prénoms féminins d'origine asiatique
    ('Mei', 'F'), ('Yuki', 'F'), ('Linh', 'F'), ('Sakura', 'F'),
    -- Prénoms féminins d'origine portugaise/espagnole
    ('Maria', 'F'), ('Ana', 'F'), ('Carmen', 'F'), ('Lucia', 'F');

-- ============================================================================
-- NOMS DE FAMILLE (diversité française)
-- ============================================================================
CREATE OR REPLACE TABLE ref_noms (
    nom VARCHAR(50)
);

INSERT INTO ref_noms (nom) VALUES
    -- Noms français classiques
    ('Martin'), ('Bernard'), ('Dubois'), ('Thomas'), ('Robert'),
    ('Richard'), ('Petit'), ('Durand'), ('Leroy'), ('Moreau'),
    ('Simon'), ('Laurent'), ('Lefebvre'), ('Michel'), ('Garcia'),
    ('David'), ('Bertrand'), ('Roux'), ('Vincent'), ('Fournier'),
    ('Morel'), ('Girard'), ('André'), ('Mercier'), ('Dupont'),
    ('Lambert'), ('Bonnet'), ('François'), ('Martinez'), ('Legrand'),
    -- Noms d'origine maghrébine
    ('Benali'), ('Bensaid'), ('Hadj'), ('Bouaziz'), ('Kaddour'),
    ('Amrani'), ('Belkacem'), ('Cherif'), ('Hamidi'), ('Zidane'),
    -- Noms d'origine africaine
    ('Diallo'), ('Traoré'), ('Diop'), ('Ndiaye'), ('Sow'),
    ('Camara'), ('Konaté'), ('Cissé'), ('Touré'), ('Ba'),
    -- Noms d'origine asiatique
    ('Nguyen'), ('Tran'), ('Wang'), ('Chen'), ('Li'),
    ('Yamamoto'), ('Tanaka'), ('Suzuki'), ('Pham'), ('Le'),
    -- Noms d'origine portugaise/espagnole
    ('Ferreira'), ('Santos'), ('Silva'), ('Costa'), ('Oliveira'),
    ('Rodriguez'), ('Fernandez'), ('Lopez'), ('Gonzalez'), ('Perez');

-- ============================================================================
-- POSTES ET CATÉGORIES SOCIO-PROFESSIONNELLES (CSP)
-- Distribution cible : 20% cadres, 50% ETAM, 30% ouvriers
-- Pondération par répétition dans la table
-- ============================================================================
CREATE OR REPLACE TABLE ref_postes (
    id_poste INT,
    libelle_poste VARCHAR(100),
    categorie_csp VARCHAR(20),       -- CADRE, ETAM, OUVRIER
    salaire_min INT,
    salaire_max INT,
    poids INT DEFAULT 1              -- Pour pondérer la distribution
);

INSERT INTO ref_postes (id_poste, libelle_poste, categorie_csp, salaire_min, salaire_max, poids) VALUES
    -- CADRES (20% de l'effectif) - 10 postes x poids 2 = 20 unités
    (1, 'Directeur général', 'CADRE', 120000, 200000, 1),
    (2, 'Directeur financier', 'CADRE', 90000, 150000, 1),
    (3, 'Directeur commercial', 'CADRE', 85000, 140000, 1),
    (4, 'Directeur technique', 'CADRE', 85000, 140000, 1),
    (5, 'Directeur RH', 'CADRE', 80000, 130000, 1),
    (6, 'Responsable département', 'CADRE', 55000, 85000, 3),
    (7, 'Chef de projet', 'CADRE', 45000, 70000, 4),
    (8, 'Ingénieur senior', 'CADRE', 50000, 75000, 4),
    (9, 'Responsable qualité', 'CADRE', 48000, 72000, 2),
    (10, 'Contrôleur de gestion', 'CADRE', 45000, 68000, 3),
    
    -- ETAM (50% de l'effectif) - poids total = 50 unités
    (11, 'Technicien informatique', 'ETAM', 28000, 42000, 5),
    (12, 'Comptable', 'ETAM', 30000, 45000, 5),
    (13, 'Assistant commercial', 'ETAM', 26000, 38000, 5),
    (14, 'Technicien méthodes', 'ETAM', 29000, 43000, 4),
    (15, 'Chargé de clientèle', 'ETAM', 27000, 40000, 5),
    (16, 'Assistant RH', 'ETAM', 26000, 38000, 4),
    (17, 'Technicien maintenance', 'ETAM', 28000, 42000, 5),
    (18, 'Gestionnaire paie', 'ETAM', 30000, 44000, 4),
    (19, 'Technicien qualité', 'ETAM', 28000, 41000, 4),
    (20, 'Assistant administratif', 'ETAM', 24000, 35000, 5),
    (21, 'Dessinateur industriel', 'ETAM', 29000, 43000, 4),
    
    -- OUVRIERS (30% de l'effectif) - poids total = 30 unités
    (22, 'Opérateur de production', 'OUVRIER', 22000, 30000, 8),
    (23, 'Cariste', 'OUVRIER', 23000, 31000, 5),
    (24, 'Manutentionnaire', 'OUVRIER', 21500, 28000, 6),
    (25, 'Conducteur de ligne', 'OUVRIER', 25000, 34000, 4),
    (26, 'Agent de maintenance', 'OUVRIER', 24000, 33000, 4),
    (27, 'Magasinier', 'OUVRIER', 22500, 30000, 3);

-- Table dénormalisée pour tirage pondéré (astuce GENERATOR)
CREATE OR REPLACE TABLE ref_postes_pondere AS
SELECT p.*
FROM ref_postes p,
     LATERAL FLATTEN(SPLIT(REPEAT(',', p.poids - 1), ',')) AS ponderation;

-- ============================================================================
-- ÉTABLISSEMENTS (sites géographiques)
-- ============================================================================
CREATE OR REPLACE TABLE ref_etablissements (
    id_etablissement INT,
    nom_etablissement VARCHAR(100),
    ville VARCHAR(50),
    region VARCHAR(50),
    effectif_cible INT,
    poids INT DEFAULT 1
);

INSERT INTO ref_etablissements (id_etablissement, nom_etablissement, ville, region, effectif_cible, poids) VALUES
    (1, 'Siège social', 'Paris', 'Île-de-France', 150, 30),
    (2, 'Centre RetD', 'Lyon', 'Auvergne-Rhône-Alpes', 80, 16),
    (3, 'Usine Nord', 'Lille', 'Hauts-de-France', 120, 24),
    (4, 'Usine Sud', 'Marseille', 'Provence-Alpes-Côte d''Azur', 100, 20),
    (5, 'Agence commerciale Ouest', 'Nantes', 'Pays de la Loire', 50, 10);

-- Table dénormalisée pour tirage pondéré
CREATE OR REPLACE TABLE ref_etablissements_pondere AS
SELECT e.*
FROM ref_etablissements e,
     LATERAL FLATTEN(SPLIT(REPEAT(',', e.poids - 1), ',')) AS ponderation;

-- ============================================================================
-- MOTIFS DE DÉPART (pour le turnover)
-- ============================================================================
CREATE OR REPLACE TABLE ref_motifs_depart (
    id_motif INT,
    libelle_motif VARCHAR(100),
    categorie VARCHAR(50),
    poids INT DEFAULT 1
);

INSERT INTO ref_motifs_depart (id_motif, libelle_motif, categorie, poids) VALUES
    (1, 'Démission', 'VOLONTAIRE', 40),
    (2, 'Licenciement économique', 'INVOLONTAIRE', 10),
    (3, 'Licenciement faute', 'INVOLONTAIRE', 5),
    (4, 'Rupture conventionnelle', 'NEGOCIEE', 25),
    (5, 'Fin CDD', 'FIN_CONTRAT', 15),
    (6, 'Retraite', 'RETRAITE', 5);

CREATE OR REPLACE TABLE ref_motifs_depart_pondere AS
SELECT m.*
FROM ref_motifs_depart m,
     LATERAL FLATTEN(SPLIT(REPEAT(',', m.poids - 1), ',')) AS ponderation;

-- ============================================================================
-- TYPES DE FORMATION
-- ============================================================================
CREATE OR REPLACE TABLE ref_formations (
    id_formation INT,
    libelle_formation VARCHAR(200),
    domaine VARCHAR(50),
    duree_heures INT,
    cout_moyen INT,
    poids INT DEFAULT 1
);

INSERT INTO ref_formations (id_formation, libelle_formation, domaine, duree_heures, cout_moyen, poids) VALUES
    -- Sécurité (obligatoire)
    (1, 'Habilitation électrique', 'SECURITE', 14, 450, 15),
    (2, 'SST - Sauveteur Secouriste du Travail', 'SECURITE', 14, 300, 20),
    (3, 'CACES cariste', 'SECURITE', 21, 800, 10),
    (4, 'Gestes et postures', 'SECURITE', 7, 200, 15),
    -- Métier
    (5, 'Excel avancé', 'BUREAUTIQUE', 14, 500, 12),
    (6, 'Management d''équipe', 'MANAGEMENT', 21, 1500, 8),
    (7, 'Gestion de projet', 'MANAGEMENT', 14, 1200, 6),
    (8, 'Anglais professionnel', 'LANGUES', 40, 2000, 8),
    -- Technique
    (9, 'Maintenance préventive', 'TECHNIQUE', 21, 900, 6);

CREATE OR REPLACE TABLE ref_formations_pondere AS
SELECT f.*
FROM ref_formations f,
     LATERAL FLATTEN(SPLIT(REPEAT(',', f.poids - 1), ',')) AS ponderation;

-- ============================================================================
-- GRILLE SALARIALE PAR ANCIENNETÉ
-- Coefficient multiplicateur du salaire de base selon ancienneté
-- ============================================================================
CREATE OR REPLACE TABLE ref_coeff_anciennete (
    annees_anciennete_min INT,
    annees_anciennete_max INT,
    coefficient DECIMAL(3,2)
);

INSERT INTO ref_coeff_anciennete VALUES
    (0, 1, 1.00),
    (2, 4, 1.05),
    (5, 9, 1.12),
    (10, 14, 1.20),
    (15, 19, 1.28),
    (20, 24, 1.35),
    (25, 40, 1.42);

-- ============================================================================
-- TYPES DE CONTRAT
-- ============================================================================
CREATE OR REPLACE TABLE ref_types_contrat (
    id_contrat INT,
    libelle VARCHAR(50),
    poids INT
);

INSERT INTO ref_types_contrat VALUES
    (1, 'CDI', 75),
    (2, 'CDD', 20),
    (3, 'Alternance', 5);

CREATE OR REPLACE TABLE ref_types_contrat_pondere AS
SELECT c.*
FROM ref_types_contrat c,
     LATERAL FLATTEN(SPLIT(REPEAT(',', c.poids - 1), ',')) AS ponderation;

-- ============================================================================
-- VÉRIFICATION DES DISTRIBUTIONS
-- ============================================================================
SELECT 'Postes par CSP' AS verification,
       categorie_csp,
       COUNT(*) AS nb_lignes,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM ref_postes_pondere
GROUP BY categorie_csp
ORDER BY categorie_csp;

SELECT 'Établissements' AS verification,
       nom_etablissement,
       COUNT(*) AS poids_effectif
FROM ref_etablissements_pondere
GROUP BY nom_etablissement
ORDER BY poids_effectif DESC;
