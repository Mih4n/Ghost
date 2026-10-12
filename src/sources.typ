#import "util.typ": draft-state

// Keys in the order of their first reference in the text.
#let cited-keys() = {
  let keys = ()
  for m in query(<ghost-src>) {
    if m.value not in keys { keys.push(m.value) }
  }
  keys
}

#let defined-keys() = {
  let lists = query(<ghost-sources>)
  if lists.len() == 0 { () } else { lists.first().value }
}

/// Reference to a source: `#src("knuth")` gives "[1]",
/// `#src("knuth", page: 386)` gives "[1, с. 386]".
#let src(key, page: none) = {
  [#metadata(key)<ghost-src>]
  context {
    let i = cited-keys().position(k => k == key) + 1
    if key not in defined-keys() {
      text(fill: red)[[?#key]]
    } else {
      "[" + str(i) + if page != none { ", с. " + str(page) } else { "" } + "]"
    }
  }
}

/// List of sources, numbered by the first reference in the text. Entries
/// are written by GOST 7.1 by hand:
/// `#sources(knuth: [Кнут, Д. Искусство программирования ...])`.
/// Sources without references are left out, `draft: true` lists them.
#let sources(..entries) = {
  let entries = entries.named()
  [#metadata(entries.keys())<ghost-sources>]
  heading(level: 1, numbering: none)[Список использованных источников]
  context {
    let cited = cited-keys().filter(k => k in entries)
    for (i, key) in cited.enumerate() {
      par[#(i + 1). #entries.at(key)]
    }
    let unused = entries.keys().filter(k => k not in cited)
    if draft-state.get() and unused.len() > 0 {
      text(fill: red, size: 10pt)[Нет ссылок в тексте: #unused.join(", ")]
    }
  }
}
