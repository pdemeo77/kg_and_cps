# Laboratorio — Costruire un Knowledge Graph per un Patient Digital Twin cardiaco
## Guida e spiegazione dell'esercitazione ( Parte 2 della lezione)

> Documento di accompagnamento al laboratorio in `lab/` (README + `student-lab.ipynb`). Spiega in italiano, passo per passo, l'esercitazione hands-on di 90 minuti, **e riporta in fondo una verifica della riproducibilità** (con due bug individuati durante l'esecuzione e i relativi fix).

---

## Sommario

1. [Obiettivi e caso clinico](#1-obiettivi-e-caso-clinico)
2. [Stack tecnico e setup](#2-stack-tecnico-e-setup)
3. [I tre dataset](#3-i-tre-dataset)
4. [L'ontologia `healthcare_cardio.ttl`](#4-lontologia-healthcare_cardiottl)
5. [Fase 2 — Costruire il Knowledge Graph](#5-fase-2--costruire-il-knowledge-graph)
6. [Fase 3 — Query SPARQL e inferenza clinica](#6-fase-3--query-sparql-e-inferenza-clinica)
7. [Fase 4 — Esercizi guidati](#7-fase-4--esercizi-guidati)
8. [Collegamento con la teoria (Parte 1)](#8-collegamento-con-la-teoria-parte-1)
9. [Estensioni opzionali](#9-estensioni-opzionali)
10. [⚠️ Verifica della riproducibilità e bug individuati](#10--verifica-della-riproducibilità-e-bug-individuati)

---

## 1. Obiettivi e caso clinico

### Il caso
Sei il **knowledge engineer** di un reparto di cardiologia che sta sperimentando un **Patient Digital Twin (PDT)**. Il reparto ha tre fonti dati disconnesse:

- un **ECG wearable** che streamma frequenza cardiaca e ritmo (JSON);
- l'**EHR** con demografia, diagnosi e terapie croniche (CSV);
- un **log di eventi clinici**: ricoveri, esami di laboratorio, variazioni di terapia (CSV).

Il team clinico vuole che il twin risponda a domande che nessuna fonte, da sola, può soddisfare, ad esempio:

> *"Quali pazienti con fibrillazione atriale assumono due farmaci che interagiscono tra loro e hanno una lettura di tachicardia recente?"*

L'esercitazione costruisce il KG che rende questa domanda risolvibile con **una singola query**.

### Obiettivi di apprendimento
- Caricare dati clinici eterogenei (JSON/CSV) con **Pandas** e mapparli in triple RDF.
- Costruire, serializzare e validare un **Knowledge Graph** con `rdflib`.
- Scrivere ed eseguire **SPARQL** con `FILTER`, join tra fonti e `DISTINCT`.
- Visualizzare un KG con **NetworkX + Matplotlib** (sottografo ego).
- Estendere un'**ontologia OWL** via codice.

### Istantaneizzazione della teoria
| Concetto della Parte 1 | Dove appare nel lab |
|---|---|
| **Dati (A-box)** | I record CSV/JSON → triple RDF |
| **Schema (T-box)** | `healthcare_cardio.ttl` — classi e proprietà |
| **Inferenza / ragionamento** | `interactsWith` come `SymmetricProperty` |
| **Vocabolari standard** | SNOMED CT (diagnosi) + LOINC (osservazioni) + HL7 FHIR (allineamento) |
| **Ponte sull'eterogeneità** | JSON + CSV + Turtle fusi in un unico `rdflib.Graph` |

---

## 2. Stack tecnico e setup

| Libreria | Versione | Ruolo |
|---|---|---|
| Python | 3.11+ | runtime |
| rdflib | ≥ 7.0 | manipolazione RDF/OWL, motore SPARQL |
| pandas | ≥ 2.2 | caricamento/trasformazione dei CSV |
| NetworkX | ≥ 3.3 | analisi e layout del grafo |
| Matplotlib | ≥ 3.9 | rendering delle visualizzazioni |

**Setup (come da README):**
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install "rdflib>=7.0" "pandas>=2.2" "networkx>=3.3" "matplotlib>=3.9" "jupyterlab>=4.0"
jupyter lab
```
Aprire `student-lab.ipynb` ed eseguire le celle dall'alto verso il basso.

---

## 3. I tre dataset

Tutti i dati sono **simulati ma clinicamente coerenti**: gli stessi 20 `patient_id` (`P001`–`P020`) appaiono in tutti i file; diagnosi, farmaci e reperti ECG sono allineati; le date cadono tutte nel 2024. In produzione questi dati arriverebbero da API FHIR e gateway di dispositivo.

| Dataset | File | Record | Pazienti | Periodo |
|---|---|---|---|---|
| ECG wearable | `ecg_data.json` | 100 | 20 | 09–14 mar 2024 |
| Storia clinica | `clinical_history.csv` | 20 | 20 | baseline |
| Eventi clinici | `clinical_events.csv` | 50 | 20 | feb–mar 2024 |

### `clinical_history.csv` — scheda paziente permanente
Campi: `patient_id`, `name`, `age`, `sex`, `diagnoses` (codici **SNOMED CT** separati da `;`), `medications` (nomi farmaci separati da `;`). Esempio:
```csv
P006,Paolo Greco,59,M,62709007,Amiodarone;Digoxin
```
`P006` ha **aritmia cardiaca** (62709007) ed è in terapia con **Amiodarone + Digoxin**.

### `ecg_data.json` — stream ECG wearable
Ogni record: `record_id`, `patient_id`, `timestamp` (ISO-8601), `heart_rate` (LOINC 8867-4), `qrs_ms`, `qt_ms`, `rhythm`. Esempio:
```json
{"record_id":"ECG-026","patient_id":"P006","timestamp":"2024-03-09T08:05:00",
 "heart_rate":118,"qrs_ms":88,"qt_ms":520,"rhythm":"Atrial fibrillation"}
```
`P006` ha **QT = 520 ms** mentre assume Amiodarone + Digoxin: un "flag" pro-aritmico deliberatamente realistico che gli studenti devono saper estrarre con una query.

### `clinical_events.csv` — log eventi episodico
Campi: `event_id`, `patient_id`, `event_date`, `event_type` (`admission`/`lab_test`/`medication_change`), `concept_code` (polimorfo: SNOMED CT per i ricoveri, **LOINC** per i lab, nome farmaco per i cambi), `value`, `unit`, `severity`. Esempio:
```csv
E001,P001,2024-03-09,lab_test,8480-6,158,mmHg,moderate
```
Pressione sistolica (LOINC 8480-6) = 158 mmHg per `P001`.

> **Verifica della riproducibilità dei dati:** i tre file sono la "single source of truth" prodotta dallo script `generate_data.ps1`. L'ho verificato per ispezione: lo script è deterministico e rigenera esattamente i file presenti (20 pazienti, 100 ECG = 20×5, 50 eventi = 40 lab + 10 extra).

---

## 4. L'ontologia `healthcare_cardio.ttl`

Il file Turtle definisce lo **schema (T-box)** più le **istanze di codice e interazioni**. È scritto in **OWL** e allinea l'ontologia locale `cardio:` agli standard.

### Namespace
| Prefisso | URI | Ruolo |
|---|---|---|
| `cardio:` | `http://example.org/cardio#` | ontologia locale del lab |
| `snomed:` | `http://snomed.info/id/` | SNOMED CT (concetti clinici) |
| `loinc:` | `http://loinc.org/` | LOINC (osservazioni) |
| `fhir:` | `http://hl7.org/fhir/` | allineamento HL7 FHIR |

### Classi principali
`Patient` (sottoclasse di `fhir:Patient`), `WearableSensor`, `ECGMeasurement`, `ClinicalEvent`, `Diagnosis`, `Drug`.

### Proprietà oggetto (relazioni tra entità)
`hasDiagnosis`, `monitoredBy`, `hasEvent`, `takes`, `produced` e soprattutto **`interactsWith`**, dichiarata come `owl:ObjectProperty, owl:SymmetricProperty`: se il farmaco A interagisce con B, allora anche B interagisce con A (relazione simmetrica clinicamente corretta).

### Proprietà datatype (valori letterali)
`hasHeartRate` (intero), `hasQTDuration` (intero), `hasRhythm` (stringa), `hasTimestamp` (dateTime), `hasValue` (double), `hasAge` (intero), ecc.

### Codici reali usati
- **SNOMED CT** (≥7): 49436004 (fibrillazione atriale), 84114007 (scompenso cardiaco), 22298006 (infarto miocardico acuto), 38341003 (ipertensione), 73211009 (diabete), 62709007 (aritmia cardiaca), 48694002 (angina).
- **LOINC** (3): 8867-4 (frequenza cardiaca), 8480-6 (pressione sistolica), 8462-4 (pressione diastolica).
- I farmaci usano il namespace locale `cardio:` (in produzione si mapperebbero a **RxNorm**; nel lab si evitano codici SNOMED finti per i farmaci).

### Interazioni farmaco-farmaco (dichiarate una sola volta, simmetriche)
```
Warfarin – Amiodarone      (INR ↑ / sanguinamento)
Warfarin – Aspirin         (sanguinamento)
Digoxin – Amiodarone       (tossicità da digossina)
Digoxin – Furosemide       (ipokaliemia → tossicità)
Ramipril – Spironolactone  (iperkaliemia)
Metoprolol – Amiodarone    (bradicardia)
```

> **Esempio di triple di istanza (A-box)** generate nella Fase 2 — vedi `§5` del README e la sua sezione 5.8.

---

## 5. Fase 2 — Costruire il Knowledge Graph

Il cuore del lab è la trasformazione **CSV/JSON → triple RDF**. Il codice (presente sia nel README §6.1 che nel notebook) fa tre blocchi:

1. **Storia clinica →** per ogni paziente aggiunge `rdf:type`, nome, età, sesso, le diagnosi (URI SNOMED) e i farmaci (URI `cardio:`).
2. **ECG wearable →** collega il paziente a un sensore (`monitoredBy`), e il sensore a ogni misurazione (`produced`), con frequenza cardiaca, QT, QRS, ritmo e timestamp.
3. **Eventi clinici →** collega ogni evento al paziente (`hasEvent`) con tipo, codice, valore, severità.

Verifica (dal notebook): `len(g) > 600` e i conteggi esatti **20 pazienti / 100 ECG / 50 eventi**. La serializzazione produce `cardiac_kg.ttl` (riapribile/ri-validabile).

### Visualizzazione ego
Un grafo da ~1300 triple disegnato intero è illeggibile ("hairball"). La buona pratica — ribadita dal README — è disegnare un **sottografo ego** di un solo paziente, raggio 1–2, con `nx.ego_graph(...)` e `spring_layout`.

---

## 6. Fase 3 — Query SPARQL e inferenza clinica

Il notebook propone quattro query di complessità crescente.

### Q1 — Pazienti con fibrillazione atriale (semplice)
Pattern: `?patient → rdf:type cardio:Patient → hasName → hasDiagnosis snomed:49436004`.
**Risultato atteso:** 8 pazienti — `P001, P004, P007, P009, P012, P014, P017, P020`.

### Q2 — Letture tachicardiche HR > 100 (con `FILTER` + `ORDER BY`)
**Risultato atteso:** 18 letture; in cima `P001` con HR=142, poi `P009` con 131, ecc.

### Q3 — Prolungamento del QT > 470 ms (flag pro-aritmico)
**Risultato atteso:** 5 letture, **tutte di `P006`** (QT 505–520 ms), in terapia con Amiodarone + Digoxin: il caso clinico deliberatamente "nascosto" nei dati.

### Q4 — FA + due farmaci che interagiscono (multi-fonte, complessa)
La query clinica centrale. **Risultato atteso** (3 pazienti, uno per coppia interagente):
| Paziente | Coppia interagente |
|---|---|
| `P007` | Digoxin + Furosemide |
| `P009` | Amiodarone + Warfarin |
| `P014` | Aspirin + Warfarin |

> ⚠️ **Attenzione:** come spiegato in [§10](#10--verifica-della-riproducibilità-e-bug-individuati), la query Q4 **così com'è scritta nel notebook/README non restituisce questi risultati** a causa di un bug sulla gestione della simmetria. Va corretta.

---

## 7. Fase 4 — Esercizi guidati

### Esercizio 1 (medio) — Estendere l'ontologia con un farmaco + interazione
Aggiungere `cardio:Sotalol` (anti-aritmico di classe III che prolunga il QT), asserirlo `interactsWith Amiodarone` (rischio QT additivo), assegnarlo a `Patient/P016` e verificare ri-eseguendo Q4. **Funziona correttamente** (verificato).

### Esercizio 2 (avanzato) — Query multi-criterio "a rischio"
Una sola query SPARQL che restituisca i pazienti che sono **(a)** in fibrillazione atriale, **(b)** in terapia con una coppia di farmaci interagenti, **(c)** con una lettura di tachicardia recente (HR > 100).
**Risultato atteso (corretto):** `P007, P009, P014`. ⚠️ Anche questa risente del bug di simmetria di Q4 (vedi §10).

### Esercizio 3 (aperto) — Proposta architetturale
In ≤3 slide, proporre un miglioramento concreto al lab partendo da un gap della Parte 1 (es. ingestion di un vero stream ECG; provenance/calibrazione dei sensori; federazione tra ospedali senza condividere i segnali grezzi). Nessuna risposta unica; valutato su chiarezza e fattibilità.

---

## 8. Collegamento con la teoria (Parte 1)

L'esercitazione materializza i pilastri teorici visti a lezione:

- **Il KG come "ponte semantico"**: dati sintatticamente ricchi (JSON/CSV) ma semanticamente poveri diventano interrogabili e confrontabili grazie all'ontologia.
- **Standard, non invenzioni**: SNOMED CT per le diagnosi, LOINC per le osservazioni, FHIR come spina dorsale di scambio — esattamente lo "stack ontologico" discusso a lezione.
- **Inferenza dallo schema**: la `SymmetricProperty` `interactsWith` è l'esempio più semplice di "fatti derivati" (se A interagisce con B, anche B con A).
- **Trade-off real-time vs ragionamento**: il lab lavora in batch su file; la domanda *"pazienti che sono diventati a rischio nelle ultime 24 h"* (prompt di discussione) introduce il problema della latenza del ragionamento, centrale nella Parte 1.

I **prompt di discussione per PhD** (README §9) spingono verso le RQ di ricerca: validità clinica dell'inferenza, quali relazioni sarebbero *pericolose* da modellare come simmetriche (es. `causes`), federazione con privacy.

---

## 9. Estensioni opzionali

- **Neo4j**: riversare le triple in un property graph e confrontare **Cypher** con **SPARQL** sulla stessa domanda clinica, discutendo la perdita di semantica ontologica.
- **ML di risk scoring**: esportare i feature vector dei pazienti (variabilità della FC, n. comorbidità, n. interazioni) per un classificatore di readmissione a 30 giorni, confrontando black-box vs regole.
- **LLM RAG clinico**: mettere il KG dietro uno SPARQL endpoint e far tradurre a un LLM domande in linguaggio naturale in SPARQL (text-to-SPARQL), valutando le allucinazioni sui codici mancanti.
- **KG federati e privacy**: dividere i pazienti tra due store `rdflib` e interrogare via `SERVICE`, esplorando cosa rivela un join federato sulla topologia del grafo.

---

## 10. ✅ Verifica della riproducibilità (bug individuati e corretti)

Ho eseguito l'intera pipeline in un ambiente pulito (Python 3.14.6, rdflib 7.6.0, pandas 3.0.3, networkx 3.6.1, matplotlib 3.11.0). La verifica ha individuato **due bug critici** che impedivano di ottenere i risultati documentati per Q1, Q4 e l'Esercizio 2. Entrambi sono stati **corretti** in `README.md` e `student-lab.ipynb`, e la **riesecuzione del notebook conferma ora tutti i risultati attesi**.

### ✅ Stato attuale (dopo le correzioni)
- Costruzione del KG: **1356 triple**, `cardiac_kg.ttl` scritto e riapribile.
- Asserzioni di validazione: **20 pazienti / 100 ECG / 50 eventi** ✓.
- **Q1** ora stampa i **nomi veri**: `P001 - Maria Rossi`, `P004 - Marco Ferrari`, … ✓.
- **Q2** (tachicardia, 18 letture) e **Q3** (QT>470, 5 letture tutte di P006) ✓.
- **Q4** ora restituisce `P007` (Digoxin+Furosemide), `P009` (Amiodarone+Warfarin), `P014` (Aspirin+Warfarin) ✓.
- **Esercizio 1** (aggiunta di Sotalol) ✓; **Esercizio 2** (a rischio) restituisce `P007, P009, P014` ✓.
- Dati coerenti e riproducibili da `generate_data.ps1` ✓.

### 🔧 Bug 1 (risolto) — i nomi dei pazienti venivano salvati come indici numerici

**Sintoma (prima del fix):** Q1 stampava `P001 - 0`, `P004 - 3`, `P007 - 6` … invece dei nomi ("Maria Rossi", …). I numeri `0,3,6,8,…` erano esattamente gli indici di riga dei pazienti nel DataFrame.

**Causa:** nella costruzione del grafo si usava `Literal(r.name)`, dove `r` è una `Series` di pandas ottenuta da `iterrows()`. In pandas **`Series.name` è l'etichetta della riga (l'indice), non il valore della colonna "name"**. (Confermato: `r.name` → `0`; `r["name"]` → `'Maria Rossi'`.)

**Correzione applicata** in `README.md` §6.1 e in `student-lab.ipynb` (cella Fase 2):
```python
# PRIMA (bug)
g.add((p, CARDIO.hasName, Literal(r.name)))
# DOPO  (corretto)
g.add((p, CARDIO.hasName, Literal(r["name"])))
```

### 🔧 Bug 2 (risolto) — Q4 ed Esercizio 2 non gestivano la simmetria di `interactsWith`

**Sintoma (prima del fix):** Q4 restituiva **solo `P007`**, mentre il README (§7.5 e §8) indicava `P009` (Amiodarone + Warfarin) e `P014` (Aspirin + Warfarin). Stesso difetto per l'Esercizio 2 (restituiva solo `P007` invece di `P007, P009, P014`).

**Causa:** `cardio:interactsWith` è dichiarata `owl:SymmetricProperty`, ma **`rdflib` non è un reasoner**: esegue solo pattern-matching, **non inferisce** la direzione inversa. Le interazioni sono salvate in una sola direzione (es. `Warfarin → Amiodarone`, ma non `Amiodarone → Warfarin`). Il filtro `str(?d1) < str(?d2)` richiede un ordinamento alfabetico; combinato con l'assenza del reverse, alcune coppie non matchavano mai. Il README §7.5 assumeva erroneamente che `FILTER(?d1 != ?d2)` bastasse.

**Correzione applicata** in `README.md` (§7.4, §7.5, §8 Esercizio 2) e in `student-lab.ipynb` (query Q4): il property-path `(^cardio:interactsWith|cardio:interactsWith)` matcha entrambe le direzioni senza reasoner.
```sparql
# PRIMA (bug: perde le coppie simmetriche)
?d1 cardio:interactsWith ?d2 .
FILTER(?d1 != ?d2 && str(?d1) < str(?d2))

# DOPO (corretto: gestisce la simmetria senza reasoner)
?d1 (^cardio:interactsWith|cardio:interactsWith) ?d2 .
FILTER(?d1 != ?d2 && str(?d1) < str(?d2))
```
*(Alternativa equivalente: aggiungere un reasoner come `owlrl`, ma non è tra le dipendenze dichiarate.)*

### 🔧 Bug 3 (minore, risolto) — verifica dell'Esercizio 1

L'Esercizio 1 assegna Sotalol a `Patient/P016`, ma **P016 non è in fibrillazione atriale**, quindi la vecchia istruzione "re-esegui Q4 per verificare la nuova coppia" non avrebbe mostrato nulla (Q4 filtra sulla FA). Corretto l'invito in `README.md` §8 e nel notebook: la verifica ora usa una **query generica sulle interazioni** (che ignora il filtro FA), coerentemente con la *lecturer solution* del README §8.

### Riepilogo (post-correzione)
| Componente | Stato |
|---|---|
| Setup / dipendenze | ✅ riproducibile |
| Costruzione KG + validazione conteggi | ✅ |
| Q1 (pazienti FA, con nomi reali) | ✅ |
| Q2, Q3 | ✅ |
| Q4 (FA + interazione) → P007, P009, P014 | ✅ |
| Esercizio 1 (Sotalol) | ✅ |
| Esercizio 2 (a rischio) → P007, P009, P014 | ✅ |
| Dati / `generate_data.ps1` | ✅ deterministici e coerenti |

**Conclusione:** dopo le tre correzioni, **il laboratorio è pienamente funzionante e riproducibile**: il notebook esegue dall'inizio alla fine senza errori e tutti i risultati clinici (Q1, Q4, Esercizio 2) coincidono con quanto documentato nel README. I fix sono piccoli e chirurgici; l'esecuzione di controllo è stata fatta con `jupyter nbconvert --execute`.

> **Nota per la pulizia del repository:** la Fase 2 genera `cardiac_kg.ttl` come deliverable; conviene aggiungere al `.gitignore` voci come `lab/cardiac_kg.ttl`, `lab/.venv/` e `__pycache__/` per evitare di committare artefatti rigenerabili.

---

*Spiegazione compilata a supporto del laboratorio in `lab/` — Parte 2 di "Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins in Healthcare."*
