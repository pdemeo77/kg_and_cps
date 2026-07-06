# Knowledge Graph e Cyber-Physical Systems in Sanità

**Corso per Scuola di Dottorato** · 3 ore (1.5 teoria + 1.5 esercitazione)

[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)

## 🎯 Obiettivi di Apprendimento

Al termine di questa lezione, i dottorandi saranno in grado di:

1. **Comprendere** i fondamenti teorici dei Knowledge Graph e il loro ruolo come ponte semantico tra sistemi eterogenei
2. **Analizzare** architetture che integrano CPS/IoT sanitario e KG per applicazioni cliniche
3. **Implementare** un mini-KG per un caso di studio di Patient Digital Twin
4. **Valutare criticamente** le direzioni di ricerca attuali e identificare gap per tesi di dottorato

## 🗓️ Programma

### Parte 1: Teoria (90 minuti)

| Sezione | Contenuto | Durata |
|---------|-----------|--------|
| **1. KG Fundamentals** | Definizione, confronto con DB, ontologie, pipeline di costruzione | 25 min |
| **2. KG + CPS in Sanità** | Survey bibliografica su Digital Twin, IoT, AI reasoning | 45 min |
| **3. Bridge to Lab** | Architettura del caso di studio, setup, dataset | 20 min |

### Parte 2: Esercitazione Pratica (90 minuti)

- **Caso di Studio**: Patient Digital Twin per Monitoraggio Cardiaco
- Costruzione di un KG con Python (`rdflib`)
- Query SPARQL per inferenze cliniche
- Esercizi guidati e discussione

## 🚀 Quick Start

### Per gli Studenti

```bash
# Clona il repository
git clone https://github.com/TUO-USERNAME/phd-course-kg-cps-healthcare.git
cd phd-course-kg-cps-healthcare

# Crea ambiente Python
python3.11 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Installa dipendenze
pip install -r requirements.txt

# Apri il notebook del laboratorio
jupyter lab lab/notebook/student-lab.ipynb