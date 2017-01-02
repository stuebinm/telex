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
  * Just a Linkbutton with a bit of default formatting. 
  * Not sure if it's any use, since there's currently only one child-class (TODO?)
 */
abstract class IButton : Gtk.LinkButton {

    protected new  Label label;

    public IButton () {
        this.set_relief (ReliefStyle.NONE);
        this.label = new Label (null);
        
        this.label.set_line_wrap (true);
        this.label.set_justify (Justification.CENTER);
        
        this.add (this.label);
    }


}

/**
 *  This is a button with a link on it, for use in any number of places,
 *  but mainly for the viewport. That's why the contructor doesn't take any
 *  argumenty ('cause the view's empty when constructed), and why there's
 *  a special 'is header'-Constructor for convenience.
*/
class LinkButton : IButton {

    string text;
    string link;
    
    bool isHeader;

    /**
     * Creates a new #LinkButton
    */
    public LinkButton () {
        this.isHeader = false;
        this.text = "";
        this.link = "";
        
        this.update ();
    }
    
    /**
     * Creates a new #LinkButton which displays text in a header-sort-of style
    */
    public LinkButton.as_header () {    
        this.isHeader = true;
        this.text = "";
        this.link = "";
        
        this.update ();
    }
    
    /**
     * set_link:
     * resets the link to be displayed. If the text is empty, the widget will hide itself.
     * @text: a string containing a label (or nothing)
     * @link: a string containing a uri (or nothing)
     *
    */
    public void set_link (string? text, string? link) {
        if (text == null) {
            this.set_visible (false);
            return;
        } else {
            this.set_visible (true);
        }
        this.text = text;
        if (uri == null) {
            this.link = "";
        } else {
            this.link = link;
        }
        this.update ();
    }
    
    private void update () {
        this.set_uri (this.link);
        if (this.isHeader){
            this.label.set_markup ("<big><big><big>%s</big></big></big>".printf(text));
        }
        else {
            this.label.set_label (this.text);
        }
    }

}
