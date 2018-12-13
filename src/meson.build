vala_compiler = meson.get_compiler('vala')

shared_library(
    meson.project_name(),
    'Indicator.vala',
    'Utils.vala',
    'Services/FreqManager.vala',
    'Services/Settings.vala',
    'Widgets/PanelWidget.vala',
    'Widgets/PopoverWidget.vala',
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_gobject,
        dep_polkit,
        dep_granie,
        wingpanel_dep,
        vala_compiler.find_library('posix'),
    ],
    install: true,
    install_dir: wingpanel_dep.get_pkgconfig_variable('indicatorsdir'),
)
