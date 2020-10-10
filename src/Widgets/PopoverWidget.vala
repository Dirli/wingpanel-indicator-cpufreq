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
    public class Widgets.PopoverWidget : Gtk.Grid {
        private int top = 0;
        private GLib.Settings settings;
        private Granite.Widgets.ModeButton gov_box;
        private string[] gov_vars;

        public PopoverWidget (GLib.Settings settings) {
            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            row_spacing = 2;

            this.settings = settings;

            if (!GLib.FileUtils.test (CPU_PATH + "cpu0/cpufreq", FileTest.IS_DIR)) {
                Gtk.Label label = new Gtk.Label (_("Your system does not support\n cpufreq manage"));
                label.get_style_context ().add_class ("h2");
                label.sensitive = false;
                label.margin_top = label.margin_bottom = 24;
                label.margin_start = label.margin_end = 12;
                attach (label,  0, 0, 1, 1);
            } else {
                if (GLib.FileUtils.test (CPU_PATH + "intel_pstate", FileTest.IS_DIR)) {
                    add_turbo_boost ();
                }

                add_governor ();
            }
        }

        private void add_governor () {
            string current_governor = Utils.get_governor ();

            var separator = new Wingpanel.Widgets.Separator ();
            separator.hexpand = true;
            attach (separator, 0, top, 2, 1);
            ++top;

            gov_box = new Granite.Widgets.ModeButton ();
            gov_box.orientation = Gtk.Orientation.VERTICAL;
            gov_vars = new string[10];

            foreach (string gov in Utils.get_available_values ("governors")) {
                gov = gov.chomp ();
                int i = gov_box.append_text (gov);

                if (gov == current_governor) {
                    gov_box.selected = i;
                }

                gov_vars[i] = gov;
            }

            attach (gov_box, 0, top, 2, 1);
            ++top;
            gov_box.mode_changed.connect (toggled_governor);
        }

        private unowned void toggled_governor () {
            if (Utils.get_permission ().allowed) {
                settings.set_string ("governor", gov_vars[gov_box.selected]);
            }
        }

        private void add_turbo_boost () {
            Wingpanel.Widgets.Switch tb_switch = new Wingpanel.Widgets.Switch ("Turbo Boost", settings.get_boolean("turbo-boost"));
            settings.bind ("turbo-boost", tb_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            attach (tb_switch, 0, top, 2, 1);
            ++top;

            var separator = new Wingpanel.Widgets.Separator ();
            separator.hexpand = true;
            attach (separator, 0, top, 2, 1);
            ++top;

            Gtk.Label freq_label = new Gtk.Label (_("CPU frequency (%):"));
            freq_label.halign = Gtk.Align.CENTER;
            attach (freq_label, 0, top, 2, 1);
            ++top;

            Gtk.Label min_label = new Gtk.Label (_("Min:"));
            min_label.margin_start = 15;
            attach (min_label, 0, top, 1, 1);
            Gtk.Scale min_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 25, 100, 5);
            min_scale.margin_start = 15;
            min_scale.margin_end = 15;
            min_scale.hexpand = true;
            min_scale.set_value (Utils.get_freq_pct ("min"));
            attach (min_scale, 1, top, 1, 1);
            ++top;

            Gtk.Label max_label = new Gtk.Label (_("Max:"));
            max_label.margin_start = 15;
            attach (max_label, 0, top, 1, 1);
            Gtk.Scale max_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 25, 100, 5);
            max_scale.margin_start = 15;
            max_scale.margin_end = 15;
            max_scale.hexpand = true;
            max_scale.set_value (Utils.get_freq_pct ("max"));
            attach (max_scale, 1, top, 1, 1);
            ++top;

            min_scale.value_changed.connect (() => {
                settings.set_double ("pstate-min", min_scale.get_value ());
            });
            max_scale.value_changed.connect (() => {
                settings.set_double ("pstate-max", max_scale.get_value ());
            });
        }
    }
}
