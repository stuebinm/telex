# telex
A Gtk+3.0 feed-reader

For now, it only supports Atom-1.0 (and might crash if it's not valid, too)

For hacking, just do this:

> $ git clone https://github.com/stuebinm/telex

> $ mkdir telex-build

> $ cd telex-build

> $ cmake ../telex

> $ make install

(might need to use sudo with that last one)

This should give you a complete installed version of this program.
Note that the *make install* is necessary; otherwise, gtk will crash because of 
a missing gsettings scheme.

If that's inconvinient, you can of course compile and install that
manually, as well:

> $ cp gsettings/feedreader.gschema.xml $SOME_INSTALL_PATH/glib-2.0/schemes/

> $ glib-compile schemes $SOME_INSTALL_PATH/glib-2.0/schemes

Note that *$SOME_INSTALL_PATH* has to be in the *$XDG_DATA_DIRS* variable, or else gtk won't find it.

