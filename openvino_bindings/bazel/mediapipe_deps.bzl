load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def mediapipe_deps():

    maybe(
        git_repository,
        name = "mediapipe",
        remote = "https://github.com/google/mediapipe.git",
        commit = "e252e5667e2be398dcc4c5d49ca134248e2111c8",
        repo_mapping = {
            "@macos_opencv": "@opencv_mac",
            "@linux_opencv": "@opencv_linux",
            "@windows_opencv": "@opencv_windows",
        }

    )

    maybe(
        http_archive,
        name = "build_bazel_rules_nodejs",
        sha256 = "94070eff79305be05b7699207fbac5d2608054dd53e6109f7d00d923919ff45a",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.8.2/rules_nodejs-5.8.2.tar.gz"],
    )

    maybe(
        http_archive,
        name = "rules_proto_grpc",
        sha256 = "bbe4db93499f5c9414926e46f9e35016999a4e9f6e3522482d3760dc61011070",
        strip_prefix = "rules_proto_grpc-4.2.0",
        urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/archive/4.2.0.tar.gz"],
    )

    #maybe(
    #    http_archive,
    #    name = "google_toolbox_for_mac",
    #    url = "https://github.com/google/google-toolbox-for-mac/archive/v2.2.1.zip",
    #    sha256 = "e3ac053813c989a88703556df4dc4466e424e30d32108433ed6beaec76ba4fdc",
    #    strip_prefix = "google-toolbox-for-mac-2.2.1",
    #    build_file = "@mediapipe//third_party:google_toolbox_for_mac.BUILD",
    #)

    ## gflags needed by glog
    #maybe(
    #    http_archive,
    #    name = "com_github_gflags_gflags",
    #    strip_prefix = "gflags-2.2.2",
    #    sha256 = "19713a36c9f32b33df59d1c79b4958434cb005b5b47dc5400a7a4b078111d9b5",
    #    url = "https://github.com/gflags/gflags/archive/v2.2.2.zip",
    #)

    maybe(
        http_archive,
        name = "zlib",
        build_file = "@mediapipe//third_party:zlib.BUILD",
        sha256 = "b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30",
        strip_prefix = "zlib-1.2.13",
        url = "http://zlib.net/fossils/zlib-1.2.13.tar.gz",
        patches = [
            "@mediapipe//third_party:zlib.diff",
        ],
        patch_args = [
            "-p1",
        ],
    )



    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "87407cd28e7a9c95d9f61a098a53cf031109d451a7763e7dd1253abf8b4df422",
        strip_prefix = "protobuf-3.19.1",
        urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.19.1.tar.gz"],
        patches = [
            "@mediapipe//third_party:com_google_protobuf_fixes.diff"
        ],
        patch_args = [
            "-p1",
        ],
    )

    # 2020-08-21
    maybe(
        http_archive,
        name = "com_github_glog_glog",
        strip_prefix = "glog-0.6.0",
        sha256 = "8a83bf982f37bb70825df71a9709fa90ea9f4447fb3c099e1d720a439d88bad6",
        urls = [
            "https://github.com/google/glog/archive/v0.6.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "com_github_glog_glog_no_gflags",
        strip_prefix = "glog-0.6.0",
        sha256 = "8a83bf982f37bb70825df71a9709fa90ea9f4447fb3c099e1d720a439d88bad6",
        build_file = "@//third_party:glog_no_gflags.BUILD",
        urls = [
            "https://github.com/google/glog/archive/v0.6.0.tar.gz",
        ],
        patches = [
            "@mediapipe//third_party:com_github_glog_glog.diff",
        ],
        patch_args = [
            "-p1",
        ],
    )

    maybe(
        http_archive,
        name = "com_github_glog_glog_windows",
        strip_prefix = "glog-3a0d4d22c5ae0b9a2216988411cfa6bf860cc372",
        sha256 = "170d08f80210b82d95563f4723a15095eff1aad1863000e8eeb569c96a98fefb",
        urls = [
        "https://github.com/google/glog/archive/3a0d4d22c5ae0b9a2216988411cfa6bf860cc372.zip",
        ],
        patches = [
            "@mediapipe//third_party:com_github_glog_glog.diff",
            "@mediapipe//third_party:com_github_glog_glog_windows_patch.diff",
        ],
        patch_args = [
            "-p1",
        ],
    )

    maybe(
        http_archive,
        name = "com_google_absl",
        urls = ["https://github.com/abseil/abseil-cpp/archive//9687a8ea750bfcddf790372093245a1d041b21a3.tar.gz"],
        patches = [
            "@mediapipe//third_party:com_google_absl_windows_patch.diff"
        ],
        patch_args = [
            "-p1",
        ],
        strip_prefix = "abseil-cpp-9687a8ea750bfcddf790372093245a1d041b21a3",
        sha256 = "f841f78243f179326f2a80b719f2887c38fe226d288ecdc46e2aa091e6aa43bc",
    )

    # TensorFlow repo should always go after the other external dependencies.
    # TF on 2024-07-18.
    _TENSORFLOW_GIT_COMMIT = "117a62ac439ed87eb26f67208be60e01c21960de"
    # curl -L https://github.com/tensorflow/tensorflow/archive/117a62ac439ed87eb26f67208be60e01c21960de.tar.gz | shasum -a 256
    _TENSORFLOW_SHA256 = "2a1e56f9f83f99e2b9d01a184bc6f409209b36c98fb94b6d5db3f0ab20ec33f2"
    maybe(
        http_archive,
        name = "org_tensorflow",
        urls = [
        "https://github.com/tensorflow/tensorflow/archive/%s.tar.gz" % _TENSORFLOW_GIT_COMMIT,
        ],
        patches = [
            "@mediapipe//third_party:org_tensorflow_system_python.diff",
            # Diff is generated with a script, don't update it manually.
            "@mediapipe//third_party:org_tensorflow_custom_ops.diff",
            # Works around Bazel issue with objc_library.
            # See https://github.com/bazelbuild/bazel/issues/19912
            "@mediapipe//third_party:org_tensorflow_objc_build_fixes.diff",
        ],
        patch_args = [
            "-p1",
        ],
        strip_prefix = "tensorflow-%s" % _TENSORFLOW_GIT_COMMIT,
        sha256 = _TENSORFLOW_SHA256,
    )
