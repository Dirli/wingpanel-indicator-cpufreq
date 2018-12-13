/*
* Copyright (c) 2018 Dirli <litandrej85@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*/

namespace CPUfreq {
    public class WIdgets.PanelWidget : Gtk.Label {
        public PanelWidget () {
            label = "-";

        }

        public void add_label (double freq_val) {
            if (freq_val == 0) {
                label = "off";
            } else {
                label =  Utils.format_frequency (freq_val);
            }

            return;
        }
    }
}
