# telex
A Gtk+3.0 feed-reader

For now, it only supports Atom-1.0 (and might crash if it's not valid, too).

Mostly, I wrote it because there doesn't seem to be a feedreader using Gtk+3 around that's *not* insisting on using feedly or similar stuff, which I don't really like.

It's a bit basic for now, 'cause there's not really a usefull library for feedreading around, either (libgrss seems sort-of unfinished or unmaintained, and it's got functions with names like *quick_and_dirty_parse()*, which isn't all that encouraging), so I'm just writing my own.

## Installing and Hacking:

### Dependencies

Should run fine on any linux distro. Dependencies (as cmake'll tell you):

>gtk+-3.0

>gee-0.8 

>libxml-2.0 

>webkit2gtk-4.0

>libsoup-2.4

Also dependencies, as cmake won't tell you:

> glib-compile-schemas

> glib-compile-resources

Though they should be included in every gtk-dev package around.

Don't ask me about Windows, OS X or any such things, I've got no idea of them. Although it would be nice if, should you, for some reason, be compelled to try and compile them there and it works, you'd tell me.

### Installing

> $ git clone https://github.com/stuebinm/telex

> $ mkdir telex-build

> $ cd telex-build

> $ cmake ../telex

> $ make install

(might need to use sudo with that last one)

If you've changed the default install path, please be aware that it should be
in the *$XDG_DATA_DIRS* variable, or else the gsettings scheme  won't be found.

Also note that the *make install* is necessary; otherwise, gtk will crash because of 
a missing gsettings scheme.

If that's inconvinient for you, you can of course compile and install that
manually, as well:

> $ cp gsettings/feedreader.gschema.xml $SOME_INSTALL_PATH/glib-2.0/schemes/

> $ glib-compile-schemas $SOME_INSTALL_PATH/glib-2.0/schemes

(again, *$SOME_INSTALL_PATH* should be in *$XDG_DATA_DIRS*)
