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
using Gee;


/**
 * NewsList:
 * A list of #NewsListItem displaying several #FeedParser.FeedItem.
 *
*/
class NewsList : Stack {
    
    public enum DisplayMode {
        SHOW_ALL,
        SHOW_FAVS,
        SHOW_UNREAD,
        SHOW_SINGLE
    }
    
    ScrolledWindow scrolled;
    ListBox layout;
    FeedReader backend;
    NewsListPlaceholder placeholder;
    Spinner spinner;
    
    HashMap <string, NewsListItem> items;
    
    public DisplayMode displaymode {private set; public get; default = DisplayMode.SHOW_ALL;}
    public string visible_feed_id {private set; public get; default = "";}
    
    public NewsList (FeedReader backend) {
    
        this.backend = backend;
        this.items = new HashMap <string, NewsListItem> ();
        
        this.displaymode = DisplayMode.SHOW_ALL;
        this.scrolled = new ScrolledWindow (null, null);
        
        this.spinner = new Spinner ();
        this.spinner.start ();
        
        this.layout = new ListBox ();
        this.layout.selected_rows_changed.connect (() => {this.selection_changed();});
        this.layout.set_hexpand (true);
        this.layout.set_vexpand (true);
        this.layout.selection_mode = SelectionMode.BROWSE;
        
        this.placeholder = new NewsListPlaceholder (this.backend);
        this.layout.set_placeholder (this.placeholder);
        
        this.scrolled.add (layout);
        this.add (scrolled);
        this.add (spinner);
    
        this.scrolled.set_policy (PolicyType.EXTERNAL, PolicyType.AUTOMATIC);
        
        this.update (); // since normally there's already something in a feed-object
        this.backend.changed.connect (this.update);
        this.backend.feed_removed.connect (this.feed_removed);
        
        this.layout.set_sort_func (this.sort_function);
        this.layout.set_filter_func (this.filter_function);
        
    }
    
    /**
     * update:
     * Call this function after something in the feeds has changed.
     * it will add all new items (TODO: also remove old ones)
     *
    */
    public void update () {
        for (Gee.MapIterator<string, FeedItem> iter = this.backend.items.map_iterator(); iter.next(); iter.has_next()) {
            if (!this.items.has_key (iter.get_value().id)) {
                NewsListItem new_news = new NewsListItem (iter.get_value ());
                this.layout.add (new_news);
                this.items[iter.get_value().id] = new_news;
            }
        }
        
        this.show_all ();
    }
    
    private void feed_removed (FeedChannel feed) {
        this.layout.foreach ( (widget) => {
            NewsListItem item = (NewsListItem) widget;
            if (!this.backend.items.has_key (item.data.id)) {
                widget.destroy ();
            }
        });
    }
    
    private int sort_function (ListBoxRow a, ListBoxRow b) {
        NewsListItem a1 = (NewsListItem) a;
        NewsListItem b1 = (NewsListItem) b;
        
        return a1.relative_to (b1);
    }

    private bool filter_function (ListBoxRow l) {
        NewsListItem l1 = (NewsListItem) l;
        return this.displaymode == DisplayMode.SHOW_ALL ? true : this.visible_feed_id == l1.data.feed.id;
    }
    
    /**
     * get_selected:
     * Get the currently selected NewsListItem.
     * 
     * Returns: the selected NewsListItem.
    */
    public NewsListItem get_selected () {
        return (NewsListItem) this.layout.get_selected_row();
    }

    /**
     * get_description:
     * get a string containing a fitting a description of this newslist, to be used as a title or similar things.
     * 
     * Returns: a string containing a description of this #NewsList.
    */
    public string get_description () {
        switch (this.displaymode) {
            case DisplayMode.SHOW_ALL:
                return _("All Feeds");
            case DisplayMode.SHOW_FAVS:
                return _("Bookmarks");
            case DisplayMode.SHOW_UNREAD:
                return _("Unread");
            default:
                return this.backend.get_feed_title (this.visible_feed_id);
        }
    }
    
    /**
     * display_only:
     * Displays only items from the feed with the given @id.
     * @id: Feed that is to be displayed.
     *
    */
    public void display_only (string id) {
        this.displaymode = DisplayMode.SHOW_SINGLE;
        this.visible_feed_id = id;
        this.layout.invalidate_filter();
        this.display_changed ();
        stdout.printf ("Description: %s\n", this.get_description ());
    }
    
    /**
     * display_all:
     * Displays all newsListItems currently in memory.
     *
    */
    public void display_all () {
        this.displaymode = DisplayMode.SHOW_ALL;
        this.layout.invalidate_filter();
        this.display_changed ();
    }

    public signal void selection_changed ();
    
    /**
     * display_changed:
     * will be emitted whenever the display mode changed.
    */
    public signal void display_changed ();

}
