#import "util.typ": file-name

/// Program text from a project file for an appendix, by GOST 19.401:
/// `#listing(path("src/Program.cs"))`. The file name goes above the code.
#let listing(file, title: auto) = {
  let title = if title == auto { file-name(file) } else { title }
  block(above: 2em, below: 2em, width: 100%, {
    par(first-line-indent: 0pt, strong(title))
    raw(read(file), block: true)
  })
}

// Program text in Times 12pt with single spacing, as the guide asks.
#let code-rules(body) = {
  show raw: set text(font: "Times New Roman", size: 12pt)
  show raw.where(block: true): set par(leading: 0.4em, justify: false)
  show raw.where(block: true): set block(width: 100%)
  body
}
