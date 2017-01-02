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

class NewsListMenu : Gtk.MenuButton {

    public NewsList list {get {return _list;}}
    private NewsList _list;
    
    public FeedReader backend {get {return this._backend;}}
    private FeedReader _backend;
    
    private PopoverMenu menu;
    Grid layout;
    Label label;
    
    SimpleActionGroup actions;
    
    GLib.Menu displayMenu;
    
    public NewsListMenu (NewsList list, FeedReader backend) {
        
        
        this._list = list;
        this._backend = backend;
        this.direction = ArrowType.DOWN;
        
        this.label = new Label (_("All Feeds"));
        this.label.set_ellipsize (Pango.EllipsizeMode.END);
        this.label.set_justify (Justification.CENTER);
        this.add (this.label);
        
        this.relief = ReliefStyle.NONE;
        
        this.backend.feed_added.connect (this.add_feed);
        this.menu = new PopoverMenu ();
        
        this.actions = new SimpleActionGroup ();
        
        var pop = new Popover (this);
        
        
        GLib.Menu menu = new GLib.Menu ();
        this.displayMenu = new GLib.Menu ();
        this.displayMenu.append (_("All Feeds"), "show-all");
        this.displayMenu.append (_("Unread"), "show-unread");
        this.displayMenu.append (_("Bookmarks"), "show-favs");
        menu.append_section (_("Display:"), this.displayMenu);
        menu.append (_("More …"), "show-settings");
        
        
        pop.bind_model (menu, "win");
        
        this.clicked.connect ( () => {pop.show_all();});
        
        this.list.display_changed.connect ( () => {
            this.label.label = list.get_description ();
        });
        
        this.popover = pop;
    }

    

    private void add_feed (FeedChannel feed) {
        GLib.MenuItem m = new GLib.MenuItem (feed.title, "display-feed");
        m.set_action_and_target_value ("display-feed", feed.id);
        this.displayMenu.append_item (m);
    }

}
