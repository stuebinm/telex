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
 * ListItem:
 * A single item for a list, with webimage, title and category-like labels.
 *
*/
class ListItem : ListBoxRow {

    Grid layout;
    
    Label feed;
    Label title;
    
    WebImage image;
    
    Grid button_area;
    
    /**
     * ListItem:
     * Constructs a new listitem.
     * @title: a string setting the main title
     * @subtitle: a 'subtitle' (it actually appears above the title, but in smaller font), use it for feed, uris, etc
     * @image_uri: an uri pointing to an image that'll be displayed.
     * @image_alt_uri: an alternative image that'll be displayed in case the first uri doesn't point to an image
    */
    public ListItem (string title, string subtitle, string? image_uri, string? image_alt_uri){
        
        
        this.layout = new Grid();
        this.layout.set_orientation (Orientation.VERTICAL);
        
        this.feed = new Label ("");
        this.title = new Label ("");
        
        this.feed.set_ellipsize (Pango.EllipsizeMode.END);
        this.feed.set_justify (Justification.CENTER);
        this.feed.set_margin_start (10);
        
        this.title.set_line_wrap (true);
        this.title.set_xalign (0);
        this.title.set_halign (0);
        this.title.set_margin_start (10);
        this.title.set_hexpand (true);
        
        this.image = new WebImage.with_source (image_uri, image_alt_uri);

        this.layout.set_halign (Align.FILL);
        this.layout.set_margin_start (5);
        this.layout.set_margin_end (5);
        
        this.feed.set_markup ("<small>%s</small>".printf(Markup.escape_text(subtitle)));
         // TODO: This works fine for most (but not all!) feeds. If they don't use escape sequences, this WILL fail.
        this.title.set_markup ("<b>%s</b>".printf(Markup.escape_text(title)));
        
        this.button_area = new Grid ();
        this.button_area.orientation = Orientation.HORIZONTAL;
        this.button_area.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        
        layout.attach (this.button_area, 2, 1);
    
        layout.attach (this.feed, 1, 0, 2, 1);
        layout.attach (this.title, 1, 1, 1, 1);
        layout.attach (this.image, 0, 0, 1, 2);
        
        
        this.add (layout);
        
    }
    
    /**
     * add_button:
     * Adds a button to this item.
     * @label: a label to be displayed
     * @name: an internal name that'll be used for signals (this is seperate in order to allow label translation)
     *
    */
    public void add_button (string label, string name) {
        Button b = new Button.with_label (label);
        b.clicked.connect ( () => {
            this.button_pressed (name);
        });
        this.button_area.add(b);
        b.show ();
    }
    
    /**
     * button_pressed:
     * Signals that a button (added with #Listitem.add_button()) has been pressed.
     * @name: the name of the button.
     *
    */
    public signal void button_pressed (string name);

}
