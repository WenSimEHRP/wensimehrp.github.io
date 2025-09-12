/// Font Awesome icon
///
/// - icon (string): The Font Awesome icon name, with or without the "fa-" prefix.
/// ->
#let fa(icon) = context {
  if target() == "html" {
    html.elem("i", attrs: (class: "fa-solid " + icon))
  }
}

/// External link
///
/// - url (string): The URL to link to.
/// - c (any): The content to display for the link.
/// - ..args (dict): Additional attributes to add to the `<a>` element.
/// -> any
#let elink(url, c, show-icon: true, ..args) = context {
  if target() == "html" {
    html.elem(
      "a",
      attrs: (href: url, target: "_blank", rel: "noopener noreferrer", title: url, ..args.named()),
      [#c #if show-icon { fa("fa-arrow-up-right-from-square") }],
    )
  } else {
    link(url, c)
  }
}

/// State variable to keep track of footnotes.
#let fn-state = state("fn", (1, ()))

/// Create an HTML footnote, or regular footnote if not in HTML context.
///
/// - c (any): The content of the footnote.
/// ->
#let footnote(c) = context {
  if target() != "html" {
    return std.footnote(c)
  }
  let n = fn-state.get().at(0)
  let href = "#fn" + str(n)
  let id = "fnref" + str(n)
  html.elem(
    "sup",
    attrs: (class: "footnotes-ref"),
    html.elem("a", attrs: (href: href, id: id), [\[#n\]]),
  )
  fn-state.update(it => {
    let (id, pc) = it
    (id + 1, pc + (c,))
  })
}

/// Display the footnotes in HTML context.
#let html-display-footnote = context {
  if target() != "html" {
    return
  }
  let footnotes = fn-state.final().at(1)
  if footnotes.len() == 0 {
    return
  }
  html.elem("hr", attrs: (class: "footnotes-sep"))
  html.elem(
    "section",
    attrs: (class: "footnotes"),
    html.elem("ol", attrs: (class: "footnotes-list"))[
      #for (idx, fn) in footnotes.enumerate() {
        html.elem("li", attrs: (id: "fn" + str(idx + 1), class: "footnote-item"))[
          #let href = "#fnref" + str(idx + 1)
          #html.elem("p")[#fn #html.elem(
              "a",
              attrs: (href: href, class: "footnote-backref text-gray-400 text-sm"),
              html.elem("i", attrs: (
                class: "fa-solid fa-arrow-turn-up",
              )),
            )]
        ]
      }
    ],
  )
}

#let frame(c) = context {
  if target() == "html" {
    html.frame(c)
  } else {
    block(c)
  }
}
