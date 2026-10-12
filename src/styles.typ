#import "util.typ": appendix-state, blank, in-raw, item-letters

#let indent = 1.25cm

// Unnumbered headings written in capitals by the guide, the rest of the
// structural ones keep their case.
#let capital-headings = ("содержание", "введение", "заключение")

#let plain-text(it) = if it.has("text") { it.text } else if it.has("children") { it.children.map(plain-text).join() } else if it.has("body") { plain-text(it.body) } else { "" }

/// Page, text, paragraphs, headings and lists by guide 4334.
/// `section-pagebreak`: every section starts on a new page.
#let text-rules(section-pagebreak: true, body) = {
  set page(paper: "a4", margin: (left: 3cm, right: 1cm, top: 2cm, bottom: 2cm))
  set text(font: "Times New Roman", size: 14pt, lang: "ru", hyphenate: true)
  // 40 ± 3 lines on a page, no extra gap between paragraphs.
  set par(justify: true, leading: 0.65em, spacing: 0.65em, first-line-indent: (amount: indent, all: true))

  // --- Headings ---
  set heading(numbering: "1.1")
  // "= Введение" and "= Заключение" are not numbered and do not count.
  show selector.or(..capital-headings.map(name => (name, upper(name), upper(name.first()) + name.slice(name.first().len())))
    .flatten()
    .map(name => heading.where(level: 1, body: [#name]))): set heading(numbering: none)
  show heading: it => {
    set text(size: 14pt, weight: "bold", hyphenate: false)
    set par(justify: false, first-line-indent: 0pt)

    if it.supplement == [Приложение] {
      // Drawn by `appendix`, this one only feeds the contents.
      it.body
    } else if it.numbering == none {
      if it.level == 1 and section-pagebreak { pagebreak(weak: true) }
      let title = if lower(plain-text(it.body)) in capital-headings { upper(it.body) } else { it.body }
      block(above: blank, below: blank, sticky: true, width: 100%, align(center, title))
    } else {
      if it.level == 1 and section-pagebreak { pagebreak(weak: true) }
      let number = counter(heading).display(it.numbering)
      let title = if it.level == 1 { upper(it.body) } else { it.body }
      // Numbers of items are bold italic; the second line of a long title
      // starts under the first letter of the first one.
      block(above: blank, below: blank, sticky: true, inset: (left: indent), grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        if it.level >= 3 { emph(number) } else { number },
        title,
      ))
    }
  }

  // A new section numbers its figures, tables and formulas from 1 again.
  show heading.where(level: 1): it => {
    if it.numbering != none {
      for kind in (image, table, raw) { counter(figure.where(kind: kind)).update(0) }
      counter(math.equation).update(0)
      appendix-state.update(none)
    }
    it
  }

  // --- Contents ---
  set outline(indent: indent, depth: 2)
  show outline: set heading(outlined: false)
  show outline.entry: set par(first-line-indent: 0pt, justify: false)
  show outline.entry.where(level: 1): set block(above: 0.65em)

  // --- Lists ---
  // Every item starts at the paragraph indent, wrapped lines go back to the
  // margin: "–" for lists, "а)" and then "1)" for enumerations.
  let depth = state("ghost-list-depth", 0)
  let items(it, marker) = {
    depth.update(d => d + 1)
    context {
      let d = depth.get()
      for (i, child) in it.children.enumerate() {
        set par(first-line-indent: (amount: indent * d, all: true))
        [#marker(d, i)#h(0.5em)#child.body]
        parbreak()
      }
    }
    depth.update(d => d - 1)
  }
  show list: it => items(it, (d, i) => [–])
  show enum: it => items(it, (d, i) => if d == 1 [#item-letters.at(i))] else [#(i + 1))])

  // --- Latin in italics ---
  // Whole Latin phrases match at once: a rule per word or letter runs into
  // Typst's grouping depth on a long English text.
  show regex("[A-Za-z]+(?:[ ,.;:!?'-]+[A-Za-z]+)*"): it => context {
    if in-raw.get() { it } else { text(style: "italic", it) }
  }
  show raw: it => { in-raw.update(true); it; in-raw.update(false) }

  body
}
