#import "@local/wslib:0.1.0": *
#show: wstemplate.with(
  title: "Bad Typple",
  description: "Bad Apple with Typst",
  created: "2025-09-21",
  tags: ("Typst",),
  author: "Jeremy Gao",
)

I don't have time right now so this might be a short one.

So bascially the thing is at #elink("https://github.com/WenSimEHRP/bad-typple").
The rest I don't have time to tell you I have calculus to do right now bye bye.

#context if target() == "html" {
  html.elem("iframe", attrs: (
    src: "//player.bilibili.com/player.html?isOutside=true&bvid=BV1MnncznEbc",
    scrolling: "no",
    border: "0",
    frameborder: "no",
    framespacing: "0",
    allowfullscreen: "true",
    class: "w-full aspect-video",
    loading: "lazy",
  ))
} else [
  The video is available at #elink("https://www.bilibili.com/video/BV1MnncznEbc").
]
