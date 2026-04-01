#let appendix-heading(title) = {
  align(center)[
    #show heading: set block(inset: (left: 0em))
    #heading(level: 1, numbering: none)[#title]
  ]
}