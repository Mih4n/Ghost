#let header(faculty, department, specialty) = {
  [МИНИСТЕРСТВО ОБРАЗОВАНИЯ РЕСПУБЛИКИ БЕЛАРУСЬ]
  parbreak()
  [Учреждение образования\ «Гомельский государственный технический университет имени П.О. Сухого»]
  parbreak()
  faculty
  parbreak()
  [Кафедра «#department»]
  if specialty != none {
    parbreak()
    [Специальность #specialty]
  }
}

#let signatures(student, group, supervisor) = {
  set par(justify: false, first-line-indent: (amount: 9.5cm, all: true))
  [Выполнил: студент гр. #group]
  parbreak()
  student
  parbreak()
  [Принял: #supervisor.at(1, default: none)]
  parbreak()
  supervisor.at(0, default: none)
}

/// Title page of a laboratory work or a course work, the page itself is
/// counted but not numbered.
#let title-page(info) = {
  set text(hyphenate: false)
  set par(justify: false, first-line-indent: 0pt)
  let course = info.kind == "course"

  align(center, {
    set par(spacing: 24pt)
    header(info.faculty, info.department, if course { info.specialty })
    v(2em)
    if course [
      ПОЯСНИТЕЛЬНАЯ ЗАПИСКА\
      к курсовой работе
    ] else [
      ЛАБОРАТОРНАЯ РАБОТА №#info.number
    ]
    set par(spacing: 0.65em)
    parbreak()
    [по дисциплине «#info.discipline»]
    parbreak()
    [на тему «#info.theme»]
  })

  v(if course { 1fr } else { 18em })
  signatures(info.student, info.group, info.supervisor)
  v(1fr)

  if course {
    // Filled in by hand by the supervisor and the commission.
    align(right, grid(
      align: left + bottom,
      gutter: 0.5em,
      columns: (auto, 120pt),
      ..("Дата проверки:", "Дата допуска к защите:", "Дата защиты:", "Оценка работы:")
        .map(label => ([#label], box(width: 1fr, stroke: (bottom: 0.5pt))))
        .flatten(),
    ))
    v(1fr)
    [Подписи членов комиссии]
    parbreak()
    [по защите курсовой работы: #box(width: 200pt, stroke: (bottom: 0.5pt))]
    v(2em)
  }

  align(center)[#info.city #info.year]
  pagebreak(weak: true)
}
