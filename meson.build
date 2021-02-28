project (
    'cpufreq',
    ['c', 'vala'],
    version: '1.1.3',
)

gettext_name = meson.project_name () + '-indicator'
i18n = import ('i18n')

add_global_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (gettext_name),
    language:'c'
)

wingpanel_dep = dependency ('wingpanel')
dep_gtk3 = dependency ('gtk+-3.0', version: '>=3.18')
dep_glib = dependency ('glib-2.0', version: '>= 2.46.0')
dep_gobject = dependency ('gobject-2.0')
dep_polkit = dependency ('polkit-gobject-1')
dep_granie = dependency ('granite')

shared_library (
    meson.project_name (),
    'src/Indicator.vala',
    'src/Utils.vala',
    'src/Widgets/PanelWidget.vala',
    'src/Widgets/PopoverWidget.vala',
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_gobject,
        dep_polkit,
        dep_granie,
        wingpanel_dep,
        meson.get_compiler ('vala').find_library ('posix'),
    ],
    install: true,
    install_dir: wingpanel_dep.get_pkgconfig_variable ('indicatorsdir'),
)

subdir ('data')
subdir ('po')

meson.add_install_script ('meson/meson_post_install.py')
