---
title: Moving from sublime to atom
---

*This is my first post, so im all ears to suggestions.*

I have been using Sublime since i have memory, but i wanted to try Atom beacuse his community seems so promising and the best thing its open source. So here i will write a little roadmap of some steps i've made.

## Ui Theme
I've tried the default ones, but then i remembered a [tweet](https://twitter.com/addyosmani/status/527844932812152832) i read from **Addy Osmani** with a beautiful theme. So i installed it. [Seti UI](https://atom.io/themes/seti-ui)

## Color scheme
I couldnt get rid off my current color scheme from sublime, to my luck [Twilight](https://atom.io/themes/twilight) was available in the packages.

## Keymaps
What can a user do without his keymaps? I think nothing, so i change them to my needs
{% gist 3be761175b7bfc359dcb %}

## Packages
First i have to installed my always needed [Emmet](https://atom.io/packages/emmet), then another feature that sublime has as default, when you select a word, it highlits another ocurrences of the same world, in atom this is done by a plugin called [Highlight Selected](https://atom.io/packages/highlight-selected). Another nice feature from sublime its the possible to highlight the current indent block with another color, again this its done by a package (*thanks community for being so awesome*) [Indent Guide Improved](https://atom.io/packages/indent-guide-improved).

Then the always needed linter for when you are working long hours and forget semicolons everywhere. First you need the linter base for everyone. [Linter](https://atom.io/packages/linter).

And here the list of specific linters.

* [Linter CSSLint](https://atom.io/packages/linter-csslint)
* [Linter HTMLHint](https://atom.io/packages/linter-htmlhint)
* [Linter JSHint](https://atom.io/packages/linter-jshint)
* [Linter JSONLint](https://atom.io/packages/linter-jsonlint)
* [Linter SCSSLint](https://atom.io/packages/linter-scss-lint)

## Visual tweaks
Seti has a thing that bothers me a lot, the bottom panels has a border that is too gross, so i have to add this to my styles.less file. I've also added the colors for the *indent guide improved* package

{% gist f6db868052aedc74dfae %}
