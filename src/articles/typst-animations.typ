#import "@local/wslib:0.1.0": *
#metadata((
  layout: "layout.webc",
  title: "Animations with Typst",
  description: "A.K.A. Typst with FFmpeg, or Tanim.",
  created: "2025-09-14",
  tags: ("Typst", "tools", "FFmpeg"),
  author: "Jeremy Gao",
)) <frontmatter>
#show: wstemplate

Typst is a great typesetting tool. It's also great as a drawing tool. Reviewing its
history of #{ datetime.today() - datetime(year: 2019, month: 12, day: 1) }.days() days,
it has evolved from a simple typesetting tool to a powerful tool that can do way
more than typesetting documents alone. The community has developed presentation and
poster templates, people are using it to draw #elink("https://github.com/wensimehrp/paiagram")[train timetable diagrams]
as well as complex mathematical graphs. Despite all these, one thing nobody has done
(or at least I haven't seen anyone doing) is using Typst to create animations.

An animation is a sequence of images. Typst can generate images from Typst code,
so in theory, it is possible to generate an animation using Typst. A simple way to
do this is to first generate all frames as images using a loop or something else
that serves the same purpose
#footnote[
  Like a Makefile. Friendship ended with `do while` and `for`, now `make -j` is
  my best friend.
], then use a tool like FFmpeg to stitch the images together to form a video.
The pseudocode goes like this:

```
for idx in 0..=100 {
  typst compile frame.typ -f png frame_{idx}.png
}
ffmpeg frame_*.png output.mp4
```

But this is essentially the same as rendering one frame, and stretching the interval
of that frame 100 times -- definitely not what we wanted.

= Typst Inputs

Typst's `input` feature is _bad_. It allows the file to take an input value, and take
different actions based on that value -- non-deterministic!#footnote[
  Use the same words on `datetime.today()`.
] However, in our case,
it is the only way to pass the current frame index into the Typst file.

```
$> typst c frame.typ --input t=42
```

Typst offers `sys.inputs` for accessing input values inside the document. All inputs
are of string type, so it's necessary to convert them to numbers first.

= Speeding Up the Process

We have a simple workflow now, but it is very slow. FFmpeg only reports around 2
frames per second on my i9-13900HX machine. Can we do better? Of course we can.

== Prevent Scanning System Fonts

By default, before rendering the document, Typst would check system fonts and check
what glyphs/codepoints are available. This process takes a significant amount of time
to run on my i9-13900HX machine, and it is unreasonable to let Typst do this for
a 65536-frame animation. Luckily, there are two flags that can help:

- `--ignore-system-fonts`: Don't perform the system font check
- `--font-path`: Specify a font path to load fonts from

In my case, I just put the fonts that are required in the same working directory,
and use `--font-path ./` to load fonts from the current directory. The time difference
for rendering a single frame is huge:

#figure(
  with-frame: false,
  caption: [
    Performance comparison using `poop`. Here poop is using Typst to compile an
    early version of the article you're reading now.
  ],
  ```
  Benchmark 1 (5 runs): typst c typst-animations.typ --features html -
    measurement          mean ± σ            min … max       outliers    delta
    wall_time          1.24s  ± 11.5ms    1.22s  … 1.25s       0 ( 0%)   0%
    peak_rss           84.0MB ±  483KB    83.5MB … 84.6MB      0 ( 0%)   0%
    cpu_cycles         6.28G  ± 28.2M     6.25G  … 6.33G       0 ( 0%)   0%
    instructions       13.8G  ± 41.2M     13.7G  … 13.8G       1 (20%)   0%
    cache_references   7.30M  ±  513K     6.86M  … 8.18M       0 ( 0%)   0%
    cache_misses       2.24M  ±  105K     2.13M  … 2.37M       0 ( 0%)   0%
    branch_misses      23.2M  ± 90.5K     23.1M  … 23.3M       0 ( 0%)   0%
  Benchmark 2 (98 runs): typst c typst-animations.typ --ignore-system-fonts --font-path ./ --features html -
    measurement          mean ± σ            min … max       outliers    delta
    wall_time          51.2ms ± 2.24ms    47.7ms … 60.9ms      3 ( 3%)   ⚡- 95.9% ±  0.2%
    peak_rss           48.6MB ±  315KB    47.6MB … 49.3MB      3 ( 3%)   ⚡- 42.1% ±  0.3%
    cpu_cycles          173M  ± 6.52M      130M  …  181M       5 ( 5%)   ⚡- 97.2% ±  0.1%
    instructions        424M  ± 16.8M      313M  …  444M       6 ( 6%)   ⚡- 96.9% ±  0.1%
    cache_references    660K  ± 37.8K      509K  …  760K       6 ( 6%)   ⚡- 91.0% ±  1.4%
    cache_misses        178K  ± 27.7K      119K  …  243K       0 ( 0%)   ⚡- 92.0% ±  1.4%
    branch_misses      1.23M  ± 47.2K      927K  … 1.29M       6 ( 6%)   ⚡- 94.7% ±  0.2%
  ```,
)

The first command only runs 5 times over the 5000ms duration, while the second command
runs 98 times over the same duration. That's a 95.9% speedup!

== Multithreading with GNU Parallel

The Typst command part is now fairly fast, yet it's still possible to speed up the
process by running multiple Typst commands in parallel.

#elink("https://www.gnu.org/software/parallel/")[GNU Parallel] is the perfect tool
for this job. It can take a list of items, and run a set of commands for each item
in parallel. This tool is written in Perl. That being said, it is good enough to
spawn a lot of processes and organize them.

```bash
seq 0 100 | parallel typst c flash.typ --input t={} -f png {}.png
```

== The POSIX Pipe

The naive approach involves writing to the disk, for FFmpeg would later read from
the disk. Yet disk I/O is slow, writing lots of small images to the disk is even
slower.

A better approach is to use a pipe. A pipe redirects the standard output of the first
command to the second command's standard input. Both the standard input and output
take place in memory, and memory I/O is magnitudes faster than disk I/O.
#footnote[
  It's also possible to create a ramdisk or a tmpfs for this purpose, but for our
  scenario the pipe is sufficient. A tmpfs in this case is just an overkill.
]
Take `ls -l | grep foo` as an example:

- `ls` lists all files in the current directory, and writes the output to its standard
  output (stdout)
- The pipe (`|`) redirects the stdout of `ls` to the standard input (stdin) of `grep`
- `grep` reads from its stdin, and filters the lines that contain `foo`, then writes
  the result to its stdout

Pipes are fast and instant. Once the first command produces output, the output is
immediately sent to the second command. There is no need to wait for the first command
to finish in the first place, both commands can _run concurrently_. FFmpeg, for example,
can start encoding the video as soon as it receives input from its standard input.

Another cool feature about pipes is that if the second command cannot consume the
input fast enough, the first command is automatically paused until the second command
digests the input. This prevents memory overflow, and saves CPU cow power.

Naturally, for such a workflow, writing everything to the disk is not necessary.
Taken the code from above, we can modify it to:

```bash
seq 0 100 | \
  parallel typst c flash.typ --input t={} -f png - | \
  ffmpeg -f image2pipe -vcodec png -i - output.mp4
```

Notice that the pipe is not redirecting the output of the `typst` command, rather,
it is redirecting the output of `parallel`. This is because we want to pipe the output
of all `typst` commands to `ffmpeg`, not just one of them.

However, this introduces a new problem: how to make sure that the pipe would pipe
out images in order? The previous approach would execute multiple Typst commands
in parallel, and the output of each command is written to disk. Since FFmpeg reads
from the disk, the order is guaranteed. Yet, now that we are piping the output of
Typst commands (that are organized by `parallel`) to FFmpeg, and each Typst job might
finish at different times, it seems that the order is not guaranteed anymore.

Just kidding. GNU Parallel's `-k` or `--keep-order` flag guarantees that the output
of each command is in the exact order as the input. Now after adding the `-k` flag,
we have a script that goes like this:

```bash
seq 0 100 | \
  parallel -k typst c flash.typ --input t={} -f png - | \
  ffmpeg -f image2pipe -vcodec png -i - output.mp4
```

== The Final Script

With all those modifications, here is our final script with some additional FFmpeg
flags:

```bash
#!/usr/bin/env bash
set -euo pipefail

FPS=24
END=0xFFFF
OUTPUT="output3.mkv"

seq 0 $((END)) | parallel -k \
  typst c flash.typ \
    --input a={} \
    --ignore-system-fonts \
    --ppi 120 \
    --font-path ./ \
    -f png \
    - | \
  ffmpeg -y -f image2pipe \
    -vcodec png \
    -framerate "$FPS" \
    -i - \
    -i music.mp3 \
    -map 0:v:0 -map 1:a:0 \
    -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
    -af "loudnorm=I=-16:LRA=7:TP=-1.5" \
    -c:v libx265 -preset medium -crf 23 -threads 0 \
    -c:a aac -b:a 192k \
    -shortest \
    "$OUTPUT"
```

= Potential Speedups

Typst is already pretty fast at rendering documents, yet, on the one hand, the PNG
format is costly to both encode and decode. Using a different format such as `rgb`,
`bmp`, or `qoi` would accelerate the process even more. Yet Typst doesn't even support
JPEG yet, so I think that would take a while to happen.

Some may note that Typst also supports SVG output, and FFmpeg also supports SVG input.
However, FFmpeg's SVG is based on disk files, and piping from Typst to FFmpeg would
not work. Outputting to SVG and using ImageMagick to convert SVG to RGB would work
in theory, yet I've tried and somehow it failed for me. If you managed to make it work,
please let me know!

On the other hand, even though we are running everything in parallel, Typst itself
only runs on the CPU. Making Typst GPU-accelerated would be a huge improvement, yet
it is not something that can be done easily.

Lastly, it could be possible to get rid of `parallel` entirely -- Typst itself is
multithreaded, just that it doesn't support outputting raster images to the standard
output. If Typst supports this feature, we could just run the Typst command once,
let Typst handle the multithreading part and organize the images, then pipe that
to FFmpeg. This eliminates not just the overhead of `parallel`, but also the overhead
of cold-booting Typst 60k times.#footnote[
  Reviewing this part I realized that I missed a critical part in letting Typst handle
  parallelism: Typst provides `state`, `counter`, and `query` for querying the state
  of the current documentation. The query goes two ways in time -- time travelling.
  It is definitely possible and valid for an earlier frame to query the state of a later
  frame. This means that if any of those `foo-state.final()` code is involved, Typst
  would have to first store all 65k frames in memory, then resolve all queries, then
  pipe all frames out. The extra memory burden is definitely not what we want.
]

= This Does Not Work in Nushell!

Well, it's a bit of an overexaggeration to say that it cannot work at all in Nushell.
I am talking about the `par-each` command in Nushell, that takes a list of items and
passes them into a closure, and runs the closures in parallel. The problem is not
parallelism, neither the closure itself, but the fact that Nushell would collect
the output of all closures first, then pipe them into the next command. In our case
there are 65536 frames, and collecting all of them would take a lot of memory
and time.

Compared to GNU Parallel, `parallel` would start piping the output of each command
immediately, doesn't need to wait for all commands to finish. As soon as there are
output from one command, it would be piped into the next command immediately, which,
in our case, is FFmpeg. This saves memory, and also allows two sets of commands to
run concurrently.

= The Proper Engine That Actually Uses Typst

Okay, I hereby admit that I've just created the most advanced frame-by-frame animation
engine *Tanim*!

Jokes aside, what we've now discussed are only the elementary steps of building an
animation engine. A real engine
#footnote[
  Manim is indeed a great example, but Adobe Flash... is also not bad :P.
]
involves much more than simple frame-by-frame rendering. And this linear workflow
simply composed using Typst and FFmpeg cannot be sufficient for a real animation engine.

There is one engine, #elink("https://github.com/jkjkil4/JAnim")[JAnim], that actually
uses Typst. It doesn't use Typst to render each frame, but to invoke Typst at runtime
for elements (text, arbitrary shapes and graphs, and math formulas) that can be used
by the engine.

= Not Really a Conclusion

Here's a #elink("https://decodeunicode.org/")[Decode-Unicode] style
#elink("https://www.bilibili.com/video/BV1Z3HozoEPi")[
  unicode character display video
] #footnote[
  I know that some people might have problems playing Bilibili videos, but let's
  just keep that for now. I don't want to post it on YouTube yet.
]I made using the command given above. It has a bit less than 65536 frames -- not exactly 65536,
due to the fact that some Unicode codepoints in this range are invalid. Some codepoints
are not defined, some are not displayable, some are just in the private use area,
so the video doesn't reflect the actual Unicode standard. Nevertheless, I think this
would be a good starting point for anyone who wants to create animations using Typst.
Enjoy!

#html.elem("iframe", attrs: (
  src: "//player.bilibili.com/player.html?isOutside=true&bvid=BV1Z3HozoEPi",
  scrolling: "no",
  border: "0",
  frameborder: "no",
  framespacing: "0",
  allowfullscreen: "true",
  class: "w-full aspect-video",
  loading: "lazy",
))
