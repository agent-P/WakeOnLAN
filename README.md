WakeOnLAN
=========

![wol screenshot](https://github.com/agent-P/WakeOnLAN/raw/master/docs/wol-main-display.png)

Mac OS X utility application to find hosts on a LAN based on their advertised services, display their awake status, and send a "magic packet" to wake up specific hosts configured for wake on LAN.

License
-------

WakeOnLAN is distributed under the terms of the [GPLv2](http://www.gnu.org/licenses/gpl-2.0.html).<br/>
The text of the license is included in the file LICENSE in the root of the project.


Getting help
------------

The code has verbose javadoc style comments. They have been designed to create formal documentation when processed by [Doxygen](http://www.stack.nl/~dimitri/doxygen/index.html).

Building WakeOnLAN
------------------
[Xcode](https://developer.apple.com/xcode/) is recommended for development as the project settings are preconfigured for Mac OS X 10.7.x (Lion).

1. Note this project has a dependency on [wol\_lib](https://github.com/agent-P/wol_lib). The current project settings require library file "libwol_lib.a" to be in the project root for the build to complete successfully.
2. Clone this repository to a Mac running OS X 10.7.x or later.<br/>
3. Open the provided Xcode project with Xcode 4.5.2 or later. Double-click on the provided project.<br/>
4. Build the project.
5. To start the application, select run from within Xcode, or double-click on the .app file produced by the build.


Operation
---------

1. Double-click the application icon to start the application. The main display will open, and show your saved hosts. It will be empty the first time it is used and until one or more hosts are saved. Hosts can be added to the list manually using the "+" button on the lower middle of the display. The "-" button will remove the selected host from the saved list. Details of the selected host will appear in the right-hand panel of the main display. The owner list can be accessed and edited from the host detail panel.
2. To browse for hosts on the LAN, select the "Browser" button on the lower left of the display. This will bring up the "Service Browser" window. The "Service Hosts" list in the window will be initially empty. The LAN is scanned for a selected Bonjour service. Select the service type you wish to scan for from the drop-down selector located on the lower middle of the "Service Browser" window. This list is populated with all the Bonjour services advertising on the LAN. Once a service is selected, press the "Scan for Services" button immediately to the left of the service drop-down selector. The "Service Hosts" list will be populated with all of the hosts on the LAN providing the selected service.
3. To select a host for the saved list, select a host entry on the "Service Hosts" list, and press the "Save Selected" button on the lower right of the "Service Browser" window. This will add an entry to the saved list on the main display. The "Service Browser" window will not automatically close. So, you may select more than one host for your saved list. Close the "Service Browser" window using its red window close button on the window's upper left.
4. To wake a host from your saved list, select its entry on the host list of the main display, and press the "Wake" button on the host details panel of the main display. Note that the host you are trying to wake must be on the LAN, and it must be configured to wake on LAN from "magic packets".