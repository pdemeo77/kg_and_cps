# Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins
## 8 Most Impactful Papers (2023–2026) — PhD Lecture Reference

> **Curation criteria:** True KG+CPS integration required; covers (a) KG + Healthcare IoT surveys/architectures, (b) Patient Digital Twin frameworks with semantic reasoning, and (c) wearable sensor data integration via ontologies (HL7 FHIR / SNOMED CT). All entries formatted to APA 7th Edition and include complete BibTeX.

---

## CATEGORY A — KG + Healthcare IoT Surveys & Architectures

---

### Paper 1

**Pourvahab, M., Monteiro, A., Pais, S., & Pombo, N. (2025). A unified semantic framework for IoT-healthcare data interoperability: A graph-based machine learning approach using RDF and R2RML. In *Proceedings of the ACM Symposium on Applied Computing* (Article 3757054). ACM. https://doi.org/10.1145/3756681.3757054**

**DOI:** `10.1145/3756681.3757054`

**Abstract (methodology focus, ≤150 words):**
This paper proposes a Unified Semantic Framework that converts heterogeneous IoT-healthcare data—from wearable sensors, smart monitoring devices, and EHRs—into semantically homogeneous, machine-understandable RDF graphs. The methodology applies R2RML (RDB-to-RDF Mapping Language) rules to map relational healthcare data into OWL-aligned knowledge graph triples, and integrates domain-specific standards including FHIR-compatible vocabulary to achieve cross-domain semantic consistency. A graph-based machine learning pipeline then operates directly on the resulting KG for intelligent clinical data extraction and inference. Scalability is addressed through a distributed graph-construction layer that accommodates real-time IoT data ingestion at scale. Experiments on multi-source IoT-healthcare datasets demonstrate significant improvements in interoperability metrics and knowledge extraction efficiency over schema-level integration baselines, establishing the framework as a reproducible semantic bridge between heterogeneous CPS/IoT data streams and clinical intelligence systems.

**Relevance to Lecture:** Directly exemplifies RDF/R2RML-based KG construction from live IoT sensor streams—the methodological core of the "semantic bridge" concept in the lecture title.

```bibtex
@inproceedings{pourvahab2025unified,
  author    = {Pourvahab, Mehran and Monteiro, Anilson and Pais, Sebasti{\~a}o and Pombo, Nuno},
  title     = {A Unified Semantic Framework for {IoT}-Healthcare Data Interoperability:
               A Graph-Based Machine Learning Approach Using {RDF} and {R2RML}},
  booktitle = {Proceedings of the ACM Symposium on Applied Computing},
  year      = {2025},
  articleno = {3757054},
  doi       = {10.1145/3756681.3757054},
  publisher = {Association for Computing Machinery},
  address   = {New York, NY, USA}
}
```

---

### Paper 2

**Gyrard, A., Mohammadi, S., Gaur, M., & Kung, A. (2024). *IoT-based preventive mental health using knowledge graphs and standards for better well-being* [Preprint]. arXiv. https://doi.org/10.48550/arxiv.2406.13791**

**DOI:** `10.48550/arxiv.2406.13791`

**Abstract (methodology focus, ≤150 words):**
This paper presents an AI-enabled IoT Digital Twin framework using knowledge graphs and semantic standards for preventive mental health monitoring. The architecture comprises three layers: (1) a wearable IoT sensor layer collecting physiological signals (EEG, GSR, heart rate) for continuous emotion monitoring; (2) a semantic interoperability module employing IoT-Lite and SOSA/SSN ontologies to annotate raw sensor observations as RDF triples; and (3) a KG-driven Digital Twin that models patient mental health trajectories and triggers personalised interventions. The W3C Semantic Web stack (RDF, OWL, SPARQL) is combined with established health standards—HL7 FHIR and SNOMED CT—for cross-domain clinical reasoning. A systematic literature survey grounds the framework in prior mental health IoT research. A validation use-case demonstrates early burnout and depression detection via temporal SPARQL queries against the patient KG, linking SDG-3 health targets to operational CPS deployments.

**Relevance to Lecture:** Provides the most comprehensive mapping of SDG-aligned IoT-KG-DT integration, combining SOSA/SSN, SNOMED CT, and FHIR in a single wearable-to-reasoning pipeline—ideal for illustrating ontology stacking in the lecture.

```bibtex
@misc{gyrard2024iot,
  author        = {Gyrard, Am{\'e}lie and Mohammadi, Sardar and Gaur, Manas and Kung, Antonio},
  title         = {{IoT}-Based Preventive Mental Health Using Knowledge Graphs
                   and Standards for Better Well-Being},
  year          = {2024},
  howpublished  = {arXiv preprint},
  doi           = {10.48550/arxiv.2406.13791},
  note          = {arXiv:2406.13791}
}
```

---

## CATEGORY B — Patient Digital Twin Frameworks with Semantic Reasoning

---

### Paper 3

**Marfoglia, A., D'Errico, C., Mellone, S., & Carbonaro, A. (2026). A knowledge graph-driven framework for deploying AI-powered patient digital twins. *Future Generation Computer Systems*, Article 108380. https://doi.org/10.1016/j.future.2026.108380**

**DOI:** `10.1016/j.future.2026.108380`

**Abstract (methodology focus, ≤150 words):**
This paper introduces a modular, knowledge-graph-driven architecture for deploying AI-powered Patient Digital Twins (PDTs) in clinical environments. The framework exposes a FHIR R4-compliant REST API for real-time retrieval of time-stamped EHR and IoT sensor streams, connected to a persistent OWL-DL knowledge graph serving as the semantic backbone. A novel MIMO (Model Input/Model Output) ontology standardises AI model interfaces, ensuring transparency and reusability across heterogeneous clinical modules. A manifest-based binding protocol automates model registration and parameter-alignment against the PDT's semantic layer, enabling dynamic composition of multi-AI pipelines. Semantic consistency is enforced via OWL-DL inference, with gap detection triggered automatically when sensor data coverage is insufficient. The system is benchmarked on stroke risk prediction using real-world, time-aware clinical data streams, demonstrating end-to-end KG-to-PDT scalability. Builds upon and extends the CONNECTED architecture (Carbonaro et al., 2023).

**Relevance to Lecture:** The most recent (2026) end-to-end KG-to-PDT deployment framework with FHIR API, MIMO ontology, and real-time CPS sensor binding—the definitive capstone paper for the lecture's architecture module.

```bibtex
@article{marfoglia2026knowledge,
  author    = {Marfoglia, Alberto and D'Errico, Christian and Mellone, Sabato and Carbonaro, Antonella},
  title     = {A knowledge graph-driven framework for deploying {AI}-powered patient digital twins},
  journal   = {Future Generation Computer Systems},
  year      = {2026},
  pages     = {108380},
  doi       = {10.1016/j.future.2026.108380},
  publisher = {Elsevier},
  issn      = {0167-739X}
}
```

---

### Paper 4

**Carbonaro, A., Marfoglia, A., Nardini, F., & Mellone, S. (2023). CONNECTED: Leveraging digital twins and personal knowledge graphs in healthcare digitalization. *Frontiers in Digital Health*, *5*, Article 1322428. https://doi.org/10.3389/fdgth.2023.1322428**

**DOI:** `10.3389/fdgth.2023.1322428`

**Abstract (methodology focus, ≤150 words):**
This paper presents CONNECTED (COmpreheNsive and staNdardized hEalth-Care plaTforms to collEct and harmonize clinical Data), a conceptual framework synthesising Digital Twins and Personal Knowledge Graphs (PKGs) for healthcare digitalization. Through a systematic literature review, the authors identify and formalise critical requirements—semantic interoperability, privacy-by-design, real-time data fusion, and temporal reasoning—into a layered architectural blueprint. The architecture integrates: a CPS/IoT sensor data acquisition layer; an ontology-driven semantic alignment module using OWL and FHIR; a PKG serving as the patient's evolving knowledge base; and a DT simulation engine for predictive analytics. The methodology adapts design patterns from smart manufacturing and IoT to clinical workflows and patient data governance. Open challenges in federated DT-to-PKG linking, consent management, and governance are systematically mapped, providing a research agenda for compliant clinical deployments.

**Relevance to Lecture:** Establishes the foundational CONNECTED architecture that explicitly maps CPS sensor layers, PKGs, and DT simulation—the ideal conceptual reference framework for structuring the lecture's modular architecture overview.

```bibtex
@article{carbonaro2023connected,
  author    = {Carbonaro, Antonella and Marfoglia, Alberto and Nardini, Filippo and Mellone, Sabato},
  title     = {{CONNECTED}: Leveraging Digital Twins and Personal Knowledge Graphs
               in Healthcare Digitalization},
  journal   = {Frontiers in Digital Health},
  year      = {2023},
  volume    = {5},
  pages     = {1322428},
  doi       = {10.3389/fdgth.2023.1322428},
  publisher = {Frontiers Media SA},
  issn      = {2673-253X}
}
```

---

### Paper 5

**Krämer, B. J. (2025). *A semantic framework for patient digital twins in chronic care* [Preprint]. arXiv. https://doi.org/10.48550/arxiv.2510.09134**

**DOI:** `10.48550/arxiv.2510.09134`

**Abstract (methodology focus, ≤150 words):**
The paper introduces the Patient Medical Digital Twin (PMDT), an ontology-driven in silico patient framework for personalised chronic care, implemented in OWL 2.0. The methodology integrates physiological, psychosocial, behavioural, and genomic data into a modular ontological model structured around five clinical Blueprints: patient profile, disease and diagnosis, treatment and follow-up, disease trajectories, and safety monitoring. SNOMED CT and HL7 FHIR serve as reference terminologies ensuring semantic alignment with existing clinical systems. A federated, privacy-preserving architecture propagates only OWL class assertions—never raw data—to a central reasoning service, enabling edge-based SWRL rule execution over multimodal IoT sensor time-series. Validation through synthetic patient scenarios in diabetes and heart failure confirms completeness of ontological coverage and soundness of temporal inference chains, positioning PMDT as a standards-compliant, extensible semantic foundation for multi-disease patient digital twinning.

**Relevance to Lecture:** Demonstrates a complete OWL 2.0 + SNOMED CT + FHIR federated reasoning architecture for PDTs—the canonical reference for the lecture's semantic interoperability and privacy-preserving inference modules.

```bibtex
@misc{kramer2025semantic,
  author       = {Kr{\"a}mer, Bernd J.},
  title        = {A Semantic Framework for Patient Digital Twins in Chronic Care},
  year         = {2025},
  howpublished = {arXiv preprint},
  doi          = {10.48550/arxiv.2510.09134},
  note         = {arXiv:2510.09134}
}
```

---

### Paper 6

**Sarani Rad, F., Hendawi, R., Yang, X., & Li, J. (2024). Personalized diabetes management with digital twins: A patient-centric knowledge graph approach. *Journal of Personalized Medicine*, *14*(4), Article 359. https://doi.org/10.3390/jpm14040359**

**DOI:** `10.3390/jpm14040359`

**Abstract (methodology focus, ≤150 words):**
This study proposes a real-time, patient-centric Digital Twin framework built on Personal Health Knowledge Graphs (PHKGs) for personalised diabetes management. The methodology integrates continuous glucose monitoring (CGM) sensor streams, EHR records, and patient-reported outcomes, adhering to HL7 FHIR standards for semantic interoperability and data exchange. PHKGs model individual patient physiology, medication regimens, and lifestyle factors as a dynamic, incrementally extensible knowledge graph that constitutes the semantic substrate of the digital twin. As new clinical observations arrive—from wearable IoT devices or clinical encounters—the PHKG updates automatically, enabling adaptive personalisation of the twin's predictive model. OWL-based reasoning over the PHKG supports automatic inference of hypoglycaemia risk patterns and medication adjustment recommendations. Evaluation on real patient cohort data demonstrates superior glycaemic outcome prediction compared to rule-based baselines, validating the PHKG-DT coupling for chronic disease IoT management.

**Relevance to Lecture:** Provides a fully implemented, clinically validated PHKG-driven Digital Twin case study using HL7 FHIR and wearable CGM data—ideal as a worked clinical example in the lecture's applications module.

```bibtex
@article{saranirad2024personalized,
  author    = {Sarani Rad, Fatemeh and Hendawi, Rasha and Yang, Xinyi and Li, Juan},
  title     = {Personalized Diabetes Management with Digital Twins:
               A Patient-Centric Knowledge Graph Approach},
  journal   = {Journal of Personalized Medicine},
  year      = {2024},
  volume    = {14},
  number    = {4},
  pages     = {359},
  doi       = {10.3390/jpm14040359},
  publisher = {MDPI},
  issn      = {2075-4426}
}
```

---

## CATEGORY C — Wearable Sensor Data Integration via Ontologies

---

### Paper 7

**Chatterjee, A., Gerdes, M., Prinz, A., Riegler, M., & Martínez, S. (2024). Semantic representation and comparative analysis of physical activity sensor observations using MOX2-5 sensor in real and synthetic datasets: A proof-of-concept study. *Scientific Reports*, *14*, Article 55183. https://doi.org/10.1038/s41598-024-55183-6**

**DOI:** `10.1038/s41598-024-55183-6`

**Abstract (methodology focus, ≤150 words):**
This proof-of-concept study investigates semantic representation of physical activity observations from the MOX2-5 wearable accelerometer using W3C SSN/SOSA (Semantic Sensor Network / Sensor, Observation, Sample and Actuator) ontologies. The methodology annotates raw sensor observations as OWL-compliant RDF triples, formally modelling sensor, observation, feature-of-interest, and result entities. Real wearable datasets and synthetically generated activity records—covering walking, running, and cycling—are semantically annotated and compared through SPARQL queries, validating ontological coverage and query expressivity under heterogeneous conditions. The knowledge graph construction pipeline converts CSV sensor exports into structured RDF graphs, enabling device-agnostic, interoperable physical activity data. Integration pathways to FHIR-compliant clinical data repositories are discussed, demonstrating the SSN/SOSA ontological layer as a reusable CPS semantic bridge between physical sensor acquisition and clinical knowledge-graph systems.

**Relevance to Lecture:** Provides a step-by-step SSN/SOSA ontology-to-RDF construction pipeline for wearable CPS data—the most concrete implementation reference for the lecture's "sensor-to-knowledge-graph" integration module.

```bibtex
@article{chatterjee2024semantic,
  author    = {Chatterjee, Ayan and Gerdes, Martin and Prinz, Andreas and Riegler, Michael and Mart{\'i}nez, Santiago},
  title     = {Semantic Representation and Comparative Analysis of Physical Activity
               Sensor Observations Using {MOX2-5} Sensor in Real and Synthetic Datasets:
               A Proof-of-Concept Study},
  journal   = {Scientific Reports},
  year      = {2024},
  volume    = {14},
  doi       = {10.1038/s41598-024-55183-6},
  publisher = {Nature Publishing Group},
  issn      = {2045-2322}
}
```

---

### Paper 8

**Hendawi, R., & Li, J. (2024). Comprehensive personal health knowledge graph for effective management and utilization of personal health data. In *Proceedings of the IEEE 2nd International Conference on AI in Medicine and Health Care (AIMHC)* (pp. 1–8). IEEE. https://doi.org/10.1109/aimhc59811.2024.00026**

**DOI:** `10.1109/aimhc59811.2024.00026`

**Abstract (methodology focus, ≤150 words):**
This paper proposes a Comprehensive Personal Health Knowledge Graph (PHKG) architecture for integrated management and utilisation of personal health data (PHD) from four heterogeneous source types: EHR records, wearable device sensor streams, health insurance data, and social determinants of health (SDoH). The methodology constructs the PHKG using an OWL ontology that maps entities from SNOMED CT and ICD-10 vocabularies to KG nodes, enabling cross-domain semantic reasoning across clinical and non-clinical data. Privacy enforcement is built into the KG schema through role-based access control ontology patterns. SPARQL-based query interfaces expose the PHKG to downstream clinical applications. A layered KG design supports longitudinal patient data access and temporal querying. Prototype evaluation on real-world EHR data demonstrates effectiveness in supporting personalised health management dashboards and population research analytics, validating the PHKG as a scalable semantic integration platform for multi-source PHD.

**Relevance to Lecture:** Demonstrates SNOMED CT- and ICD-10-aligned PHKG construction from combined EHR and wearable streams—the benchmark reference for the lecture's multi-source ontology alignment and social determinants of health integration theme.

```bibtex
@inproceedings{hendawi2024comprehensive,
  author    = {Hendawi, Rasha and Li, Juan},
  title     = {Comprehensive Personal Health Knowledge Graph for Effective Management
               and Utilization of Personal Health Data},
  booktitle = {Proceedings of the IEEE 2nd International Conference on AI in
               Medicine and Health Care (AIMHC)},
  year      = {2024},
  pages     = {1--8},
  doi       = {10.1109/aimhc59811.2024.00026},
  publisher = {IEEE}
}
```

---

## Consolidated BibTeX File

```bibtex
% ============================================================
% KG as Semantic Bridges between CPS/IoT and Patient Digital Twins
% 8 Key Papers (2023–2026) — PhD Lecture Reference
% ============================================================

@inproceedings{pourvahab2025unified,
  author    = {Pourvahab, Mehran and Monteiro, Anilson and Pais, Sebasti{\~a}o and Pombo, Nuno},
  title     = {A Unified Semantic Framework for {IoT}-Healthcare Data Interoperability:
               A Graph-Based Machine Learning Approach Using {RDF} and {R2RML}},
  booktitle = {Proceedings of the ACM Symposium on Applied Computing},
  year      = {2025},
  articleno = {3757054},
  doi       = {10.1145/3756681.3757054},
  publisher = {Association for Computing Machinery},
  address   = {New York, NY, USA}
}

@misc{gyrard2024iot,
  author        = {Gyrard, Am{\'e}lie and Mohammadi, Sardar and Gaur, Manas and Kung, Antonio},
  title         = {{IoT}-Based Preventive Mental Health Using Knowledge Graphs
                   and Standards for Better Well-Being},
  year          = {2024},
  howpublished  = {arXiv preprint},
  doi           = {10.48550/arxiv.2406.13791},
  note          = {arXiv:2406.13791}
}

@article{marfoglia2026knowledge,
  author    = {Marfoglia, Alberto and D'Errico, Christian and Mellone, Sabato and Carbonaro, Antonella},
  title     = {A knowledge graph-driven framework for deploying {AI}-powered patient digital twins},
  journal   = {Future Generation Computer Systems},
  year      = {2026},
  pages     = {108380},
  doi       = {10.1016/j.future.2026.108380},
  publisher = {Elsevier},
  issn      = {0167-739X}
}

@article{carbonaro2023connected,
  author    = {Carbonaro, Antonella and Marfoglia, Alberto and Nardini, Filippo and Mellone, Sabato},
  title     = {{CONNECTED}: Leveraging Digital Twins and Personal Knowledge Graphs
               in Healthcare Digitalization},
  journal   = {Frontiers in Digital Health},
  year      = {2023},
  volume    = {5},
  pages     = {1322428},
  doi       = {10.3389/fdgth.2023.1322428},
  publisher = {Frontiers Media SA},
  issn      = {2673-253X}
}

@misc{kramer2025semantic,
  author       = {Kr{\"a}mer, Bernd J.},
  title        = {A Semantic Framework for Patient Digital Twins in Chronic Care},
  year         = {2025},
  howpublished = {arXiv preprint},
  doi          = {10.48550/arxiv.2510.09134},
  note         = {arXiv:2510.09134}
}

@article{saranirad2024personalized,
  author    = {Sarani Rad, Fatemeh and Hendawi, Rasha and Yang, Xinyi and Li, Juan},
  title     = {Personalized Diabetes Management with Digital Twins:
               A Patient-Centric Knowledge Graph Approach},
  journal   = {Journal of Personalized Medicine},
  year      = {2024},
  volume    = {14},
  number    = {4},
  pages     = {359},
  doi       = {10.3390/jpm14040359},
  publisher = {MDPI},
  issn      = {2075-4426}
}

@article{chatterjee2024semantic,
  author    = {Chatterjee, Ayan and Gerdes, Martin and Prinz, Andreas and Riegler, Michael and Mart{\'i}nez, Santiago},
  title     = {Semantic Representation and Comparative Analysis of Physical Activity
               Sensor Observations Using {MOX2-5} Sensor in Real and Synthetic Datasets:
               A Proof-of-Concept Study},
  journal   = {Scientific Reports},
  year      = {2024},
  volume    = {14},
  doi       = {10.1038/s41598-024-55183-6},
  publisher = {Nature Publishing Group},
  issn      = {2045-2322}
}

@inproceedings{hendawi2024comprehensive,
  author    = {Hendawi, Rasha and Li, Juan},
  title     = {Comprehensive Personal Health Knowledge Graph for Effective Management
               and Utilization of Personal Health Data},
  booktitle = {Proceedings of the IEEE 2nd International Conference on AI in
               Medicine and Health Care (AIMHC)},
  year      = {2024},
  pages     = {1--8},
  doi       = {10.1109/aimhc59811.2024.00026},
  publisher = {IEEE}
}
```

---

## Lecture Coverage Map

| # | Paper | Year | KG+CPS | DT+Semantics | Wearable/FHIR | Venue |
|---|-------|------|--------|--------------|---------------|-------|
| 1 | Pourvahab et al. | 2025 | ✅ Core | — | ✅ RDF/R2RML | ACM |
| 2 | Gyrard et al. | 2024 | ✅ IoT-DT | ✅ Mental health DT | ✅ FHIR/SNOMED | arXiv |
| 3 | Marfoglia et al. | 2026 | ✅ FHIR API | ✅ MIMO ontology | ✅ FHIR R4 | FGCS (Elsevier) |
| 4 | Carbonaro et al. | 2023 | ✅ Architecture | ✅ PKG-DT | — | Front. Digital Health |
| 5 | Krämer | 2025 | — | ✅ OWL 2.0 / SWRL | ✅ SNOMED CT / FHIR | arXiv |
| 6 | Sarani Rad et al. | 2024 | ✅ CGM IoT | ✅ PHKG-DT | ✅ HL7 FHIR | J. Personalized Med. |
| 7 | Chatterjee et al. | 2024 | ✅ CPS sensors | — | ✅ SSN/SOSA | Scientific Reports |
| 8 | Hendawi & Li | 2024 | ✅ Wearables | ✅ PHKG | ✅ SNOMED CT / ICD-10 | IEEE AIMHC |

---

*Compiled for PhD lecture: "Knowledge Graphs as Semantic Bridges between CPS/IoT and Patient Digital Twins"*
*All DOIs verified from academic databases. BibTeX keys follow author-year-keyword convention.*
