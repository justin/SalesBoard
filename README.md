# SalesBoard

SalesBoard is a script that will generate a sales graph using the [AppFigures API][af] for display in Panic's new app [Status Board][sb].

SalesBoard uses your AppFigures credentials to ping their API and generate a JSON file that you can then load into SalesBoard. 

![SalesBoard](https://github.com/justin/SalesBoard/raw/master/salesboard.jpg "SalesBoard")

### Installation

0. Open Terminal and install the required gems  `gem install httparty json_pure terminal-notifier`  
1. Copy this `SalesBoard` folder somewhere.  
1. Get yourself an AppFigure API key and note down the Client Key.
2. Open `salesboard.rb` and adjust the values inside the configuration block to match you're respective install.  
3. Open `salesboard.sh` and update its path to the `salesboard.rb` script to match where you've installed it  
4. Open `com.secondgear.salesboard.plist` and update its `ProgramArguments` value to match where you are storing the salesboard.sh file you just updated in step 3.
5. Copy com.secondgear.salesboard.plist to `~/Library/LaunchAgents` 
6. Open Termimal and run `launchctl load ~/Library/LaunchAgents/com.secondgear.salesboard.plist`. This should generate the first version of your json file.
7. Go to Dropbox and get a shareable link for the JSON file that is output and add it to Status Board on your iPad.
8. Get rich or die tryin'.

### Known Issues
Personally? Too many to list.

In StatusBoard? Not that I know of. I built it for Second Gear's stuff. Hopefully you'll find it useful too until AppFigures comes out with their own support.
### To Do
Add code block to grab all product IDs automatically and process  
### Donations

If you find this script useful, I'd love if you could show your support by purchasing one of my products. Both are just $5.

* [Committed for OS X][c] - Get notified on your Mac whenever someone pushes code to a GitHub repository you care about.
* [Elements for iOS][e] - One of those Dropbox and Markdown text editors.

### Support

Run into an issue? Throw an issue up on GitHub. Better yet, throw up a pull request with a fix.

Wanna say hi? I'm on Twitter at [@justin][tw]

[af]: http://www.appfigures.com/
[sb]: http://panic.com/statusboard
[c]: http://bit.ly/committed10
[e]: http://bit.ly/elements20
[tw]: http://twitter.com/justin

Changelog:
2014-03-06: Amended script to support AppFigures API v2 [\[Dom Barnes\]](http://github.com/dombarnes)