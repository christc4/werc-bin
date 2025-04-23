# werc-bin

## md2html-minified.awk

<sub>markdown handler</sub>

## About

This is a much more stripped down version of the famous 'md2html.awk' by Jesus Galan (yiyus), 2009.

## Rationale

Unless you are caching the `.html` generated, `awk` is already a sub-optimal choice to use for a `md2html` converter when there exist tools like [SMU](https://karlb.github.io/smu/), written in C.

I don't know C and I was already learning `awk`.

Less logic, fewer system calls, fewer CPU cycles.

## ~~Features~~ *lack thereof*

- No character escaping  
  - Manually insert HTML entities  
- ATX headers only
- Minified output

## Some differences

There are many differences, but this is a small example.

This was responsible for converting `#` to its appropriate `<h1>` tag:

```awk
/^#+/ && (!newli || par=="p" || /^##/)
{ for(n = 0; n < 6 && sub(/^# */, ""); n++)
 sub(/#$/, ""); par = "h" n; }
```

Less logic is needed for this:

```awk
/^# / { par = "h1"; sub(/^# +/, ""); }
(/^## /) { par = "h2"; sub(/^## +/, ""); }
(/^### /) { par = "h3"; sub(/^### +/, ""); }
```

## Bugs

`%` has to be escaped via `%%`
