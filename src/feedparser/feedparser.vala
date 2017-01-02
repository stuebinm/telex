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

using Xml;

namespace FeedParser {

    public enum FeedFormat {
        RSS,
        ATOM,
        UNKNOWN
    }
    
    /**
     * FeedParser.parse:
     * @doc: a #Xml.doc* to be parsed
     * 
     * Returns: a FeedChannel containing feed data, or null if an error occured
     */
    public FeedChannel? parse (Xml.Doc* doc) {
    
        switch (get_feed_format (doc)) {
            case FeedFormat.RSS:
                return parse_rss_feed (doc);
            case FeedFormat.ATOM:
                return parse_atom_feed (doc);
            default:
                return null;
        }
    
    }

    /**
     * get_feed_format:
     * @doc: a #Xml.doc* containing a newsfeed of some format
     *
     * Returns: a #FeedFormat describing the feed's format (note that it might be #FeedFormat.UNKNOWN)
     */
    public FeedFormat get_feed_format (Xml.Doc* doc) {
        return FeedFormat.ATOM;
    }

    

}
