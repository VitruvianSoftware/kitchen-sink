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

"""py_test wrapper that runs pytest as the main and wires in shared config.

Every py_test routes through this wrapper, so we attach the repo-root
pyproject.toml as data here. That puts pytest's [tool.pytest.ini_options]
(notably consider_namespace_packages) in the test's runfiles, where pytest
discovers it when collecting tests imported by their full repo-root package path
(e.g. `hello.py.greet`). Without it, pytest treats those leading directories as
non-namespace packages and the import fails during collection.
"""

load("@aspect_rules_py//py:defs.bzl", _py_test = "py_test")

def py_test(name, deps = [], data = [], **kwargs):
    _py_test(
        name = name,
        pytest_main = True,
        deps = deps + ["@pypi//pytest"],
        data = data + ["//:pyproject.toml"],
        **kwargs
    )
