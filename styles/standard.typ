#let standard(body) = {
  let par-indent = (amount: 1.25cm, all: true)
  
  set text(
    font: "Times New Roman", 
    size: 14pt, 
    lang: "ru",
    hyphenate: false
  )
  set page(
    paper: "a4", 
    margin: (
      left: 3cm, 
      right: 1cm, 
      top: 2cm, 
      bottom: 2cm
    )
  )
  set par(
    justify: true,
    spacing: 0.5em,
    leading: 0.5em,

    first-line-indent: par-indent, 
  )

  set list(indent: 1.25cm)
  set enum(indent: 1.25cm, full: true)

  set heading(numbering: "1.1.")

  show heading: set text(size: 14pt)
  show heading: set block(spacing: 0.5em, inset: (left: 1.25cm))
  show heading: it => block(it)

  show outline: it => {
    show heading: it => {
      set block(inset: (left: 0pt, bottom: 1em))
      align(center)[#it]
    }
    it
  }

  let capitalize(it) = {
    let s = str(it)
    
    if s.len() > 0 {
      let chars = s.clusters()
      let first = upper(chars.at(0))
      let rest = chars.slice(1).join()
      first + rest
    } else {
      it
    }
  }

  show outline.entry: it => {
    show it.body().text: b => capitalize(lower(b.text))
    link(
      it.element.location(),
      it.indented(it.prefix(), it.inner())
    ) 
  }


  show list: it => { context {
    let depth = counter(list).get().at(0)
    let indent = par-indent.amount * depth

    for child in it.children {
      set par(first-line-indent: (amount: indent, all: true))

      if type(it.marker) == content {
        it.marker
      }

      if type(it.marker) == array {
        let count = it.marker.len()
        let cycle = calc.rem(depth - 1, count)
        it.marker.at(cycle)
      }

      if type(it.marker) == function {
        it.marker(depth)
      }

      h(it.body-indent)
      child.body
      parbreak()
      set par(first-line-indent: par-indent)
    }
  }}

  set enum(full: true, numbering: "1.1.")

  let enum-path = state("enum-path", ())

  show enum: it => context {
    let depth = enum-path.get().len() + 1
    let indent = par-indent.amount * depth
    
    let parent-numbers = enum-path.get()
    
    for (index, child) in it.children.enumerate() {
      let current-number = index + 1
      let full-numbers = parent-numbers + (current-number,)
      
      set par(first-line-indent: indent)
      
      numbering(it.numbering, ..full-numbers)
      h(it.body-indent)
      
      enum-path.update(full-numbers)
      
      child.body
      parbreak()
      
      enum-path.update(parent-numbers)
    }
  }

  show table: set text(size: 12pt)
  show table.cell.where(y: 0): strong

  show regex("[a-zA-Z]"): set text(style: "italic")

  body
}