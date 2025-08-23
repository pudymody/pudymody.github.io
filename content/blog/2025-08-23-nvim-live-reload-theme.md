---
title: "Live reloading nvim theme"
date: 2025-08-23
issueId: 143
---

For my system i have a collection of scripts to toggle between themes similar to what [omarchy](https://github.com/basecamp/omarchy/issues/36) has become. With its new hype i decided to fix some of the things that didnt bothered me but wasnt great. One of them was nvim live reloading theme. Before whenever i changed themes, i had to restart nvim, but thats not the case anymore.

First of all a few things of how i have nvim setup. I have a `$NVIM_CONFIG/lua/theme.lua` file with the name of the colorscheme exported that i change with the script. For example `return "catppuccin-latte"`. Then in my `init.lua` file i have `vim.cmd.colorscheme(require("theme"))`.

The only thing missing was to retrigger that function whenever the file changed. To do this i decided to follow some common pattern that is listen to the `USR1` signal. Luckily the lua api makes this easy. Thanks to [fitrh on reddit](https://www.reddit.com/r/neovim/comments/1feskw8/comment/lmqx6rz/) for the signal hook code and to [Vivian De Smedt on stackexchange](https://vi.stackexchange.com/a/44081) on how to reload required modules.

```lua
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  group = vim.api.nvim_create_augroup("toggle_bg_on_SIGUSR1", {}),
  callback = function()
		package.loaded.theme = nil
		vim.cmd.colorscheme(require("theme"))
    vim.schedule(function()
      -- without this, nvim window need to be focused for the effect take into account
      vim.cmd("redraw!")
    end)
  end,
  nested = true, -- allow this autocmd to trigger `OptionSet background` event
})
```

Now its just a matter of running `kill -s SIGUSR1 $(pidof nvim)` whenever i change themes.
