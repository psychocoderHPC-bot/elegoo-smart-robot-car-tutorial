# Layout-API für die Kapitel

Alle Kapitel importieren `../lib/components.typ`; `main.typ` aktiviert das Layout
mit `#show: book` und bindet die Kapiteldateien ein.

```typ
#import "../lib/components.typ": *
#chapter(3, [Ultraschall], goal: [Du misst Entfernungen.])[
  #mission[Baue eine Messung mit dem Ultraschallsensor.]
  #listing("/code/041_distance/041_distance_solution/041_distance_solution.ino", title: [Abstand messen])
  #gap("/code/046_stop_before_wall/046_stop_before_wall_exercise/046_stop_before_wall_exercise.ino", [Ergänze die Berechnung.])
  #solution("/code/041_distance/041_distance_solution/041_distance_solution.ino")
]
```

`chapter(number, title, goal: none, body)` · `mission(body)` · `tipp(body)` ·
`achtung(body)` · `probiere(body)` · `merken(body)` · `fehler(items)` mit
`items = (("falsch", "so hilft es"), ...)` · `listing(path, title: none, note: none, lang: "c")` ·
`gap(path, task, space: 0)` · `solution(path, title: none)` · `notespace(lines: 6)` ·
`pinref(rows)` mit `rows = (("Pin", "Bedeutung"), ...)` · `goalbox(body, title: "Ziel")` ·
`checklist(items)` mit `items = ([Punkt], ...)`.

## Regeln
- Listing-Pfade sind root-relativ (`/code/...`); absolute Pfade brauchen `--root /`.
- Höchstens 76 Zeichen pro Codezeile; die Listingschrift bleibt 8.4 pt.
- Listings werden seitenweise in Blöcken von höchstens 52 Zeilen gesetzt; der
  letzte Block behält mindestens 8 Zeilen, damit kein Einzeiler-Rest entsteht.
- `solution` setzt die grüne Marke „Lösung“ und den ersten Codeblock als
  Einheit. Reicht der Platz auf der aktuellen Seite nicht, beginnt die Lösung
  auf der nächsten Seite; so bleibt keine Seite nur mit Schreiblinien zurück.
- `gap` zeigt Aufgabentext und unvollständiges Listing. Mit `space: n`
  (`n > 0`) folgen direkt `n` Schreiblinien; Aufgabe, Code und Linien bleiben
  zusammen auf einer Seite. Ohne `space` bleibt das Verhalten unverändert.
- Jeder Kasten hat eine Textmarke; Farbe allein trägt nie eine Bedeutung.
