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
    public class Services.FreqManager : GLib.Object {
        public static void set_turbo_boost (bool state) {
            if (Utils.get_permission ().allowed) {
                string cli_cmd = "-t ";
                if (state) {
                    cli_cmd += "on";
                } else {
                    cli_cmd += "off";
                }

                Utils.run_cli (cli_cmd);
            }

            return;
        }

        public static double get_cur_frequency () {
            string cur_value;
            double maxcur = 0;

            for (uint i = 0, isize = (int)get_num_processors (); i < isize; ++i) {
                cur_value = Utils.get_content (@"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq");

                if (cur_value == "") {continue;}
                var cur = double.parse (cur_value);

                if (i == 0) {
                    maxcur = cur;
                } else {
                    maxcur = double.max (cur, maxcur);
                }
            }

            return maxcur;
        }

        public static void set_freq_scaling (string adv, double new_val) {
            if (Utils.get_permission ().allowed) {
                if (new_val >= 25 && new_val <= 100) {
                    string cli_cmd = " -f %s:%.0f".printf(adv, new_val);
                    Utils.run_cli (cli_cmd);
                }
            }

            return;
        }

        public static void set_governor (string governor) {
            if (governor != "") {
                string cli_cmd = " -g " + governor;
                Utils.run_cli (cli_cmd);
            }

            return;
        }
    }
}
