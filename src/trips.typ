#import "@preview/oxifmt:1.0.0": strfmt
#metadata((
  layout: "layout-without-toc.webc",
  title: "Travel Log",
  description: "A record of my transportation and travel history.",
  created: "2025-08-31",
  license: "All rights reserved",
)) <frontmatter>

#html.elem("div", attrs: (class: "text-sm text-gray-600 dark:text-gray-400 mb-4 leading-tight"))[
  - Click on station names to view them on Google Maps
  - Travel logs start from 2025. Some earlier trips are included, but may not be
    complete.
  - Click on the agency logo to visit their homepage.
  - Agency logos are fetched from various sources (mainly from
    #link("https://commons.wikimedia.org/wiki/Main_Page")[Wikimedia Commons]).
    They may not always be accurate or up-to-date.
  - Through services are counted as separate companies.
  - Different directions of the same nominal bus route are counted as separate routes.
    E.g. "R4 UBC" is different from "R4 Joyce". This only apply to buses.
]

#let td = "px-3 py-1 text-sm text-gray-900 dark:text-gray-100 align-middle whitespace-nowrap h-9 max-h-9"

#let trips = (
  toml("_data/trips.toml")
    .trip
    .map(it => {
      let raw = it.at("date", default: (:)).values().at(0, default: none)
      let parsed = none
      if raw != none {
        let parts = raw.split("T").at(0).split("-").map(int)
        parsed = datetime(year: parts.at(0), month: parts.at(1), day: parts.at(2))
      }
      (..it, date: parsed)
    })
)
#let trips-additional = toml("_data/tripAdditional.toml")

#let diagnostics = (
  "Total trips": trips.len(),
  "Unique routes": trips.map(it => it.at("agency", default: none) + it.at("route", default: none)).dedup().len(),
  "Unique vehicles": trips.map(it => it.at("agency", default: none) + it.at("vehicle", default: none)).dedup().len(),
  "Transit agencies": trips.map(it => it.at("agency", default: none)).dedup().len(),
  "Stations visited": trips
    .map(it => (
      it.at("agency", default: none) + it.at("departure", default: none),
      it.at("agency", default: none) + it.at("arrival", default: none),
    ))
    .flatten()
    .dedup()
    .len(),
  "Money Spent": strfmt("CA${:.2}", trips.map(it => {
    if "fare" in it and type(it.fare) == str {
      float(it.fare.replace("CA$", ""))
    }
  }).sum())
)

#html.elem("div", attrs: (class: "grid grid-cols-2 md:grid-cols-4 gap-4 mb-8 mt-6"))[
  #for (k, v) in diagnostics {
    html.elem("div", attrs: (class: "card"))[
      #html.elem("div", attrs: (class: "text-2xl font-bold text-teal-600 dark:text-teal-400"))[#v]
      #html.elem("div", attrs: (class: "text-sm text-gray-600 dark:text-gray-400"))[#k]
    ]
  }
]

#let make-trip-row(trip) = html.elem("tr")[
  #html.elem("td", attrs: (
    class: td,
  ))[
    #if "dateStr" in trip {
      trip.dateStr
    } else {
      trip.date.display("[month repr:short] [day], [year]")
    }
  ]
  #html.elem("td", attrs: (
    class: td + " bg-gray-50 dark:bg-gray-700 text-center",
  ))[
    #let agency-info = {
      if "agency" in trip and trip.agency in trips-additional.agency {
        trips-additional.agency.at(trip.agency)
      } else {
        none
      }
    }
    #if agency-info != none {
      html.elem("a", attrs: (
        target: "_blank",
        href: agency-info.site,
        title: trip.agency,
        rel: "noopener noreferrer",
      ))[
        #html.elem("img", attrs: (
          src: agency-info.image,
          alt: trip.agency,
          class: "inline-block h-full w-auto max-w-20 m-0 p-0 align-middle border-0 object-contain",
          style: "vertical-align: middle; margin: 0; padding: 0;",
        ))
      ]
    } else {
      html.elem("div", attrs: (
        class: "inline-flex items-center",
      ))[
        #html.elem("span", attrs: (class: "text-gray-500 text-xs font-mono"))[
          #trip.at("agency", default: "---")
        ]
      ]
    }
  ]
  #html.elem("td", attrs: (
    class: td,
  ))[
    #let type-info = {
      if "type" in trip and trip.type in trips-additional.type {
        trips-additional.type.at(trip.type)
      } else {
        (colorClasses: "bg-gray-100 text-gray-800 dark:bg-gray-600 dark:text-gray-200", icon: "")
      }
    }
    #html.elem("span", attrs: (
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium min-w-30 max-w-30 overflow-hidden "
        + type-info.colorClasses,
      title: trip.at("route", default: "---"),
    ))[
      #html.elem("i", attrs: (class: type-info.icon))
      #sym.space.nobreak
      #html.elem("span", attrs: (class: "truncate"))[#trip.at(
        "route",
        default: "---",
      )]
    ]
  ]
  #(
    (trip.departure, trip.arrival)
      .map(it => html.elem("td", attrs: (
        class: td,
      ))[
        #html.elem("a", attrs: (
          class: "no-underline truncate block",
          href: "https://www.google.com/maps/search/" + it,
          target: "_blank",
          rel: "noopener noreferrer",
          title: it,
        ))[#it]
      ])
      .join()
  )
  #html.elem("td", attrs: (
    class: td,
  ))[
    #if "fare" in trip and trip.fare not in ("", 0, 0.0, none) {
      html.elem("span", attrs: (class: "text-teal-600 dark:text-teal-400"))[#trip.fare]
    } else {
      html.elem("span", attrs: (class: "text-gray-400"))[\-\-\-]
    }
  ]
  #html.elem("td", attrs: (
    class: td,
  ))[
    #html.elem("span", attrs: (
      class: "inline-flex py-0.5 font-medium min-w-30 max-w-30 overflow-hidden"
        + if "vehicle" not in trip or trip.vehicle in ("", none) { " text-gray-400" } else { " text-xs" },
      title: trip.at("vehicle", default: "---"),
    ))[
      #html.elem("span", attrs: (class: "truncate"), trip.at("vehicle", default: "---"))
    ]
  ]
  #html.elem("td", attrs: (
    class: td,
  ))[
    #if "notes" in trip and trip.notes not in ("", none) {
      html.elem(
        "span",
        attrs: (
          class: "text-gray-600 dark:text-gray-400",
          title: trip.notes,
        ),
        trip.notes,
      )
    } else {
      html.elem("span", attrs: (class: "text-gray-400"))[\-\-\-]
    }
  ]
]

#html.elem("div", attrs: (
  class: "bg-gray-50 dark:bg-gray-700 outline rounded-lg outline-gray-200 dark:outline-gray-700 overflow-x-auto",
))[
  #html.elem("table", attrs: (class: "min-w-full divide-y divide-gray-200 dark:divide-gray-700"))[
    #html.elem("thead", attrs: (class: "bg-gray-50 dark:bg-gray-700"))[
      #(
        ("Date", "Agency", "Route", "From", "To", "Fare", "Vehicle", "Notes")
          .map(it => {
            html.elem("th", attrs: (
              class: "px-3 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider",
            ))[#it]
          })
          .join()
      )
    ]
    #html.elem("tbody", attrs: (class: "bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700"))[
      #trips.rev().map(make-trip-row).join()
    ]
  ]
]
