# Wingpanel CPU frequency indicator
wingpanel-indicator-cpufreq is able to adjust the Intel p-state driver (Sandy Bridge and newer)


## Building and Installation

You'll need the following dependencies:

    libgranite-dev
    libpolkit-gobject-1-dev
    libglib2.0-dev
    libgtk-3-dev
    libwingpanel-2.0-dev
    policykit-1
    meson
    valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
