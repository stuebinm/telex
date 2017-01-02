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

class MainWindowHeader : Paned {

    private HeaderBar left;
    private HeaderBar right;

    NewsList newslist;
    FeedReader backend;

    Button reload_feed_button;
    FeedAdder add_feed_button;
    NewsListMenu newslistmenu;
   
    public string title {
        set {
            this.right.title = value;
        } 
        get {
            return this.right.title;
        }
    }

    public MainWindowHeader (NewsList newslist, FeedReader backend, AccelGroup accels) {
        this.newslist = newslist;
        this.backend = backend;
        
        this.orientation = Orientation.HORIZONTAL;
    
    
        this.right = new HeaderBar ();
        this.right.show_close_button = true;
    
        this.left = new HeaderBar ();
        
        this.pack1 (this.left, true, false);
        this.pack2 (this.right, true, false);
    
        
        this.reload_feed_button = new Button.with_label (_("Reload"));
        this.reload_feed_button.action_name = "win.reload-all";
        this.left.pack_start (this.reload_feed_button);
        
        this.newslistmenu = new NewsListMenu (this.newslist, this.backend);
        this.left.custom_title = this.newslistmenu;
        
        this.add_feed_button = new FeedAdder ();
        this.left.pack_end (this.add_feed_button);
        
        this.add_feed_button.add_accelerator ("activate", accels, Gdk.Key.N, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);
        this.add_feed_button.add_accelerator ("activate", accels, Gdk.Key.A, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);
    
        this.reload_feed_button.add_accelerator ("activate", accels, Gdk.Key.R, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);
    
        this.newslistmenu.add_accelerator ("activate", accels, Gdk.Key.M, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);
        
    }
    
    public void show_add_menu () {
        this.add_feed_button.activate ();
    }

}
