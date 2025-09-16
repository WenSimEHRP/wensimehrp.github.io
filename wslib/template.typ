#import "func.typ": *
#import "deps.typ": *

#let with-line(it) = {
  block(it, below: 0cm)
  block(above: .2cm, {
    let line = line.with(length: 100%, stroke: teal-800 + 2pt)
    let a = range(5).map(it => calc.pow(2, -it) * 1fr)
    grid(
      columns: a,
      gutter: .2cm,
      ..(line(),) * 5,
    )
  })
}
#let wstemplate(c) = context {
  set heading(numbering: "1.")
  if target() == "html" {
    c
    html-display-footnote
    return
  }
  import "@preview/zebraw:0.5.5": *
  show: zebraw.with(..zebraw-themes.zebra)
  set text(font: "Merriweather")
  set page(margin: (inside: 1in, outside: 2in), numbering: "1")
  set par(justify: true, first-line-indent: 1em)
  show heading: it => {
    set text(font: "Merriweather Sans", fill: teal-800)
    set par(justify: false)
    smallcaps(it)
  }
  let frontmatter = {
    let i = query(<frontmatter>)
    if i.len() == 0 { return (:) }
    i.at(0).value
  }
  {
    show heading: set text(size: 1.5em)
    show heading: emph
    heading(
      level: 1,
      frontmatter.at("title", default: "Untitled"),
      outlined: false,
      numbering: none,
    )
  }
  show link: it => {
    set text(weight: "bold", font: "Merriweather Sans")
    box(it, stroke: (bottom: 4pt + teal-300))
  }
  outline(title: none)
  show heading: with-line
  c
}
