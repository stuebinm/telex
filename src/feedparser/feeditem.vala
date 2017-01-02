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

using Gee;

namespace FeedParser {

    public class FeedItem : GLib.Object {
    
        [Description(nick="title", blurb="the item's title (not the feed's)")]
        public string title {get; set; default="";}
        
        [Description(nick="content text", blurb="the item's description, summary or whatever else you might want to call it")]
        public string content {get; set; default=null;}
        
        [Description(nick="email", blurb="if there's an email addres with the author, it'll be here")]
        public string email {get; set; default="";}
        
        [Description(nick="source", blurb="this is the link to the actual web page")]
        public string source {get; set; default="";}
    
        
        public string id {get; set; default="";}
        public string rights {get; set; default="";}
        public string summary {get; set; default=null;}
        
        public string image {get; set; default = null;}

        public Time published {get; set;}
        public Time updated {get; set;}
    
        public ArrayList<string> links {get {return this._links;}}
        public ArrayList<string> categories {get {return this._categories;}}
        public ArrayList<string> contributors {get {return this._contributors;}}
        public ArrayList<FeedPerson> authors {get {return this._authors;}}
        
        private ArrayList<string> _links = new ArrayList<string> ();
        private ArrayList<string> _categories = new ArrayList<string> ();
        private ArrayList<string> _contributors = new ArrayList<string> ();
        private ArrayList<FeedPerson> _authors = new ArrayList<FeedPerson> ();
        
        public FeedChannel feed {get;set;}
        
        public string get_preferred_link () {
            return this.links.size != 0 ? this.links[0] : "";
        }
        
        public FeedPerson? get_preferred_author () {
            return this.authors.size != 0 ? this.authors[0] : null;
        }
        
        public bool has_author () {
            return this.authors.size > 0;
        }
    
    }


}
