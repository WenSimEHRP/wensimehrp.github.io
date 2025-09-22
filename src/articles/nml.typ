#import "@local/wslib:0.1.0": *
#show: wstemplate.with(
  title: "NewGoofy Meta Language",
  description: "Why NML is bad, why NewGRF is bad.",
  created: "2025-09-03",
  layout: "layout.webc",
  tags: ("OpenTTD", "game", "tools"),
  author: "Jeremy Gao",
  wip: true,
)

I've been writing NewGRFs for a while. My first GRF released on #elink("https://bananas.openttd.org")[BaNaNaS]
was a China Set GRF -- despite the fact that I don't really like the project's artistic
style. It's been a bit more than a year since the release, and learning the specifications
as I developed more GRFs, NML showed its shortcomings and awkward design to me.

= What is a GRF?

The two terms "NewGRF" and "GRF" are interchangeable at most times. "GRF" stands
for "Graphics Resource Files", and the "New" in "NewGRF" adds another layer of newness
to it.#footnote[A notable amount of features in OpenTTD start with "N" or "New". They usually
  stands for "New", but in some cases they also stand for "Not" or "No".]

GRFs are the _de-facto_ "mods" of OpenTTD and TTDPatch. OpenTTD never developed
an alternative type of file for content-wise game modifications (GameScripts and
AIs are not in the scope of this article). Instead, it used the legacy of TTDPatch
and TTD -- the `.grf` format.

A GRF is composed of real sprite blocks and pseudo-sprite blocks. A real sprite block
contains a sprite. Think of a sprite as an image of a car, or a house. The landscape,
bridges, road and rail infrastructure graphics are all real sprites. In contrast,
a pseudo-sprite block does not contain visual elements. It is a piece of code, and
the game interprets it to define or redefine vehicles, industries, houses, etc.,
skip a specific portion of the game, and modify global variables.

GRFs are unlike lua scripts in Transport Fever or Factorio. It's also not the same
as zipped xml definitions in RimWorld.
#footnote[RimWorld is a fun game, but its localizations suck.
  Tynan Sylvester did not put any effort into i18n.]
They are more like self-contained
executable files that contain assembly instructions. GRFs are assembly like, and
writing a GRF from scratch, without the help of NML, or a macro processor, is hard.

= Writing a GRF

Early GRF developers relied on the `grfcodec` utility, a GRF compiler and decompiler.
At this stage of GRF development, everything is at the assembly level. A bit later,
some developers (namely Michael Blunck) developed pre-configured macros for NFO using
`GNU M4`.#footnote[Speaking of macros... LaTeX :P] After fighting with spriteblocks
for a while, NML was born.

Modern GRF developers would start using NML. NML abstracts away the low-level spriteblocks
when writing a GRF, and provides semantic codepoints for runtime variables, object
properties, and control flows. You can see the code examples at
#elink("https://www.tt-wiki.net/wiki/NMLTutorial")[NMLTutorial] for details.

Things are regulated with NML. NML also provids a solid foundation for writing NewGRFs.
It ensured that all spriteblocks generated on the lower level are in the correct
orders and positions. An example would be the if control flow. Writing a structure
that is equivalent to the if-else control flow in other languages is quite hard.
Basically, there are three steps to do:

- Count how many spriteblocks to skip
- Write a `action 7/9` block at the start of the spriteblocks you would like to skip.
- Write down the counted number. If the number exceeds 255, you would then need to
write an `action 10` "label" block at the end of the skipped spriteblocks, assign
an index to it, and write the index in the `action 7/9` block.

While in NML it is this: `if (...) {...} else {...}`.

The example above should show how helpful NML is.
#footnote[
  To be fair, I've never tried writing a GRF in pure GRF assembly language --
  oftentimes called "NFO". Writing NFO is a pain. There are too many parts that drags
  you away from actual development. Sometimes it could be a syntax error at some block,
  more likely you've accidentally written the incorrect hexadecimal offset for a runtime
  variable. Some comments in this article regarding NFO thus may be imprecise, and
  highly subjective.]
Instead of writing `action 8`
and `action 14` for GRF information declaring, NML uses the `grf` block that handles
them simultaneously. Instead of using an `action 0` and composing multiple `action 2`
together, NML does the `item` block. NML has helped numerous developers to focus
on the actual GRF logic without wasting time studying GRFSpecs, and everything seems
to be in a harmony. OpenTTD GRF devs use the latest NML, and produce wonderful contents
for players.#footnote[Oftentimes themselves. :-)]

= The Twist

We've talked about the good of NML, now it is time to talk about its bad.

NML is wonderful for simple operations such as adding a vehicle or simple house.
Its quirks starts showing up when you decided to implement some advanced logical
mechanism.

I've worked on a Station GRF called _WINS Is Not (only) Stations_. I tried to implement
advanced logic, such as querying nearby tiles to determine the current tile's graphics
in the GRF -- and implementing the stuff is a pain in the arse. Station tiles may
use multiple pieces of graphics, and graphics are organized using a structure called
a `spritelayout`. The Sprite layout block keeps in track of a list of bounding boxes
#footnote[
  The technical detail behind this: OpenTTD is a 2.5D game, and to make sure
  the overlapping relationships between objects are handled correctly, the game uses
  a system that creates 3D bounding boxes, and organize the display priority based
  on how the bounding boxes are laid out.]
and the graphics associated with it. To make graphics change or display conditionally,
I must write conditions in the spritelayout block. Even if I write those variables,
because a spritelayout block have limited registers, I cannot use more than six variables,
and that is for all components on a single tile.

= The Solution -- External Tools and Macros

NML, by default, does not support merging together multiple files.
#footnote[There are efforts to address this though. #elink("https://github.com/OpenTTD/nml/pull/358")[A PR]
  adds initial support for including files. Nonetheless, it is still a draft, and is
  unmerged for months.]
A popular way to address that is to use `gcc -E -x c <input-file> > <output-file>`,
with an input file that looks like this:

```cpp
#include "trucks/torakku-hi"
#include "trucks/torakku-fu"
#include "trucks/torakku-mi"
...
#include "buses/basu-one"
```

Other methods include:

- Using a python script that reads and concats all files, and output the result to
  another file, which is then passed to nmlc, the NML compiler
- `cat src/**/* > /tmp/nmltmp; nmlc /tmp/nmltmp`.
- #elink("https://www.tt-forums.net/viewtopic.php?t=83239")[StarRaid's NML pypatcher] --
  this is basically the same as the gcc approach.

Using GCC comes with another side affect, which I consider as a benefit. GCC supports
expanding C-style macros#footnote[ref: `Q_OBJECT`], and macros help reducing boilerplate.
