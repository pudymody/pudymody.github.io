---
title: Crossreferencing Firefox and QuiteRSS
date: 2022-05-14
issueId: 53
---

I like to get my news from [RSS](https://chriscoyier.net/2022/04/29/rss-3/) sources. I use [QuiteRSS](https://quiterss.org/) because i also like software thats local-first instead of cloud based. And my browser of choice is [Firefox](https://www.mozilla.org/en-US/firefox/new/). Both of them uses [Sqlite](https://sqlite.org/index.html) as their backend mechanism.

At the end of the week i like to have some kind of "things that i read and liked this week". To do this, i mark those items in QuiteRSS as *starred*. And then on monday mornings or sunday nights i run this script.

```sh
#!/usr/bin/env bash
myfile=$(mktemp --suffix ".html")
echo "<style>body{margin: 0;font-family: monospace;font-size: 16px;line-height: 1.6;}table{border-collapse:collapse}tr,td{border:1px solid #999}td{padding:0.25rem 0.5rem}tr:nth-child(2n){background:#f5f5f5}</style><table>" >> $myfile
sqlite3 ~/.local/share/QuiteRss/QuiteRss/feeds.db --readonly -html "SELECT feeds.text AS author, news.title, news.link_href FROM news LEFT JOIN feeds ON ( feeds.id = news.feedId ) WHERE news.starred = 1 AND strftime('%W', 'now', 'localtime', 'weekday 0', '-6 days') = strftime('%W', received, 'localtime', 'weekday 0', '-6 days') AND strftime('%Y', 'now', 'localtime', 'weekday 0', '-6 days') = strftime('%Y', received, 'localtime', 'weekday 0', '-6 days') ORDER BY received DESC" >> $myfile
echo "</table>" >> $myfile
xdg-open $myfile
```

It gets all the items that are starred and received in the last week and then makes an html file for me to review. This was working fine until last weeks, where the time between i received a news, and read it was starting to be more than a week.

Then it came to my mind, firefox also uses sqlite as its backend, can i make a database with both (firefox and quiterss) and query the time i last visit a starred page?. My first attempt was to export both databases and import them to a new one to prevent me from breaking them.

But then i discover that you can [attach databases](https://sqlite.org/lang_attach.html) as [read only](https://sqlite.org/c3ref/open.html#coreuriqueryparameters).

Now its only a matter of writing the right query.
```sh
sqlite3 <<EOF
.mode csv
.output feeds.csv
attach database "file:/home/pudymody/.local/share/QuiteRss/QuiteRss/feeds.db?mode=ro" as RSS;
attach database "file:/home/pudymody/.mozilla/firefox/o78vjzqw.default-release/places.sqlite?mode=ro" as FF;
SELECT
	FF.moz_places.title,
	FF.moz_places.url,
	strftime('%d/%m %H:%M', FF.moz_places.last_visit_date/1000000, "unixepoch", 'localtime') as visit_date
FROM FF.moz_historyvisits
LEFT JOIN FF.moz_places ON (FF.moz_places.id = FF.moz_historyvisits.place_id)
WHERE
	FF.moz_places.url IN (SELECT RSS.news.link_href FROM RSS.news WHERE RSS.news.starred = 1 ORDER BY RSS.news.received DESC)
	AND strftime('%s', FF.moz_places.last_visit_date/1000000, "unixepoch", 'localtime') >= strftime('%s', 'now', 'localtime', '-7 days')
GROUP BY FF.moz_historyvisits.place_id
ORDER BY FF.moz_places.last_visit_date DESC;
EOF
```

And with this i can have a list of things i've read and liked in the last 7 days, using the time i've read them, and not the time i received them.
