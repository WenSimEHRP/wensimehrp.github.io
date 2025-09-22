#import "func.typ": *
#import "deps.typ": *

#let dashy-line = {
  let line = line.with(length: 100%, stroke: teal-800 + 1.5pt)
  let a = range(5).map(it => calc.pow(2, -it) * 1fr)
  grid(
    columns: a,
    gutter: .2cm,
    ..(line(),) * 5,
  )
}

#let with-line(it) = {
  block(it, below: 0cm)
  block(above: .2cm, dashy-line)
}

#let default-config = (
  layout: "layout.webc",
  title: "Untitled",
  description: "No description.",
  created: "2025-01-01",
  tags: (),
  author: "Unknown",
  toc: true,
  comments: true,
)

#let wstemplate(c, ..matter) = context {
  let frontmatter = default-config + matter.named()
  [#metadata(frontmatter) <frontmatter>]
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
  show heading: it => {
    set text(font: "Merriweather Sans", fill: teal-800)
    set par(justify: false)
    smallcaps(it)
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

  [
    By #frontmatter.at("author", default: "Jeremy Gao")

    #(
      frontmatter
        .at("tags", default: ())
        .map(
          it => (
            h(weak: true, .5em)
              + box(
                text(fill: luma(30%), font: "Merriweather Sans", smallcaps(it)),
                fill: luma(85%),
                inset: .2em,
                radius: .2em,
              )
          ),
        )
        .join()
    )
  ]
  dashy-line

  outline(title: none)
  dashy-line
  show heading: with-line
  set par(justify: true, first-line-indent: 1em)
  c
}
