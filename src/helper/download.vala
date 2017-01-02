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


using Soup;

namespace helper {

    /**
     * download_file:
     * legacy stuff, use #load_from_uri_or_temp instead.
    */
    [deprecated]
    public string download_file (string uri, bool force = false) {
        
         // seperate the file ending of the original file
        string[] temp = uri.split(".");
        string ending = ".%s".printf(temp[temp.length-1]);
        if (ending.length > 5) ending = "";
        
         // generate a filepath keeping the file ending intact
        string path = "/tmp/%s%s".printf (uri.hash().to_string(), ending);
        
         // check if it's already downloaded (except if download is forced, say, for reloading
        if (GLib.FileUtils.test(path, GLib.FileTest.EXISTS) && !force) {
            return path;
        }
        
         // generate a system command
        string command  = "wget \"%s\" -O \"%s\" > /dev/null 2> /dev/null".printf(uri, path);
        
         // execute wget and download the actual file
        Posix.system(command);
        
         // return the filepath
        return path;
    }
    

    /**
     * load_from_uri:
     * Will download what is to be found at @uri (and only that, this function will not
     * follow links or anything) and call @callback with the downloaded file (in a #string) as the 
     * single argument. If the given uri doesn't exist this argument will be #null (if the uri is
     * invalid, this function will return false).
     *
     * @uri: The uri to download from. Can be anything that libsoup understands
     * @callback: the callback to be called, with the downloaded file as single argument.
     *
     * Returns: whether or not the uri is valid (i.e. whether or not the download thread could be started).
    */
    public bool load_from_uri (string uri, DownloadCallback callback) {
        
        Session session = new Session ();
        Message message = new Message ("GET", uri);
        
         // if uri's invalid or something else went wrong, return false.
        if (message == null) return false;
        
        try {
             // this does the whole downloading and threading and stuff
            new Thread<void*> ("downloading…", () => {
                session.send_message (message);
                callback ((string) message.response_body.data, uri);
                return null;
            });
             // request was valid, ergo, return true.
            return true;
        }
        catch (ThreadError e) {
            stderr.printf ("%s\n", e.message);
        }
    }
    
    
    public delegate void DataCallback (MessageBody m);
    
    public bool load_data_uri (string uri, DataCallback callback) {
        
        Session session = new Session ();
        Message message = new Message ("GET", uri);
        
         // if uri's invalid or something else went wrong, return false.
        if (message == null) return false;
        
        try {
             // this does the whole downloading and threading and stuff
            new Thread<void*> ("downloading…", () => {
                session.send_message (message);
                
                string format = "";
                message.response_body.flatten ();
                message.response_headers.foreach ((name, val) => {
                    if (name == "Content-Type") format = val;
                });
                
                callback (message.response_body);
                return null;
            });
             // request was valid, ergo, return true.
            return true;
        }
        catch (ThreadError e) {
            stderr.printf ("%s\n", e.message);
        }
    }
    
    

    /**
     * load_from_uri_or_temp:
     * does the same as #download_from_uri, except that it will also save the given file
     * in /tmp (with the uri hashed as filename, but retaining the file ending), or just
     * load from that file if it already exists (i.e. this function won't load the same thing
     * twice)
     *
     * @uri: The uri to download or to be loaded from temp.
     * @callback: the callback to be called, with the downloaded file as single argument.
     *
     * Returns: whether or not the uri is valid (i.e. whether or not the download thread could be started).
    */
    public bool load_from_uri_or_temp (string uri, DownloadCallback c) {

         // generate a hashed file name while preserving the original ending
        string[] temp = uri.split(".");
        string ending = ".%s".printf(temp[temp.length-1]);
        if (ending.length > 10) ending = ""; // if an ending's got more than 10 characters, chances are it's not an ending but part of a domain or sth.
        string path = "/tmp/feedreaderdownload-%s%s".printf (uri.hash().to_string(), ending);
        
         // check if there's a downloaded version of this
        if (GLib.FileUtils.test(path, GLib.FileTest.EXISTS)) {
            string content;
            FileUtils.get_contents (path, out content);
            c (content, uri);
            return true;
        }
        
         // do the downloading …
        
        Session session = new Session ();
        Message message = new Message ("GET", uri);
        
         // if uri's invalid or something else went wrong, return false.
        if (message == null) return false;
        
        try {
             // this does the whole downloading and threading and stuff
            new Thread<void*> ("downloading…", () => {
                session.send_message (message);
                GLib.FileUtils.set_contents (path, (string) message.response_body.data);
                c ((string) message.response_body.data);
                return null;
            });
             // request was valid, ergo, return true.
            return true;
        }
        catch (ThreadError e) {
            stderr.printf ("%s\n", e.message);
        }
    }


    /**
     * DownloadCallback:
     * Does exactly what it seems to do. Content will contain the server's response, or else be empty if
     * the server doesn't exist.
     *
     * @content: A string containing the loaded file.
     */

    public delegate void DownloadCallback (string? content, string uri="");
    
}
