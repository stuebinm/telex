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

class FeedListItem : ListItem {

    public FeedChannel feed {public get; private set;}
    
    public FeedReader backend {public get; private set;}

    public FeedListItem (FeedReader backend, FeedChannel feed) {
        base (feed.title, feed.uri, feed.icon, "");
        
        this.feed = feed;
        this.backend = backend;
        
        this.add_button (_("reload"), "reload");
        this.add_button (_("remove"), "remove");
        
        this.button_pressed.connect ( (name) => {
            switch (name) {
                case "reload":
                    this.backend.reload_feed (feed);
                    break;
                case "remove":
                    this.backend.remove_feed (feed);
                    break;
            }
        });
    }



}
