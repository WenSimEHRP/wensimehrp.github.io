#let translink(p) = (
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
)
