---
title: "Run your regex in DOOM"
date: 2022-10-04
issueId: 93
---

## Intro

Some time ago, i saw and **loved** this [regex to fat32 thing](https://github.com/8051Enthusiast/regex2fat). Its the kind of nonsense thing i love. Time passed and i started studying [regex](https://en.wikipedia.org/wiki/Regular_expression), [DFA](https://en.wikipedia.org/wiki/Deterministic_finite_automaton) and [formal languages](https://en.wikipedia.org/wiki/Formal_language). Then i came across this [resume built in DOOM](https://www.arm64.ca/post/creating-a-resume-in-doom/), and there everything fell in place.

A regex is also a DFA. DFAs are graphs. A maze, map, labyrinth or whatever you want to call it could be abstracted with a graph.

You know where you could play and wander around a maze? **Yes, in DOOM.**

Although my first idea was to make it in Half-Life, the first FPS i've ever played. But DOOM is the meme. So lets build something to convert a regex into a DOOM map, so you could walk through it. And who knows, maybe even [run it in a pregnancy test](https://twitter.com/foone/status/1302820468819288066).

## Regex to DFA

Im not ***that*** insane to build my own regex to DFA library just for this. Luckily some clever folk have [already done this](https://github.com/BurntSushi/regex-automata).

So for this step, the only thing i needed to do was write some [glue code](https://github.com/pudymody/regex2doom/blob/main/src/main.rs#L302) to convert the DFA to a graph using an [adjacency list](https://en.wikipedia.org/wiki/Adjacency_list).

## DOOM map

Now with a graph, i need to convert it to a map. I will use [GZDoom](https://zdoom.org/), a modern implementation of the DOOM engine. With modern implementations, comes better tooling.

For the map, im going to write a *[UDMF](https://github.com/ZDoom/gzdoom/blob/master/specs/udmf.txt)* one. This is a new way of writing maps using only plain text with a well-defined syntax. Which i think its awesome, because its easier to debug than looking through binary files. At least for me.

The [code](https://github.com/pudymody/regex2doom/blob/main/src/main.rs#L352) works by creating a room for every node in the graph, creating the needed vertexes, linedefs, sidedefs, sectors and portals and making sure they dont overlap. If you dont know what im talking, dont worry, neither do i. Its just DOOM map jargon.

## Textures
For the textures of the walls, ceiling, floor, im going to use [Freedoom](https://freedoom.github.io/about.html). The missing part are the "letters portals", where you would walk to traverse the string.

For them, i downloaded [this asset](https://opengameart.org/content/sprite-fonts-64x64-abblv-by-raid) by Raid from OpenGameArt.

It was a single image with every letter or spritesheet. Nothing that and old bash command couldnt solve.
```sh
convert vermelha.png -crop 5x9@ +repage tile-%d.png
```
Here the *+repage* flags its very important. What i would expect to happen by default. I lost many hours to this. Without it, the image will have a [virtual canvas](https://imagemagick.org/Usage/crop/#crop_repage).

I also needed to overlay them in the floor texture.
```sh
for file in tile-*.png; do convert -flatten floor.png $file ./parsed/$file; done
```

### Sidenote about texture aligment
One thing that i found interesting, its that [textures are aligned to a 64-unit grid](https://doomwiki.org/wiki/Texture_alignment#Floor_and_ceiling_textures). So whenever i have a portal at a position that is not divisible by 64, i need to offset its texture by that remainder.

## Packaging
To package everything and make it playable, first i thought of using this [Standalone Game Template](https://forum.zdoom.org/viewtopic.php?t=70232) by Nash. But i didnt want to be packaging everything everytime i compile a new regex. And i also wanted that DOOM look.

I discover that you can create what is called a [PWAD](https://doomwiki.org/wiki/PWAD) file. A container with files to patch, so you could load freedoom with every texture, and then load your custom map to only overwrite the first level.

First i compiled my [Alphabet texture](https://github.com/pudymody/regex2doom/blob/main/dist/textures.wad) using [SLADE3](https://slade.mancubus.net/) (a GUI doom editor) to a file called *textures.wad*.

Then [i would create a new PWAD](https://github.com/pudymody/regex2doom/blob/main/src/main.rs#L376) file which will overwrite the first level in the game with the map for the regex.

## Gameplay
The first thing its to [run the thing](https://github.com/pudymody/regex2doom) with a regex you like. If you cant, dont worry, you could [download this same test map](https://github.com/pudymody/regex2doom/blob/main/dist/MAP01.wad)

```sh
echo "DOOO*M" | regex2doom
```

*(This will match DOOM, DOOOM, DOOOOM and so on, with how many Os you want.)*

Then you will need [Freedom](https://freedoom.github.io/download.html) and the [custom alphabet texture i made earlier](https://github.com/pudymody/regex2doom/blob/main/dist/textures.wad).

And finally, you need to run gzdoom with the three files.
```sh
gzdoom -iwad ./freedoom1.wad -file ./textures.wad -file ./MAP01.wad
```

- The alphabet only allows uppercase letters and numbers, but it shouldnt be too difficult to modify it.
- Inside every room is a "portal" for every edge in the graph to the correct room.
- If you are in an "accepting state", the room will have green walls.
- If you are in a "dead state", there wont be any portal.

You take the correct portals for the string you want to test, and if you arrive to a green room, you could assert that the string is matched. If not, you know it wont.

{{< rawhtml html >}}
<video src="https://user-images.githubusercontent.com/814791/193956005-3a36f286-e5e2-4b22-a6cf-5c9d8807c12e.mp4" controls="controls" muted="muted" style="max-width:100%;max-height:640px;"></video>
{{< /rawhtml >}}

In this gameplay you could see that DOOOOM is accepted, but DOOOOMU is not.
