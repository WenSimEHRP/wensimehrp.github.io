---
title: "RingWorld"
description: "Localization and internationalization madness."
created: 2025-09-03
layout: layout.webc
tags: ["RimWorld", "game", "localization", "internationalization"]
author: "Jeremy Gao"
wip: true
---

## RingWorld?

_Rim_ means the _edge_ of a subject, and a _ring_ is a circular and hollow object.
In _some year_, before RimWorld's released its initial Chinese translations, a group
of translator from 3DMgames translated RimWorld into Simplified Chinese. In their
translation, they made a mistake, and translated the title of the game -- the most
important piece of text -- to "RingWorld", and started a chain of unbelievable misunderstandings
that still deeply affect the game community until today.

## Being Affected

The translators from 3DMgames shaped the initial Chinese player community. Their
mistake was never entirely corrected. Even I almost thought that a _rim_ is a _ring_.
Their legacy can still be seen on online video sites like bilibili, general discussion
sites like Baidu Tieba, and countless discussion groups on QQ, the Line of China.

Like many other players, I accepted the "RingWorld" translation -- almost because
at the time I started playing I didn't see any other viable title translations.
A game may stay alive for ten years, some maybe thirty, yet most of them will be
forgotten very soon. RimWorld is no exception.

## Sticking To the Default Language

Despite the fact that my native speak is Mandarin[^native], I've set most of my services
and devices' displaying language to English[^canadian]. I have three reasons for
doing so:

- Terminologies are (usually) easier to understand.[^robust]
- Most software, at their initial design phase, did not consider non-latin text layout,
or they've considered that, but did a poor job on it. I am picky on text layouts,
and Chinese is not a latin language[^roman]. Putting Chinese text in a latin-oriented
user interface that does not follow Chinese typesetting rules is completely intolerable.
- Similar to the previous problem, translations with variable text may also break
Chinese grammar rules[^english]. Even if they don't break the grammar, the translation
may still be a result of machine translation, unreviewed AI translation, or from
a careless translator[^me].

[^native]: The written language is Chinese, and the spoken language is Mandarin.
When somebody tell you that they "speak Chinese", they are essentially telling you
that they can speak "ink printed on a newspaper", although they usually don't mean
that -- 99% of the time they are trying to say that they know Mandarin. I wish I
could learn more Wenzhounese, though. This is not a joke.

[^canadian]: Canadian English, of course.

[^robust]: Ref.: [Shandong Club-ness (robustness)](https://www.zhihu.com/question/27877812).
This does not stand for "鲁智深提着狼牙棒" or "Koreans in Shandong"

[^roman]: That is only valid if you are not a Romanized Chinese educand from the
1940s. I just cannot understand the idea at all -- look at Vietnam, and look how
their language has changed after the French colonized the country.

[^english]: If you don't know Chinese already, here is an example in English: try
to put `eat, grow, inspect` in `I did apple <placeholder>ed.`. A translator may argue
that they can move the placeholder, but in more cases the entire string the result
of string concatenating, which is a part of the main program, and cannot be modified
unless reverse engineered (English is subject-verb-object, this example is subject-object-verb).

[^me]: ref: I mistranslated some string of a game once and some angry players got
pissed off of my translation.

## The Modern Translator Platform

Many developers may heard of Crowdin, and just like its name, its a crowdsourced
site that helps translating applications.

## Why Concat?

There are plenty of translation frameworks out their, and Tynan chose the worst one --
manually injecting definitions and doing concatenation at source code level. Each
piece of
