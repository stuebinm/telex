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


namespace helper {
    
    
    /**
     * parse_iso_date:
     * @date: a #string containing a date as defined in ISO
     *
     * Returns: a #Date containing the date, or else #null if an error occured.
    */
    public Time? parse_iso_date (string timestring) {
    
        string input = timestring.replace (" ", "");
        input = input.replace ("\n", "");
        input = input.replace ("\t", "");
        
        string[] inputlist = input.split ("T");
        
        if (inputlist.length != 2) return null;
        
        
        inputlist[1] = inputlist[1].replace ("Z", "");
        
        int timezonemult = 0;
        
        string[] temp = inputlist[1].split ("+");
        timezonemult = -1;
        
        if (temp.length == 1) {
            temp = inputlist[1].split("-");
            timezonemult = 1;
        }
        
        string[] date = inputlist[0].split("-");
        if (date.length != 3) return null;
        
        string[] time = temp[0].split(":");
        if (time.length != 3) return null;

        
        Time ret = Time ();
        
        ret.year = int.parse (date[0]);
        ret.month = int.parse (date[1]);
        ret.day = int.parse (date[2]);
        
        ret.hour = int.parse (time[0]);
        ret.minute = int.parse (time[1]);
        ret.second = int.parse (time[2].split(".")[0]);
    
    
        if (temp.length == 2) {
            string[] offset = temp[1].split (":");
            ret.hour += int.parse (offset [0]) * timezonemult;
            if (offset.length == 2) {
                ret.minute += int.parse (offset [1]) * timezonemult;
            }
        }

        
        return ret;
    }


}
