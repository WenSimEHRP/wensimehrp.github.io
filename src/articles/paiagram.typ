#import "@local/wslib:0.1.0": *
#metadata((
  title: "Paiagram",
  description: "How to make timetables (for trains).",
  created: "2025-09-11",
  layout: "layout.webc",
  tags: ("timetable", "tools", "Typst"),
  author: "Jeremy Gao",
  wip: true,
)) <frontmatter>
#show: wstemplate

Years ago I watched a video about how Chinese railways are scheduled and organized.
The video talked about a tool named "运行图". I don't have an official English translation
for it (and I also couldn't find related materials of North American railway companies),
so I'll just call it a "timetable diagram" afterwards. Anyways, as an elementary kid who
have some weird obsession with transportation
#footnote[
  This includes automobiles. Don't ask me why. If you think I hate trains you're
  wrong.
], the organization displayed in the video absolutely fascinated me.

The storytelling part is done, let's talk about something else.

= Timetable Diagrams

A timetable diagram is a diagram that describes the position and time of trains on
a one-dimensional railway. First invented in Paris in the 19th century, it has been
the primary tool for railway schedule planning.

It looks like this:#footnote[
  Sorry if it does not work on dark mode -- I've tried my best to make it look good
  on both light and dark modes, but it seems just to be impossible.
]

#figure(
  caption: [
    #elink("https://en.wikipedia.org/wiki/Beijing%E2%80%93Harbin_railway")[
      Beijing-Harbin railway
    ]
    timetable diagram
  ],
  context {
    import "@preview/paiagram:0.1.1": *
    set text(font: "Merriweather Sans")
    let data = qetrc.read(
      json("../_data/jingha.pyetgr"),
      train-label: train => {
        pad(.1cm, train.name)
      },
    )
    paiagram(
      ..data,
      stations-to-draw: data.stations.keys().slice(4),
      start-hour: 15,
      end-hour: 20,
      label-angle: 30deg,
      time-axis-scale: 3,
      position-axis-scale: .8,
    )
  },
)

Each line represents a train. The actual position of the train is usually not exactly
the same as the position shown in the diagram, since trains' speeds varies over the
journey. The lines are approximations of the actual positions. Despite that, they
still remain a powerful tool to prevent collisions, and optimize track usage.

= A Rust Plugin

I was messing with Typst since last year. It's a handy tool, specifically for typesetting.
However, it has the potential to do more than just typesetting. It has these powerful
functions:

- ```typc place()```
- ```typc curve()```
- ```typc box()```

And these values:

- Values of the `alignment` type, including `top`, `bottom`, `left`, `horizon`, etc.

These functions and values could build up an elementary drawing library, and that
is exactly what I did. I made Paiagram.
