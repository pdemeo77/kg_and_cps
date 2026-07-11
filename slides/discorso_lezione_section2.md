# Discorso della lezione — Section 2
## From Heterogeneous Biomedical Data to Patient Digital Twins
### Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins

> Questo file accompagna le slide `section2_modificata_pasquale.qmd`. Segue l'ordine delle slide e fornisce il discorso esteso da tenere durante la lezione.

---

## Apertura — La tesi del "ponte semantico"

**[Slide: The Semantic Bridge Thesis]**

Buongiorno a tutti. La lezione di oggi si articola attorno a un'immagine semplice ma potente.

Immaginate tre blocchi. A sinistra i **sistemi CPS e IoT** — sensori, wearable, dispositivi medici che producono flussi di dati eterogenei. Al centro un **Knowledge Graph**, arricchito da standard come FHIR, SNOMED CT e SOSA. A destra il **Patient Digital Twin**, il gemello digitale del paziente.

Le frecce ci dicono due cose. Primo: i dati dei sensori attraversano il KG grazie a un **ponte semantico**. Secondo: il ragionamento sul KG alimenta il gemello digitale.

Il punto cruciale — e questa e la tesi della lezione — e il seguente: **la qualita del ponte** (ontologie, pipeline, ragionamento), non la quantita o la precisione dei sensori, determina l'affidabilita clinica di un Patient Digital Twin.

I dati dei CPS sono sintatticamente ricchi ma semanticamente poveri: un valore di glucosio `72` non ci dice unita di misura, paziente, timestamp, o significato clinico. Il KG aggiunge esattamente questo strato di significato, rendendo le osservazioni interrogabili, ragionabili e clinicamente confrontabili.

---

**[Slide: Roadmap]**

La lezione si articola in quattro parti.

Nella **prima** stabiliremo i fondamenti ontologici: quali standard usiamo e come si combinano. Nella **seconda** esamineremo le pipeline di integrazione, cioe come i dati passano dal sensore alla tripla RDF. Nella **terza** affronteremo il ragionamento: come il KG "pensa" e produce inferenze cliniche. Nella **quarta** sintetizzeremo le sfide aperte e le domande di ricerca.

Ci baseremo su **otto paper recenti** (2023-2026). Sentitevi liberi di suggerire altri riferimenti rilevanti durante la discussione.

---

## Sezione 1 — Fondamenti e standard

**[Slide: Section 1 — Foundations & Standards]**

Partiamo dalle fondamenta. Prima di costruire qualsiasi pipeline, dobbiamo rispondere a una domanda: *che lingua parlano i sensori?*

L'obiettivo e stabilire il **vocabolario ontologico** e l'**architettura concettuale**. Ci ancoriamo a tre paper: Hendawi e Li per le terminologie cliniche, Chatterjee et al. per le ontologie di sensore, e Carbonaro et al. come blueprint concettuale.

*[Le tre slide di dettaglio su questi paper sono state commentate e verranno illustrate oralmente dal docente.]*

### Nota orale — I tre paper di fondamento

**Hendawi & Li (2024)** propongono un Personal Health Knowledge Graph che unifica cartelle cliniche, wearable, dati assicurativi e determinanti sociali della salute sotto un unico schema OWL con SNOMED CT e ICD-10. La novita interessante e che la privacy e *nello schema*, non aggiunta dopo: il controllo degli accessi basato sui ruoli e incorporato nel KG.

**Chatterjee et al. (2024)** forniscono il riferimento piu concreto su come "triplificare un wearable". Annotano osservazioni di un accelerometro MOX2-5 come triple OWL/RDF usando lo standard W3C SSN/SOSA, che modella formalmente sensore, osservazione, feature-of-interest e risultato. La pipeline converte CSV in RDF e confronta dati reali con sintetici tramite SPARQL.

**Carbonaro et al. (2023)**, con CONNECTED, offrono una systematic review distillata in un'architettura a strati: acquisizione CPS/IoT, allineamento semantico OWL/FHIR, Personal Knowledge Graph e simulazione DT. Formalizzano quattro requisiti raramente co-locati: interoperabilita semantica, privacy-by-design, fusione dati in tempo reale e ragionamento temporale.

---

**[Slide: Ontology Stacking]**

Questa slide mostra come nessuno standard sia canonico da solo. Ogni ontologia copre un aspetto diverso, e il **KG e il punto in cui vengono riconciliate**.

- **SSN/SOSA** descrive la provenance dell'osservazione: chi ha misurato, come e quando.
- **FHIR** e la spina dorsale dello scambio dati tramite API RESTful.
- **SNOMED CT** fornisce la semantica clinica, con oltre 350.000 concetti.
- **ICD-10** da la granularita amministrativa per classificazione e billing.
- **OWL 2.0** e la logica che vincola e lega tutti gli altri.

Il messaggio chiave: il KG e dove questi vocabolari si incontrano. Proprio per questo, **l'allineamento ontologico e il collo di bottiglia piu fragile**. Mappare "glucosio" di SNOMED CT sul codice E87 di ICD-10 non e banale, e errori qui si propagano a tutte le inferenze a valle.

---

## Sezione 2 — Pipeline di integrazione CPS verso KG

**[Slide: Section 2 — CPS-to-KG Integration Pipelines]**

Entriamo nel cuore ingegneristico della lezione. Il ponte non e un concetto astratto: e un artefatto progettato. I dati devono passare dall'essere un voltaggio su un polso all'essere una tripla in un grafo.

Il percorso e: *ingestion, mapping, materializzazione delle triple, query*. Confronteremo quattro architetture lungo uno spettro: quanto avviene all'edge rispetto al centro, e con quale frequenza.

---

**[Slide: The Generic Sensor-to-Triple Pipeline]**

Prima di vedere i casi specifici, guardiamo la pipeline generica.

Partiamo dai dispositivi fisici — wearable, CGM, EEG — che producono dati grezzi in CSV, JSON o stream. Poi c'e la fase di **mapping ontologico** con linguaggi come R2RML, SOSA o FHIR. Il risultato e un **grafo RDF** con triple OWL. Infine il **ragionamento** tramite SPARQL, SWRL o machine learning, che alimenta il Digital Twin.

Ogni paper che vedremo e un'istanziazione di questi stadi. Differiscono per il linguaggio di mapping, per dove avviene la materializzazione e per la frequenza di aggiornamento.

La domanda ingegneristica onesta non e "RDF o no?", ma **"materializzazione in tempo reale o ricostruzione batch?"**.

---

**[Slide: Pourvahab et al. — RDF + R2RML]**

Il primo caso e Pourvahab et al. (2025). L'architettura usa **R2RML** per mappare dichiarativamente dati sanitari relazionali in triple allineate a OWL. Uno strato distribuito assorbe il volume IoT in tempo reale.

I passi di trasformazione sono: riga relazionale, template R2RML, tripla RDF, nodo classificato OWL, vocabolario compatibile FHIR.

Il trade-off: l'ingestione e real-time, ma **l'inferenza graph-ML e batch** sul grafo costruito. Per allerte a bassa latenza serve un bypass di streaming separato.

R2RML e dichiarativo: le regole di mapping vivono in un file separato, non nel codice. Questo rende il mapping ispezionabile, versionabile e riapplicabile quando lo schema sorgente cambia.

---

**[Slide: Chatterjee et al. — CSV verso RDF con SSN/SOSA]**

Il secondo caso e Chatterjee et al. (2024). E la pipeline CSV-RDF piu concreta del corpus.

L'accelerometro MOX2-5 produce un CSV. Questo viene annotato con SSN/SOSA: ogni riga diventa una `sosa:Observation` con `hasResult`, collegata al `FeatureOfInterest` che e il paziente. Il risultato e un grafo RDF OWL-compliant, interrogabile con SPARQL e allineabile a FHIR.

Il trade-off: il proof-of-concept e **offline/batch**. Guadagna semplicita e riproducibilita, ma perde in latenza, quindi non e adatto al monitoraggio acuto.

---

**[Slide: Gyrard et al. — Pipeline a tre strati]**

Gyrard et al. (2024) propongono un'architettura a tre strati per la salute mentale.

Il **primo strato** raccoglie segnali fisiologici da wearable IoT: EEG, risposta galvanica della pelle, frequenza cardiaca. Il **secondo strato** fa l'interoperabilita semantica con IoT-Lite e SOSA/SSN, producendo annotazioni RDF. Il **terzo strato** e il Digital Twin guidato dal KG, che modella le traiettorie di salute mentale.

Il ragionamento cross-domain usa FHIR, SNOMED CT e lo stack W3C. Il monitoraggio delle emozioni e near-real-time, ma il ragionamento e guidato da query SPARQL temporali, quindi semi-batch. Buono per screening e prevenzione, insufficiente per intervento in crisi.

---

**[Slide: Marfoglia et al. — FHIR + MIMO]**

L'ultimo caso, Marfoglia et al. (2026), e il piu recente del corpus.

Una **FHIR R4 REST API** recupera stream EHR e IoT time-stamped in un KG persistente OWL-DL. L'ontologia **MIMO** (Model Input/Model Output) standardizza gli input e output di ogni modello AI, permettendo una composizione trasparente e riutilizzabile. Un protocollo di binding basato su manifest automatizza la registrazione dei modelli.

Il concetto interessante e la **gap detection automatica**: il sistema "sa" quali dati servirebbero per una certa inferenza e segnala quando mancano. Qualcosa che un database tradizionale non puo fare.

Il trade-off: retrieval API in tempo reale, ma la latenza di inferenza OWL-DL sotto carico e il freno.

---

**[Slide: Confronto real-time vs batch]**

Questa tabella riassume le quattro architetture.

Il **pattern universale** e chiaro: l'ingestione si muove verso il real-time, ma il ragionamento resta batch o periodico. **Il divario tra i due e il collo di bottiglia della latenza clinica.**

Nessuna delle quattro architetture fornisce ragionamento incrementale in streaming con garanzie di latenza limitata. Questo e il cuore del problema pratico: un paziente puo generare migliaia di punti al secondo, ma se il ragionamento gira solo ogni ora, la "freschezza" dei dati e sprecata.

---

## Sezione 3 — Digital Twin e ragionamento AI

**[Slide: Section 3 — Digital Twin & AI Reasoning]**

Arriviamo alla domanda: come "pensa" il grafo? E soprattutto, ha ragione?

Le famiglie di ragionamento in gioco sono tre: **rule-based** (OWL-DL e SWRL), **neuro-simbolico/RAG**, e **query-driven** con inferenza temporale. Per ciascuna vedremo meccanismo, validazione e gap di applicabilita clinica.

---

**[Slide: The Reasoning Mechanism Landscape]**

Il panorama dei meccanismi di ragionamento si articola cosi.

Il **rule-based** (OWL-DL/SWRL) e trasparente e auditabile, ma fragile e oneroso da scrivere. E usato da Marfoglia, Kramer e Sarani Rad.

Il **neuro-simbolico** e il **RAG** sono emergenti per QA clinica: scambiano parte dell'auditabilita per adattivita, ma non sono ancora ancorati a sistemi deployati nel nostro corpus.

Il **gap comune** a tutti: scarsa validazione clinica prospettica. Quasi tutto e retrospettivo o proof-of-concept.

---

**[Slide: Marfoglia — OWL-DL + MIMO]**

Marfoglia et al. (2026) usano inferenza **OWL-DL** per imporre consistenza semantica e attivare automaticamente la gap detection. L'ontologia MIMO standardizza I/O dei modelli AI per composizione multi-modello dinamica.

La validazione e un benchmark end-to-end sulla **predizione del rischio di ictus** con stream clinici reali time-aware.

Il gap: nessun trial prospettico, generalizzazione oltre lo stroke non testata, latenza di ragionamento OWL-DL sotto carico non quantificata.

---

**[Slide: Kramer — SWRL federato]**

Kramer (2025) propone il Patient Medical Digital Twin in OWL 2.0 con cinque Blueprint clinici. Le **regole SWRL sono eseguite all'edge** su serie temporali IoT multimodali. Solo le asserzioni di classe OWL — mai i dati grezzi — sono propagate centralmente.

Questo pattern "class assertions only" e geniale per la privacy: invece di spedire "glicemia=72 alle 14:32 del paziente Rossi", l'edge classifica e spedisce solo "questa osservazione e un'istanza di HypoglycaemiaRisk". Il ragionamento centrale opera su concetti, non su valori sensibili.

La validazione e su scenari sintetici in diabete e scompenso cardiaco. Il gap: solo sintetico, nessun deploy reale, ragionamento federato non testato a scala.

---

**[Slide: Sarani Rad — PHKG per il diabete]**

Sarani Rad et al. (2024) costruiscono un PHKG come substrato del Digital Twin. Il grafo si **auto-aggiorna** quando arrivano osservazioni CGM, EHR o PROM. Il ragionamento OWL inferisce pattern di rischio di ipoglicemia e suggerimenti di aggiustamento farmacologico.

E l'esempio clinico piu completo del corpus: valutato su una **coorte di pazienti reali**, con predizione degli outcome glicemici superiore ai baseline rule-based.

Il gap: malattia singola, coorte retrospettiva, nessun RCT prospettico, latenza di aggiornamento del PHKG sotto CGM ad alta frequenza non affrontata.

---

**[Slide: Gyrard — Mental-Health Twin]**

Gyrard et al. (2024) usano query **SPARQL temporali** per rilevare traiettorie di burnout e depressione nel KG del paziente.

La validazione e un proof-of-concept legato ai target SDG-3, senza benchmark su coorte clinica.

Il gap: l'affetto non ha una rappresentazione pulita in SNOMED CT, quindi il ragionamento poggia su semantica clinica sotto-specificata. Un caveat epistemologico importante: se il concetto che si vuole inferire manca di una codifica standard solida, l'inferenza riposa su fondamenta semantiche fragili. **L'ontologia limita cio che si puo ragionare.**

---

## Sezione 4 — Sfide aperte e frontiere di ricerca

**[Slide: Section 4 — Open Challenges]**

L'ultima sezione sintetizza tutti gli otto paper su quattro assi: scalabilita, ragionamento temporale, privacy e federazione, benchmark di valutazione. L'obiettivo e convertire i gap in tre domande di ricerca per un dottorato.

---

**[Slide: Sintesi cross-paper]**

Questa tabella semplificata mostra la copertura dei paper sui quattro assi.

La **privacy** e l'asse piu raro. I **benchmark** sono inconsistenti: ogni paper usa i propri dataset e metriche. Solo due paper affrontano la scalabilita in modo convincente.

---

**[Slide: Scalabilita e ragionamento temporale]**

La contraddizione fondamentale: gli stream CPS esigono grafi freschi, ma il ragionamento OWL-DL/SWRL e **non incrementale**. Il costo di ri-materializzazione cresce con la dimensione del grafo.

Solo Pourvahab e Marfoglia affrontano la scala, e nessuno dei due fornisce ragionamento incrementale in streaming con latenza limitata.

Il supporto temporale e per lo piu query-time (SPARQL) o scenario-based, non un modello temporale first-class come il **valid-time RDF**, dove ogni tripla porta informazioni di validita temporale.

---

**[Slide: Privacy e KG federati]**

Sulla privacy, i migliori della classe sono: Kramer che propaga solo asserzioni di classe OWL, Hendawi e Li che incorporano RBAC nello schema, e Carbonaro che eleva la privacy-by-design a requisito.

Il **gap collettivo**: nessuna differential privacy, nessuna secure multi-party computation, nessuna federazione verificabile sui KG sanitari. La **re-identificazione basata su inferenza** di pazienti rari e completamente inanalizzata.

Anche se non condividi il nome del paziente, la struttura del grafo puo tradirlo: un paziente con una combinazione rara di diagnosi, farmaci e determinanti sociali e univocamente identificabile.

---

**[Slide: Benchmark di valutazione]**

Ogni paper inventa il proprio dataset e la propria metrica: metriche di interoperabilita, copertura SPARQL, AUC di coorte, benchmark di scalabilita, completezza sintetica.

**Non esiste un benchmark CPS-KG-PDT condiviso** che misuri insieme interoperabilita semantica, latenza di inferenza e fedelta del twin.

La validazione solo sintetica non puo certificare la correttezza clinica. Ed e proprio per questo che la terza domanda di ricerca e cruciale.

---

**[Slide: Three Open PhD Research Questions]**

Le tre domande di ricerca che emergono dalla sintesi sono:

**RQ1 — Ragionamento temporale in streaming.** Come eseguire ragionamento temporale incrementale su stream CPS/IoT con latenza limitata e clinicamente tollerabile, invece della periodica ri-materializzazione batch?

**RQ2 — Ragionamento federato verificabilmente privato.** Possiamo progettare ragionamento federato neuro-simbolico che non esponga mai triple grezze ne struttura del grafo re-identificante, con garanzie di privacy provabili e piena auditabilita (GDPR Art. 22)?

**RQ3 — Un benchmark CPS-KG-PDT condiviso.** Quale suite di benchmark permetterebbe di confrontare architetture eterogenee KG-PDT su base paritaria, e quale scala di dati sintetico-reale la renderebbe clinicamente credibile?

La regola d'oro: una tesi difendibile vive dove la matrice ha un "No" su un asse critico per il deployment.

---

## Chiusura — Key Takeaways

**[Slide: Key Takeaways]**

Riassumiamo in cinque punti.

1. **I KG sono il ponte** — ma la qualita del ponte e fissata dall'allineamento ontologico, non dal numero di sensori.
2. **L'ingestione e real-time; il ragionamento no** — quel divario e il problema della latenza clinica.
3. **Il ragionamento rule-based domina**; neuro-simbolico e RAG restano promettenti ma non ancorati clinicamente.
4. **Privacy e benchmark sono i due punti ciechi** dell'intero corpus.
5. **Una tesi difendibile vive dove la matrice ha un "No"** su un asse critico per il deployment.

Grazie per l'attenzione. Sono disponibile per domande e discussione.

---

## Riferimenti bibliografici

I paper di riferimento (2023-2026):

1. **Pourvahab et al. (2025)** — Framework unificato RDF+R2RML per interoperabilita IoT-sanita. ACM SAC.
2. **Gyrard et al. (2024)** — IoT-DT salute mentale, 3 strati, temporal SPARQL. arXiv.
3. **Marfoglia et al. (2026)** — KG-driven PDT, FHIR R4 API, ontologia MIMO, benchmark stroke. FGCS.
4. **Carbonaro et al. (2023)** — CONNECTED: blueprint concettuale PKG+DT, 4 requisiti. Frontiers in Digital Health.
5. **Kramer (2025)** — PMDT OWL 2.0, SWRL all'edge, federazione class-assertion. arXiv.
6. **Sarani Rad et al. (2024)** — PHKG-driven diabetes twin, CGM, validazione su coorte reale. J. Personalized Medicine.
7. **Chatterjee et al. (2024)** — MOX2-5, SSN/SOSA, pipeline CSV-RDF. Scientific Reports.
8. **Hendawi & Li (2024)** — PHKG comprehensivo, EHR+wearable+SDoH, RBAC schema-native. IEEE AIMHC.

I riferimenti completi con DOI sono nel file `KG_CPS_IoT_DigitalTwin_PhD_Bibliography.md`.
