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
 * SettingsDialog:
 * Provides a window with a settings menu in it (for feed selection, deletion and other stuff …)
 *
*/
class SettingsDialog : Window {

    FeedReader backend;

    HeaderBar header;
    
    Notebook tabs;
    
    Grid feeds_layout;
    FeedList feedlist;
    
    Grid reload_layout;
    Label reload_time;

    public SettingsDialog (FeedreaderWindow parent, FeedReader backend) {
        
        this.backend = backend;
        
        this.set_transient_for (parent);
        this.modal = true;
        
        
        
        /* * * * * ↓ Widgets go here ↓ * * * * */
        
        this.header = new HeaderBar ();
        this.header.title = _("Settings");
        this.header.show_close_button = true;
        this.set_titlebar(this.header);
        
        
        
        this.tabs = new Notebook ();
        
        
        ScrolledWindow scroller = new ScrolledWindow (null, null);
        scroller.hscrollbar_policy = PolicyType.NEVER;
        scroller.vscrollbar_policy = PolicyType.AUTOMATIC;
        
        this.feeds_layout = new Grid ();
        this.feeds_layout.orientation = Orientation.VERTICAL;
        
        this.feedlist = new FeedList (this.backend);
        this.feedlist.margin = 30;
        this.feeds_layout.add (this.feedlist);
        
        Label title1 = new Label (_("Feeds"));
        scroller.add (this.feeds_layout);
        this.tabs.append_page (scroller, title1);
        
        
        
        this.reload_layout = new Grid ();
        this.reload_layout.orientation = Orientation.VERTICAL;
        this.reload_layout.margin = 30;
        
        this.reload_time = new Label (null);
        this.reload_time.set_justify (Justification.CENTER);
        this.hexpand = true;
        this.reload_time.set_markup ("<big><big><big><big><big><big><b>10</b></big></big></big></big></big></big>");
        this.reload_layout.add (this.reload_time);
        
        Label title2 = new Label (_("Reloading"));
        
        this.tabs.append_page (this.reload_layout, title2);
        
        
        this.add (this.tabs);
        this.set_size_request (0,300);
        
        this.backend.counted.connect (this.update_countdown);
    }
    
    private void update_countdown () {
        this.reload_time.set_markup (_("<big><big><big><big><big><big><b>%d</b></big></big></big></big></big></big> seconds till reload").printf (backend.get_countdown ()));
    }

}




