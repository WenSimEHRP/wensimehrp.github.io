#import "@preview/oxifmt:1.0.0": strfmt
#import "@local/wslib:0.1.0": *
#import "./_data/colours.typ"
#import "_data/trips.typ": trips

#show: wstemplate.with(
  layout: "layout.webc",
  toc: "false",
  title: "Transit Log",
  description: "A record of my transportation and travel history.",
  created: "2025-08-31",
  license: "All rights reserved",
)

#html.elem("div", attrs: (class: "text-sm text-gray-600 dark:text-gray-400 mb-4 leading-tight"))[
  - Click on station names to view them on Google Maps
  - Travel logs start from 2025. Some earlier trips are included, but may not be
    complete.
  - Click on the agency logo to visit their homepage.
  - Agency logos are fetched from various sources (mainly from
    #elink("https://commons.wikimedia.org/wiki/Main_Page")[Wikimedia Commons]).
    They may not always be accurate or up-to-date.
  - Through services are counted as separate companies.
  - Different directions of the same nominal bus route are counted as separate routes.
    E.g. "R4 UBC" is different from "R4 Joyce". This only apply to buses.
]

// we don't use elinks with icons here
#let elink = elink.with(show-icon: false)
#let td = "px-3 py-1 text-sm text-gray-900 dark:text-gray-100 align-middle whitespace-nowrap h-9 max-h-9"

#let diagnostics = (
  "Total trips": trips.len(),
  "Unique routes": trips
    .map(it => (it.at("agency", default: none), it.at("route", default: none)))
    .dedup()
    .filter(it => none not in it)
    .sorted(),
  "Unique vehicles": trips
    .map(it => (it.at("agency", default: none), it.at("vehicle", default: none)))
    .dedup()
    .filter(it => none not in it)
    .sorted(),
  "Transit agencies": trips.map(it => it.at("agency", default: none)).dedup().sorted(),
  "Stations visited": trips
    .map(it => (it.at("departure", default: none), it.at("arrival", default: none)))
    .flatten()
    .dedup()
    .filter(it => it not in (none, ""))
    .sorted(),
  "Money Spent": strfmt(
    "CA${:.2}",
    trips
      .map(it => {
        if "fare" in it and type(it.fare) == str {
          float(it.fare.replace("CA$", ""))
        }
      })
      .sum(),
  ),
)

#html.elem("div", attrs: (class: "grid grid-cols-2 md:grid-cols-4 gap-4 mb-8 mt-6"))[
  #for (k, v) in diagnostics {
    html.elem("div", attrs: (class: "card"))[
      #html.elem("div", attrs: (class: "text-2xl font-bold text-teal-600 dark:text-teal-400"), if type(v)
        in (array, dictionary) {
        [#v.len()]
      } else {
        [#v]
      })
      #html.elem("div", attrs: (class: "text-sm text-gray-600 dark:text-gray-400"))[#k]
    ]
  }
]

#let make-trip-row(trip) = html.elem("tr")[
  #let trip-info = colours.get(trip)
  // date
  #html.elem("td", attrs: (
    class: td,
  ))[
    #if "dateStr" in trip {
      trip.dateStr
    } else {
      trip.date.display("[month repr:short] [day], [year]")
    }
  ]
  // agency
  #html.elem("td", attrs: (
    class: td + " bg-gray-50 dark:bg-gray-700 text-center",
  ))[
    #if trip-info.agency-icon != none {
      elink(trip-info.agency-site, title: trip.agency)[
        #html.elem("img", attrs: (
          src: trip-info.agency-icon,
          alt: trip.agency,
          class: "inline-block h-full w-auto max-w-20 m-0 p-0 align-middle border-0 object-contain",
          style: "vertical-align: middle; margin: 0; padding: 0;",
        ))
      ]
    }
  ]
  // route
  #html.elem("td", attrs: (
    class: td,
  ))[
    #html.elem("span", attrs: (
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium min-w-30 max-w-30 overflow-hidden "
        + trip-info.route-colours,
      title: trip.at("route", default: "---"),
    ))[
      #html.elem("i", attrs: (class: trip-info.route-icon))
      #sym.space.nobreak
      #html.elem("span", attrs: (class: "truncate"))[#trip.at(
        "route",
        default: "---",
      )]
    ]
  ]
  // arrival and departure
  #(
    (trip.departure, trip.arrival)
      .map(it => html.elem("td", attrs: (
        class: td,
      ))[
        #elink("https://www.google.com/maps/search/" + it, title: it, class: "no-underline")[#it]
      ])
      .join()
  )
  // fare
  #html.elem("td", attrs: (
    class: td,
  ))[
    #if "fare" in trip and trip.fare not in ("", 0, 0.0, none) {
      html.elem("span", attrs: (class: "text-teal-600 dark:text-teal-400"))[#trip.fare]
    } else {
      html.elem("span", attrs: (class: "text-gray-400"))[\-\-\-]
    }
  ]
  // vehicle
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
  // notes
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
