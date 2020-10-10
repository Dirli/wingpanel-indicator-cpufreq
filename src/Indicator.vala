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

public class CPUfreq.Indicator : Wingpanel.Indicator {
    private Widgets.PanelWidget? cpu_freq = null;
    private Widgets.PopoverWidget? main_widget = null;
    private uint timeout_id;

    private GLib.Settings settings;

    public Indicator () {
        Object (code_name: "cpufreq-indicator");

        settings = new GLib.Settings ("io.elementary.desktop.wingpanel.cpufreq");
        on_settings_change ("turbo-boost");
        on_settings_change ("governor");
        on_settings_change ("pstate-max");
        on_settings_change ("pstate-min");
        settings.changed.connect (on_settings_change);

        this.visible = Utils.can_manage ();
    }

    protected void on_settings_change (string key) {
        switch (key) {
            case "turbo-boost":
                Services.FreqManager.set_turbo_boost (settings.get_boolean ("turbo-boost"));
                break;
            case "governor":
                Services.FreqManager.set_governor (settings.get_string ("governor"));
                break;
            case "pstate-max":
                Services.FreqManager.set_freq_scaling ("max", settings.get_double ("pstate-max"));
                break;
            case "pstate-min":
                Services.FreqManager.set_freq_scaling ("min", settings.get_double ("pstate-min"));
                break;
        }
        return;
    }

    public override Gtk.Widget get_display_widget () {
        if (cpu_freq == null) {
            cpu_freq = new Widgets.PanelWidget ();
            if (update ()) {
                if (timeout_id > 0) {
                    GLib.Source.remove (timeout_id);
                }

                timeout_id = GLib.Timeout.add (2000, update);
            }
        }

        return cpu_freq;
    }

    public override Gtk.Widget? get_widget () {
        if (main_widget == null) {
            main_widget = new Widgets.PopoverWidget (settings);
        }

        return main_widget;
    }

    public unowned bool update () {
        double cur_freq = Utils.get_cur_frequency ();
        cpu_freq.add_label (cur_freq);

        return cur_freq != 0;
    }

    public override void opened () {}

    public override void closed () {}
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating CPUFreq Indicator");
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new CPUfreq.Indicator ();
    return indicator;
}
