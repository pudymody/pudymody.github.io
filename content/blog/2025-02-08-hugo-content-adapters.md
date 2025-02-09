---
title: "Hugo content adapters"
date: 2025-02-08
issueId: 135
---

As [i said previously](/blog/2023-04-14-quiterss-to-freshrss/) i use [FreshRSS](https://www.freshrss.org/) to my feed reader needs. From time to time, i found some article that i like and share them with some excerpt into my [stream section](/stream), but there are others that i like and star but not share. I've been wanting to do something with them for a long time, and finally i found how.

In the past, i would have triggered some job to get all of them, put it in a json file, use [hugo data sources](https://gohugo.io/content-management/data-sources/) and make a commit which would retrigger a build. But they wouldnt appear as the same pages that i already have without doing some magic in between.

But something new caught my eyes, [Content adapters](https://gohugo.io/content-management/content-adapters/).

> A content adapter is a template that dynamically creates pages when building a site. For example, use a content adapter to create pages from a remote data source such as JSON, TOML, YAML, or XML.

It seems to be the perfect solution, you load data dynamically and they appear as normal pages within the content that you created. Some simple and silly coding in the freshrss side to expose the content as json format, some new hugo magic, some cronjobs to rebuild the site using [netlify build hooks](https://docs.netlify.com/configure-builds/build-hooks/) *(not before realizing that i almost lost my 2fa codes, to my luck backups exists. Friendly reminder to test that your backups can be restored)* and everything is rolling.

You can view the [commit](https://github.com/pudymody/pudymody.github.io/commit/37d4fee4349194e38c44a712b1614abbd3632884) to see how small and simple the change is. Its almost the same code as in the example. Thanks hugo for implementing this. Now i can postpone even more that [11ty](https://www.11ty.dev/) migration.

The only thing missing to make everything even smoother would be to automate the process of creating a github issue for comments. We will see.
