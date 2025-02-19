---
title: "Which GO dependency is bumping the version?"
date: 2025-02-19
issueId: 136
---

Today i was reviewing a PR at work which updated various dependencies. One of them was bumping our go version from 1.20 to 1.23 and i couldnt review one by one as they were a lot.

Thanks to [reddit](https://www.reddit.com/r/golang/comments/1cdjyzk/why_is_go_mod_tidy_bumping_the_version_of_go/) i found this little snippet that allows to "pin" the go version.

```sh
go mod tidy -go=1.20
```

Now with the output, i can trace why this is needed

```sh
go: github.com/DataDog/go-libddwaf/v3@v3.5.3 requires go@1.23, but 1.20 is requested
```

```sh
go mod graph | rg "github.com/DataDog/go-libddwaf"
```

As you may guessed this is only for myself, thats why the title is what i was asking at the moment.
