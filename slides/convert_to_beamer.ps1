# Script per convertire tutti i .qmd da Reveal.js a Beamer

$beamerFrontmatter = @"
---
title: "Knowledge Graph e CPS in Sanità"
subtitle: "PhD Lecture Module"
author: "Tuo Nome"
institute: "Tua Università · Scuola di Dottorato"
date: "2026"
format:
  beamer:
    theme: "Madrid"
    colortheme: "default"
    fonttheme: "default"
    slidelevel: 2
    aspectratio: 169
    fontsize: 10pt
    incremental: false
    navigation: horizontal
    header-includes:
      - \usepackage{tikz}
      - \usepackage{pgfplots}
      - \usepackage{booktabs}
      - \usepackage{graphicx}
      - \usepackage{hyperref}
    include-in-header:
      text: |
        \setbeamertemplate{navigation symbols}{}
        \setbeamertemplate{footline}{
          \leavevmode\hbox{
            \begin{beamercolorbox}[wd=.33\paperwidth,ht=2.5ex,dp=1ex,center]{author in head/foot}
              \usebeamerfont{author in head/foot}\insertshortauthor
            \end{beamercolorbox}
            \begin{beamercolorbox}[wd=.34\paperwidth,ht=2.5ex,dp=1ex,center]{title in head/foot}
              \usebeamerfont{title in head/foot}\insertshorttitle
            \end{beamercolorbox}
            \begin{beamercolorbox}[wd=.33\paperwidth,ht=2.5ex,dp=1ex,right]{date in head/foot}
              \usebeamerfont{date in head/foot}\insertshortdate{}\hspace*{2em}
              \insertframenumber{} / \inserttotalframenumber\hspace*{2ex}
            \end{beamercolorbox}
          }
          \vskip0pt
        }
execute:
  echo: false
---
"@

Get-ChildItem -Filter *.qmd | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Trova e sostituisci il frontmatter
    $pattern = '(?s)^---.*?---'
    $newContent = $content -replace $pattern, $beamerFrontmatter
    
    # Salva il file
    Set-Content -Path $_.FullName -Value $newContent -NoNewline
    
    Write-Host "✓ Convertito: $($_.Name)" -ForegroundColor Green
}

Write-Host "`nConversione completata!" -ForegroundColor Cyan