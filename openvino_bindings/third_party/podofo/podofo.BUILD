load("@rules_foreign_cc//foreign_cc:cmake.bzl", "cmake")

visibility = ["//visibility:public"]

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

cmake(
    name = "podofo_mac",
    build_args = [
        "--verbose",
        "--",  # <- Pass remaining options to the native tool.
        # https://github.com/bazelbuild/rules_foreign_cc/issues/329
        # there is no elegant paralell compilation support
        "VERBOSE=1",
        "-j 4",
    ],
    cache_entries = {
        "CMAKE_FIND_FRAMEWORK": "NEVER",
        "CMAKE_PREFIX_PATH": "/opt/homebrew",
        "Fontconfig_INCLUDE_DIR": "/opt/homebrew/opt/fontconfig/include",
        "OPENSSL_ROOT_DIR": "/opt/homebrew/opt/openssl@3",
        #"PODOFO_BUILD_LIB_ONLY": 'TRUE CACHE BOOL "" FORCE',
        #"DPODOFO_BUILD_STATIC": 'TRUE CACHE BOOL "" FORCE',
    },
    lib_source = ":all_srcs",
    out_shared_libs = ["libpodofo.2.dylib"],
    visibility = ["//visibility:public"]
)
