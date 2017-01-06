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
    
    /**
     * parse_atom_feed:
     * Parses the #Xml.Doc* given in @doc as an atom newsfeed.
     * @doc: A Xml.Doc* containing an atom feed (note that it will assume it's valid without checking for it).
     * 
     * Returns: A #FeedChannel containing the parsed result, or null if an error occured.
    */
    public FeedChannel? parse_atom_feed (Xml.Doc* doc) {
        FeedChannel ret = new FeedChannel ();
        
        Xml.Node* root = doc->get_root_element ();
        
        if (root == null) return null;
        
        for (Xml.Node* iter = root->children; iter != null; iter = iter->next) {
            
             // parses the possible children of an atom document, as defined by the atom standard (https://tools.ietf.org/html/rfc4287)
            switch (iter->name){
                case "category":
                    ret.categories.add (iter->get_content ());
                    break;
                case "contributor":
                    ret.contributors.add (iter->get_content ());
                    break;
                case "generator":
                    ret.generator = iter->get_content ();
                    break;
                case "icon":
                    ret.icon = iter->get_content ();
                    break;
                case "id":
                    ret.id = iter->get_content ();
                    break;
                case "link":
                    ret.links.add (parse_atom_link (iter));
                    break;
                case "logo":
                    ret.logo = iter->get_content ();
                    break;
                case "rights":
                    ret.rights = iter->get_content ();
                    break;
                case "subtitle":
                    ret.subtitle = iter->get_content ();
                    break;
                case "title":
                    ret.title = iter->get_content ();
                    break;
                case "updated":
                    ret.updated = iter->get_content ();  // TODO! (parse as time_t, not string)
                    break;
                case "author":
                    ret.author = iter->get_content ();
                    break;
                case "entry":
                    FeedItem item = parse_atom_feed_item (iter);
                    ret.items.add (item);
                    item.feed = ret;
                    break;
                default:
                    continue;
            }
        }
        
        return ret;
    }
    
    private FeedItem? parse_atom_feed_item (Xml.Node* node) {
        
        if (node->name != "entry") return null;
        
        FeedItem ret = new FeedItem ();
                
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == null) continue;
            if (iter->name == "text") continue;
            
             // parses the possible children of an atom entry, as defined by RFC 4287
            switch (iter->name) {
                case "text":
                    break;
                case "category":
                    ret.categories.add (iter->get_content ());
                    break;
                case "content":
                    ret.content = parse_atom_content (iter, ret);
                    break;
                case "contributor":
                    ret.contributors.add(iter->get_content ());
                    break;
                case "id":
                    ret.id = iter->get_content ();
                    break;
                case "link":
                    ret.links.add (parse_atom_link (iter));
                    break;
                case "author":
                    ret.authors.add (parse_atom_person (iter));
                    break;
                case "published":
                    DateTime? t = helper.parse_iso_date (iter->get_content ());
                    if (t == null) stderr.printf (_("Error while parsing date!"));
                    else ret.published = t;
                    break;
                case "rights":
                    ret.rights = iter->get_content ();
                    break;
                case "source":
                    ret.source = iter->get_content ();
                    break;
                case "summary":
                    ret.summary = iter->get_content ();
                    break;
                case "updated":
                    DateTime? t = helper.parse_iso_date (iter->get_content ());
                    if (t == null) stderr.printf (_("Error while parsing date!"));
                    else ret.updated = t;
                    break;
                case "title":
                    ret.title = iter->get_content ();
                    break;
                default:
                    continue;
            }
        }
    
        if (ret.content == null) {
            ret.content = ret.summary;
        }
    
        return ret;
    }

    
    private string? parse_atom_link (Xml.Node* node) {
        if (node->name != "link") return null;
        
        for (Xml.Attr* iter = node->properties; iter != null; iter = iter->next) {
            if (iter->name == "href") {
                return iter->children->content;
            }
        }
        return null;
    }
    
    private FeedPerson? parse_atom_person (Xml.Node* node) {
        if (node->name != "author") return null;
        
        FeedPerson ret = new FeedPerson ();
        
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            switch (iter->name) {
                case "name":
                     // some feeds insist on passing the link within the author's name (i.e., in a "<a href="…">author</a>" format)
                    if ("</a>" in iter->get_content ()) {
                        string[] stuff = iter->get_content().split("href=\"");
                        if (stuff.length > 1) {
                            ret.uri = stuff[1].split("\"")[0];
                            // TODO: Sometimes, those feeds only give internal links (i.e. without a domain). In those cases, the site domain should be added.
                        }
                        string name = iter->get_content().replace ("</a>", "");
                        stuff = name.split(">");
                        if (stuff.length > 1) {
                            ret.name = stuff[1];
                        }
                    } else
                        ret.name = iter->get_content ();
                    break;
                case "email":
                    ret.email = iter->get_content ();
                    break;
                case "uri":
                    ret.uri = iter->get_content ();
                    break;
                default:
                    continue;
            }
        }
        
        if (ret.name == null) return null;
        
        return ret;
    }
    
    enum AtomContentType {
        TEXT,
        HTML,
        XHTML
    }
    
    private string parse_atom_content (Xml.Node* node, FeedItem item) {
    
        AtomContentType type = AtomContentType.TEXT;
    
        for (Xml.Attr* iter = node->properties; iter != null; iter = iter->next) {
            if (iter->name == "type") {
                switch (iter->children->get_content ()) {
                    case "xhtml":
                        type = AtomContentType.XHTML;
                        item.image = search_for_image_in_node (node);
                        break;
                    case "html":
                        type = AtomContentType.HTML;
                        item.image = search_for_image_in_xml (node->get_content ());
                        break;
                    default:
                        continue;
                }
            }
        }
        
        
        if (type == AtomContentType.TEXT) {
            return node->get_content ();
        }
        
        return helper.get_xml (node);
    
    }
    
    private string? search_for_image_in_node (Xml.Node* node) {
    
        if (node->name == "img") {
            for (Xml.Attr* iter = node->properties; iter != null; iter = iter->next) {
                if (iter->name == "src") return iter->children->get_content ();
            }
            return null;
        }
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            string img = search_for_image_in_node (iter);
            if (img != null) return img;
        }
        return null;
    }
    
    private string? search_for_image_in_xml (string xml) {
         /* this funny little construction will search for 
            the first <img>-Element in the given string and return
            its source (it's written like this -- instead of actually
            parsing the string -- because this way, it'll return something
            even if the document isn't actually valid xml, which happens
            distressingly often).
         */
        string[] stuff = xml.split("<img ");
        if (stuff.length > 1) {
            string doc = stuff[1];
            stuff = doc.split ("src=\"");
            if (stuff.length > 1) {
                doc = stuff[1];
                stdout.printf ("%s\n", doc.split("\"")[0]);
                return doc.split("\"")[0];
            }
        }
        return null;
    }


}
