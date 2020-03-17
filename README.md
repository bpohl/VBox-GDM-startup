# GDM VirtualBox Startup

**Start a [VirtualBox](http://www.virtualbox.org/) VM as the user login session**

Normally, the Display Manager (DM), of which [GDM](http://wiki.gnome.org/Projects/GDM) is one, will show a welcome screen after boot up which allows the user to log in.  The DM then starts the users GUI session, usually a selected Linux desktop environment.  However, given the right startup files, the DM can start any GUI executable, which for our purposes is a virtual machine using [Oracle VirtualBox](http://www.virtualbox.org/).

Once installed there will be new selections in the sessions menu that each user can set on the welcome screen.  In addition to the VM(s) to start there is also a 'VirtualBox' selection that starts the VirtualBox configuration GUI from which the VM(s) can be configured and launched.

[GDM](http://wiki.gnome.org/Projects/GDM) can also be set to skip the welcome screen and log in automatically as the VM user.  The installer can be told to set that up when it is run.

This package was developed and tested on [Ubuntu 19.10](http://releases.ubuntu.com/19.10/).  There's no magic in it so it should work on most distros whose DM uses `.desktop` files to define sessions.  Your mileage may vary.  Let me know.

## Configuration

This repository contains two examples.

* The first is what will start a VM named **Virtual Machine**.

  [GDM](http://wiki.gnome.org/Projects/GDM) uses a rough version of the `.desktop` format files to define what kind of session to start when the user logs in.  Typically there is one made for each type of desktop and can be selected from a menu when logging in.
  
  Edit `Virtual Machine.desktop` to change the `Name=` to what should be listed in the session menu and make `Comment=`   The `Exec=` attribute refers to the scrip, `Virtual-Machine.Exec`, on the user's home which starts the VM followed by the name of the VM as [VirtualBox](http://www.virtualbox.org/) knows it.  **Do not put the name in quotes** even if it has spaces.  (See notes on [Known Bugs](#Known Bugs) below.)

  <pre>
  [Desktop Entry]
  ....
  Name=<i><b>Virtual Machine</b></i>
  Comment=Starts the VirtualBox machine named <i><b>Virtual Machine</b></i>
  Exec=./Virtual-Machine.Exec <i><b>Virtual Machine</b></i>
  </pre>

  If there will be more than one VM set up, make a copy of `VirtualBox.desktop` to any name but keeping the `.desktop` extension.  The installer will use anything with `.desktop`.  In fact, `VirtualBox.desktop` can be renamed to something more descriptive of the VM.

* The other example is named `VirtualBox.desktop` and you may want to install as-is.  It adds to the session menu a startup of the [VirtualBox](http://www.virtualbox.org/) GUI.  It is handy to have if you need to tweak the VM.  It does not need a `.Exec` to go with it.

## Installation

The `Install.sh` script will place all the files in the system directories and in the user specified as the VM executor.  Optionally the installer will set the user to login automatically thus skipping the Display Manager login screen. 

For example, if the name of the user that the VM should run as is `vmuser` execute the script like this:

    $ ./Install.sh vmuser

If you wish to have that user logged in automatically and go straight to the VM, add the command `auto` like this:

    $ ./Install.sh vmuser auto

The script checks to see if an auto login is already set up and if so it won't change the configuration but will print some instructions on how to do it manually.

### What's put where?

* Any file with a `.desktop` extension goes in `/usr/share/xsessions`.

* Any file with a `.Exec` extension goes in the executing user's home directory.

* If the user is set to auto login then changes are made to `/etc/gdm3/custom.conf`.

## <a id="Known Bugs"></a>Known Bugs

* Even though [GDM3](http://wiki.gnome.org/Projects/GDM) uses `.desktop` files it doesn't implement it well.  That includes the rules in the spec about quoting of values.  This left no viable way to put the name of a VM as the parameter to `Exec=` if it had a space in it.  Since VM names allow spaces that is a problem.  Until it is fixed by [GDM3](http://wiki.gnome.org/Projects/GDM) the script `Virtual-Machine.Exec` will accept every parameter on its command line and concatenate them together with a space, with the result used as the VM name.

  This works unless there are two consecutive spaces in the name (though not likely, still legal).  To get around that, `Virtual-Machine.Exec` can be edited and the VM name put as the default the environment variable `$VM`.
  
## Version

<!-- $Id$ -->

$Revision$<br>$Tags$

## Copyright

&copy; 2020 Bion Pohl/Omega Pudding Software Some Rights Reserved

$Author$<br>$Email$
