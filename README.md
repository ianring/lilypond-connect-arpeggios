# lilypond-connect-arpeggios

A magic lilypond function that connects arpeggio lines across staves! 

Based on a snippet by Mark Polesky taken from: 
http://lilypond.1069038.n5.nabble.com/cross-staff-versions-of-arpeggioArrowUp-etc-td119964.html#none

# Usage

When you want arpeggios to connect across staves, do this:
```
\connectArpeggiosOn
```
Then when you want them to be separated, do this:
```
\connectArpeggiosOff
```

I suggest you make a Plugins folder, and put the connect-arpeggios.ly file in it. Then you can include it, like:
```
\include "Plugins/connect-arpeggios.ly"
```

## As a submodule
If you keep your lilypond projects in a git repository (a great idea, btw), then there's 
an even better way. Create that Plugins folder, then navigate to it and execute this command:
```
git submodule add https://github.com/ianring/lilypond-connect-arpeggios connect-arpeggios
```
That will create a "connect-arpeggios" folder with this project in it, with the plugin that you can include:
```
\include "Plugins/connect-arpeggios/connect-arpeggios.ly"
```
Then when there are updates to this project, you can get them with the command ```git submodule update --recursive --remote```. Seek out some of the excellent tutorials for using submodules effectively.


