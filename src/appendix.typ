#import "util.typ": appendix-letters, appendix-state, blank, unreferenced

#let appendix-counter = counter("ghost-appendix")

/// Starts an appendix on a new page: "ПРИЛОЖЕНИЕ А", "(обязательное)", the
/// title. Figures, tables and formulas inside are numbered "А.1".
/// `#appendix([Листинг программы], name: "code")`, `@code` gives "А".
#let appendix(title, kind: "обязательное", name: none) = {
  pagebreak(weak: true)
  appendix-counter.step()
  context {
    let letter = appendix-letters.at(appendix-counter.get().first() - 1)
    appendix-state.update(letter)
    for kind in (image, table, raw) { counter(figure.where(kind: kind)).update(0) }
    counter(math.equation).update(0)

    // Invisible heading for the contents, the bookmarks and `@name`.
    let target = heading(level: 1, numbering: none, supplement: [Приложение], [Приложение #letter #title])
    place(hide(if name == none { target } else { [#target#label(name)] }))

    block(below: blank, width: 100%, align(center, {
      set par(first-line-indent: 0pt, justify: false)
      set text(hyphenate: false)
      strong[ПРИЛОЖЕНИЕ #letter]
      linebreak()
      [(#kind)]
      linebreak()
      strong(title)
    }))
    if name != none { unreferenced(label(name), [нет ссылки на приложение]) }
  }
}
