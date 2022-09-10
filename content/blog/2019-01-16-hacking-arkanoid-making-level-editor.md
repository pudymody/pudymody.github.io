---
title: "Hacking Arkanoid: Making a level editor."
date: 2019-01-16
toc: true
issueId: 29
---

# Intro
This post is going to be another i-write-as-i-make, so you are going to see all the thinking and progress as i do. The idea is the following, the other day playing some old PSX games, i was playing [Arkanoid 2000](https://en.wikipedia.org/wiki/Arkanoid_Returns) when i saw the level editor and i thought, *"wouldnt it be cool if we could take any image and made it a playable level?"*, so let put hands to work.

# Choosing the game
Reverse ingeneering a ps1 game seems a lot of work just for a fun project, lets review what other arkanoid games are available.

- Arkanoid (1986)
- Arkanoid: Revenge of Doh (1987)
- Arkanoid: Doh It Again (1997)
- Arkanoid Returns (1997)
- Arkanoid DS (2007)
- Arkanoid Live y Arkanoid Plus!
- Arkanoid vs Space Invaders (2015)

**Arkanoid: Doh It Again** being on SNES seems the perfect choice, as there are cool tools and forums around that console, and the complexity doesnt seem to high. And also, its just the previous released game to the one i was playing!.

# Tools
For the emulation im going to use [Snes9x](https://www.snes9x.com/) and for the hex manipulation [hexcmp](https://www.fairdell.com/hexcmp/) because they are the ones that google suggests. But after some uses, i was uncomfortable with hexcmp, so i decided to use [Frhed](https://frhed.sourceforge.net/en/).

# First attempt
As the emulator dont have a memory viewer to fiddle around, i decided to save the current state everytime i break a tile, and then try to diff them. This doesnt seem a good idea.

# Second attempt
My second thought was to search if there is already any hack of the game. To my surprise, there is [one](https://www.romhacking.net/hacks/2249/). It is distributed as a IPS file. A format that seems famous around rom hacking. As famous as it is, there are plenty of material explain how it works and how to apply them. This seems a good way to go. To my luck, placing the IPS file along with the rom with the same name, Snes9x will apply it. So i can say that we already have a nice tooling to play along.

# Understanding level format.
Searching on the internet, i found [this article](https://fileformats.archiveteam.org/wiki/IPS_(binary_patch_format)) which describes how the IPS format is stored. The next step would be to make some script to output the list of hunks in the patch. [Time for some coding.](https://github.com/pudymody/arkanoid-level-editor/blob/master/listHunks/index.js)

My hope was to find some payload which represents some kind of grid with the tiles. That wasnt the case. So, the next step was to investigate how many bricks are in the game, and think of other ways to store it.

# Another way
Looking at the first map, i tried to do it the hard way, i opened the rom, and started looking for the following: ```value1 00 00 00 00 00 00 00 00 value1 00 value2 00 value2``` because of the map format.

![First level of the game](/static/imgs/hacking-arkanoid-making-level-editor/firstLevel.png)

After hours of search and reading, i could find it in the following address **0x07000a**, after editing it to make sure it was, i found that this is indeed the first map. Next step, deciphering the brick format.

# Brick format
As every brick is made of a single byte, and a byte has only 256 different values, i will brute force my way.
After testing every value, we get the following chart, which could be defined as this:

1. The first three bits defines the color of the brick
2. The fourth defines if it has a powerup or not
3. Fifth and sixth defines if its a normal, silver or gold brick.

## Group 1
- 0001 0000 -> Silver
- 0001 0001 -> Orange
- 0001 0010 -> Cyan
- 0001 0011 -> Green
- 0001 0100 -> Red
- 0001 0101 -> Blue
- 0001 0110 -> Pink
- 0001 0111 -> Gold

## Group 2
- xxxx 0xxx -> Without power
- xxxx 1xxx -> With power

## Group 3
- 0010 xxxx -> Silver
- 0011 xxxx -> Unbreakable gold

## Group 4
- 0100 xxxx -> Broken
- 0101 xxxx -> Broken
- 0110 xxxx -> Silver
- 0111 xxxx -> Broken
- 1000 xxxx -> Broken
- 1001 xxxx -> Same as Group 1
- 1010 xxxx -> Same as Group 3
- 1011 xxxx -> Same as Group 3
- 1100 xxxx -> Broken
- 1101 xxxx -> Broken
- 1110 xxxx -> Same as Group 2
- 1111 xxxx -> Broken

# Making my first patch
Now that we have the level address, the brick format, and how to read a patch, its time we make our first patch. To do this, i made [another script](https://github.com/pudymody/arkanoid-level-editor/blob/master/makeHunks/index.js) which read a text file with 100 words, where each word represent a different kind of brick.

# Level editor
Now that we can make a patch, test it and its playable, its time we make a [level editor.](https://pudymody.github.io/arkanoid-level-editor/levelEditor/)

# Final thoughts
Although i couldnt make what this journey was about, an image-to-arkanoid script, because a grid of 10x10 seems small even for some pixel art, i could put my low level skills to practice. Show that is possible with Javascript to do some low level hacky things. Learn some things about the world of rom hacking for the snes. And have some fun.

For the future, the level editor could use a better UI/UX, find all the map addresses to make a full game, which i think are all one after the other, make the editor patch the rom instead of generating a IPS file.
