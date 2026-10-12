#import "sources.typ": cited-keys, defined-keys
#import "appendix.typ": appendix-counter

/// Signed assignment sheets, one page each, counted but not numbered:
/// `task: image("task.pdf")` or `task: (image("task.pdf", page: 1), image("task.pdf", page: 2))`.
#let task-pages(task) = {
  let pages = if type(task) == array { task } else { (task,) }
  for p in pages {
    page(margin: 0pt, footer: none, align(center + horizon, {
      set image(width: 100%, height: 100%, fit: "contain")
      p
    }))
  }
}

// Russian forms of a counted noun: 1 рисунок, 2 рисунка, 5 рисунков.
#let plural(n, one, few, many) = {
  let tens = calc.rem(n, 100)
  let units = calc.rem(n, 10)
  if tens >= 11 and tens <= 14 { many } else if units == 1 { one } else if units >= 2 and units <= 4 { few } else { many }
}

/// Abstract with the size of the work counted automatically.
#let abstract-page(body, keywords) = {
  heading(level: 1, numbering: none, outlined: false)[Реферат]
  context {
    let pages = counter(page).final().first()
    let figures = query(figure.where(kind: image)).len()
    let tables = query(figure.where(kind: table)).len()
    let sources = cited-keys().filter(k => k in defined-keys()).len()
    let appendices = appendix-counter.final().first()
    let parts = (
      [#pages с.],
      [#figures рис.],
      [#tables табл.],
      [#sources #plural(sources, "источник", "источника", "источников")],
      [#appendices прил.],
    )
    par[Курсовая работа: #parts.join(", ")]
  }
  if keywords.len() > 0 { par(upper(keywords.join(", "))) }
  body
}

/// List of abbreviations: Russian terms first, then the rest, each group
/// in alphabetical order.
#let abbreviations-page(terms) = {
  heading(level: 1, numbering: none)[Перечень условных обозначений и сокращений]
  par[В настоящей пояснительной записке применяются следующие термины, обозначения и сокращения.]
  let latin = term => term.clusters().first().match(regex("[A-Za-z]")) != none
  let sorted = terms.pairs().sorted(key: ((term, _)) => (if latin(term) { 1 } else { 0 }, lower(term)))
  grid(
    columns: (auto, auto, 1fr),
    column-gutter: 0.5em,
    row-gutter: 0.65em,
    ..sorted.map(((term, meaning)) => (term, [–], par(first-line-indent: 0pt, meaning))).flatten(),
  )
}
