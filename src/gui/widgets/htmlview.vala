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

using WebKit;

/**
 * HtmlView:
 * Basically, just a widget displaying some html.
 * This only exists to provide some widget formatting,
 * and to stop WebKit from opening links by itself (TODO)
 *
*/
class HtmlView : WebView {

    string raw;
    bool load_allowed = false;
    
    public HtmlView (){
        
        this.raw = "";
        
        WebKit.Settings settings = new WebKit.Settings ();
        settings.set_enable_caret_browsing (false);
        settings.set_enable_hyperlink_auditing (true);
        settings.set_allow_file_access_from_file_urls (false);
        
        this.set_settings (settings);
        
         /* These few magic lines would stop the view from loading stuff it's not supposed to.
          * (i.e. it won't allow the user to follow links if this bit of code isn't commented out.
          * Unfortunately, this also stops it from loading images and other resources that might 
          * be useful … 
         */
        /*this.load_changed.connect (() => {
            if (!this.load_allowed) 
                this.stop_loading(); 
            else 
                this.load_allowed = false;
        });*/
        
    }

    /**
     * display_string:
     * Sets what to display.
     * @html: a string containing valid html code.
    */
    public void display_string (string html) {
        this.stop_loading ();
        this.load_allowed = true;
        this.load_html (html, null);
    }
    


}



