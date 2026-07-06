# Practical Lab: Patient Digital Twin for Cardiac Monitoring

::: {.callout-note}
**Part 2 of the three-hour lecture** *"Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins in Healthcare."* This document is the **lecturer + student guide**: it is self-contained and lets any instructor run the 90-minute session with no extra preparation.
:::

---

## 1. Overview

| Item | Detail |
|---|---|
| **Title** | Building a knowledge graph for a cardiac patient digital twin |
| **Duration** | 90 minutes (hands-on) |
| **Audience** | PhD students with mixed backgrounds (clinicians, bioengineers, computer scientists) who have just completed Part 1 (KG fundamentals, literature, architectures) |
| **Prerequisites** | Basic Python; the Part 1 concepts of *nodes/edges, ontology (TBox), instances (ABox), inference*; familiarity with the `ttl`/`csv`/`json` formats |
| **Deliverable** | A working mini-KG in RDF/Turtle that integrates wearable-ECG, clinical-history and clinical-event data, queried with SPARQL to answer real cardiology questions |

### 1.1 Case study

You are the **knowledge engineer** for a cardiology ward piloting a **Patient Digital Twin (PDT)**. The ward runs three disconnected data sources:

- a **wearable ECG** that streams heart-rate + rhythm measurements (JSON),
- the **EHR** with demographics, diagnoses and chronic medications (CSV),
- a **clinical-event log** of admissions, lab tests and medication changes (CSV).

The clinical team wants the twin to answer questions a single source cannot, e.g.:

> *"Which patients with atrial fibrillation are taking two drugs that interact, and have a recent tachycardia reading?"*

You will build the KG that makes that question answerable by a single query.

### 1.2 Link to the theory (Part 1)

The lab instantiates every theoretical pillar introduced earlier:

| Part 1 concept | Where it appears in the lab |
|---|---|
| **Data (A-box)** | The CSV/JSON records → RDF triples in Phase 2 |
| **Schema (T-box)** | `healthcare_cardio.ttl` — classes & properties |
| **Inference / reasoning** | `interactsWith` as a `SymmetricProperty` → derived facts in Phase 3 |
| **Standard vocabularies** | SNOMED CT (diagnoses) + LOINC (observations) + HL7 FHIR (alignment) |
| **Heterogeneity bridge** | JSON + CSV + Turtle unified into one `rdflib.Graph` |

---

## 2. Learning Outcomes

By the end of the session a student will be able to:

**Technical skills (know-how)**
1. Load heterogeneous clinical data (JSON/CSV) with **Pandas** and map each record to RDF triples.
2. Build, serialise and validate a **knowledge graph** with `rdflib` (Turtle input/output).
3. Author and run **SPARQL** queries with `FILTER`, joins across sources and `DISTINCT`.
4. Visualise a KG locally with **NetworkX + Matplotlib** (ego/subgraph).
5. Extend an **OWL ontology** (add a class/property/instance) programmatically.

**Conceptual skills (knowledge)**
1. Explain why **standard codes** (SNOMED CT, LOINC) are required for semantic interoperability.
2. Distinguish **object** vs **datatype** properties and their effect on what can be reasoned.
3. Justify, on clinical grounds, when a derived fact (e.g. *drug–drug interaction risk*) is actionable.

**Future research seeds (PhD direction)**
1. Real-time incremental reasoning over **streaming** ECG data (the Part-1 *temporal-latency* problem).
2. **Federated, privacy-preserving** KGs so hospitals share inferences, not raw signals.
3. **Neuro-symbolic** risk scoring: embedding the KG + clinical rules for arrhythmia prediction.

---

## 3. Technical Stack

### 3.1 Libraries

| Library | Version | Purpose |
|---|---|---|
| Python | 3.11+ | Runtime |
| JupyterLab | 4.x | Interactive notebook environment |
| rdflib | ≥ 7.0 | RDF/OWL graph manipulation, SPARQL engine |
| pandas | ≥ 2.2 | Tabular load/transform of CSV history & events |
| NetworkX | ≥ 3.3 | Graph analysis & layout |
| Matplotlib | ≥ 3.9 | Rendering of graph visualisations |

### 3.2 Environment setup

```bash
# from the lab/ folder
python -m venv .venv

# --- Windows (PowerShell) ---
.venv\Scripts\Activate.ps1
# --- macOS / Linux ---
# source .venv/bin/activate

pip install --upgrade pip
pip install "rdflib>=7.0" "pandas>=2.2" "networkx>=3.3" "matplotlib>=3.9" "jupyterlab>=4.0"
jupyter lab
```

::: {.callout-tip}
Open `student-lab.ipynb` from the JupyterLab launcher. Keep this README open beside it as the step-by-step reference.
:::

### 3.3 Installation verification

Run this cell first; it must print all four versions without error:

```python
import sys
print("Python:", sys.version.split()[0])
import rdflib, pandas, networkx, matplotlib, IPython
for m in (rdflib, pandas, networkx, matplotlib, IPython):
    print(f"{m.__name__:12s} {m.__version__}")
```

Expected (versions may be newer):

```text
Python: 3.11.x
rdflib       7.x
pandas       2.2.x
networkx     3.3.x
matplotlib   3.9.x
IPython      8.x
```

::: {.callout-warning}
If `rdflib` is missing, the rest of the lab cannot run. Re-run the `pip install` command from §3.2.
:::

---

## 4. Dataset Description

All three files are **simulated** but **clinically consistent**: the same 20 `patient_id`s appear across files; diagnoses, drugs and ECG findings are coherent; timestamps fall on the same 2024 timeline. In production these would come from FHIR APIs and device gateways.

**Summary statistics**

| Dataset | File | Records | Patients | Period |
|---|---|---|---|---|
| Wearable ECG | `ecg_data.json` | 100 | 20 | 2024-03-09 → 2024-03-14 |
| Clinical history | `clinical_history.csv` | 20 | 20 | baseline (standing) |
| Clinical events | `clinical_events.csv` | 50 | 20 | 2024-02 → 2024-03 |

### 4.1 `clinical_history.csv` — standing patient record

**Schema**

| Field | Type | Description | Example |
|---|---|---|---|
| `patient_id` | string | Unique patient key (P001–P020) | `P001` |
| `name` | string | Pseudonymised name | `Maria Rossi` |
| `age` | int | Years | `68` |
| `sex` | string | `M` / `F` | `F` |
| `diagnoses` | string | SNOMED CT codes, **`;`-separated** | `49436004;38341003` |
| `medications` | string | Drug names, **`;`-separated** | `Warfarin;Metoprolol` |

**Clinical use cases enabled:** cohort selection by diagnosis, chronic-medication review, comorbidity counts.

**Example records** (6 of 20 — note the interacting-drug patients `P006`, `P009`, `P015`):

```csv
patient_id,name,age,sex,diagnoses,medications
P001,Maria Rossi,68,F,49436004;38341003,Warfarin;Metoprolol
P002,Giovanni Bianchi,72,M,84114007;38341003,Furosemide;Ramipril;Bisoprolol
P003,Lucia Conti,55,F,22298006,Atorvastatin;Aspirin;Bisoprolol
P006,Paolo Greco,59,M,62709007,Amiodarone;Digoxin
P009,Anna Bruno,80,F,49436004,Warfarin;Amiodarone
P015,Luca Costa,75,M,84114007;73211009,Spironolactone;Furosemide;Ramipril
```

### 4.2 `ecg_data.json` — wearable ECG stream

**Schema (per record)**

| Field | Type | Description | Example |
|---|---|---|---|
| `record_id` | string | Unique reading (`ECG-001`…) | `ECG-001` |
| `patient_id` | string | Foreign key → history | `P001` |
| `timestamp` | ISO-8601 | Acquisition time | `2024-03-10T08:05:00` |
| `heart_rate` | int | BPM (LOINC 8867-4) | `142` |
| `qrs_ms` | int | QRS duration (ms) | `98` |
| `qt_ms` | int | QT interval (ms) | `380` |
| `rhythm` | string | Algorithmic interpretation | `AFib` |

**Clinical use cases enabled:** tachycardia detection (HR>100), QT-prolongation surveillance on pro-arrhythmic drugs, AF burden estimation.

**Example records** (4 of 100):

```json
[
  {"record_id":"ECG-001","patient_id":"P001","timestamp":"2024-03-09T08:05:00","heart_rate":142,"qrs_ms":88,"qt_ms":380,"rhythm":"AFib"},
  {"record_id":"ECG-002","patient_id":"P001","timestamp":"2024-03-10T12:20:00","heart_rate":96,"qrs_ms":92,"qt_ms":372,"rhythm":"AFib"},
  {"record_id":"ECG-026","patient_id":"P006","timestamp":"2024-03-09T08:05:00","heart_rate":118,"qrs_ms":88,"qt_ms":520,"rhythm":"Atrial fibrillation"},
  {"record_id":"ECG-041","patient_id":"P009","timestamp":"2024-03-09T08:05:00","heart_rate":131,"qrs_ms":88,"qt_ms":460,"rhythm":"AFib"}
]
```

::: {.callout-note}
`P006` has QT = 520 ms while on **Amiodarone + Digoxin** — a deliberately realistic pro-arrhythmia flag students should be able to surface by query.
:::

### 4.3 `clinical_events.csv` — episodic event log

**Schema**

| Field | Type | Description | Example |
|---|---|---|---|
| `event_id` | string | Unique event | `E002` |
| `patient_id` | string | FK → history | `P001` |
| `event_date` | date | `YYYY-MM-DD` | `2024-03-09` |
| `event_type` | string | `admission` / `lab_test` / `medication_change` | `lab_test` |
| `concept_code` | string | **polymorphic**: SNOMED CT (admission reason), **LOINC** (lab tests), drug name (med change) | `8480-6` |
| `value` | float | Result value (labs only) | `158` |
| `unit` | string | UCUM unit | `mmHg` |
| `severity` | string | `mild`/`moderate`/`severe` | `mild` |

**Clinical use cases enabled:** BP surveillance (LOINC 8480-6 / 8462-4), acute-event timeline reconstruction, medication-change auditing.

**Example records** (5 of 50):

```csv
event_id,patient_id,event_date,event_type,concept_code,value,unit,severity
E001,P001,2024-03-09,lab_test,8480-6,158,mmHg,moderate
E002,P001,2024-03-09,lab_test,8462-4,95,mmHg,moderate
E041,P001,2024-02-20,admission,49436004,,,severe
E043,P006,2024-03-05,medication_change,Amiodarone,,,
E047,P015,2024-03-03,medication_change,Spironolactone,,,
```

---

## 5. Ontology Design — `healthcare_cardio.ttl`

### 5.1 Namespaces

| Prefix | URI | Role |
|---|---|---|
| `cardio:` | `http://example.org/cardio#` | Local lab ontology (classes/properties/instances) |
| `snomed:` | `http://snomed.info/id/` | SNOMED CT clinical concepts |
| `loinc:` | `http://loinc.org/` | LOINC observations |
| `fhir:` | `http://hl7.org/fhir/` | HL7 FHIR alignment (e.g. `fhir:Patient`) |
| `owl`, `rdf`, `rdfs`, `xsd` | standard | OWL2 / RDF / datatypes |

### 5.2 Classes

| Class | Description |
|---|---|
| `cardio:Patient` | `rdfs:subClassOf fhir:Patient` — the person |
| `cardio:WearableSensor` | The ECG device |
| `cardio:ECGMeasurement` | One heart-rate/rhythm reading |
| `cardio:ClinicalEvent` | An admission / lab test / med change |
| `cardio:Diagnosis` | A coded clinical condition (SNOMED CT instances) |
| `cardio:Drug` | A medication individual |

### 5.3 Object properties

| Property | Domain → Range | Notes |
|---|---|---|
| `cardio:hasDiagnosis` | Patient → Diagnosis | |
| `cardio:monitoredBy` | Patient → WearableSensor | |
| `cardio:hasEvent` | Patient → ClinicalEvent | |
| `cardio:takes` | Patient → Drug | |
| `cardio:interactsWith` | Drug → Drug | declared `owl:SymmetricProperty` |
| `cardio:produced` | WearableSensor → ECGMeasurement | links device to readings |

### 5.4 Datatype properties

| Property | Range | Example |
|---|---|---|
| `cardio:hasHeartRate` | `xsd:integer` | 142 |
| `cardio:hasQTDuration` | `xsd:integer` | 520 |
| `cardio:hasQRS` | `xsd:integer` | 88 |
| `cardio:hasRhythm` | `xsd:string` | `AFib` |
| `cardio:hasTimestamp` | `xsd:dateTime` | 2024-03-09T08:05:00 |
| `cardio:hasValue` | `xsd:double` | 158.0 |
| `cardio:hasSeverity` | `xsd:string` | `severe` |
| `cardio:hasAge` | `xsd:integer` | 68 |
| `cardio:hasConceptCode` | `xsd:string` | `8480-6` |

### 5.5 SNOMED CT instances used (real codes, ≥5)

| Code | Label |
|---|---|
| `snomed:22298006` | Acute myocardial infarction |
| `snomed:49436004` | Atrial fibrillation |
| `snomed:84114007` | Heart failure |
| `snomed:38341003` | Hypertensive disorder, systemic arterial |
| `snomed:73211009` | Diabetes mellitus |
| `snomed:62709007` | Cardiac arrhythmia |
| `snomed:48694002` | Angina pectoris |

### 5.6 LOINC instances used (real codes, ≥3)

| Code | Label | Unit |
|---|---|---|
| `loinc:8867-4` | Heart rate | /min |
| `loinc:8480-6` | Systolic blood pressure | mmHg |
| `loinc:8462-4` | Diastolic blood pressure | mmHg |

::: {.callout-note}
Drug individuals use a **local `cardio:` namespace** (e.g. `cardio:Warfarin`). In a production system these would map to **RxNorm** CUIs; the lab keeps them local for clarity. Do **not** invent fake SNOMED codes for drugs.
:::

### 5.7 The Turtle file (TBox + code/interaction instances)

```turtle
@prefix cardio: <http://example.org/cardio#> .
@prefix snomed: <http://snomed.info/id/> .
@prefix loinc:  <http://loinc.org/> .
@prefix fhir:   <http://hl7.org/fhir/> .
@prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:    <http://www.w3.org/2001/XMLSchema#> .
@prefix owl:    <http://www.w3.org/2002/07/owl#> .

cardio: a owl:Ontology ;
    rdfs:label "Cardiac Patient Digital Twin ontology"@en ;
    rdfs:comment "Lab subset aligned to SNOMED CT + HL7 FHIR; LOINC for observations."@en .

# ---------- Classes ----------
cardio:Patient         a owl:Class ; rdfs:subClassOf fhir:Patient ;        rdfs:label "Patient"@en .
cardio:WearableSensor  a owl:Class ; rdfs:label "Wearable sensor"@en .
cardio:ECGMeasurement  a owl:Class ; rdfs:label "ECG measurement"@en .
cardio:ClinicalEvent   a owl:Class ; rdfs:label "Clinical event"@en .
cardio:Diagnosis       a owl:Class ; rdfs:label "Diagnosis"@en .
cardio:Drug            a owl:Class ; rdfs:label "Drug"@en .

# ---------- Object properties ----------
cardio:hasDiagnosis a owl:ObjectProperty ; rdfs:domain cardio:Patient ; rdfs:range cardio:Diagnosis .
cardio:monitoredBy  a owl:ObjectProperty ; rdfs:domain cardio:Patient ; rdfs:range cardio:WearableSensor .
cardio:hasEvent     a owl:ObjectProperty ; rdfs:domain cardio:Patient ; rdfs:range cardio:ClinicalEvent .
cardio:takes        a owl:ObjectProperty ; rdfs:domain cardio:Patient ; rdfs:range cardio:Drug .
cardio:produced     a owl:ObjectProperty ; rdfs:domain cardio:WearableSensor ; rdfs:range cardio:ECGMeasurement .
cardio:interactsWith a owl:ObjectProperty , owl:SymmetricProperty ;
    rdfs:domain cardio:Drug ; rdfs:range cardio:Drug ;
    rdfs:comment "Clinically significant drug-drug interaction."@en .

# ---------- Datatype properties ----------
cardio:hasHeartRate a owl:DatatypeProperty ; rdfs:range xsd:integer .
cardio:hasQTDuration a owl:DatatypeProperty ; rdfs:range xsd:integer .
cardio:hasQRS a owl:DatatypeProperty ; rdfs:range xsd:integer .
cardio:hasRhythm a owl:DatatypeProperty ; rdfs:range xsd:string .
cardio:hasTimestamp a owl:DatatypeProperty ; rdfs:range xsd:dateTime .
cardio:hasValue     a owl:DatatypeProperty ; rdfs:range xsd:double .
cardio:hasSeverity  a owl:DatatypeProperty ; rdfs:range xsd:string .
cardio:hasAge       a owl:DatatypeProperty ; rdfs:range xsd:integer .
cardio:hasSex       a owl:DatatypeProperty ; rdfs:range xsd:string .
cardio:hasName      a owl:DatatypeProperty ; rdfs:range xsd:string .
cardio:hasEventType a owl:DatatypeProperty ; rdfs:range xsd:string .
cardio:hasConceptCode a owl:DatatypeProperty ; rdfs:range xsd:string .

# ---------- SNOMED CT diagnosis instances (real codes) ----------
snomed:22298006 a cardio:Diagnosis ; rdfs:label "Acute myocardial infarction"@en .
snomed:49436004 a cardio:Diagnosis ; rdfs:label "Atrial fibrillation"@en .
snomed:84114007 a cardio:Diagnosis ; rdfs:label "Heart failure"@en .
snomed:38341003 a cardio:Diagnosis ; rdfs:label "Hypertensive disorder, systemic arterial"@en .
snomed:73211009 a cardio:Diagnosis ; rdfs:label "Diabetes mellitus"@en .
snomed:62709007 a cardio:Diagnosis ; rdfs:label "Cardiac arrhythmia"@en .
snomed:48694002 a cardio:Diagnosis ; rdfs:label "Angina pectoris"@en .

# ---------- LOINC observation codes (real) ----------
cardio:LoincCode a owl:Class ; rdfs:label "LOINC observation code"@en .
loinc:8867-4 a cardio:LoincCode ; rdfs:label "Heart rate"@en .
loinc:8480-6 a cardio:LoincCode ; rdfs:label "Systolic blood pressure"@en .
loinc:8462-4 a cardio:LoincCode ; rdfs:label "Diastolic blood pressure"@en .

# ---------- Drug individuals + interactions ----------
cardio:Warfarin     a cardio:Drug ; rdfs:label "Warfarin"@en .
cardio:Amiodarone   a cardio:Drug ; rdfs:label "Amiodarone"@en .
cardio:Digoxin      a cardio:Drug ; rdfs:label "Digoxin"@en .
cardio:Furosemide   a cardio:Drug ; rdfs:label "Furosemide"@en .
cardio:Ramipril     a cardio:Drug ; rdfs:label "Ramipril"@en .
cardio:Spironolactone a cardio:Drug ; rdfs:label "Spironolactone"@en .
cardio:Metoprolol   a cardio:Drug ; rdfs:label "Metoprolol"@en .
cardio:Bisoprolol   a cardio:Drug ; rdfs:label "Bisoprolol"@en .
cardio:Aspirin      a cardio:Drug ; rdfs:label "Aspirin"@en .
cardio:Atorvastatin a cardio:Drug ; rdfs:label "Atorvastatin"@en .
cardio:Apixaban     a cardio:Drug ; rdfs:label "Apixaban"@en .

# Interactions (declared once; symmetric so they infer the reverse)
cardio:Warfarin       cardio:interactsWith cardio:Amiodarone .   # INR / bleeding
cardio:Warfarin       cardio:interactsWith cardio:Aspirin .      # bleeding
cardio:Digoxin        cardio:interactsWith cardio:Amiodarone .   # digoxin toxicity
cardio:Digoxin        cardio:interactsWith cardio:Furosemide .   # hypokalaemia → toxicity
cardio:Ramipril       cardio:interactsWith cardio:Spironolactone . # hyperkalaemia
cardio:Metoprolol     cardio:interactsWith cardio:Amiodarone .   # bradycardia
```

### 5.8 Example of 12 instance triples (A-box, generated in Phase 2)

```turtle
cardio:Patient/P001 a cardio:Patient ;
    cardio:hasName "Maria Rossi" ;
    cardio:hasAge 68 ;
    cardio:hasSex "F" ;
    cardio:hasDiagnosis snomed:49436004 ;
    cardio:hasDiagnosis snomed:38341003 ;
    cardio:takes cardio:Warfarin ;
    cardio:takes cardio:Metoprolol ;
    cardio:monitoredBy cardio:Sensor/P001-ECG .

cardio:Sensor/P001-ECG a cardio:WearableSensor ;
    cardio:produced cardio:ECG/ECG-001 .

cardio:ECG/ECG-001 a cardio:ECGMeasurement ;
    cardio:hasTimestamp "2024-03-09T08:05:00"^^xsd:dateTime ;
    cardio:hasHeartRate 142 ;
    cardio:hasQTDuration 380 ;
    cardio:hasQRS 88 ;
    cardio:hasRhythm "AFib" .
```

---

## 6. Detailed Time Budget

| Time | Phase | Activity | Lecturer (L) / Students (S) | Expected output |
|---|---|---|---|---|
| 00–03 | 1 | Env check + open notebook | L demos, S replicate | Verification cell prints versions |
| 03–07 | 1 | Load 3 datasets with Pandas; `.head()`, `.describe()` | S hands-on | 3 DataFrames / 1 list |
| 07–10 | 1 | Exploratory queries (e.g. count per diagnosis) | S + L discuss | Counts on screen |
| 10–14 | 2 | `g.parse("healthcare_cardio.ttl")`; inspect triples | L walkthrough | TBox loaded (`len(g)` > 0) |
| 14–24 | 2 | Map CSV/JSON → triples; build `rdflib.Graph` | S code along | ~600–900 triples |
| 24–30 | 2 | Serialise to `cardiac_kg.ttl`; NetworkX ego-plot | S | `.ttl` written + 1 figure |
| 30–37 | 3 | Simple SPARQL (patients with AF) | L + S | Patient list |
| 37–45 | 3 | `FILTER` queries (tachycardia, QT>500) | S | Flagged readings |
| 45–55 | 3 | Complex multi-source query (AF + interacting drugs) | L + S | At-risk patients |
| 55–63 | 4 | Exercise 1 (ontology extension) | S pairs | New class/edge + verifying query |
| 63–73 | 4 | Exercise 2 (advanced at-risk query) | S pairs | Result set |
| 73–80 | 4 | Exercise 3 (architecture proposal, open) | S group | 3-slide pitch |
| 80–86 | 5 | Share results + limitations | S present, L chairs | Notes on board |
| 86–90 | 5 | PhD research directions + close | L | Roadmap |

### 6.1 Phase-by-phase build (Phase 2 reference solution)

```python
from rdflib import Graph, Namespace, URIRef, Literal, RDF, RDFS, XSD
import pandas as pd, json

CARDIO = Namespace("http://example.org/cardio#")
SNOMED = Namespace("http://snomed.info/id/")
LOINC  = Namespace("http://loinc.org/")
FHIR   = Namespace("http://hl7.org/fhir/")

g = Graph()
g.bind("cardio", CARDIO)
g.bind("snomed", SNOMED)
g.bind("loinc", LOINC)
g.bind("fhir", FHIR)
g.parse("healthcare_cardio.ttl", format="turtle")     # TBox + codes

def pt(pid): return CARDIO[f"Patient/{pid}"]

# (1) History → patients, diagnoses, drugs
hist = pd.read_csv("clinical_history.csv")
for _, r in hist.iterrows():
    p = pt(r.patient_id)
    g.add((p, RDF.type, CARDIO.Patient))
    g.add((p, CARDIO.hasName, Literal(r.name)))
    g.add((p, CARDIO.hasAge, Literal(int(r.age), datatype=XSD.integer)))
    g.add((p, CARDIO.hasSex, Literal(r.sex)))
    for code in str(r.diagnoses).split(";"):
        if code.strip():
            g.add((p, CARDIO.hasDiagnosis, URIRef(SNOMED[code.strip()])))
    for drug in str(r.medications).split(";"):
        if drug.strip():
            g.add((p, CARDIO.takes, URIRef(CARDIO[drug.strip()])))

# (2) Wearable ECG → sensor + measurements
ecg = json.load(open("ecg_data.json"))
for rec in ecg:
    p = pt(rec["patient_id"])
    sensor = URIRef(CARDIO[f"Sensor/{rec['patient_id']}-ECG"])
    g.add((p, CARDIO.monitoredBy, sensor))
    g.add((sensor, RDF.type, CARDIO.WearableSensor))
    obs = URIRef(CARDIO[f"ECG/{rec['record_id']}"])
    g.add((sensor, CARDIO.produced, obs))
    g.add((obs, RDF.type, CARDIO.ECGMeasurement))
    g.add((obs, CARDIO.hasTimestamp, Literal(rec["timestamp"], datatype=XSD.dateTime)))
    g.add((obs, CARDIO.hasHeartRate, Literal(int(rec["heart_rate"]), datatype=XSD.integer)))
    g.add((obs, CARDIO.hasQTDuration, Literal(int(rec["qt_ms"]), datatype=XSD.integer)))
    g.add((obs, CARDIO.hasQRS, Literal(int(rec["qrs_ms"]), datatype=XSD.integer)))
    g.add((obs, CARDIO.hasRhythm, Literal(rec["rhythm"])))

# (3) Clinical events
ev = pd.read_csv("clinical_events.csv")
for _, r in ev.iterrows():
    p = pt(r.patient_id)
    e = URIRef(CARDIO[f"Event/{r.event_id}"])
    g.add((p, CARDIO.hasEvent, e))
    g.add((e, RDF.type, CARDIO.ClinicalEvent))
    g.add((e, CARDIO.hasTimestamp, Literal(f"{r.event_date}T00:00:00", datatype=XSD.dateTime)))
    g.add((e, CARDIO.hasEventType, Literal(r.event_type)))
    if pd.notna(r.concept_code) and str(r.concept_code).strip():
        g.add((e, CARDIO.hasConceptCode, Literal(str(r.concept_code).strip())))
    if pd.notna(r.value):
        g.add((e, CARDIO.hasValue, Literal(float(r.value), datatype=XSD.double)))
    if pd.notna(r.severity) and str(r.severity).strip():
        g.add((e, CARDIO.hasSeverity, Literal(r.severity)))

print("Triples in KG:", len(g))
g.serialize(destination="cardiac_kg.ttl", format="turtle")
```

### 6.2 Phase 2 — NetworkX visualisation

```python
import networkx as nx
from rdflib.extras.external_graph_libs import rdflib_to_networkx_multidigraph
import matplotlib.pyplot as plt

nxg = rdflib_to_networkx_multidigraph(g)
center = URIRef(CARDIO["Patient/P001"])
ego = nx.ego_graph(nxg, center, radius=2)
pos = nx.spring_layout(ego, seed=7)
nx.draw(ego, pos, node_size=350, node_color="#9ecae1", edge_color="#9aa", with_labels=False)
nx.draw_networkx_labels(ego, pos,
                        {n: str(n).split("/")[-1] for n in ego.nodes}, font_size=7)
plt.title("Patient P001 — ego graph (radius 2)")
plt.axis("off"); plt.show()
```

::: {.callout-warning}
A 900-triple graph drawn whole is unreadable. Always visualise an **ego subgraph** (one patient, radius 1–2).
:::

---

## 7. SPARQL Queries & Clinical Inference (Phase 3)

### 7.1 Simple — *all patients with atrial fibrillation*

```sparql
PREFIX cardio: <http://example.org/cardio#>
PREFIX snomed: <http://snomed.info/id/>
SELECT ?patient ?name WHERE {
  ?patient a cardio:Patient ;
           cardio:hasName ?name ;
           cardio:hasDiagnosis snomed:49436004 .
}
```

```python
for row in g.query(q_simple):
    print(row.patient.split("/")[-1], row.name)
```

### 7.2 Filtered — *tachycardia readings (HR > 100) ordered, with patient*

```sparql
PREFIX cardio: <http://example.org/cardio#>
SELECT ?patient ?hr ?ts WHERE {
  ?patient cardio:monitoredBy ?sensor .
  ?sensor cardio:produced ?obs .
  ?obs cardio:hasHeartRate ?hr ;
       cardio:hasTimestamp ?ts .
  FILTER(?hr > 100)
}
ORDER BY DESC(?hr)
```

### 7.3 Pattern match — *QT prolongation (> 470 ms), a pro-arrhythmia flag*

```sparql
PREFIX cardio: <http://example.org/cardio#>
PREFIX xsd:    <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?patient ?qt WHERE {
  ?patient cardio:monitoredBy ?s .
  ?s cardio:produced ?obs .
  ?obs cardio:hasQTDuration ?qt .
  FILTER(?qt > 470)
}
```

### 7.4 Complex multi-source — *AF patients taking two drugs that interact*

```sparql
PREFIX cardio: <http://example.org/cardio#>
PREFIX snomed: <http://snomed.info/id/>
SELECT DISTINCT ?patient ?d1 ?d2 WHERE {
  ?patient cardio:hasDiagnosis snomed:49436004 ;
           cardio:takes ?d1 ; cardio:takes ?d2 .
  ?d1 cardio:interactsWith ?d2 .
  FILTER(?d1 != ?d2 && str(?d1) < str(?d2))
}
```

### 7.5 Clinical discussion of results

- Patients returned by 7.4 (e.g. `P009` on **Warfarin + Amiodarone**, `P006` on **Digoxin + Amiodarone**) are exactly those flagged in real pharmacovigilance. Because `interactsWith` is `owl:SymmetricProperty`, a reasoner (or `FILTER(?d1 != ?d2)`) yields each pair once — a concrete demonstration of **inference from the schema**.
- Cross-check 7.2 + 7.4: an AF patient with tachycardia *and* an interacting pair is a high-priority clinical review target — the seed of the advanced exercise.

---

## 8. Independent Exercises (Phase 4)

### Exercise 1 — Extend the ontology with a new drug + interaction (Medium)

**Objective.** Add a `cardio:Drug` individual, an `interactsWith` link, assign it to a patient, and verify with SPARQL.

**Step-by-step**
1. Add `cardio:Sotalol` (a class-III anti-arrhythmic that prolongs QT).
2. Assert it `interactsWith cardio:Amiodarone` (additive QT risk).
3. Give it to `Patient/P016`.
4. Re-run the §7.4 query and confirm the new pair appears.

**Starter code (complete the TODOs)**

```python
from rdflib import RDF, RDFS, Literal
Sotalol = URIRef(CARDIO["Sotalol"])
# TODO: type it as a Drug and label it
# TODO: assert interactsWith Amiodarone
# TODO: patient P016 takes Sotalol
```

**Lecturer solution**

```python
Sotalol = URIRef(CARDIO["Sotalol"])
Amiodarone = URIRef(CARDIO["Amiodarone"])
g.add((Sotalol, RDF.type, CARDIO.Drug))
g.add((Sotalol, RDFS.label, Literal("Sotalol")))
g.add((Sotalol, CARDIO.interactsWith, Amiodarone))
g.add((URIRef(CARDIO["Patient/P016"]), CARDIO.takes, Sotalol))

# verify
q = """PREFIX cardio: <http://example.org/cardio#>
       SELECT ?d1 ?d2 WHERE { ?d1 cardio:interactsWith ?d2 . FILTER(?d1!=?d2) }"""
print(sorted({(str(r.d1).split('#')[-1], str(r.d2).split('#')[-1]) for r in g.query(q)}))
```

**Assessment criteria:** new triples present; query returns the new pair; turtle re-serialises without error. **Time ≈ 8 min.**

---

### Exercise 2 — Multi-criteria at-risk query (Advanced)

**Objective.** One SPARQL query returning patients who are **(a)** atrial-fibrillation, **(b)** taking two interacting drugs, **(c)** with a recent **tachycardia** reading (HR > 100).

**Instructions**
1. Reuse the §7.4 pattern for (a)+(b).
2. Join through `monitoredBy → produced → hasHeartRate` for (c).
3. Use `DISTINCT` so each patient appears once.

**Starter code**

```python
q2 = """
PREFIX cardio: <http://example.org/cardio#>
PREFIX snomed: <http://snomed.info/id/>
SELECT DISTINCT ?patient WHERE {
  # TODO: diagnosis AF
  # TODO: takes d1, takes d2, d1 interactsWith d2, d1 != d2
  # TODO: monitoredBy ?s ; produced ?obs ; hasHeartRate ?hr ; FILTER ?hr > 100
}
"""
for r in g.query(q2):
    print(r.patient.split("/")[-1])
```

**Lecturer solution**

```sparql
PREFIX cardio: <http://example.org/cardio#>
PREFIX snomed: <http://snomed.info/id/>
SELECT DISTINCT ?patient WHERE {
  ?patient cardio:hasDiagnosis snomed:49436004 ;
           cardio:takes ?d1 ; cardio:takes ?d2 .
  ?d1 cardio:interactsWith ?d2 .
  FILTER(?d1 != ?d2 && str(?d1) < str(?d2))
  ?patient cardio:monitoredBy ?s .
  ?s cardio:produced ?obs .
  ?obs cardio:hasHeartRate ?hr .
  FILTER(?hr > 100)
}
```

**Assessment criteria:** query returns only qualifying patients (at least `P009`; `P014` if the dataset gives it a tachycardia reading), no false positives, runs without error. **Time ≈ 10 min.**

---

### Exercise 3 — Architectural improvement proposal (Open-ended)

**Objective.** In ≤3 slides, propose **one** concrete improvement to the lab architecture, grounded in a Part-1 gap.

**Prompts to choose from**
- *Real-time:* how would you ingest a true ECG stream (not a JSON file) without breaking the SOSA/FHIR alignment?
- *Provenance:* where would you stamp sensor calibration / trust, and how does it change the §7.5 inferences?
- *Privacy:* what changes so two hospitals can run Exercise 2 jointly without sharing raw signals?

**Deliverable:** problem → proposed change → one risk. **Time ≈ 7 min.** No single right answer; assessed on clarity and feasibility.

---

## 9. Discussion Prompts for PhD Students

1. **Clinical validity.** Is this KG *clinically* valid? Which missing element (provenance? temporal validity of a triple? negation?) would make a §7.5 inference unsafe to act on?
2. **Symmetry as reasoning.** We declared `interactsWith` symmetric. What clinical relationship would be **dangerous** to model as symmetric? (Hint: think `causes`.)
3. **Standards vs. speed.** Mapping every concept to SNOMED CT is slow. Where in a real-time arrhythmia pipeline would you accept a *local* code, and what does that cost you downstream?
4. **Thesis angle.** Exercise 2 returns a static snapshot. What would have to change in the **schema** (not the query) to support *"patients who **became** at-risk in the last 24 h"*?
5. **Federated honesty.** If two hospitals each hold a sub-graph for the **same** patient, what is the minimal shared TBox that lets them merge inferences without merging data — and where does it still leak identity?

---

## 10. Assessment & Evaluation

### 10.1 Success criteria (to "pass")
- [ ] Verification cell prints all library versions.
- [ ] `len(g)` reports a non-zero triple count after Phase 2.
- [ ] `cardiac_kg.ttl` is written and re-parseable.
- [ ] At least one ego-graph renders.
- [ ] Queries §7.1, §7.2, §7.4 return **non-empty** results.
- [ ] Exercise 1 *or* 2 completed with a correct result set.

### 10.2 Student self-assessment checklist
- [ ] I can explain object vs datatype property in my own words.
- [ ] I can read a SPARQL `FILTER` and predict which rows survive.
- [ ] I can add a new class/property to the `.ttl` without breaking it.
- [ ] I know **which standard vocabulary** codes my diagnoses vs my observations.

### 10.3 Feedback to collect (improve next edition)
- Which phase felt most time-pressured?
- Which exercise best connected Part-1 theory to hands-on skill?
- Which tool (rdflib / SPARQL / NetworkX) was the steepest to learn?
- One dataset inconsistency you noticed.

---

## 11. Troubleshooting

| # | Symptom | Likely cause | Fix |
|---|---|---|---|
| 1 | `ModuleNotFoundError: rdflib` | Wrong env / not installed | Re-activate `.venv`, run `pip install "rdflib>=7.0"` |
| 2 | `PluginException: No plugin found for turtle` | `format` typo or empty file | Ensure `g.parse(..., format="turtle")` and the `.ttl` is non-empty |
| 3 | SPARQL returns 0 rows always | Prefix URI mismatch (e.g. `snomed.info/sct/` vs `snomed.info/id/`) | Use exactly the namespace strings from §5.1 in **both** ttl and query |
| 4 | `ParserError` / "expected ." in Turtle | Missing `;`/`.` or a stray `&`/`_` | In literals escape `&`→`\&`, keep `.` at end of each statement |
| 5 | `ValueError` parsing `pd.notna` on int column | blank cells read as `NaN` | guard with `if pd.notna(r.value):` before adding the literal |
| 6 | NetworkX plot is a hairball | whole graph drawn | draw `nx.ego_graph(nxg, node, radius=2)` only |
| 7 | Matplotlib shows nothing inline | backend | add `%matplotlib inline` as the first notebook cell |

::: {.callout-warning}
**If a stage fails late (Phase 3):** the KG built fine but a query is wrong — the bug is in the SPARQL/prefixes, **not** the build. Do **not** rebuild the graph; inspect prefixes and `FILTER` types first. Rebuilding masks the real issue.
:::

---

## 12. Future Extensions (Optional)

- **Neo4j integration** — mirror the triples into a property graph and compare **Cypher** (`MATCH (p:Patient)-[:takes]->(d)`) with **SPARQL** for the same clinical question; discuss the loss/gain of ontology semantics.
- **Risk scoring ML** — export the patient feature vectors (HR variability, comorbidity count, interaction count) to **scikit-learn** for a 30-day readmission classifier; debate *black-box* vs *rule-based* (Part-1 reasoning) trust.
- **LLM clinical RAG** — put the KG behind a SPARQL endpoint and let an LLM translate natural-language clinical questions into SPARQL (text-to-SPARQL); evaluate hallucination risk on missing codes.
- **Federated KGs & privacy** — split patients across two `rdflib` stores and query via `SERVICE`; explore what a federated join leaks about graph topology (links to the Part-1 *privacy* gap).

---

## 13. Resources & References

**Library docs**
- rdflib — https://rdflib.readthedocs.io/
- NetworkX — https://networkx.org/documentation/stable/
- Pandas — https://pandas.pydata.org/docs/
- JupyterLab — https://jupyterlab.readthedocs.io/

**SPARQL & RDF tutorials**
- SPARQL 1.1 Query Language (W3C) — https://www.w3.org/TR/sparql11-query/
- RDF 1.1 Turtle — https://www.w3.org/TR/turtle/
- rdflib SPARQL cookbook — https://rdflib.readthedocs.io/en/stable/gettingstarted.html

**Reference ontologies / browsers**
- SNOMED CT browser — https://browser.ihtsdotools.org/
- LOINC search — https://search.loinc.org/
- HL7 FHIR — https://www.hl7.org/fhir/

**Academic references (APA 7)**
- Carbonaro, A., Marfoglia, A., Nardini, F., & Mellone, S. (2023). *CONNECTED: Leveraging digital twins and personal knowledge graphs in healthcare digitalization*. **Frontiers in Digital Health**, *5*, Article 1322428. https://doi.org/10.3389/fdgth.2023.1322428
- Sarani Rad, F., Hendawi, R., Yang, X., & Li, J. (2024). *Personalized diabetes management with digital twins: A patient-centric knowledge graph approach*. **Journal of Personalized Medicine**, *14*(4), Article 359. https://doi.org/10.3390/jpm14040359
- Hendawi, R., & Li, J. (2024). *Comprehensive personal health knowledge graph for effective management and utilization of personal health data*. In **Proceedings of IEEE AIMHC** (pp. 1–8). IEEE. https://doi.org/10.1109/aimhc59811.2024.00026

---

*Prepared as Part 2 of "Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins in Healthcare." Report issues or dataset inconsistencies to the course lecturer.*
