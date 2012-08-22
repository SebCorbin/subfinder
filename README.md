SubFinder
=========

This PoC is abandoned, feel free to submit pull requests though.
This app provides a service (a contextual menu) on Mac, it helps you download 
automatically subtitles for your favorite shows.
For now, it uses data from addic7ed.com and subscene.com to retrieve subtitles


Roadmap
---------
Services to be added as per the ServiceProtocol:
 * BetaSeries
 * OpenSubtitles
 
Don't hesitate to provide yours!


Contributing
------------
If you want to contribute to this project, don't hesitate to file an issue in 
the issue queue, and/or make a patch. I will review it ASAP and commit it.


Download
--------
Binary versions are compiled for Snow Leopard. Just drag and drop the app into 
you Applications directory.


Compilation
---------
Libxml2 (included in Mac OSX) and RegexKit 
(http://regexkit.sourceforge.net/#Downloads) frameworks are required


Troubleshooting
---------------
If the entry doesn't appear in the contextual menu in Finder, type this in a 
terminal:

	/System/Library/CoreServices/pbs -flush
