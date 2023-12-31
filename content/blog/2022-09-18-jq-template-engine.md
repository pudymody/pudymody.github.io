---
title: "jq as a template engine"
date: 2022-09-18
issueId: 92 
---

[jq](https://stedolan.github.io/jq/) is one of those softwares that i normally dont use, but im glad its there when i need it. Thats the reason why i can never remember its syntax. This post is that, a kind of cheatsheet or reference to myself for the tasks that i normally use it for.

## Extract a single property
If i want to extract a single property, in this case *name*, i only need to select it.
```sh
curl "https://jsonplaceholder.typicode.com/users/1" | jq '.name'
```

The **.** filter is the identity. Whether its the toplevel object, or an item of an iterator. Usually used to access the current item.

## Filtering data
I can also "pipe" some property to a function or filter. For example to convert to uppercase
```sh
curl "https://jsonplaceholder.typicode.com/users/1" | jq '.name | ascii_upcase'
```

It could also be used to create new json objects
```sh
curl "https://jsonplaceholder.typicode.com/users/1" | jq '. | {name:.name, id:.id}'
```

## Iterating data
If i want to apply a filter to every object in an array, i could use the *.property[]* iterator.

```sh
curl "https://jsonplaceholder.typicode.com/users" | jq '.[] | .username'
```

If i only need one property of the array, i could use a more compact syntax
```sh
curl "https://jsonplaceholder.typicode.com/users" | jq '.[].username'
```

If i want to collect everything in an array, i need to wrap all in *[]*
```sh
curl "https://jsonplaceholder.typicode.com/users" | jq '[.[] | .username]'
```

## String interpolation
If i need to interpolate some value to its string value, i could use the following syntaxis. **\\(.foo)**

```sh
curl "https://jsonplaceholder.typicode.com/users" | jq '.[] | "\(.username) its called \(.name)"'
```
**Its important to wrap the string in quotes ("). This is one of the main things i always forget**

## As a template example
With this, i could run the following command to get a list of users
```sh
curl "https://jsonplaceholder.typicode.com/users" | jq -r '.[] | "<li class=\"list-item\">\(.username) its called \(.name)</li>"'
```

**What the -r flag does is output the content as a raw string, instead of trying to parse everything as a json value**

---

*edit 2023/12/31*: Reading [Scraping Goodreads](https://remysharp.com/2023/11/21/scraping-goodreads) i found out about [jqterm: jq as a service](https://jqterm.com/)
