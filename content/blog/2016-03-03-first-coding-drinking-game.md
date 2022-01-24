---
title: The first drinking coding game in JS
date: 2016-03-03
issueId: 25
---

Its been a long time since i write my last post, so here we are.

Currently im on my holidays and i want to play some drinking games, but i couldnt find anyone who mix the fun of resolving some js problems while you drink. I only found one similar which is called [Crash and compile](http://crashandcompile.com) but it has to be played manually. So i thought, "why dont i build one who makes everything easier?"

**WARNING:** This is going to be a *i-write-as-i-code* post, so dont read it as a tutorial, read it as a chronicle of the developing process of this app.

## When to drink
If you're here, it means you want to read this article, or know a little about this app, so first we need to set our rules.

* If your code gives an error, you drink
* If your code dont give any error, but dont produce the correct expected value, you drink

## Structure
To play the game, we need to define two kind of apps. The client, which will be running the participants, and the server, which will be running in a common screen to view the status of the players.

### Client
It's going to be a CLI app which will take by parameters, the file where the code is being writen, and a token to identify the user. It has to do the following tasks:

* Check that the given file exists
* Make a connection to the server with the given token
* Whenever the file changes, post it to the server
* Listen for server events such as *DRINK!*

### Server
The server is also going to be a CLI app which will expose a WebSocket to handle everything in realtime. It has to do the following tasks:

* Create tokens for users who wants to participate
* Whenever a new code is submitted, lint it and test it and answer with the correct values *win*, * drink*.

## Writing
We are going to start writing the client app. First, we need to check that the given file exists, but we are going to do that lately when we watch for file changes, and that we are given a valid token. They are two simple arguments, we are not going to use any module to parse them.

To watch for file changes, i used the *unstable* api of the fs core module, but in windows it fires two times, and we dont want our participants to drink when they dont. So i searched for which module uses gulp, and we are going to use **chokidar**

```sh
npm install chokidar --save
```
So we add our check that the file exists, and if it does, start watching for change events.

Nice, now whenever the file changes, we get an event which we are listening for, so we now need to read its content and send it to the server. As we currently dont have any server, we are going to write it.
First we are going to write the logic to the websocket interface which will get the contents of the files, lint it, and check the output value.

For the socket interface im going to use the **ws** module

```sh
npm install --save ws
```
We create our websocket server. Now, we need our client to connect to this server, and at this point i think that it would be nice if anyone who wants to use this app could give the server ip by argument, so im going to modify our client connection to handle that, connect to the sv and send the data.

Now we get our data, we need to lint it to check for errors, for this task im going to use **eslint**
```sh
npm install eslint --save
```

I forgot to write some kind of handlers for sockets actions, so im going to use the following format: an js object with the key *action* which is the function to call, and a key *data* which is an array of arguments for the function.

Now with the handler for actions, we need to lint the submitted content. We need to check the linter result, and trigger a drink action for the current user if we have any error and show everything in console.

At this point i found out that, we dont need to create a token for every user, just pass the username and make a dictionary with the usernames and total drinks.

We have almost everything, a server which expose a websocket connection, parses the content for errors, a client who takes a file, username and ip and connects, we only need to check if the given file produces the expected result.

To execute the code given, im going to use the **Virtual machine** core module, because it also allows me to pass some global context for the problem. And im also going to create a function which will check and return if the code gets the expected value, which gets the context values as argument. To clone the initial context im going to use *JSON.parse(JSON.stringify());* beacuse i dont want to write a function or use a library JUST to clone an object.

## Extra when to drink
Another **rule** that i think know is, if you get the incorrect expected result, you have to drink.

## Source code
You can view and download the source code in my [repo](https://github.com/pudymody/code-and-drink) so you can also play with your friends.
