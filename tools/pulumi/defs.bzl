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

"""Bazel macro that wraps a Pulumi Go project behind `bazel run` targets.

Developers should never need to memorize the `pulumi` CLI. Instead of running
`pulumi up` from the project dir, they run:

    bazel run //infrastructure/pulumi/repo_config:up
    bazel run //infrastructure/pulumi/repo_config:preview -- --diff
    bazel run //infrastructure/pulumi/repo_config:config -- set repoOwner my-org
    bazel run //infrastructure/pulumi/repo_config:setup        # guided bootstrap

Each target is a thin `sh_binary` whose wrapper (`//tools/pulumi:pulumi_cmd.sh`
or `:pulumi_setup.sh`) cd's to the project dir under $BUILD_WORKSPACE_DIRECTORY
and execs the real `pulumi` CLI (Pulumi compiles/runs the Go program itself —
Bazel only launches it). Extra args after `--` are forwarded to pulumi verbatim.
"""

load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

# pulumi subcommands exposed as run targets, each baked into the wrapper via args.
_SUBCOMMANDS = [
    "preview",
    "up",
    "destroy",
    "refresh",
    "config",
]

def pulumi_project(name, dir, visibility = ["//visibility:public"]):
    """Generate `bazel run` wrappers for a Pulumi Go project.

    Args:
      name: label prefix for the generated targets (purely a unique handle; the
        developer-facing target names are fixed — `preview`, `up`, `destroy`,
        `refresh`, `config`, `setup` — in the calling package).
      dir: workspace-relative path to the Pulumi project directory (the dir that
        holds the project's `go.mod` and `Pulumi.yaml`), e.g.
        "infrastructure/pulumi/repo_config".
      visibility: visibility for the generated targets.
    """
    for subcmd in _SUBCOMMANDS:
        sh_binary(
            name = subcmd,
            srcs = ["//tools/pulumi:pulumi_cmd.sh"],
            args = [dir, subcmd],
            visibility = visibility,
        )

    # Guided bootstrap helper (prereq checks, login, stack select, hints).
    sh_binary(
        name = "setup",
        srcs = ["//tools/pulumi:pulumi_setup.sh"],
        args = [dir],
        visibility = visibility,
    )

def pulumi_create_app(name = "create-app", visibility = ["//visibility:public"]):
    """Declare the one-time GitHub App Manifest-flow bootstrap target.

    Unlike `pulumi_project`, this is NOT per Pulumi project — it is a single
    repo-level helper run ONCE per GitHub org to create a shared App and set
    org-level credentials (`bazel run //tools/pulumi:create-app`). Call it from
    the `//tools/pulumi` package's BUILD file.

    Args:
      name: target name (the developer-facing label is `create-app`).
      visibility: visibility for the generated target.
    """
    sh_binary(
        name = name,
        srcs = ["create_app.sh"],
        visibility = visibility,
    )
