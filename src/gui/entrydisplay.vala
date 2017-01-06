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
 * EntryDisplay:
 * This widget displays a single #FeedParser.FeedItem at a time.
 * Used as the main viewport widget in this application.
 *
*/
class EntryDisplay : ScrolledWindow {

    Grid layout;
    FeedItem data;
    
    LinkButton feed;
    LinkButton title;
    LinkButton author;
    
    // TODO: A LinkButton allowing you to open an email application if there's a mail attached to the author.
    //LinkButton email;
    
    Label published;
    
    HtmlView web;
    
    
    public EntryDisplay (){
    
    
        this.margin = 30;
    
        this.layout = new Grid ();
        this.layout.set_orientation (Orientation.VERTICAL);
        this.layout.set_row_spacing (10);
        
        this.feed = new LinkButton ();
        this.title = new LinkButton.as_header ();
        this.author = new LinkButton ();
        
        this.published = new Label (null);
        
        this.web = new HtmlView ();
        this.web.set_hexpand (true);
        this.web.set_vexpand (true);
        
        Frame webFrame = new Frame (null);
        webFrame.margin_top = 20;
        webFrame.add (this.web);
        
        this.layout.add (this.feed);
        this.layout.add (this.title);
        this.layout.add (this.author);
        this.layout.add (this.published);
        layout.add (webFrame);
        
        this.add (layout);
        
    }
    
    /**
     * display_entry:
     * Set the #FeedParser.FeedItem that is to be displayed.
     * @data: Item to be displayed.
     *
    */
    public void display_entry (FeedItem data){
        this.data = data;
        this.update();
    }
    
     // Does everything that's necessary to actually display anything
    private void update (){
        if (this.data == null) {
            this.set_visible (false);
            return;
        }
        
        this.feed.set_link (Markup.escape_text (this.data.feed.title), this.data.feed.get_preferred_link ());
        this.title.set_link (Markup.escape_text (this.data.title), this.data.get_preferred_link ());
        
        if (this.data.has_author()){
            this.author.set_link (this.data.get_preferred_author().name, this.data.get_preferred_author().uri);
        } else {
            this.author.set_link (null, null);
        }
        
        this.published.label = this.data.published.format("%c");
        
       // stdout.printf ("%d\n", this.data.published.year);
        
        this.web.display_string (this.data.content);
        
    }
    
}



