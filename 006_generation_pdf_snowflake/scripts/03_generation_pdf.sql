-- --------------------------------------------------------------------------------------------------------------------
-- 03_generation_pdf.sql
--
-- Génère les PDF à partir de la table simili_cartes_grises_data.
-- UDF Python (fpdf) + COPY FILES vers le stage documents_cartes_grises.
-- Les PDF peuvent ensuite servir d'input au pipeline OCR (005_cortex_ocr_ai_extract).
-- Prérequis : 02_generation_donnees.sql exécuté.
-- --------------------------------------------------------------------------------------------------------------------

use database SNOW_VIBER_OCR_005;
use schema raw_data;
use warehouse SNOW_VIBER_WH;

-- =============================================================================
-- 1. UDF Python : une partition = un PDF
-- =============================================================================

create or replace function create_simili_carte_grise_pdf(row_json string)
returns table (file string)
language python
runtime_version = '3.12'
packages = ('snowflake-snowpark-python', 'fpdf')
handler = 'CreateSimiliPdf'
as $$
from snowflake.snowpark.files import SnowflakeFile
from fpdf import FPDF
import json

class CreateSimiliPdf:
    def __init__(self):
        self.row = None

    def process(self, row_json):
        self.row = json.loads(row_json)

    def end_partition(self):
        pdf = FPDF()
        pdf.add_page()
        pdf.set_font('Helvetica', '', 10)
        pdf.cell(0, 8, 'SIMILI CARTE GRISE (demonstration)', ln=True)
        pdf.ln(4)
        for label, key in [
            ('Immatriculation', 'immatriculation'),
            ('Nom titulaire', 'nom_titulaire'),
            ('Prenom titulaire', 'prenom_titulaire'),
            ('Adresse', 'adresse'),
            ('Marque', 'marque'),
            ('Genre', 'genre'),
            ('Date 1ere immat.', 'date_premiere_immat'),
        ]:
            val = self.row.get(key, '')
            pdf.cell(50, 6, label + ':', ln=False)
            pdf.cell(0, 6, str(val), ln=True)
        f = SnowflakeFile.open_new_result('wb')
        f.write(pdf.output(dest='S').encode('latin-1'))
        yield f,
$$;

-- =============================================================================
-- 2. COPY FILES : UDF → stage
-- =============================================================================

copy files into @documents_cartes_grises
from (
    select
        reports.file,
        'simili_' || s.immatriculation || '.pdf'
    from simili_cartes_grises_data s,
         table(
             create_simili_carte_grise_pdf(
                 object_construct(
                     'immatriculation', s.immatriculation,
                     'nom_titulaire', s.nom_titulaire,
                     'prenom_titulaire', s.prenom_titulaire,
                     'adresse', s.adresse,
                     'marque', s.marque,
                     'genre', s.genre,
                     'date_premiere_immat', s.date_premiere_immat
                 )::string
             ) over (partition by s.immatriculation)
         ) as reports
);

-- =============================================================================
-- 3. Vérification : liste des PDF générés
-- =============================================================================

alter stage documents_cartes_grises refresh;
list @documents_cartes_grises;
