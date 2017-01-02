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
 * FeedAdder:
 * This widget provides a nice little menu-button that'll pop open a menu allowing the user to add a feed.
 *
*/
class FeedAdder : MenuButton {

    Grid layout;
    Entry textfield;
    Button add_button;

    public FeedAdder () {

        this.popover = new Popover (this);
        this.label = _("Add");
        //this.set_image (new Image.from_icon_name ("new-tab-symbolic", IconSize.BUTTON));
        
        this.layout = new Grid ();
        this.layout.orientation = Orientation.HORIZONTAL;
        this.layout.margin = 7;
        this.layout.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        
        this.popover.add (this.layout);
        
        this.textfield = new Entry ();
        this.textfield.placeholder_text = "https://www.example.org/atom.xml";
        this.textfield.set_size_request (400,0);
        
        this.add_button = new Button.with_label (_("Add uri"));
        this.add_button.action_name = "win.add-feed-uri";
        this.add_button.action_target = "";
        this.add_button.get_style_context().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        
        this.add_button.clicked.connect (this.popover.popdown);
        
        this.textfield.buffer.inserted_text.connect ( () => {
            this.update ();
        });
        this.textfield.buffer.deleted_text.connect (this.update);
        
        this.layout.add (this.textfield);
        this.layout.add (this.add_button);
        
        this.textfield.activate.connect ( () => {
            this.add_button.activate ();
        });
        
        this.popover.show.connect ( () => {
            this.textfield.text = "";
            this.textfield.has_focus = true;
            this.popover.show_all ();
        });
    }
    
    private void update () {
        this.add_button.action_target = this.textfield.text;
    }


}
