#import "util.typ": file-stem, number-at, unreferenced

// Attaches a label when there is a name, `@name` then refers to it.
#let labelled(body, name) = if name == none { body } else { [#body#label(name)] }

/// Figure from an image: `#picture(image("img/er.png", width: 60%), [ER-диаграмма])`.
/// The label is the file name without extension, `@er` gives "2.3".
#let picture(img, caption, name: auto) = {
  let name = if name == auto and img.has("source") { file-stem(img.source) } else if name == auto { none } else { name }
  labelled(figure(img, caption: caption, kind: image), name)
}

/// Table with its caption above: `#tbl(table(...), [Исходные данные], name: "data")`.
#let tbl(body, caption, name: none) = labelled(figure(body, caption: caption, kind: table), name)

/// Numbered formula: `#formula($ W(s) = 1 / (m s^2 + k) $, name: "w")`, `@w` gives "(3.1)".
#let formula(body, name: none) = labelled(body, name)

/// Code fragment of at most half a page in the text, captioned as a figure.
/// `code` is a `path(...)`, a string or a raw block.
#let code-figure(code, caption, name: auto) = {
  let name = if name == auto and type(code) == path { file-stem(code) } else if name == auto { none } else { name }
  let body = if type(code) == path { raw(read(code), block: true) } else if type(code) == str { raw(code, block: true) } else { code }
  labelled(figure(align(left, body), caption: caption, kind: image), name)
}

/// Explanation of the symbols right below a formula:
/// `#where(($m$, [масса системы]), ($k$, [коэффициент жёсткости пружины]))`.
#let where(..rows) = {
  let rows = rows.pos()
  block(above: 1em, below: 2em, grid(
    columns: (auto, auto, 1fr),
    column-gutter: 0.4em,
    row-gutter: 0.65em,
    ..rows.enumerate().map(((i, (symbol, meaning))) => (
      if i == 0 [где] else [],
      symbol,
      par(first-line-indent: 0pt)[– #meaning#if i == rows.len() - 1 [.] else [;]],
    )).flatten(),
  ))
}

// Rules for the figures above, applied by `ghost`.
#let figure-rules(body) = {
  set figure(numbering: "1")
  set figure.caption(separator: [ – ])
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => {
    let number = context number-at(it.location(), it.counter.at(it.location()).first())
    [#it.supplement #number#it.separator#it.body]
  }

  // Picture, blank line, caption centred; long captions are not stretched.
  show figure.where(kind: image): it => {
    block(above: 2em, below: 2em, breakable: false, width: 100%, {
      align(center, it.body)
      v(1.3em)
      align(center, par(justify: false, first-line-indent: 0pt, it.caption))
      if it.has("label") { unreferenced(it.label, [нет ссылки на рисунок]) }
    })
  }

  // Caption above with the paragraph indent, table on the left margin.
  show figure.where(kind: table): it => {
    set text(size: 12pt)
    block(above: 2em, below: 2em, width: 100%, {
      set align(left)
      par(justify: false, first-line-indent: (amount: 1.25cm, all: true), text(size: 14pt, it.caption))
      it.body
      if it.has("label") { unreferenced(it.label, [нет ссылки на таблицу]) }
    })
  }

  set math.equation(numbering: n => context "(" + number-at(here(), n) + ")")
  show math.equation.where(block: true): set block(above: 2em, below: 2em)

  body
}
