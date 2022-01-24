---
title: Get youtube playlist length
date: 2022-01-20
issueId: 43
---

Sometimes i need to know how long a youtube playlist is. To do this i always end in some random website that will calculate it for me. Yesterday i decided to make a little bookmarklet to have this info without navigating away. As always, this could fail in the future, but for now it works. Another drawback it has is that you need to scroll to the bottom of the page to load all the videos.

You can always execute this snippet in the console devtools.
```js
(function(window,document){
	function fmt(s){
		const dateObj = new Date(s * 1000);
		const hours = dateObj.getUTCHours();
		const minutes = dateObj.getUTCMinutes();
		const seconds = dateObj.getSeconds();
		return `${hours} hrs ${minutes} min ${seconds} sec`
	}

	const total = [...document.querySelector("ytd-playlist-video-list-renderer")?.querySelectorAll("ytd-playlist-video-renderer")]
		.map( i => i.querySelector("#text") )
		.map( t => t.textContent.trim().split(":")
			.map( e => parseInt(e,10) )
			.reverse()
			.map( (n,i) => n*Math.pow(60,i) )
			.reduce( (prev,curr) => prev + curr, 0)
		)
		.reduce( (prev,curr) => prev + curr, 0);

	alert(fmt(total));
})(window,document);
```

Another option is to add this {{< rawhtml >}}<a href="javascript:(function()%7B(function(window%2Cdocument)%7Bfunction%20fmt(s)%7Bconst%20dateObj%20%3D%20new%20Date(s%20*%201000)%3Bconst%20hours%20%3D%20dateObj.getUTCHours()%3Bconst%20minutes%20%3D%20dateObj.getUTCMinutes()%3Bconst%20seconds%20%3D%20dateObj.getSeconds()%3Breturn%20%60%24%7Bhours%7D%20hrs%20%24%7Bminutes%7D%20min%20%24%7Bseconds%7D%20sec%60%7D%20const%20total%20%3D%20%5B...document.querySelector(%22ytd-playlist-video-list-renderer%22)%3F.querySelectorAll(%22ytd-playlist-video-renderer%22)%5D.map(%20i%20%3D%3E%20i.querySelector(%22%23text%22)%20).map(%20t%20%3D%3E%20t.textContent.trim().split(%22%3A%22).map(%20e%20%3D%3E%20parseInt(e%2C10)%20).reverse().map(%20(n%2Ci)%20%3D%3E%20n*Math.pow(60%2Ci)%20).reduce(%20(prev%2Ccurr)%20%3D%3E%20prev%20%2B%20curr%2C%200)%20).reduce(%20(prev%2Ccurr)%20%3D%3E%20prev%20%2B%20curr%2C%200)%3B%20alert(fmt(total))%3B%7D)(window%2Cdocument)%7D)()">YTPlaylistLength</a>{{< /rawhtml >}} bookmarklet to your bookmarks and just click it.
