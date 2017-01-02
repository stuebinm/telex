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
using FeedParser;

/**
 * FeedList:
 * Displays the list of feeds saved in one FeedReader-backend.
 *
*/

class FeedList : Frame {

    FeedReader backend;
    
    ListBox layout;
    
    public FeedList (FeedReader backend) {
    
        this.backend = backend;

        this.layout = new ListBox ();
        this.layout.selected_rows_changed.connect (() => {this.selection_changed();});
        this.layout.set_hexpand (true);
        this.layout.set_vexpand (true);
        this.layout.selection_mode = SelectionMode.BROWSE;
        
        
        for (Gee.MapIterator<string, FeedChannel> iter = this.backend.channels.map_iterator(); iter.next(); iter.has_next()) {
            this.layout.add (new FeedListItem (iter.get_value ()));
        }
        
        this.add (this.layout);
        this.set_size_request (400,0);
    }
    
    
    public signal void selection_changed ();


}
