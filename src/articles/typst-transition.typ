#metadata((
  layout: "layout.webc",
  title: "Transitioning to Typst",
  description: "Hey, are you one of the Typst dudes?",
  created: "2025-09-09",
  tags: ("Typst", "tools", "typesetting"),
  author: "Jeremy Gao",
  wip: true,
)) <front-formatter>

#let fn-state = state("fn", (1, ()))
#let footnote(c) = context {
  let n = fn-state.get().at(0)
  let href = "#fn" + str(n)
  let id = "fnref" + str(n)
  html.elem("sup", attrs: (class: "footnotes-ref"), html.elem("a", attrs: (href: href, id: id), [\[#n\]]))
  fn-state.update(it => {
    let (id, pc) = it
    (id + 1, pc + (c,))
  })
}

I've been using typst for a while, even using it to generate my eleventy blog site
(as you can see). It is a great tool, with a typesetting quality that rivals LaTeX --
I cannot say if it is doing better than LaTeX, since I am never a LaTeXer, nor do
I think I will in the near future when I am (hopefully) in Uni. It's got scripting
capabilities that are even better than python's -- from a personal perspective, of
course, and sad news is that Typst does not support OOP now.#footnote[
  And look at this amazing footnote in typst! Eleventy already features a full-feature
  markdown compiler that translate all of markdown's components to html. Typst, on
  the other hand, does not have that luxury, which means that I would have to
  manually create the mappings from typst elements (or I should say basic typesetting
  elements) to HTML elements. This footnote is created using a custom footnote mapper.
]

So the decision is to make (at least some parts) of this site to be Typst. Typst
supports exporting HTML, as well as rendering parts of the documents in SVG. Exporting
to HTML is only a experimental feature, but it is somewhat mature now. People like
Camiyori and OverflowCat already created exciting services such as typst.ts, and
astro-typst. Uwni's also created their own blog with typst using their own extension.
In fact, I got inspiration from Uwni's blog, and I used the same eleventy build system.

I've already done some experiments on typst, like my #link("/trips")[Travel Log page]
is entirely in typst.

#context html.elem("ol", attrs: (class: "footnotes-list"))[
  #let footnotes = fn-state.final().at(1)
  #for (idx, fn) in footnotes.enumerate() {
    html.elem("li", attrs: (id: "fn" + str(idx + 1)))[
      #let href = "#fnref" + str(idx + 1)
      #fn #html.elem("a", attrs: (href: href, class: "footnote-backref"))[↩︎]
    ]
  }
]
