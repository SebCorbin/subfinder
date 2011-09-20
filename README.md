SubFinder
=========

This PoC is currently under maintenance only, further development (including a complete OOP rewrite) will be done as soon as I have enough time.


Contributing
------------
If you want to contribute to this project, don't hesitate to file an issue in the issue queue, and/or make a patch. I will review it ASAP and commit it.


Download
--------
Binary version is available at http://subfinder.sebcorbin.fr

Usage
-----
This app provides a service (a contextual menu) on Mac, it helps you download automatically subtitles for your favorite shows.
For now, it uses data from addic7ed.com and betaseries.com to retrieve subtitles.


Troubleshooting
---------------
If the entry doesn't appear in the contextual menu in Finder, type this in a terminal:

	/System/Library/CoreServices/pbs -flush
