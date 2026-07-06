# Compilazione Slide Beamer

Questo documento spiega come compilare i file `.qmd` della cartella `slides/` in
presentazioni PDF tramite il formato **Beamer** (LaTeX).

> **File `.qmd` attualmente presenti nella cartella:**
> - `section1_kg_heterogeneous_healthcare_data.qmd`
> - `section2_kg_cps_pdt_lecture.qmd`
>
> I nomi `01-kg-fundamentals.qmd`, `02-kg-cps-healthcare.qmd`, `03-bridge-to-lab.qmd`
> (citati nel `metadata.yaml`) **non corrispondono ad alcun file** e vanno ignorati o
> rinominati di conseguenza.

## Prerequisiti

- Quarto installato (https://quarto.org/docs/get-started/)
- Distribuzione LaTeX (TinyTeX raccomandato: `quarto install tool tinytex`)

Verifica che LaTeX sia disponibile:

```powershell
quarto check
```

## Compilazione Singoli File

```powershell
cd C:\Users\User\Documents\teaching\kg_and_cps\slides
quarto render section1_kg_heterogeneous_healthcare_data.qmd --to beamer
quarto render section2_kg_cps_pdt_lecture.qmd --to beamer
```

L'output PDF viene generato nella stessa cartella con lo stesso nome del file sorgente.

## Compilazione di Tutti i File

```powershell
cd C:\Users\User\Documents\teaching\kg_and_cps\slides
Get-ChildItem -Filter *.qmd | ForEach-Object { quarto render $_.Name --to beamer }
```

## Note sul Contenuto delle Slide

- Il frontmatter Beamer usa il tema **Madrid**, aspectratio **16:9**, fontsize **10pt** e
  un footer personalizzato (autore · titolo · numero frame).
- I pacchetti LaTeX `tikz`, `pgfplots`, `booktabs`, `graphicx`, `hyperref` sono già
  inclusi via `header-includes`.
- **Attenzione — Mermaid:** i blocchi ` ```{mermaid} ` sono supportati solo nei formati
  HTML (revealjs/html) e **non vengono renderizzati in Beamer/PDF**. Per i diagrammi,
  convertirli in codice LaTeX nativo (TikZ/pgfplots) o in immagini PNG/SVG da includere.
- I callout Quarto (`::: {.callout-note}`, `.callout-tip`, `.callout-warning`) vengono
  convertiti automaticamente in blocchi Beamer.
