# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""This defines a repository rule for configuring the rules' defaults.

For now, this is limited to docker_push, where the default can be
specified as follows:

```python
  === WORKSPACE ===
  load(
    "@io_bazel_rules_docker//docker/contrib:with-defaults.bzl",
    "docker_defaults",
  )
  docker_defaults(
      name = "defaults",
      registry = "us.gcr.io",
      tag = "{BUILD_USER}"
  )

  === BUILD ===
  load("@defaults//:defaults.bzl", "docker_push")
```

Any of "registry", "repository" or "tag" may be given a new default.
"""

def _impl(repository_ctx):
  """Core implementation of docker_default."""

  repository_ctx.file("BUILD", "")

  repository_ctx.file("defaults.bzl", """
load(
  "@io_bazel_rules_docker//docker:push.bzl",
  _docker_push="docker_push"
)

def docker_push(**kwargs):
  if "registry" not in kwargs:
    kwargs["registry"] = "{registry}" or None
  if "repository" not in kwargs:
    kwargs["repository"] = "{repository}" or None
  if "tag" not in kwargs:
    kwargs["tag"] = "{tag}" or None

  _docker_push(**kwargs)
""".format(
  registry=repository_ctx.attr.registry or "",
  repository=repository_ctx.attr.repository or "",
  tag=repository_ctx.attr.tag or "",
))

_docker_defaults = repository_rule(
    attrs = {
        "registry": attr.string(),
        "repository": attr.string(),
        "tag": attr.string(),
    },
    implementation = _impl,
)

def docker_defaults(**kwargs):
  """Creates a version of docker_push with the specified defaults."""
  _docker_defaults(**kwargs)
  
