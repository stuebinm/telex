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




/**
 * NewsListPlaceholder:
 * A placeholder widget for the #NewsList. Should either display a 'loading'-sign
 * (if there's something in the feed list) or else a 'add-feed'-Button (if there isn't).
 *
*/
class NewsListPlaceholder : Stack {

     // Widgets for the 'empty feed'-message
    Grid emptyList;
    Label emptyLabel;
    FeedAdder addButton;
    
     // Widgets for the 'loading feeds'-message
    Grid loadingList;
    Label loadingLabel;
    Spinner spinner;
    
    FeedReader backend;
    
    public NewsListPlaceholder (FeedReader backend) {
        this.backend = backend;
        
        /** ↓ 'empty-feed*-thingies go here ↓ */

        this.emptyList = new Grid ();
        
        this.emptyLabel = new Label (_("No Feeds in here just yet"));
        this.addButton = new FeedAdder ();
        this.addButton.label = _("Add some?");
        
        this.emptyList.set_orientation (Orientation.VERTICAL);
        this.emptyList.set_margin_top (40);
        this.emptyList.set_row_spacing (10);
        this.emptyList.set_halign (Align.CENTER);
        
        this.emptyList.add (emptyLabel);
        this.emptyList.add (addButton);
        
        
        
        /* ↓ 'loading-feeds'-stuff should be here ↓ */
        
        this.loadingList = new Grid ();
        
        this.loadingList.set_orientation (Orientation.VERTICAL);
        this.loadingList.set_margin_top (40);
        this.loadingList.set_row_spacing (10);
        this.loadingList.set_halign (Align.CENTER);
        
        this.loadingLabel = new Label (_("Reading newspapers …"));
        this.spinner = new Spinner ();
        this.spinner.start ();
        
        this.loadingList.add (this.loadingLabel);
        this.loadingList.add (this.spinner);
        
        
        /* ↓ general stuff goes down here ↓ */
        
        this.set_hexpand (true);
        this.set_vexpand (true);
        
        this.add (this.emptyList);
        this.add (this.loadingList);

        this.show_all (); // No idea why this is necessary, but it seems to be …
        
        this.set_display (this.backend.status != FeedReader.Status.LOADING);
        
        this.backend.status_changed.connect ( () => {
            this.set_display (this.backend.status != FeedReader.Status.LOADING);
        });
        
    }
    
    public void set_display (bool emptyList) {
        if (emptyList) {
            this.set_visible_child (this.emptyList);
        } else {
            this.set_visible_child (this.loadingList);
        }
    }

}
