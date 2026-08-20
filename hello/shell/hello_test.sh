#!/usr/bin/env bash
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

# Runs hello.sh and verifies its greeting output.
set -o errexit -o nounset -o pipefail

hello="$(dirname "${BASH_SOURCE[0]}")/hello.sh"

actual="$("${hello}" Bazel)"
expected="Hello, Bazel!"

if [[ "${actual}" != "${expected}" ]]; then
	printf 'FAIL: got %q, want %q\n' "${actual}" "${expected}" >&2
	exit 1
fi

printf 'PASS\n'
