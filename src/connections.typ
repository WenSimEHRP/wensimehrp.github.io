#import "@local/wslib:0.1.0": *
#metadata((
  layout: "layout.webc",
  title: "Friends",
  description: "My friends.",
  created: "2025-09-10",
  toc: false,
)) <frontmatter>

// connections are sorted alphabetically by title.
#let (example, ..connections-data) = toml("_data/connections.toml").connections
#(connections-data = (example,) + connections-data.sorted(key: it => it.title))

#let to-card(data) = context {
  if target() != "html" {
    return
  }
  elink(
    data.link,
    show-icon: false,
    class: "card no-underline flex",
    html.elem(
      "article",
      attrs: (class: "min-w-full [&>h3]:mt-2 [&>h3]:mb-1 text-left [&>p]:mb-3 [&>p]:leading-loose [&_code]:text-teal-700"),
    )[
      == #data.title
      #data.description\
      #raw(data.link.trim(at: start, regex("https?://")))
    ],
  )
}

Links are sorted alphabetically.

= The Honour List

#html.elem(
  "div",
  attrs: (
    class: "grid grid-cols-2 md:grid-cols-3 gap-4",
  ),
  connections-data.map(to-card).join(),
)

= Adding an Entry
