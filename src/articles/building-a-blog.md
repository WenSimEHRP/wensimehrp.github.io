---
title: "Building a Blog"
layout: layout.njk
description: "Presumably, my first site in my life."
created: 2025-08-30
tags: ["blog"]
---

## Our Modern Landscape

I wanted to start a site since I was a kid. I think at that time I was only some 12 years old maybe.
My first year in middle school wasn't easy. I had mental breaks, I would hide myself in my room.
Things got better since the end of middle school. I moved, I made new friends, had new teachers,
most importantly, I learned how to code my way out.

I had programming courses in school, mostly python courses, and a bit of C++. Just like many other
people, I never learned a single line of JavaScript or TypeScript. These two languages (technically one),
however, are the foundations of our modern virtual world.

I learned about online railway sites by railway enthusiasts some day in 2024. Despite the minimal interface,
many still had fun reading their article. Starting a site isn't that hard, I thought, then I got puzzled by
all of those domain, cctld[^iso-3166], and server renting "solutions". I didn't ask for others' help, though.

Some time in the summer of 2025, I built my first proper rust project - [Paiagram](https://github.com/wensimehrp/paiagram), a typst plugin for drawing train timetable diagrams. I thought I would need to prepare online
documents for people to learn how to use this plugin, so I wrote
[some online documentation](https://wensimehrp.github.io/Paiagram/) for it.[^openttd] Writing it wasn't easy for me,
but eventually, I conquered most of the difficulties, to name a few, path errors, margin mismatches,
and trouble opening python servers. Big thanks to Kamiyori for their great work on
[shiroa](https://myriad-dreamin.github.io/shiroa/), and also on instant helps when I have trouble using shiroa.

Eventually, on the day I am writing this article, I `rm -rf`ed my old `blog` directory that's filled with
unrealistic thoughts and trash files, and reinitialized it. To my surprise, writing a site is not that hard anymore.
I can write the basic framework in only a day with the help of an LLM. I don't need to read all of the documentation
myself, the LLM will just do it for me. Of course, this raises lots of moral questions. Some would say that the use
of an LLM is scraping somebody else's work, and should not be allowed under any circumstances. It helped me, a guy who
just don't have that much time to learn every piece of document, an opportunity and tool to help expressing my
thoughts.

And now you are seeing the results. This is my blog site.

[^iso-3166]: Reference: I once had a fight with someone about ISO 3166-1 codes.

[^openttd]: I also had two sets of OpenTTD related documentation hosted on <readthedocs.io> before
that, but those are automatically generated using sphinx, and I didn't bother manually configuring most
of the contents generated except for a few html templates, so they don't really count in my opinion.

## Thank You, and Goodbye

This site couldn't be possible without the encouragement from my friends, both
the I know in real life and online.

Conrad - I've spent a pleasing and calming time with you, Conrad. I hope you'll do well in Hong Kong!

HCL - I don't know why you name yourself `drinking hydrochloride acid everyday`, I guess you do have
a reason. Thanks for your stories, and I have to say having a website at that age is very impressive.

Uwni - Thanks for your 11ty advices.

John Franklin - I have to say I don't like you very much. You're like the typical nerd we see on television
shows. Nonetheless, at least in terms of blog sites you've shown us the real techstack-minimalism. You're also
the No.1 reason why I'd write this site - I believe I can write something that looks better!
