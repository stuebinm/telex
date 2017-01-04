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

using FeedParser;
using Gee;





 /** 
  * FeedLoader:
  * Will download and store feeds, as well as provide a HashMap with all the items currently in memory.
  * 
 */
class FeedReader : GLib.Object {

    public HashMap<string, FeedItem> items {get{return _items;}}
    private HashMap<string, FeedItem> _items = new HashMap<string, FeedItem> ();
    
     // Maps all the FeedChannels with their ids.
    public HashMap<string, FeedChannel> channels {get{return _channels;}}
    private HashMap<string, FeedChannel> _channels = new HashMap<string, FeedChannel> ();
    
     // contains the uris of all feeds
    public ArrayList<string> feeds {get{return this._feeds;}}
    private ArrayList<string> _feeds = new ArrayList<string> ();
    
    public enum Status {
        EMPTY,
        LOADING,
        NONEMPTY
    }
    
    public Status status {public get; private set; default = FeedReader.Status.EMPTY;}
    
    
    Settings settings;
    
    int counter;
    int reload_period;
    
    
    public FeedReader () {
        
        settings = new Settings ("de.tum.in.stuebinm.feedreader");
    
        string[] feeds = settings.get_strv ("feeds");
    
        for (int i = 0; i<feeds.length; i++) {
            this.add_feed (feeds[i]);
        }
    
        counter = 0;
        reload_period = settings.get_int ("reload-period");
    
        this.update ();
        
        new Thread<void*> ("waiting to reload", () => {
            while (true) {
                GLib.Thread.usleep (1000000);
                FeedReaderMainLoop.invoke ( () => {this.increase (); return false;});
            }
        });
        
        this.changed.connect ( () => {
            if (this.feeds.size == 0) {
                this.status = FeedReader.Status.EMPTY;
            } else {
                this.status = FeedReader.Status.NONEMPTY;
            }
            this.status_changed ();
        });
    }
    
    
    /**
     * add_feed:
     * adds feed @uri to the feed list. Note that #FeedReader.update() should be called right afterwards,
     * since this function doesn't actually load the feeds.
     *
     * @uri: feed-uri to be added.
     *
    */
    public void add_feed (string uri) {
        this.feeds.add (uri);
        this.status = Status.LOADING;
        this.status_changed ();
    }
    
    /**
     * add_uri_to_settings:
     * Does exactly what it says on the tin: it adds a given @uri to the list of feeds.
     * Is meant to be called only from a #Loader Object (after it's made sure that the feed is valid,
     * not a double and so on)
     *  @uri: a string containing a (hopefully) valid feed uri.
    */
    public void add_uri_to_settings (string uri) {
        string[] old = this.settings.get_strv ("feeds");
        for (int i = 0; i<old.length; i++) {
            if (old[i] == uri) return;
        }
        old += uri;
        this.settings.set_strv ("feeds", old);
    }
    
    /**
     * update:
     * Will go through the feed list and update every one of them (i.e. re-download, parse, and add
     * all the items to #FeedReader.items).
     * It also resets the reload counter (and the countdown starts anew -- even if it's the user who's pressed the 'reload'-Button)
     * 
     * TODO: save all items somewhere, so they're still there the next time the program's started,
     * together with flags like 'read' or 'bookmark'.
    */
    public void update () {
        this.counter = 0;
        foreach (string feed in this.feeds) {
            this.load_feed (feed);
        }
    }
    
    
    public string get_feed_title (string id) {
        return this.channels[id].title;
    }
    
    public int get_countdown () {
        return this.reload_period - this.counter;
    }
    
    /**
     * load_feed:
     * Takes a feed uri in @uri, downloads and parses the feed is possible.
     * Finally, will emit the #changed signal.
     *
     * @uri: a feed uri.
     *
     * Returns: whether or not loading was succesfull.
    */
    private bool load_feed (string uri) {
        if (uri == "") return false;
        
        if (helper.load_from_uri (uri, (doc, uri) => {this.parse_and_add_feed_async(doc, uri);})) {
            
            this.add_uri_to_settings (uri);
            return true;
        }
        return false;
        
    }
    
    private void parse_and_add_feed_async (string? doc, string uri) {
        if (doc == null) return;
        FeedReaderMainLoop.invoke (new Loader(doc, this, uri).run);
    }
    
    private void increase () {
        this.counter += 1;
        if (counter == reload_period) {
            this.update ();
        }
        this.counted ();
    }

    /**
     * remove_feed:
     * Will remove the given feed from all lists using it in here.
     * Also emits the #FeedReader.changed() and #FeedReader.removed_feed() signals.
     * @channel: The feed to be removed. Should be one that's already in the feed, of course.
    */
    public void remove_feed (FeedChannel channel) {
        
         // remove every item that's in this feed.
        MapIterator <string, FeedItem> iter = this.items.map_iterator ();
        while (iter.has_next ()) {
            iter.next ();
            if (iter.valid) {
                if (iter.get_value().feed.uri == channel.uri) {
                    iter.unset ();
                }
            }
        }
        
         // remove this feed from the parsed list.
        this.channels.unset (channel.id);
        
         // remove this feed from the source list.
        this.feeds.remove (channel.uri);
        
         // remove this feed from the settings list (to be re-loaded at next startup
        string[] old = this.settings.get_strv ("feeds");
        string[] gen = new string [0];
        bool removed = false;
        for (int i = 0; i<old.length; i++) {
            if (old[i] == channel.uri) {
                removed = true;
            } else {
                gen += old [i];
            }
        }
        // TODO: uncomment this
        //this.settings.set_strv ("feeds", gen);
        
         // emit signals
        this.feed_removed (channel);
        this.changed ();
    }
    
    /**
     * reload_feed:
     * Reloads a feed.
     * @feed: the feed to be reloaded.
    */
    public void reload_feed (FeedChannel feed) {
        this.load_feed (feed.uri);
    }
    
    /**
     * changed:
     * Will be emitted whenever something in the feeds changed.
     * Usually, one of #FeedReader.feed_added() and #FeedReader.feed_removed() 
     * will be throwned right before it, except when a simple reload was performed
     * (i.e. just new items, no new feeds).
    */
    public signal void changed ();
    
    /**
     * status_changed:
     * Will be emitted whenever the status is changed.
     * This is different to the #FeedReader.changed() signal, which won't change when
     * a loading operation is started.
    */
    public signal void status_changed ();
    
    /**
     * feed_added:
     * Will be emitted when a new feed is added.
     * @feed: the newly-added feed
    */
    public signal void feed_added (FeedChannel feed);
    
    /**
     * feed_removed:
     * Will be emitted when a feed was removevd.
     * @feed: the feed that's been removed, to be deleted from every list displaying it.
    */
    public signal void feed_removed (FeedChannel feed);
    
    /**
     * counted:
     * Will be emitted whenever the seconds-counter (till next reload) has changed.
    */
    public signal void counted ();
}

/**
 * Loader:
 * helper object for async downloading; Basically, all it's for is to call #run with the required arguments
*/
private class Loader : Object {

    string doc;
    string uri;
    FeedReader reader;
    
    public Loader (string doc, FeedReader reader, string uri) {
        this.doc = doc;
        this.reader = reader;
        this.uri = uri;
    }

    /**
     * run:
     * Will parse a string and add the feed described by it to the given #FeedReader.
     *
     * Returns: false. That seems to be a requirement for #MainContext.invoke()
    */
    public bool run () {
    
        Xml.Doc* xml = Xml.Parser.parse_memory (doc, doc.length);
        
        if (doc == null) return false;
        
        FeedChannel channel = FeedParser.parse (xml);
        channel.uri = this.uri;
        delete xml;
        
        foreach (FeedItem i in channel.items) {
            if (!reader.items.has_key (i.id)) reader.items[i.id] = i;
        }
        
        if (!this.reader.channels.has_key (channel.id)) {
            this.reader.channels[channel.id] = channel;
            this.reader.feed_added (channel);
        }
        
        reader.changed ();
        return false;
    }
}
