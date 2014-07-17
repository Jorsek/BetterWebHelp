BetterWebHelp
=============

_Finally, Better Web Help for the DITA OT_

---

Built as a plugin for the DITA Open Toolkit, Better Web Help (BWH) is a frameless adaptation of the XHMTL output. It is designed to be very customizable and easy to adapt.

 - [Documentation](https://github.com/Jorsek/BetterWebHelp#documentation)
 - [Sample Output](https://github.com/Jorsek/BetterWebHelp#sample-output)
 - [Styling](https://github.com/Jorsek/BetterWebHelp#styling)
 - [Sponsor](https://github.com/Jorsek/BetterWebHelp#sponsor)

##Documentation
Within the Documentation/ folder, there are files that describe how to install the plugin into your Local DITA-OT build in addition to how to install it into an instance of easyDITA.

##Sample Output
To load the sample output (/bwh) follow the instructions to get a localhost server running on your machine (/Documentation/Installation/Installing_BWH.pdf). Then copy /bwh into your /Library/WebServer/Documents/ folder.

Navigate to http://localhost/bwh/ to see the site.

##Styling
Note that the styling for BWH was written in [LESS for CSS](http://lesscss.org/) however the .less files are not copied to the output folder since they are compiled to CSS before building with the DITA OT. If you wish to alter these files, they are located in /com.jorsek.bwh/resource/scripts/ and you can use [Crunch](http://crunchapp.net/) to edit and compile into your output directory (or whichever LESS editor/compiler you prefer).

##Sponsor
This project is sponsored by [Jorsek LLC, makers of easyDITA software](http://www.easydita.com).

---