#import "@local/wslib:0.1.0": *
#show: wstemplate.with(
  layout: "layout.webc",
  title: "404!",
  permalink: "/404.html",
  description: "The page you've visited doesn't exist.",
  eleventyExcludeFromCollections: true,
)

Go back to the #link("/")[home page]
