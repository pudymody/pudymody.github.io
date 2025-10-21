---
title: "Firefox Zen"
date: 2025-03-15
issueId: 138
---

One of the things that i love about [Arc](https://arc.net/) and [zen browser](https://zen-browser.app/) is the almost clutter free experience they provide. Its almost a full view of the webpage without any kind of ui. Im also used to my firefox installation, i dont want to tinker with other browsers.

Thanks to the [new released vertical tabs](https://connect.mozilla.org/t5/discussions/sidebar-and-vertical-tabs-launch-in-release-136/m-p/896529), some useful extensions like [Userchrome Toggle Extended](https://addons.mozilla.org/en-US/firefox/addon/userchrome-toggle-extended/) and some css wizardy, i can have a similar experience. I have binded `ctrl+shift+L` to toggle the styles because its similar to `ctrl+L` that will put my cursor in the urlbar.

Want to go back or forwards? You have the buttons in the context menu, or you can hit `alt+scroll wheel`. For this i needed to set in `about:config` the value `mousewheel.with_alt.delta_multiplier_y` to `-100` because i wanted them the other way.

Want to refresh? Context menu or classic F5.

And while writing this, i found out that in the context menu there is also the bookmark button. Amazing.

If i want an experience without any kind of UI, i can press `ctrl+shift+L`, toggle the sidebar from the button, and press it again to hide everything else.

```css
:root[titlepreface*="᠎show-ui"]{
	#navigator-toolbox {
		border: none !important;
	}

	#TabsToolbar, #PersonalToolbar {
		display: none;
	}

	#nav-bar {
		height: 0 !important;
		min-height: 0 !important;
		max-height: 0;
		border: none !important;
	}

	#urlbar-container {
		top: 5vh;
		position: fixed;
		left: 0;
		right: 0;
		width: 80% !important;
		margin: 0 auto !important;
	}

	#urlbar {
		opacity: 0;
		pointer-events: none;

		&::before {
			content: "";
			position: fixed;
			top: 0;
			left: 0;
			right: 0;
			bottom: 0;
			background: rgba(28, 27, 34, 0.45);
			display: none;
		}
	}

	#urlbar:focus-within {
		opacity: 1;
		pointer-events: all;

		&::before {
			display: block;
		}
	}
}

.titlebar-spacer[type="pre-tabs"], .titlebar-spacer[type="post-tabs"], #vertical-spacer {
	display: none;
}
```

![firefox in normal state](/static/imgs/firefox-zen/normal.jpg)
![firefox with focus on the urlbar](/static/imgs/firefox-zen/focus.jpg)

# Update 2025-10-21
I made more changes, so here they are for posterity:

```css
:root[titlepreface*="!"]{
	#browser {
		--sidebar-launcher-collapsed-width: 10px !important;
	}
	&[sidebar-expand-on-hover] #sidebar-main {
		width: var(--sidebar-launcher-collapsed-width);
	}
	#navigator-toolbox {
		border: none !important;
	}

	#TabsToolbar, #PersonalToolbar {
		display: none;
	}

	#nav-bar {
		height: 0 !important;
		min-height: 0 !important;
		max-height: 0;
		border: none !important;
	}

	#urlbar-container {
		top: 5vh;
		position: fixed;
		left: 0;
		right: 0;
		width: 80% !important;
		margin: 0 auto !important;
	}

	#urlbar {
		opacity: 0;
		pointer-events: none;

		&::before {
			content: "";
			position: fixed;
			top: 0;
			left: 0;
			right: 0;
			bottom: 0;
			background: rgba(28, 27, 34, 0.45);
			display: none;
		}
	}

	#urlbar:focus-within {
		opacity: 1;
		pointer-events: all;

		&::before {
			display: block;
		}
	}

	tab[discarded], tab[pending=true]{
		opacity: 0.35;
	}
}

.titlebar-spacer[type="pre-tabs"], .titlebar-spacer[type="post-tabs"], #vertical-spacer {
	display: none;
}
```

And to have better smooth scrolling take from [Betterfox](https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js):

```js
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.currentVelocityWeighting", "1");
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2");
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("general.smoothScroll.stopDecelerationWeighting", "1");
```
