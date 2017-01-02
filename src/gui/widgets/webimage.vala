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

class WebImage : Frame {

    private Stack layout;
    private Image i;
    private Spinner s;
    
    private string source;
    
    public WebImage () {
        this.setup ();
    }
    
    public WebImage.with_source (string? prim_source, string? sec_source = null) {
        
        this.setup ();
        
        this.source = prim_source == null ? sec_source : prim_source;
        
        
        this.load ();
    }
    
    private void setup () {
        
        this.set_size_request (70,70);
        
        this.layout = new Stack ();
        this.i = new Image();
        this.s = new Spinner();
        this.s.start();
        
        layout.add_named (this.i, "image");
        layout.add_named (this.s, "spinner");
        layout.set_visible_child_name ("spinner");
    
        this.add (layout);
    }
    
    
    public void load(){


        
        this.set_visible (true);
    
        if (this.source != null) {
            
            helper.load_data_uri (this.source, (d) => {this.finish_loading(d);});
            
        }
    }
    
    private void finish_loading (Soup.MessageBody m) {
    
        FeedReaderMainLoop.invoke ( () => {
            m.flatten ();
            Gdk.PixbufLoader l = new Gdk.PixbufLoader();
            l.write (m.data);
            try {
                l.close ();
                Gdk.Pixbuf buffer = l.get_pixbuf();
                
                int w = buffer.get_width ();
                int h = buffer.get_height ();
                
                this.i.set_from_pixbuf (buffer.scale_simple (w*70/h,70, Gdk.InterpType.BILINEAR));
                
                this.layout.set_visible_child_name ("image");
                this.set_size_request (0,0);
            } catch (Error e) {
                stdout.printf ("failed to load image: %s\n", this.source);
            }
            return false;
        });
    
    }
    
    
    /*
    public void open(string path){
        Gdk.Pixbuf p = new Gdk.Pixbuf.from_file_at_scale(path, 100, 100, true);
        this.i.set_from_pixbuf(p);
        this.layout.set_visible_child_name ("image");
    }*/
   
}

