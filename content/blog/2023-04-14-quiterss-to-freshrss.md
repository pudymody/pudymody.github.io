---
title: "QuiteRSS to FreshRSS"
date: 2023-04-14
issueId: 109 
---

This post is [too niche](https://rachsmith.com/learning-in-public-is-complicated/). The audience is probably only one person, and its the one writing it. But who knows, maybe its useful to you too, or you like reading the tales of some random dude on the internet. Boring ones, but who i am to judge?.

I have used [QuiteRSS](https://quiterss.org/) in the past to read my feeds. I like my software to have as less connection to the internet as possible, so a local-only feed reader was the right one. But i also like to read while waiting for the bus or conmuting to college. For this, i had a script that queried the sqlite database, made an html file, and uploaded it to a personal server. Too cumbersone to maintain.

So, i migrated to [FreshRSS](https://freshrss.org/). The problem was that i had too many unread articles yet, and some of those feeds doesnt provide the full list, only the last X ones. Both using sqlite as database, i could write some queries to migrate between both.

Now i could visit my private url and read from wherever i am. Have the read status of them synced. And one of the best things ever, is the [Reading Time extension](https://github.com/FreshRSS/Extensions/tree/master/xExtension-ReadingTime). If im waiting for the bus, i know i could start reading an article or not depending on the approximated time. A feed doesnt provide the full content on it? Never mind, it provides a way to [scrape the content from the webpage](https://freshrss.github.io/FreshRSS/en/users/04_Subscriptions.html).

I think i could allow some *cloudiness* given the benefits it provides. As long as its **on my own server** and i control it.

Stop talking and lets go to the tech details

First, we begin by opening the freshrss sqlite database. Its usually under the *data/users/username/db.sqlite*
```sh
sqlite3 db.sqlite 
```

Next, we need to attach the QuiteRSS database so we could work with both at the same time. Usually under *~/.local/share/QuiteRss/QuiteRss/feeds.db*
```sql
attach database "feeds.db?mode=ro" as RSS;
```

Now with everything in place, we only need to query the unread posts, format them with the freshrss columns, and insert them
```sql
insert into entry (id,guid,title,author,content,link,date,lastSeen,is_read,is_favorite,id_feed) 
select row_number() over (order by '') as id, news.guid, news.title, news.author_name as author, news.description as content, news.link_href as link, strftime("%s", news.published) as date, strftime("%s", news.received) as lastSeen, (news.read == 1) as is_read, (news.starred == 1) as is_favorite, f.id as id_feed from RSS.qr_news as news LEFT JOIN RSS.qr_feeds AS feeds ON (feeds.id = news.feedId) LEFT JOIN feed as f ON (f.url = feeds.xmlUrl) WHERE news.deleted = 0 and news.read = 0 and f.id not null;
```
