# FlowchartBuilder

IDE for drawing and running Flowcharts with statements written in Pascal-like mini-language.

It was my school project in 2002—2004. Archived here for the sake of nostalgia. Don't mind the code quality :)


## Building

Back in 2004 the code was built on Windows NT4/XP with Delphi 3 or Delphi 5.

Now in 2017 Lazarus almost builds it, except the absent `TMetaFile` and that MDI
is broken in Lazarus. But FlowchartBuilder actually doesn't fully use MDI (there is
exactly one `TChildForm` instance), so probably it can be refactored using something
like `TFrame`.
