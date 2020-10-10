/*
* Copyright (c) 2018-2020 Dirli <litandrej85@gmail.com>
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
    public const string CPU_PATH = "/sys/devices/system/cpu/";

    public class Utils {
        public static bool can_manage () {
            return GLib.FileUtils.test (CPU_PATH + "cpu0/cpufreq", FileTest.IS_DIR);
        }

        public static string get_content (string file_path) {
            string content;

            try {
                GLib.FileUtils.get_contents (file_path, out content);
            } catch (Error e) {
                warning (e.message);
                return "";
            }

            return content.chomp ();
        }

        public static double get_freq_pct (string adv) {
            string cur_freq_pct = Utils.get_content (CPU_PATH + "intel_pstate/" + adv + "_perf_pct");
            return double.parse (cur_freq_pct);
        }

        public static string get_governor (bool def_val = false) {
            return Utils.get_content (CPU_PATH + "cpu0/cpufreq/scaling_governor");
        }

        public static string[] get_available_values (string path) {
            string val_str = Utils.get_content (CPU_PATH + @"cpu0/cpufreq/scaling_available_$path");
            return val_str.split (" ");
        }

        public static double get_cur_frequency () {
            string cur_value;
            double maxcur = 0;

            for (uint i = 0, isize = (int)get_num_processors (); i < isize; ++i) {
                cur_value = Utils.get_content (CPU_PATH + @"cpu$i/cpufreq/scaling_cur_freq");

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

        public static void run_cli (string cmd_par) {
            string stdout;
            string stderr;
            int status;
            string cli_path = "pkexec /usr/bin/io.elementary.cpufreq.modifier ";
            string cmd = cli_path + cmd_par;

            try {
                Process.spawn_command_line_sync (
                    cmd,
                    out stdout,
                    out stderr,
                    out status);
            } catch (Error e) {
                warning (e.message);
            }

            return;
        }

        private static Polkit.Permission? permission = null;
        public static Polkit.Permission? get_permission () {
            if (permission != null) {
                return permission;
            }

            try {
                permission = new Polkit.Permission.sync ("io.elementary.wingpanel.cpufreq.setcpufreq", new Polkit.UnixProcess (Posix.getpid ()));
                return permission;
            } catch (Error e) {
                critical (e.message);
                return null;
            }
        }

        public static string format_frequency (double val) {
            const string[] units = {
                "{} MHz",
                "{} GHz"
            };
            int index = -1;

            while (index + 1 < units.length && (val >= 1000 || index < 0)) {
                val /= 1000;
                ++index;
            }
            var pattern = units[index].replace ("{}", val <   9.95 ? "%.1f" : "%.0f");
            return pattern.printf (val);
        }
    }
}
