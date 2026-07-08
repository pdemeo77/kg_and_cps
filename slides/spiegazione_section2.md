# Spiegazione estesa — Section 2
## From Heterogeneous Biomedical Data to Patient Digital Twins
### Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins

> Dispense di accompagnamento alle slide `section2_modificata.qmd`. La spiegazione segue l'ordine delle slide e approfondisce ciascun argomento attingendo agli 8 paper di riferimento (2023–2026) elencati in `KG_CPS_IoT_DigitalTwin_PhD_Bibliography.md`.

---

## Sommario

1. [La tesi del "ponte semantico" (slide di apertura)](#1-la-tesi-del-ponte-semantico)
2. [Roadmap della lezione](#2-roadmap-della-lezione)
3. [Sezione 1 — Fondamenti e standard ontologici](#3-sezione-1--fondamenti-e-standard-ontologici)
4. [Sezione 2 — Pipeline di integrazione CPS→KG](#4-sezione-2--pipeline-di-integrazione-cps--kg)
5. [Sezione 3 — Digital Twin e ragionamento AI](#5-sezione-3--digital-twin-e-ragionamento-ai)
6. [Sezione 4 — Sfide aperte e frontiere di ricerca](#6-sezione-4--sfide-aperte-e-frontiere-di-ricerca)
7. [Sintesi finale (Key Takeaways)](#7-sintesi-finale-key-takeaways)
8. [Mappa dei paper e riferimenti](#8-mappa-dei-paper-e-riferimenti)

---

## 1. La tesi del "ponte semantico"

La lezione si apre con un diagramma a tre nodi:

```
CPS / IoT  ──semantic bridge──▶  Knowledge Graph  ──reasoning──▶  Patient Digital Twin
(sensori e dispositivi)          (FHIR · SNOMED CT · SOSA)        (PDT)
```

### Cosa dice la slide
I flussi di dati eterogenei provenienti da sistemi cyber-fisici (CPS) e IoT sono **"syntactically rich but semantically poor"**: ricchi di formato (JSON, CSV, DICOM, HL7 FHIR…) ma poveri di significato. Un Knowledge Graph (KG) fornisce lo strato di significato mancante, rendendo le osservazioni **interrogabili (queryable), ragionabili (reason-able) e clinicamente confrontabili** — il substrato su cui un Digital Twin viene simulato.

**La tesi centrale della lezione** è netta: la *qualità del ponte* (ontologie + pipeline + ragionamento), e non la quantità o la precisione dei sensori, determina l'affidabilità clinica di un Patient Digital Twin.

### Approfondimento
Per capire questa tesi bisogna partire dalla distinzione tra **sintassi** e **semantica**:
- Un sensore CGM produce un valore numerico (es. `glucose=72`). Quello è un dato sintatticamente ben formato, ma non dice *cosa* significhi, *in quali unità*, *a quale paziente* appartiene, *come* si relaziona agli altri dati del paziente.
- La **semantica** aggiunge: "72 è un livello di glucosio in mg/dL (codice LOINC 99504-3), misurato dal sensore X, del paziente Y, alle ore Z, e indica un rischio di ipoglicemia se combinato con la terapia insulinica".

Il KG codifica proprio questa semantica sotto forma di **triple** *soggetto–predicato–oggetto* (es. `Paziente:12345 —haOsservazione→ Osservazione:glucosio72`), sostenute da un'**ontologia formale** che dà alle relazioni un significato ben definito e processabile da una macchina.

Il punto chiave dell'intera lezione è quindi **architetturale**: il KG non è un dettaglio, è l'artefatto ingegneristico su cui poggia tutto. Se il ponte è debole (allineamento ontologico sbagliato, pipeline che perde significato), il Digital Twin a valle produrrà inferenze clinicamente pericolose, per quanto i sensori siano perfetti.

---

## 2. Roadmap della lezione

| Sezione | Focus |
|---|---|
| **1. Fondamenti e standard** | Stack ontologico, architetture, limiti di interoperabilità |
| **2. Pipeline CPS→KG** | Architetture sensore→tripla, real-time vs batch |
| **3. Digital Twin e ragionamento AI** | Rule-based / neuro-symbolic / RAG, validazione |
| **4. Sfide aperte e frontiere** | Scalabilità, privacy, benchmark |

La lezione è costruita su **8 paper recenti (2023–2026)** selezionati con criterio: vera integrazione KG+CPS, coprendo (a) survey/architetture KG+IoT sanitario, (b) framework di Patient Digital Twin con ragionamento semantico, (c) integrazione di dati wearable via ontologie (FHIR/SNOMED CT).

---

## 3. Sezione 1 — Fondamenti e standard ontologici

> *"What language do the sensors speak?"*

L'obiettivo della sezione è stabilire **prima** il vocabolario ontologico e l'architettura concettuale, prima di parlare di pipeline. È ancorata a tre paper: **Hendawi & Li (2024)** sulle terminologie cliniche, **Chatterjee et al. (2024)** sulle ontologie di sensore, e **Carbonaro et al. (2023)** come blueprint concettuale (CONNECTED).

### 3.1 Healthcare Ontology Foundations — Hendawi & Li (2024)

**Paper:** *Comprehensive Personal Health Knowledge Graph (PHKG)*, IEEE AIMHC 2024.

**Contributo chiave.** Gli autori propongono un PHKG che **unifica quattro fonti eterogenee** sotto un unico schema OWL:
- cartelle cliniche elettroniche (EHR),
- flussi da dispositivi wearable,
- dati assicurativi sanitari,
- **determinanti sociali della salute (SDoH)** — fattori come reddito, istruzione, ambiente, che influenzano fortemente gli outcome clinici ma raramente entrano nei sistemi clinici.

I nodi del grafo sono allineati a **SNOMED CT** (terminologia clinica) e **ICD-10** (classificazione amministrativa). La **privacy è "schema-native"**: il controllo degli accessi basato sui ruoli (RBAC) è incorporato nello schema stesso del KG, non aggiunto a posteriori. Le query **SPARQL** espongono interrogazioni **longitudinali/temporali** (es. "come è variata la glicemia di questo paziente nell'ultimo anno?").

> **Lezione per il corso:** la privacy non è un ornamento. Quando è *native* nello schema, la governance è verificabile e consistente; quando è *bolted on* (aggiunta dopo), diventa una fonte di vulnerabilità e di incoerenza.

**Ontologie usate:** OWL · SNOMED CT · ICD-10.

### 3.2 Sensor Semantics: il ponte SSN/SOSA — Chatterjee et al. (2024)

**Paper:** *Semantic representation of physical activity sensor observations (MOX2-5)*, Scientific Reports 2024.

**Contributo chiave.** È il riferimento più concreto del corpus su "come triplificare un wearable". Gli autori annotano le osservazioni di un accelerometro **MOX2-5** come triple OWL/RDF usando lo standard W3C **SSN/SOSA** (Semantic Sensor Network / Sensor, Observation, Sample, and Actuator).

Il modello SSN/SOSA formalizza quattro entità fondamentali:
- **Sensor** — il dispositivo fisico (es. l'accelerometro MOX2-5);
- **Observation** — l'atto di misurare in un certo istante;
- **Feature of Interest** — la grandezza osservata / il paziente (es. l'attività fisica della persona);
- **Result** — il valore misurato (es. "walking").

La pipeline converte **CSV → RDF** e confronta dati di attività reali con dati sintetici (walking, running, cycling) tramite query **SPARQL**, validando la copertura ontologica e l'espressività delle query. Discute anche un **percorso di integrazione verso FHIR**.

> **Perché conta:** SSN/SOSA rende i dati del sensore **device-agnostic** e **interoperabili**. Lo stesso concetto di "osservazione di camminata" può essere espresso allo stesso modo indipendentemente dalla marca dell'accelerometro, perché l'ontologia ne standardizza la struttura.

**Ontologie usate:** W3C SSN/SOSA + allineamento FHIR candidato.

### 3.3 Conceptual Blueprint: CONNECTED — Carbonaro et al. (2023)

**Paper:** *CONNECTED: Leveraging Digital Twins and Personal Knowledge Graphs*, Frontiers in Digital Health 2023.

**Contributo chiave.** È una **systematic review** distillata in un'**architettura a strati**:
```
acquisizione CPS/IoT → allineamento semantico OWL/FHIR → Personal Knowledge Graph (PKG) → simulazione DT
```

CONNECTED formalizza **quattro requisiti raramente co-locati** nello stesso sistema:
1. **interoperabilità semantica**,
2. **privacy-by-design**,
3. **fusione dati in tempo reale**,
4. **ragionamento temporale**.

Il motore del Digital Twin si trova **sopra** il PKG: il grafo è la base di conoscenza che evolve, il DT è il motore di simulazione predittiva che la consuma.

> **Lezione per il corso:** CONNECTED è il "big picture". Mappa esplicitamente il flusso dai sensori CPS fino al DT, passando per il PKG. Le sue **agende aperte** (federazione DT-PKG, consenso, governance) diventano i semi delle domande di ricerca della Sezione 4.

**Ontologie usate:** OWL · FHIR (strato di allineamento).

### 3.4 Ontology Stacking — un paziente, molti vocabolari

La slide mostra come nessuno standard è "canonico": ognuno copre un aspetto, e **il KG è dove vengono riconciliati**.

| Standard | Ruolo |
|---|---|
| **SSN/SOSA** | provenance dell'osservazione (chi/come/Quando ha misurato) |
| **HL7 FHIR** | spina dorsale di **scambio** (API RESTful, risorse) |
| **SNOMED CT** | semantica **clinica** (350.000+ concetti: diagnosi, procedure, reperti) |
| **ICD-10** | granularità **amministrativa** (classificazione, billing, epidemiologia) |
| **OWL 2.0** | la **logica** che li vincola e li lega |

> **Teso dell'ingegnere:** proprio perché il KG è il punto di riconciliazione, **l'allineamento è il collo di bottiglia più error-prone**. Mappare "glucosio" di SNOMED sul codice E87 "altro disturbo del glucosio" di ICD-10 non è banale; errori qui si propagano a tutte le inferenze a valle.

---

## 4. Sezione 2 — Pipeline di integrazione CPS→KG

> *"From a voltage on a wrist to a triple in a graph"*

Il **ponte** è esso stesso un artefatto ingegnerizzato: *ingestion → mapping → materializzazione dei triple → query*. La sezione confronta **quattro architetture** lungo uno spettro: **quanto avviene all'edge vs centralmente, e con quale frequenza**.

### 4.1 La pipeline generica sensore→tripla

```
Physical CPS/IoT → Raw data (CSV/JSON/streams) → Ontology mapping (R2RML·SOSA·FHIR)
   → RDF Knowledge Graph (OWL triple) → Reasoning & query (SPARQL·SWRL·ML) → Patient Digital Twin
```

Ogni paper della Sezione 2 è un'**istanziazione** degli stadi B→D. Differiscono per:
- **linguaggio di mapping** (R2RML vs annotazione SOSA vs API FHIR),
- **dove** avviene la materializzazione (on-write, on-load, on-retrieval),
- **frequenza** di aggiornamento (batch, near-real-time, real-time).

La domanda ingegneristica onesta **non** è "RDF o no?" ma **"materializzazione real-time o ricostruzione batch?"**.

### 4.2 Unified Semantic Framework — Pourvahab et al. (2025)

**Paper:** *A unified semantic framework for IoT-healthcare data interoperability*, ACM SAC 2025.

**Architettura.** Usa **R2RML** (*RDB-to-RDF Mapping Language*) per mappare dichiarativamente dati sanitari relazionali in triple allineate a OWL; uno **strato distribuito di costruzione del grafo** assorbe il volume IoT in tempo reale.

**Passi di trasformazione:**
```
riga relazionale → template R2RML → tripla RDF → nodo classificato OWL → vocabolario FHIR-compatibile
```

**Trade-off real-time vs batch:** l'*ingestion* è real-time, ma l'**inferenza graph-ML è batch** sul grafo costruito. Risultato: per allerte a bassa latenza serve un **bypass di streaming** separato.

> **R2RML** è dichiarativo: le regole di mapping vivono in un file separato, non nel codice. Questo rende il mapping ispezionabile, versionabile e riapplicabile quando lo schema sorgente cambia — una proprietà preziosa in sanità, dove gli schema EHR evolvono.

### 4.3 Costruzione CPS→KG per wearable — Chatterjee et al. (2024)

**Architettura (già vista in 3.2):**
```
MOX2-5 accelerometer → CSV export → annotazione SSN/SOSA → grafo RDF OWL → SPARQL + repo FHIR
```

**Passi di trasformazione:** accelerometria grezza → classificazione dell'attività → `sosa:Observation` con `hasResult` → collegamento al `FeatureOfInterest` (il paziente).

**Trade-off:** il proof-of-concept è **offline/batch** (export di file). *Guadagna* semplicità e riproducibilità, *perde* latenza → inadatto allo stato attuale per monitoraggio acuto.

### 4.4 IoT-KG-Digital-Twin: pipeline a tre strati — Gyrard et al. (2024)

**Paper:** *IoT-based preventive mental health using KGs and standards*, arXiv 2024.

**Architettura:**
- **Layer 1** — wearable IoT: EEG, GSR (risposta galvanica della pelle), heart rate → monitoraggio continuo delle emozioni;
- **Layer 2** — interoperabilità semantica: IoT-Lite + SOSA/SSN → annotazione RDF;
- **Layer 3** — DT guidato dal KG: modella le **traiettorie di salute mentale** e attiva interventi personalizzati.

Il ragionamento **cross-domain** (HL7 FHIR · SNOMED CT · stack W3C) collega segnali fisiologici a concetti clinici.

**Trade-off:** il monitoraggio delle emozioni è near-real-time, ma il **ragionamento è guidato da query (semi-batch)** → buono per *screening/prevenzione*, insufficiente per *intervento in crisi*.

> **Collegamento SDG-3:** il paper lega esplicitamente il deploy operativo a target di salute globale (Sustainable Development Goal 3) — un esempio di come la ricerca KG-PDT possa ancorarsi a priorità di salute pubblica.

### 4.5 Ingestion FHIR-nativa e binding dei modelli — Marfoglia et al. (2026)

**Paper:** *A knowledge graph-driven framework for AI-powered patient digital twins*, Future Generation Computer Systems 2026 (il più recente del corpus; estende CONNECTED).

**Architettura.** Una **FHIR R4 REST API** recupera stream EHR/IoT time-stamped in un **KG persistente OWL-DL**; l'innovativa **ontologia MIMO** (*Model Input/Model Output*) standardizza gli input/output di ogni modello AI, per una composizione trasparente e riutilizzabile. Un protocollo di **binding basato su manifest** automatizza la registrazione dei modelli e l'allineamento dei parametri contro lo strato semantico del PDT.

**Passi di trasformazione:**
```
risorsa FHIR → asserzione OWL-DL → match interfaccia MIMO → binding manifest-driven → pipeline multi-AI
```

**Trade-off:** retrieval API real-time + **gap detection automatica** quando la copertura sensoristica è insufficiente, ma la **latenza di inferenza OWL-DL** sotto carico è il freno.

> **Il concetto di "gap detection":** è un meccanismo semanticamente consapevole. Il sistema "sa" quali dati servirebbero per una certa inferenza e segnala quando mancano — qualcosa che un database tradizionale non può fare, perché non ha la nozione di "cosa sarebbe necessario per concludere X".

### 4.6 Tabella di sintesi: Real-Time vs Batch

| Architettura | Ingestion | Materializzazione | Cadenza ragionamento | Best fit |
|---|---|---|---|---|
| **Pourvahab 2025** (RDF/R2RML) | real-time (distribuito) | on-write | batch ML | analytics su larga scala |
| **Chatterjee 2024** (CSV→SOSA) | offline/batch | on-load | query-time | ricerca / riproducibilità |
| **Gyrard 2024** (3-layer) | near-real-time | on-annotation | semi-batch SPARQL | screening / prevenzione |
| **Marfoglia 2026** (FHIR+MIMO) | real-time API | on-retrieval | on-demand OWL-DL | clinical decision support |

**Pattern universale:** l'ingestion va verso il real-time, ma il **ragionamento resta batch/periodico**. **Il divario tra i due è il collo di bottiglia della latenza clinica.** Nessuna delle quattro architetture fornisce **ragionamento incrementale in streaming con garanzie di latenza limitata (bounded)**.

> **Questo è il cuore del problema pratico:** un paziente può generare migliaia di punti al secondo, ma se il ragionamento (che trasforma quei dati in una decisione clinica) può girare solo ogni ora, la "freschezza" dei dati è sprecata. È esattamente il gap che alimenta la RQ1 della Sezione 4.

---

## 5. Sezione 3 — Digital Twin e ragionamento AI

> *"A graph that thinks — but how, and is it right?"*

La sezione confronta le **famiglie di ragionamento** in gioco: **rule-based (OWL-DL / SWRL)**, **neuro-symbolic / RAG**, e **query-driven** (inferenza temporale). Per ciascuna: meccanismo → metodologia di validazione → **gap di applicabilità clinica**.

### 5.1 Il panorama dei meccanismi di ragionamento

| Famiglia | Meccanismo | Pro | Contro |
|---|---|---|---|
| **Rule-based** (OWL-DL / SWRL) | logica descrittiva + regole Horn-like | trasparente, auditabile | fragile, onerosa da authoring |
| **Neuro-symbolic** | embedding del KG + regole | adattiva | perde parte dell'auditabilità |
| **RAG / query-driven** | LLM sopra SPARQL/KG | linguaggio naturale, flessibile | allucinazioni, non ancorata al deployed |

**Gap comune a tutte:** scarsa **validazione clinica prospettica**. Quasi tutto è retrospective o proof-of-concept.

### 5.2 Ragionamento OWL-DL + MIMO — Marfoglia et al. (2026)

- **Meccanismo:** inferenza **OWL-DL** che impone consistenza semantica e **attiva automaticamente la gap detection** quando la copertura sensoristica è insufficiente; **MIMO** standardizza I/O dei modelli AI per composizione multi-modello dinamica guidata da manifest.
- **Validazione:** benchmark end-to-end su **stroke-risk prediction** con stream clinici reali time-aware → dimostra scalabilità KG→PDT.
- **Gap:** nessun trial prospettico; generalizzazione oltre lo stroke non testata; **latenza di ragionamento OWL-DL sotto carico concorrente** non quantificata.

> **OWL-DL (Description Logic)**: un fragment di OWL la cui inferenza è **decidibile** (garantisce terminazione) e basata sulla teoria dei modelli. Permette di derivare automaticamente, ad esempio, che "se Metformin è un biguanide e i biguanidi interagiscono col contrasto iodato, allora il paziente che assume Metformin è a rischio di acidosi lattica" — senza che questa regola sia codificata a mano, ma derivata dalla struttura ontologica.

### 5.3 Ragionamento SWRL federato — Krämer (2025)

- **Meccanismo:** il **Patient Medical Digital Twin (PMDT)** in **OWL 2.0** con cinque **Blueprint** clinici (profilo paziente, malattia/diagnosi, trattamento/follow-up, traiettorie di malattia, monitoraggio sicurezza); **regole SWRL eseguite all'edge** su serie temporali IoT multimodali; solo le **asserzioni di classe OWL** (mai i dati grezzi) sono propagate centralmente.
- **Validazione:** scenari paziente **sintetici** in diabete e scompenso cardiaco → verifica *completezza* della copertura ontologica e *correttezza* delle catene di inferenza temporale.
- **Gap:** solo sintetico, nessun deploy reale; la copertura SWRL dipende dall'**authoring di regole da parte di esperti**; ragionamento federato non testato a scala.

> **Il pattern "class assertions only" è geniale per la privacy:** invece di spedire "glicemia=72 alle 14:32 del paziente Rossi" (dato che re-identifica), l'edge classifica e spedisce solo "questa osservazione è un'istanza della classe `HypoglycaemiaRisk`". Il ragionamento centrale opera su **concetti**, non su valori sensibili.

### 5.4 Diabetes Twin guidato da PHKG — Sarani Rad et al. (2024)

- **Meccanismo:** un **Personal Health KG (PHKG)** è il substrato del digital twin; si **auto-aggiorna** quando arrivano osservazioni CGM/EHR/PROM (Patient-Reported Outcomes); il **ragionamento OWL inferisce pattern di rischio di ipoglicemia** e suggerimenti di aggiustamento farmacologico (HL7 FHIR per lo scambio).
- **Validazione:** valutato su una **coorte di pazienti reali**; predizione degli outcome glicemici **superiore ai baseline rule-based**.
- **Gap:** malattia singola, **coorte retrospettiva**, nessun RCT prospettico; **latenza di aggiornamento del PHKG** sotto CGM ad alta frequenza non affrontata.

> **L'esempio clinico più "completo":** è l'unico paper del corpus con validazione su pazienti reali e una malattia cronica end-to-end. Il paziente diabetico con CGM è il filo conduttore dell'intera lezione.

### 5.5 Cross-check: Mental-Health Twin — Gyrard et al. (2024)

- **Meccanismo:** query **temporal SPARQL** sul KG del paziente rilevano traiettorie di burnout/depressione; SOSA/SSN + SNOMED CT + FHIR abilitano join clinici cross-domain.
- **Validazione:** dimostrazione proof-of-concept collegata a target **SDG-3** — *nessun benchmark su coorte clinica*.
- **Gap:** l'**affetto** (emozione) non ha una rappresentazione pulita in SNOMED CT → il ragionamento poggia su **semantica clinica sotto-specificata**; il triggering di interventi non validato.

> **Un caveat epistemologico:** misurare "depressione" tramite EEG/GSR è clinicamente controverso. Se il concetto stesso che si vuole inferire manca di una codifica standard solida (SNOMED), l'inferenza — per quanto tecnicamente corretta — riposa su fondamenta semantiche fragili. È un monito: **l'ontologia limita ciò che si può ragionare**.

---

## 6. Sezione 4 — Sfide aperte e frontiere di ricerca

> *"Where the graph still breaks"*

La sezione sintetizza tutti gli 8 paper su **quattro assi**: **scalabilità, ragionamento temporale, privacy/federazione, benchmark di valutazione**. L'obiettivo è **convertire i gap in tre domande di ricerca PhD-defining**.

### 6.1 Matrice di sintesi cross-paper

| Paper (anno) | Scalabilità | Ragion. temporale | Privacy / federato | Valutazione |
|---|:--:|:--:|:--:|:--:|
| Pourvahab et al. (2025) | Sì: strato distribuito | — | No | Sì: metriche interop |
| Gyrard et al. (2024) | Parziale | Sì: SPARQL temporale | No | Parziale: use-case demo |
| Marfoglia et al. (2026) | Sì: bench end-to-end | Sì: time-aware | No | Sì: benchmark stroke |
| Carbonaro et al. (2023) | — | Sì: req. identificati | Sì: privacy-by-design | — concettuale |
| Krämer (2025) | Parziale | Sì: inferenza temporale | Sì: federazione class-assertion | Parziale: solo sintetico |
| Sarani Rad et al. (2024) | Parziale | Sì: PHKG incrementale | No | Sì: coorte reale |
| Chatterjee et al. (2024) | — | — | No | Sì: real vs synthetic |
| Hendawi & Li (2024) | Parziale: prototipo | Sì: longitudinale | Sì: RBAC schema | Sì: EHR reali |

**Legenda:** Sì = affrontato · Parziale = parziale · No / — = assente. **La privacy è l'asse più raro; i benchmark sono inconsistenti.**

### 6.2 Scalabilità × ragionamento temporale

- **La contraddizione:** gli stream CPS esigono graffi *freschi*; il ragionamento OWL-DL/SWRL è **non-incrementale** → il costo di ri-materializzazione cresce con la dimensione del grafo.
- Solo **Pourvahab (2025)** e **Marfoglia (2026)** affrontano la scala, e nessuno dei due fornisce **ragionamento incrementale in streaming con latenza limitata**.
- Il supporto temporale è per lo più **query-time** (SPARQL) o **scenario-based** (Krämer), non un modello temporale first-class (es. **valid-time RDF**).

> **Valid-time RDF:** un'estensione in cui ogni tripla porta informazioni di validità temporale (es. "questa terapia era valida da T1 a T2"). Permettere al ragionatore di sapere *quando* un fatto era vero — non solo *se* lo è — è fondamentale in clinica, dove la cronologia conta più dello stato istantaneo.

### 6.3 KG privacy-preserving e federati

- **Migliori della classe:** Krämer (2025) propaga *solo asserzioni di classe OWL*; Hendawi & Li (2024) incorporano **RBAC nello schema**; Carbonaro (2023) eleva la **privacy-by-design** a requisito.
- **Gap collettivo:** nessuna **differential privacy, secure multi-party computation, o federazione verificabile** sui KG sanitari; la **re-identificazione basata su inferenza** di pazienti rari è inanalizzata.
- **Consenso e governance** (agenda aperta di CONNECTED) restano **non implementati** in nessun sistema recensito.

> **Re-identificazione per inferenza:** anche se non condividi il nome del paziente, la struttura del grafo può tradirlo. Un paziente con una combinazione rara di diagnosi + farmaci + determinanti sociali è *univocamente identificabile* nel grafo, per quanto tu abbia anonimizzato i nodi. È un rischio specifico dei KG che i database relazionali non hanno allo stesso modo.

### 6.4 Benchmark di valutazione: il metro mancante

- Ogni paper inventa **il proprio** dataset/metrica: metriche interop (Pourvahab), copertura SPARQL (Chatterjee), AUC di coorte (Sarani Rad), benchmark di scalabilità (Marfoglia), completezza sintetica (Krämer).
- **Non esiste un benchmark CPS-KG-PDT condiviso** che misuri *insieme* interoperabilità semantica, latenza di inferenza e fedeltà del twin.
- La validazione **solo sintetica** (Krämer, Gyrard) non può certificare la correttezza clinica.

> **Perché manca un benchmark:** misurare "interoperabilità semantica" è filosoficamente difficile — non c'è una ground truth universale. E mescolarla con "latenza" e "fedeltà del twin" richiede dataset clinici reali con etica e governance, che sono costosi e rari. È proprio per questo che la **RQ3** è cruciale.

### 6.5 Tre domande di ricerca PhD

**RQ1 — Ragionamento temporale in streaming.**
Come possiamo eseguire **ragionamento temporale incrementale** (valid-time RDF + OWL/SWRL delta-aware) su stream CPS/IoT con **latenza limitata e clinicamente tollerabile** — invece della periodica ri-materializzazione batch?

**RQ2 — Ragionamento federato verificabilmente privato.**
Possiamo progettare **ragionamento federato neuro-symbolico** che non esponga mai triple grezze del paziente *né* struttura del grafo re-identificante, con **garanzie di privacy provabili e piena auditabilità** (GDPR Art. 22)?

**RQ3 — Un benchmark CPS-KG-PDT condiviso.**
Quale suite di benchmark (dataset, metriche di interop/latenza/fedeltà, baseline) permetterebbe di confrontare architetture eterogenee KG-PDT su base paritaria — e quale scala di dati *sintetico→reale* la renderebbe clinicamente credibile?

> **La regola d'oro della scelta del topic:** *una tesi difendibile vive dove la matrice ha un "No" su un asse critico per il deployment*. Le tre RQ sono posizionate esattamente lì.

---

## 7. Sintesi finale (Key Takeaways)

1. **I KG sono il ponte** — ma la qualità del ponte è fissata dall'***allineamento ontologico***, non dal numero di sensori.
2. **L'ingestion è real-time; il ragionamento no** — quel divario *è* il problema della latenza clinica.
3. **Il ragionamento rule-based domina**; neuro-symbolic/RAG restano promettenti ma non ancorati clinicamente.
4. **Privacy e benchmark sono i due punti ciechi** dell'intero corpus.
5. **Una difendibile tesi di PhD vive dove la matrice ha un "No" su un asse critico per il deployment.**

---

## 8. Mappa dei paper e riferimenti

| # | Paper | Anno | Categoria | Contributo distintivo |
|---|---|---|---|---|
| 1 | Pourvahab et al. | 2025 | A — KG+IoT | Framework unificato RDF+R2RML, ingestion real-time distribuito |
| 2 | Gyrard et al. | 2024 | A — KG+IoT | IoT-DT salute mentale, 3 strati, temporal SPARQL, SDG-3 |
| 3 | Marfoglia et al. | 2026 | B — PDT | KG-driven PDT, FHIR R4 API, ontologia MIMO, stroke benchmark |
| 4 | Carbonaro et al. | 2023 | B — PDT | CONNECTED: blueprint concettuale PKG+DT, 4 requisiti |
| 5 | Krämer | 2025 | B — PDT | PMDT OWL 2.0, 5 Blueprint, SWRL all'edge, federazione class-assertion |
| 6 | Sarani Rad et al. | 2024 | B — PDT | PHKG-driven diabetes twin, CGM, validazione su coorte reale |
| 7 | Chatterjee et al. | 2024 | C — Wearable | MOX2-5, SSN/SOSA, pipeline CSV→RDF più concreta del corpus |
| 8 | Hendawi & Li | 2024 | C — Wearable | PHKG comprehensivo, EHR+wearable+assicurativo+SDoH, RBAC schema-native |

**Riferimenti completi (APA 7) e BibTeX:** si trovano in `KG_CPS_IoT_DigitalTwin_PhD_Bibliography.md` (root del progetto).

---

### Glossario rapido dei termini chiave

- **CPS (Cyber-Physical System):** sistema in cui componenti fisiche (sensori, attuatori) e computazionali sono strettamente accoppiati. In sanità: CGM, ventilatori, pompe di infusione.
- **IoT (Internet of Things):** rete di dispositivi connessi che scambiano dati; sovrapposto a CPS nel contesto sanitario (wearable).
- **KG (Knowledge Graph):** grafo diretto, etichettato, semanticamente fondato, sostenuto da un'ontologia formale.
- **Ontologia OWL (Web Ontology Language):** linguaggio formale per definire concetti, proprietà e vincoli, con semantica basata sulla logica descrittiva.
- **OWL-DL:** fragment di OWL decidibile (inferenza garantita terminante), basato sulla Description Logic.
- **SWRL (Semantic Web Rule Language):** linguaggio di regole di tipo Horn combinabile con OWL per inferenze che vanno oltre la pura DL.
- **RDF (Resource Description Framework):** modello a triple (soggetto–predicato–oggetto) per rappresentare dati sul Web semantico.
- **R2RML:** linguaggio standard W3C per mappare relational DB → RDF in modo dichiarativo.
- **SPARQL:** linguaggio di query per RDF (l'SQL del Web semantico).
- **SSN/SOSA:** ontologie W3C per descrivere sensori, osservazioni, campioni, attuatori.
- **FHIR (Fast Healthcare Interoperability Resources):** standard HL7 per lo scambio di dati sanitari via API RESTful.
- **SNOMED CT:** terminologia clinica comprehensiva (>350.000 concetti).
- **ICD-10:** classificazione internazionale delle malattie (uso amministrativo/epidemiologico).
- **Digital Twin:** replica digitale di un'entità fisica (qui: il paziente) che evolve e supporta simulazione/previsione.
- **PHKG (Personal Health Knowledge Graph):** KG centrato sul singolo paziente.
- **PKG (Personal Knowledge Graph):** grafo di conoscenza personale che evolve (concetto base di CONNECTED).
- **MIMO (Model Input/Model Output):** ontologia che standardizza le interfacce dei modelli AI.
- **SDoH (Social Determinants of Health):** fattori sociali/economici/ambientali che influenzano la salute.
- **RAG (Retrieval-Augmented Generation):** paradigma in cui un LLM recupera fatti da una fonte esterna (qui: il KG) prima di generare una risposta.
- **Neuro-symbolic:** approccio che combina sub-simbolico (reti neurali/embedding) e simbolico (regole/logica).
- **RBAC (Role-Based Access Control):** modello di controllo degli accessi basato sui ruoli.
- **Valid-time RDF:** estensione temporale di RDF dove ogni tripla reca il suo intervallo di validità.

---

*Spiegazione compilata a supporto delle slide `section2_modificata.qmd` — lezione PhD "Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins".*
