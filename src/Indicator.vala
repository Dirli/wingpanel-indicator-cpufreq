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

    public class Indicator : Wingpanel.Indicator {

        private Widgets.PanelWidget? cpu_freq = null;
        private Widgets.PopoverWidget? main_widget = null;
        private uint timeout_id = 0;

        public bool intel_pstate {
            get; construct set;
        }

        private GLib.Settings settings;

        public Indicator () {
            Object (code_name: "cpufreq-indicator",
                    intel_pstate: GLib.FileUtils.test (CPU_PATH + "intel_pstate", FileTest.IS_DIR));

            settings = new GLib.Settings ("io.elementary.desktop.wingpanel.cpufreq");
            on_changed_governor ();

            if (intel_pstate) {
                on_changed_tb ();
                on_changed_max ();
                on_changed_min ();

                settings.changed["turbo-boost"].connect (on_changed_tb);
                settings.changed["pstate-max"].connect (on_changed_max);
                settings.changed["pstate-min"].connect (on_changed_min);
            }

            settings.changed["governor"].connect (on_changed_governor);

            visible = Utils.can_manage ();
        }

        public override Gtk.Widget get_display_widget () {
            if (cpu_freq == null) {
                cpu_freq = new Widgets.PanelWidget ();
                if (visible && update ()) {
                    timeout_id = GLib.Timeout.add (2000, update);
                }
            }

            return cpu_freq;
        }

        public override Gtk.Widget? get_widget () {
            if (main_widget == null) {
                if (visible) {
                    main_widget = new Widgets.PopoverWidget (settings, intel_pstate);
                } else {
                    return null;
                }
            }

            return main_widget;
        }

        private void on_changed_tb () {
            Utils.set_turbo_boost (settings.get_boolean ("turbo-boost"));
        }

        private void on_changed_max () {
            Utils.set_freq_scaling ("max", settings.get_double ("pstate-max"));
        }

        private void on_changed_min () {
            Utils.set_freq_scaling ("min", settings.get_double ("pstate-min"));
        }

        protected void on_changed_governor () {
            Utils.set_governor (settings.get_string ("governor"));
        }

        public unowned bool update () {
            double cur_freq = Utils.get_cur_frequency ();
            cpu_freq.add_label (cur_freq);

            return cur_freq != 0;
        }

        public override void opened () {}

        public override void closed () {}
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating CPUFreq Indicator");
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new CPUfreq.Indicator ();
    return indicator;
}
