# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
#
# The Comfy Catapult project requires contributions made to this file be licensed
# under the MIT license or a compatible open source license. See LICENSE.md for
# the license text.

from typing import NamedTuple


class WorkflowTemplates(NamedTuple):
  """This should hold all the workflows this API will serve."""
  simple_workflow: dict
