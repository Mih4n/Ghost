// Letters allowed by GOST 2.105: appendices skip Ё З Й О Ч Ь Ы Ъ (and Е by
// guide 4334), list items skip ё з й о ч ъ ы ь.
#let appendix-letters = "АБВГДЖИКЛМНПРСТУФХЦШЩЭЮЯ".clusters()
#let item-letters = "абвгдежиклмнпрстуфхцшщэюя".clusters()

// One empty line of 14pt text between blocks, as the guide asks around
// headings, figures, tables and formulas.
#let blank = 2em

// Letter of the current appendix, none in the main part.
#let appendix-state = state("ghost-appendix", none)

// Set while a raw block is shown, Latin in code stays upright.
#let in-raw = state("ghost-in-raw", false)

#let draft-state = state("ghost-draft", false)

// "img/er-diagram.png" or path("/img/er-diagram.png") -> "er-diagram.png"
#let file-name(source) = {
  let s = if type(source) == str {
    source
  } else {
    let r = repr(source)
    r.slice(6, r.len() - 2)
  }
  s.split("/").last()
}

// "er-diagram.png" -> "er-diagram"
#let file-stem(source) = {
  let parts = file-name(source).split(".")
  if parts.len() > 1 { parts.slice(0, -1).join(".") } else { parts.first() }
}

// Section number or appendix letter at a location: "3" or "А", none
// before the first numbered section.
#let prefix-at(loc) = {
  let letter = appendix-state.at(loc)
  if letter != none {
    letter
  } else {
    let section = counter(heading).at(loc).first()
    if section > 0 { str(section) } else { none }
  }
}

// "3.2", "А.1", or just "2" in a lab without sections.
#let number-at(loc, n) = {
  let prefix = prefix-at(loc)
  if prefix == none { str(n) } else { prefix + "." + str(n) }
}

// Red note in the left margin, only with `draft: true`.
#let draft-note(message) = context {
  if draft-state.get() {
    place(left, dx: -2.8cm, box(width: 2.5cm, text(size: 9pt, fill: red, style: "normal", hyphenate: false, message)))
  }
}

// A note when nothing in the text refers to the label.
#let unreferenced(lbl, message) = context {
  if draft-state.get() and lbl != none and query(ref.where(target: lbl)).len() == 0 {
    draft-note(message)
  }
}
