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

    public class FeedChannel : GLib.Object {
    
        public string uri {get; set; default=null;}
    
         // single-string properties as defined by the atom standard
        public string generator {get; set; default=null;}
        public string icon {get; set; default=null;}
        public string id {get; set; default=null;}
        public string logo {get; set; default=null;}
        public string rights {get; set; default=null;}
        public string subtitle {get; set; default=null;}
        public string title {get; set; default=null;}
        public string xml {get; set; default=null;}
        public string author {get; set; default=null;}
        
         // update time (parsed)
        public string updated {get; set; default="";}

         // atom properties that might occur more than once
        public ArrayList<string> links {get {return this._links;}}
        public ArrayList<string> categories {get {return this._categories;}}
        public ArrayList<string> contributors {get {return this._contributors;}}
        public ArrayList<FeedItem> items {get {return this._items;}}
        
        private ArrayList<string> _links = new ArrayList<string> ();
        private ArrayList<string> _categories = new ArrayList<string> ();
        private ArrayList<string> _contributors = new ArrayList<string> ();
        
         // item list
        private ArrayList<FeedItem> _items = new ArrayList<FeedItem> ();
        

        public string to_string () {
            return "Feed: %s, from %s\n".printf (this.title, this.links[0]);
        }

        public string get_preferred_link () {
            return this.links.size != 0 ? this.links[0] : "";
        }
        
    }


}
