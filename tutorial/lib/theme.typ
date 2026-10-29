// Gemeinsames Layout, Farben und Schriften für das gesamte Buch.
// Alle Kapitel importieren dieses Modul und wenden `book` als show rule an.

#let palette = (
  ink: rgb("#1B1F24"),
  accent: rgb("#1F5FA8"),
  warm: rgb("#C25E00"),
  green: rgb("#2E7D32"),
  violet: rgb("#6A3FA0"),
  surface: rgb("#F5F7FA"),
  line: rgb("#D6DBE1"),
)

#let ink = palette.ink
#let accent = palette.accent
#let warm = palette.warm
#let green = palette.green
#let violet = palette.violet
#let surface = palette.surface
#let line-color = palette.line

#let font-body = "Atkinson Hyperlegible"
#let font-mono = "JetBrains Mono"
#let book-title = "Programmieren lernen mit dem Elegoo Smart Robot Car V4.0"
#let current-chapter = state("chapter", "")
// Wird nur während der Kapitelüberschrift auf true gesetzt. So kann die
// show-Regel die große Kapitelzeile von den Abschnittsüberschriften trennen.
#let in-chapter-heading = state("in-chapter-heading", false)

// Set- und Show-Regeln aus einem importierten Modul greifen nicht automatisch.
// Deshalb bündelt `book` das gesamte Layout und wird per `#show: book` aktiviert.
#let book(body) = {
  // A4, gespiegelte Ränder für den Druck. Der Kopfbereich ist 12 mm hoch.
  set page(
    paper: "a4",
    binding: left,
    margin: (top: 22mm, bottom: 20mm, inside: 26mm, outside: 14mm),
    header-ascent: 12mm,
    header: context {
      set text(size: 8pt, fill: ink)
      grid(
        columns: (1fr, auto),
        column-gutter: 8mm,
        [#book-title],
        align(right)[#current-chapter.get()],
      )
      v(2pt)
      line(length: 100%, stroke: 0.4pt + line-color)
    },
    footer: context {
      set text(size: 8pt, fill: ink)
      align(center)[Seite #counter(page).display() von #counter(page).final().first()]
    },
  )

  set text(
    font: font-body,
    size: 10.5pt,
    lang: "de",
    hyphenate: true,
    fill: ink,
  )
  set par(justify: true, leading: 0.72em, spacing: 0.85em)
  show raw.where(block: false): set text(font: font-mono, size: 9pt)

  // Überschriften bleiben linksbündig. Kapitelüberschriften setzt components.typ.
  // Die Abstände stehen als explizite `v()`-Blöcke vor und nach der Überschrift.
  // `sticky: true` hält die Überschrift am folgenden Text, damit sie nicht
  // allein am Seitenende steht.
  set heading(numbering: none)
  show heading: it => context {
    set par(justify: false)
    let chapter-title = in-chapter-heading.get()
    if it.level == 1 and chapter-title {
      // Große Kapitelzeile, der Abstand kommt aus components.chapter.
      block(sticky: true, above: 0pt, below: 0pt)[
        #set text(size: 26pt, weight: "bold", fill: ink)
        #it
      ]
    } else if it.level <= 2 {
      // Abschnittsüberschrift (im Buch bisher Typst-Ebene 1) und Ebene 2.
      v(20pt, weak: true)
      // Der Abstand unter der Überschrift steckt in `below` statt in einem
      // schwachen `v()` im Block: ein schwacher Abstand am Blockende wird
      // verworfen und der folgende Text überlappt die Überschrift.
      block(sticky: true, above: 0pt, below: 14pt)[
        #set text(size: 15pt, weight: "bold", fill: ink)
        #it
      ]
    } else {
      // Ebene 3: kleiner, aber farblich klar vom Fließtext getrennt.
      v(12pt, weak: true)
      block(sticky: true, above: 0pt, below: 12pt)[
        #set text(size: 12pt, weight: "bold", fill: accent)
        #it
      ]
    }
  }

  // Fußnoten
  set footnote(numbering: "1")
  show footnote.entry: set text(size: 8.5pt)

  // Tabellen: ruhige Linien, Kopfzeile auf Flächenfarbe.
  set table(
    stroke: 0.5pt + line-color,
    inset: (x: 6pt, y: 4pt),
    fill: (x, y) => if y == 0 { surface } else { none },
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  // Aufzählungen kompakt halten.
  set list(indent: 1.1em, spacing: 0.45em)
  set enum(indent: 1.4em, spacing: 0.45em)

  // Dotted-Leader für das Inhaltsverzeichnis.
  set outline.entry(fill: repeat[.])

  body
}
