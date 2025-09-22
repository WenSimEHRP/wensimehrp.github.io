#let get(profile) = {
  // default values
  let route-icon = "fa-solid fa-question"
  let route-site = none
  let route-colours = "bg-gray-100 text-gray-800 dark:bg-gray-600 dark:text-gray-200"
  let agency-icon = none
  let agency-site = none
  // agency overrides
  let agency = profile.at("agency", default: "_default")
  let agencies-dict = (
    "TransLink": p => (
      agency-icon: "https://upload.wikimedia.org/wikipedia/commons/3/3e/TransLink_%28Vancouver%29_Logo.svg",
      agency-site: "https://www.translink.ca/",
      route-icon: {
        let route = p.at("route", default: "")
        if route.ends-with("Line") {
          "fa-solid fa-train-subway"
        } else if route.starts-with(regex("(N|R|\d+)")) {
          "fa-solid fa-bus"
        } else if route == "SeaBus" {
          "fa-solid fa-ferry"
        } else if route == "West Coast Express" {
          "fa-solid fa-train"
        }
      },
      route-colours: {
        let name = p.at("route", default: "")
        let a = (
          "Canada Line": l => "bg-sky-100 dark:bg-sky-900 text-sky-800 dark:text-sky-200",
          "Millennium Line": l => "",
          "Expo Line": l => "bg-blue-200 dark:bg-blue-950 text-blue-800 dark:text-blue-200",
          "SeaBus": l => "",
          "West Coast Express": l => "",
          "_default": l => {
            let name = l.at("route", default: "")
            if name.starts-with("N") {
              ""
            } else if name.starts-with("R") {
              "bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200"
            } else if name.starts-with("99") {
              "bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200"
            } else {
              "bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200"
            }
          },
        )
        if name not in a { a.at("_default")(p) } else { a.at(name)(p) }
      },
    ),
    "BC Transit": p => (
      agency-icon: "https://upload.wikimedia.org/wikipedia/commons/5/5e/BC_Transit_logo.svg",
      agency-site: "https://www.bctransit.com/",
    ),
    "BC Ferries": p => (
      agency-icon: "https://upload.wikimedia.org/wikipedia/en/2/21/BC_Ferries_Logo.svg",
      agency-site: "https://www.bcferries.com/",
      route-icon: "fa-solid fa-ferry",
      route-colours: "bg-neutral-100 dark:bg-neutral-900 text-blue-800 dark:text-blue-200 outline-2",
    ),
    "Cathay Pacific": p => (
      agency-icon: "https://upload.wikimedia.org/wikipedia/en/1/17/Cathay_Pacific_logo.svg",
      agency-site: "https://www.cathaypacific.com/",
      route-icon: "fa-solid fa-plane",
      route-colours: "bg-sky-100 dark:bg-sky-900 text-sky-800 dark:text-sky-200",
    ),
    "_default": p => (:),
  )
  let result = if agency not in agencies-dict {
    agencies-dict.at("_default")(profile)
  } else {
    agencies-dict.at(agency)(profile)
  }
  return (
    (
      route-icon: route-icon,
      route-site: route-site,
      route-colours: route-colours,
      agency-icon: agency-icon,
      agency-site: agency-site,
    )
      + result.pairs().filter(it => it.at(1) not in (none, "")).to-dict()
  )
}
