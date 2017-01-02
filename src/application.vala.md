/* Copyright 2017 Matthias Stübinger
*
* This file is part of the Telex feed-reader.
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*
*/

using Gtk;

MainContext FeedReaderMainLoop;


 // The feedreader app
class FeedreaderApp : Gtk.Application {

    public FeedreaderApp () {
        Object (application_id:  "de.tum.in.stuebinm.feedreader",
                flags: ApplicationFlags.FLAGS_NONE);
        
        
        SimpleAction quit = new SimpleAction ("quit", null);
        quit.activate.connect ( () => {
            this.quit ();
        });
        this.add_action (quit);
        
    }
    
    
    protected override void activate () {
        
        this.set_resource_base_path ("${PKGDATADIR}/gtk");
        
         // the main window
        FeedreaderWindow window = new FeedreaderWindow (this);
        this.add_window (window);

        stdout.printf ("help window: %d\n", (int) (window.get_help_overlay () == null));

         // display stuff
        window.show_all ();
        
    }
}

