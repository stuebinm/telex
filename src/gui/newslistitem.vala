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
 * NewsListItem:
 * A single item for the newslist.
 * Will display title, feed, and the first image of a #FeedParser.FeedItem.
 *
*/
class NewsListItem : ListItem{ //ListBoxRow {
    public FeedItem data {private set; public get;}

    
    /**
     * FeedListItem:
     * Takes a #FeedParser.FeedItem and displays it.
     *
    */
    public NewsListItem (FeedItem data){
        base (data.title, data.feed.title, data.image, data.feed.icon);
        
        this.data = data;
    }
    
    /**
     * Gives this position relative to another #NewsListItem.
     * (for sorting functions; sorted according to published time for now)
     *
    */
    public int relative_to (NewsListItem other) {
        return (int) (other.data.published.mktime() - this.data.published.mktime());
    }
    

}
