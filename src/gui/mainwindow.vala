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
  * TelexWindow:
  * the actual application window (duh)
 */
class TelexWindow : ApplicationWindow {

    MainWindowHeader header; // headerbar

    Paned layout; // main layout
    Paned headerLayout; // the header's main layout
    NewsList newslist; // sidepanel displaying feeds
    EntryDisplay display; // main viewport
    NewsListMenu newsListMenu;
    
    FeedReader backend;
    
    AccelGroup keyboard;
    
    public TelexWindow(Gtk.Application app){
        Object (application: app); // Can't use base() here, Gtk doesn't support it (for whatever reason)
        
        this.add_actions ();
        
        this.backend = new FeedReader ();
        
        this.set_size_request (1000,600);
        
        this.keyboard = new AccelGroup ();
        this.add_accel_group (this.keyboard);
        

        /* * * * * * * * *  ↓ Widgets go here ↓ * * * * * * * * */

         // Main layout
        this.layout = new Paned (Orientation.HORIZONTAL);
        

         // Sidepanel with list of news. Every time its selections changes, update the viewport.
        this.newslist = new NewsList (this.backend);
        this.newslist.selection_changed.connect (this.update_entry);
        
         // the main view panel, displaying one newsentry at a time
        this.display = new EntryDisplay ();
        
         // the header
        this.header = new MainWindowHeader (this.newslist, this.backend, this.keyboard);
        this.layout.bind_property ("position", this.header, "position", BindingFlags.BIDIRECTIONAL);
        this.newslist.selection_changed.connect ( () => {
            this.header.title = this.newslist.get_selected().data.title;
        });
        this.set_titlebar (this.header);
        
         // stuff things into the layout
        this.layout.pack1 (this.newslist, true, false);
        this.layout.pack2 (this.display, true, false);
        this.layout.set_position (350); // set a comfortable default position for the handler
        
         // stuff things into the window
        this.add (layout);
        
    }
    
    public bool test () {
        stdout.printf ("Hello\n");
        return true;
    }
    
    public void add_actions () {
        
        SimpleAction a = new SimpleAction ("hello", null);
        a.activate.connect ( () => {stdout.printf ("Hello!\n");});
        this.add_action (a);
    
        SimpleAction reload = new SimpleAction ("reload-all", null);
        reload.activate.connect ( () => {
            this.backend.update ();
        });
        this.add_action (reload);
    
        SimpleAction add_feed = new SimpleAction ("add-feed-uri", VariantType.STRING);
        add_feed.activate.connect ( (val) => {
            stdout.printf ("adding feed from %s\n", val.get_string ());
            this.backend.add_feed (val.get_string ());
            this.backend.update ();
        });
        this.add_action (add_feed);
        
        SimpleAction add_feed_menu = new SimpleAction ("show-add-feed-menu", null);
        add_feed_menu.activate.connect ( () => {
            this.header.show_add_menu ();
        });
        this.add_action (add_feed_menu);
        
        SimpleAction show_all = new SimpleAction ("show-all", null);
        show_all.activate.connect ( () => {
            this.newslist.display_all ();
        });
        this.add_action (show_all);
        
        SimpleAction show_favs = new SimpleAction ("show-favs", null);
        show_favs.activate.connect ( () => {
            stdout.printf ("Displaying bookmarks\n");
        });
        this.add_action (show_favs);
        
        SimpleAction show_unread = new SimpleAction ("show-unread", null);
        show_unread.activate.connect ( () => {
            stdout.printf ("Displaying unread items\n");
        });
        this.add_action (show_unread);
        
        SimpleAction display_feed = new SimpleAction ("display-feed", VariantType.STRING);
        display_feed.activate.connect ( (val) => {
            this.newslist.display_only (val.get_string ());
        });
        this.add_action (display_feed);
        
        SimpleAction settings = new SimpleAction ("show-settings", null);
        settings.activate.connect ( () => {
            SettingsDialog s = new SettingsDialog (this, this.backend);
            s.show_all ();
        });
        this.add_action (settings);
        
    }
    
    
     // takes the currently selected item of the list and displays it 
    private void update_entry () {
        this.display.display_entry (this.newslist.get_selected().data);
    }


}
