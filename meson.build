project(
    'cpufreq',
    ['c', 'vala'],
    version: '1.1.2',
    license: 'GPL-2.0',
    default_options: [
        'c_std=c11',
    ],
)

gettext_name = meson.project_name() + '-indicator'
i18n = import('i18n')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

wingpanel_dep = dependency('wingpanel-2.0')
dep_gtk3 = dependency('gtk+-3.0', version: '>=3.18')
dep_glib = dependency('glib-2.0', version: '>= 2.46.0')
dep_gobject = dependency('gobject-2.0')
dep_polkit = dependency('polkit-gobject-1')
dep_granie = dependency('granite')

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('meson/meson_post_install.py')
