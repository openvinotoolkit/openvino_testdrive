load("@rules_pkg//pkg:tar.bzl", "pkg_tar")

pkg_tar(
    name = "windows_bindings",
    srcs = ["//src:windows_bindings.dll"],
    include_runfiles = True,
)

pkg_tar(
    name = "macos_bindings",
    srcs = ["//src:macos_bindings"],
    include_runfiles = True,
    extension = "tgz",
)

pkg_tar(
    name = "linux_bindings",
    srcs = ["//src:linux_bindings"],
    include_runfiles = True,
    extension = "tgz",
)
