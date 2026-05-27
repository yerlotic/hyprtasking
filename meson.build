project('hyprtasking', 'cpp',
  version: '0.1',
  default_options: ['buildtype=debug'],
  meson_version: '>= 1.1'
)

cpp_compiler = meson.get_compiler('cpp')
if cpp_compiler.has_argument('-std=c++23')
  add_global_arguments('-std=c++23', language: 'cpp')
elif cpp_compiler.has_argument('-std=c++2b')
  add_global_arguments('-std=c++2b', language: 'cpp')
else
  error('Could not configure current C++ compiler (' + cpp_compiler.get_id() + ' ' + cpp_compiler.version() + ') with required C++ standard (C++23)')
endif

add_project_arguments(
  [
    '-Wno-narrowing', '-shared', '-fPIC', '--no-gnu-unique'
  ],
  language: 'cpp')

globber = run_command('find', '.', '-name', '*.cpp', check: true)
src = globber.stdout().strip().split('\n')

incdir = []
dependencies = [
  dependency('pixman-1'),
  dependency('libdrm'),
  dependency('pangocairo'),
  dependency('libinput'),
  dependency('libudev'),
  dependency('wayland-server'),
  dependency('xkbcommon'),
  dependency('lua5.5'),
]

if get_option('local_include')
  incdir += include_directories('include')
  incdir += include_directories('include/hyprland/protocols')
else
  hyprland_dep = dependency('hyprland')
  dependencies += hyprland_dep

  hyprland_cflags = run_command(
    'pkg-config',
    '--cflags-only-I',
    'hyprland',
    check: true
  ).stdout().strip().split()

  foreach flag : hyprland_cflags
    if flag.startswith('-I')
      incdir += include_directories(flag.substring(2))
    endif
  endforeach
endif

shared_module(meson.project_name(), src,
  dependencies: dependencies,
  install: true,
  include_directories: incdir
)
