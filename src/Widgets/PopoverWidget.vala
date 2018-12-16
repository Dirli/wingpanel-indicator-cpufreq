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
        private CPUfreq.Services.Settings settings;

        public PopoverWidget () {
            orientation = Gtk.Orientation.HORIZONTAL;
            hexpand = true;
            row_spacing = 2;

            settings = CPUfreq.Services.Settings.get_default ();

            if (!FileUtils.test(CPU_PATH + "cpu0/cpufreq", FileTest.IS_DIR)) {
                Gtk.Label label = new Gtk.Label (_("Your system does not support cpufreq manage"));
                label.get_style_context ().add_class ("h2");
                label.sensitive = false;
                label.margin_top = label.margin_bottom = 24;
                label.margin_start = label.margin_end = 12;
                attach (label,  0, 0, 1, 1);
            } else {
                string freq_driver = Utils.get_content (CPU_PATH + "cpu0/cpufreq/scaling_driver");
                if (freq_driver != "intel_pstate") {
                    debug ("not yet implemented");
                    string[] available_freqs = Utils.get_available_values ("frequencies");
                } else {
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

            Gtk.RadioButton? button1 = null;

            foreach (string gov in Utils.get_available_values ("governors")) {
                Gtk.RadioButton button;
                gov = gov.chomp ();

                button = new Gtk.RadioButton.with_label_from_widget (button1, gov);
                button.margin_start = button.margin_end = 15;
                button.margin_bottom = 10;
                button.halign = Gtk.Align.START;
                button.valign = Gtk.Align.CENTER;
                attach (button, 0, top, 2, 1);
                ++top;

                if (button1 == null) {button1 = button;}
                if (gov == current_governor) {
                    button.set_active (true);
                }
                button.toggled.connect (toggled_governor);
            }
        }

        private unowned void toggled_governor (Gtk.ToggleButton button) {
            if (Utils.get_permission ().allowed) {
                if (button.get_active ()) {
                    settings.set_string("governor", button.label);
                }
            }
        }

        private void add_turbo_boost () {
            Wingpanel.Widgets.Switch tb_switch = new Wingpanel.Widgets.Switch ("Turbo Boost", settings.get_boolean("turbo-boost"));
            settings.bind("turbo-boost", tb_switch, "active", GLib.SettingsBindFlags.DEFAULT);
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
