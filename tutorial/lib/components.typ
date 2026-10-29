// Wiederverwendbare Bausteine für alle Kapitel.
// Die öffentliche API ist in lib/README.md dokumentiert.

#import "theme.typ": *

// ---------------------------------------------------------------------------
// Farbige Hinweiskästen. Jeder Kasten trägt eine Textmarke, nie nur Farbe.
// ---------------------------------------------------------------------------

#let callout(label, color, body, fill: surface) = block(
  width: 100%,
  above: 8pt,
  below: 8pt,
  fill: fill,
  stroke: (left: 3pt + color),
  inset: (left: 10pt, right: 9pt, top: 6pt, bottom: 6pt),
  radius: 2pt,
)[
  #text(size: 8.5pt, weight: "bold", fill: color)[#label]
  #v(2pt)
  #body
]

#let mission(body) = callout("Mission", accent, body, fill: accent.lighten(90%))
#let tipp(body) = callout("Tipp", green, body, fill: green.lighten(90%))
#let achtung(body) = callout("Achtung", warm, body, fill: warm.lighten(90%))
#let probiere(body) = callout("Probiere", violet, body, fill: violet.lighten(90%))
#let merken(body) = callout("Merken", ink, body, fill: surface)

#let goalbox(body, title: "Ziel") = callout(title, accent, body, fill: accent.lighten(92%))

// ---------------------------------------------------------------------------
// Kapitelanfang: neue Seite, große Nummer, Titel, optionales Ziel.
// ---------------------------------------------------------------------------

#let chapter(number, title, goal: none, body) = {
  current-chapter.update(title)
  pagebreak(weak: false)
  in-chapter-heading.update(true)
  block(width: 100%, above: 0pt, below: 15pt)[
    #v(4mm)
    #text(size: 42pt, weight: "bold", fill: accent)[#number]
    #v(8pt)
    #heading(level: 1)[#title]
    #v(6pt)
  ]
  in-chapter-heading.update(false)
  if goal != none {
    goalbox(goal)
  }
  body
}

// ---------------------------------------------------------------------------
// Fehlertabelle: zwei Spalten, immer beide beschriftet.
// ---------------------------------------------------------------------------

#let fehler(items) = block(width: 100%, above: 10pt, below: 10pt)[
  #text(size: 9pt, weight: "bold", fill: warm)[Häufiger Fehler]
  #v(3pt)
  #table(
    columns: (1fr, 1fr),
    table.header([So sieht es aus], [Das hilft]),
    ..items.flatten(),
  )
]

// ---------------------------------------------------------------------------
// Code-Listings: Datei lesen, Titelzeile, Zeilennummern, C++-Highlighting.
// Jede Seite nimmt bis zu 52 Zeilen auf (empirisch gemessen, siehe README).
// Blöcke werden so voll wie möglich gefüllt; der letzte Block hat mindestens
// 8 Zeilen. Die Schrift bleibt bei 8.4 pt; Quellcode darf höchstens 76 Zeichen
// je Zeile haben (siehe lib/README.md).
// ---------------------------------------------------------------------------

#let _filename(path) = path.split("/").last()

#let _caption(filename, title, continuation: false) = block(
  width: 100%,
  fill: ink,
  inset: (x: 8pt, y: 5pt),
  radius: (top: 2pt),
)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 8mm,
    text(size: 8.5pt, weight: "bold", fill: white)[#(
      if continuation { "Fortsetzung" } else if title != none { title } else { "Listing" }
    )],
    align(right)[#text(font: font-mono, size: 8pt, fill: white)[#filename]],
  )
]

#let listing(path, title: none, note: none, lang: "c", first-max: none, prelude: none) = {
  let source = read(path)
  let lines = source.split("\n")
  if lines.len() > 0 and lines.last() == "" {
    lines = lines.slice(0, lines.len() - 1)
  }
  // The "// Beispiel NNN - ..." line is metadata for the file, not part of the
  // printed program. Hiding it keeps listing line numbers and page breaks
  // identical to the sketch body.
  if lines.len() > 0 and lines.first().starts-with("// Beispiel ") {
    lines = lines.slice(1)
  }
  let total = lines.len()
  let filename = _filename(path)
  let digits = str(calc.max(total, 1)).len()

  // Maximale Zeilenzahl pro Listingsseite. Bei 8.4 pt passen 53 Zeilen in den
  // Satzspiegel; 52 lässt Reserve für die grüne Lösungsmarke am Seitenkopf.
  let max-lines = 52

  // Erster Block darf kleiner sein, wenn er nach einem vollen Seitenanfang
  // noch in die Restfläche passen muss (siehe `solution`).
  let first = if first-max == none { max-lines } else { calc.min(first-max, max-lines) }
  if total > first and total - first < 8 and total > 8 {
    first = total - 8
  }

  // Seitenweise auffüllen. Wäre der Rest kleiner als 8 Zeilen, wird der letzte
  // volle Block gekürzt, damit kein Einzeiler-Rest entsteht.
  let starts = {
    let out = (0,)
    if total > first {
      out.push(first)
    }
    let pos = first
    while total - pos > max-lines {
      let next = pos + max-lines
      let rest = total - next
      if rest > 0 and rest < 8 {
        next = total - 8
      }
      out.push(next)
      pos = next
    }
    out
  }

  for ci in range(starts.len()) {
    let start = starts.at(ci)
    let span = if ci == 0 { first } else { max-lines }
    let stop = calc.min(start + span, total)
    if ci > 0 { pagebreak(weak: false) }

    let chunk-lines = if total == 0 { ("",) } else { lines.slice(start, stop) }
    let code = chunk-lines.join("\n")
    let nums = if total == 0 {
      ""
    } else {
      range(start + 1, stop + 1)
        .map(n => " " * (digits - str(n).len()) + str(n))
        .join("\n")
    }

    let chunk = block(
      width: 100%,
      breakable: false,
      above: if ci == 0 and prelude == none { 10pt } else { 0pt },
      below: if ci == starts.len() - 1 { 10pt } else { 4pt },
      stroke: 0.5pt + line-color,
      radius: 2pt,
    )[
      #_caption(filename, title, continuation: ci > 0)
      #block(width: 100%, fill: surface, inset: (x: 8pt, y: 6pt))[
        #show raw: set text(font: font-mono, size: 8.4pt)
        #grid(
          columns: (auto, 1fr),
          column-gutter: 10pt,
          align: (right + top, left + top),
          raw(nums, block: true),
          raw(code, lang: lang, block: true),
        )
      ]
      #if note != none and ci == starts.len() - 1 [
        #block(width: 100%, inset: (x: 8pt, y: 5pt))[
          #text(size: 8.5pt, fill: ink)[#note]
        ]
      ]
    ]

    if ci == 0 and prelude != none {
      // Marke und erster Block wandern gemeinsam auf die nächste Seite.
      block(width: 100%, breakable: false, above: 10pt)[#prelude #chunk]
    } else {
      chunk
    }
  }
}

// Lückenaufgabe: Aufgabentext plus unvollständiges Listing.
// Mit `space > 0` folgen direkt Schreiblinien. Aufgabe, Code und Linien bilden
// dann einen gemeinsamen, nicht umbrechbaren Block und landen nie getrennt.
#let gap(path, task, space: 0) = {
  let exercise = {
    callout("Deine Aufgabe", warm, task, fill: warm.lighten(90%))
    listing(path, title: "Dein Code", note: "Ergänze die fehlenden Zeilen.")
  }
  if space > 0 {
    block(width: 100%, breakable: false, sticky: true)[
      #exercise
      #notespace(lines: space)
    ]
  } else {
    exercise
  }
}

// Lösung: grüne Marke und vollständiges Listing. Kein harter Seitenumbruch:
// Nach einem `notespace` bliebe sonst eine Seite nur mit Schreiblinien zurück.
// Marke und erster Codeblock werden als Einheit gesetzt.
#let solution(path, title: none) = {
  let first-max = 39
  let mark = block(
    width: 100%,
    fill: green.lighten(88%),
    stroke: (left: 3pt + green),
    inset: (left: 9pt, right: 9pt, top: 6pt, bottom: 6pt),
    radius: 2pt,
    above: 0pt,
    below: 4pt,
  )[
    #text(size: 10pt, weight: "bold", fill: green)[Lösung]
    #if title != none [ #h(6pt) #title ]
  ]
  listing(path, title: title, lang: "c", first-max: first-max, prelude: mark)
}

// ---------------------------------------------------------------------------
// Schreib- und Merkhilfen.
// ---------------------------------------------------------------------------

#let notespace(lines: 6) = {
  block(width: 100%, above: 8pt, below: 8pt, breakable: false)[
    #for _ in range(lines) {
      line(length: 100%, stroke: (paint: line-color, thickness: 0.5pt, dash: "loosely-dotted"))
      v(7mm)
    }
  ]
}

#let pinref(rows) = block(width: 100%, above: 8pt, below: 8pt, breakable: false)[
  #table(
    columns: (auto, 1fr),
    align: (left, left),
    table.header([Pin], [Bedeutung]),
    ..rows.flatten(),
  )
]

#let checklist(items) = block(width: 100%, above: 6pt, below: 6pt)[
  #for item in items {
    grid(
      columns: (4.6mm, 1fr),
      column-gutter: 3pt,
      align: (center + horizon, left),
      rect(width: 3.4mm, height: 3.4mm, stroke: 0.7pt + ink),
      item,
    )
    v(2pt)
  }
]
