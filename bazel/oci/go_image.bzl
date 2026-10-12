# Copyright 2026 MyProject
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"go_image macro for OCI containers"

load("@bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load", "oci_push")
load("@tar.bzl", "tar")

def go_image(name, binary, base = "@distroless_base"):
    tar(
        name = name + "_app_layer",
        srcs = [binary],
        mtree = [
            "./opt/app type=file content=$(execpath {})".format(binary),
        ],
    )
    oci_image(
        name = name,
        base = base,
        tars = [
            name + "_app_layer",
        ],
        entrypoint = [
            "/opt/app",
        ],
    )
    platform_transition_filegroup(
        name = name + "_platform",
        srcs = [name],
        target_platform = select({
            "@platforms//cpu:arm64": "@rules_go//go/toolchain:linux_arm64",
            "@platforms//cpu:x86_64": "@rules_go//go/toolchain:linux_amd64",
        }),
    )
    oci_load(
        name = name + ".load",
        image = name + "_platform",
        repo_tags = [
            native.package_name() + ":latest",
        ],
    )

    # Deliverable: `aspect delivery` builds + pushes every `oci_push` (its query
    # matches the rule kind — see .aspect/config.axl). ttl.sh is an anonymous,
    # ephemeral registry — fine for a demo; point `repository` at your registry.
    oci_push(
        name = name + "_push",
        image = name + "_platform",
        remote_tags = [
            "latest",
        ],
        repository = "ttl.sh/" + native.package_name(),
    )
