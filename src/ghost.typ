#import "util.typ": draft-state, number-at, prefix-at
#import "styles.typ": text-rules
#import "figures.typ": figure-rules
#import "code.typ": code-rules
#import "title.typ": title-page
#import "front.typ": abbreviations-page, abstract-page, task-pages

/// Report by GSTU guide 4334: `#show: ghost.with(kind: "course", ...)`.
///
/// - kind: "lab" or "course". A course work gets the contents and starts
///   every section on a new page.
/// - supervisor: (name, title), for example ("Асенчик О. Д.", "доцент").
/// - task: assignment pages after the title, `image("task.pdf")` or an array.
/// - abstract, keywords: the abstract of a course work, the size of the
///   work is counted by itself.
/// - abbreviations: dictionary term -> meaning.
/// - draft: marks figures, tables, appendices and sources nothing refers to.
#let ghost(
  kind: "lab",
  number: none,
  discipline: none,
  theme: none,
  student: none,
  group: none,
  supervisor: (none, none),
  faculty: "Факультет автоматизированных и информационных систем",
  department: "Информационные технологии",
  specialty: "6-05-0611-01 «Информационные системы и технологии»",
  city: "Гомель",
  year: auto,
  task: none,
  abstract: none,
  keywords: (),
  abbreviations: none,
  outline: auto,
  draft: false,
  body,
) = {
  assert(kind in ("lab", "course"), message: "kind: \"lab\" или \"course\"")
  let course = kind == "course"
  let outline = if outline == auto { course } else { outline }
  let year = if year == auto { datetime.today().year() } else { year }

  set document(title: theme, author: if student != none { student } else { () })
  show: text-rules.with(section-pagebreak: course)
  show: figure-rules
  show: code-rules
  draft-state.update(draft)

  // References give the bare number, the case of "рисунке" or "таблицы"
  // stays with the text around: "на рисунке @er" -> "на рисунке 2.3".
  show ref: it => {
    let el = it.element
    if el == none { return it }
    if el.func() == figure {
      link(el.location(), number-at(el.location(), el.counter.at(el.location()).first()))
    } else if el.func() == math.equation {
      link(el.location(), "(" + number-at(el.location(), counter(math.equation).at(el.location()).first()) + ")")
    } else if el.func() == heading and el.supplement == [Приложение] {
      link(el.location(), prefix-at(el.location()))
    } else if el.func() == heading and el.numbering != none {
      link(el.location(), numbering(el.numbering, ..counter(heading).at(el.location())))
    } else { it }
  }

  // Page numbers at the bottom right in 12pt: from page 2 in a lab, from
  // the second page of the contents in a course work.
  set page(footer: context {
    let starts = query(<ghost-contents>)
    let first = if starts.len() > 0 { starts.first().location().page() + 1 } else { 2 }
    if here().page() >= first { align(right, text(size: 12pt, str(here().page()))) }
  })

  title-page((
    kind: kind, number: number, discipline: discipline, theme: theme,
    student: student, group: group, supervisor: supervisor,
    faculty: faculty, department: department, specialty: specialty,
    city: city, year: year,
  ))
  if task != none { task-pages(task) }
  if abstract != none { abstract-page(abstract, keywords) }
  if outline {
    // On the first page of the contents, numbers start from the next one.
    pagebreak(weak: true)
    [#metadata(none)<ghost-contents>]
    std.outline(title: [Содержание])
  }
  if abbreviations != none { abbreviations-page(abbreviations) }

  body
}
