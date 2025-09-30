#import "translink.typ": translink
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
    "TransLink": translink,
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
