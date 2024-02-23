# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
#
# The Comfy Catapult project requires contributions made to this file be licensed
# under the MIT license or a compatible open source license. See LICENSE.md for
# the license text.

from pydantic import BaseModel, Field


class Lora(BaseModel):
  name: str
  """The name of the lora."""
  strength: float


class SimpleWorkflowRequest(BaseModel):
  job_id: str = Field(..., description='The job_id of the workflow.')
  positive_prompt: str = Field(..., description='The postive prompt.')
  negative_prompt: str = Field(..., description='The negative prompt.')
  ckpt_name: str = Field(..., description='The checkpoint name.')
  # TODO: This should be a list.
  lora: Lora = Field(..., description='List of LoRas to apply to model.')
  hires: bool = Field(..., description='High resolution toggle.')
  seed: int = Field(..., description='The seed value.')
  cfg: float = Field(..., description='The Stable Diffusion cfg value.')
  denoise: float = Field(..., description='The Stable Diffusion denoise value.')
  steps: int = Field(..., description='The number of Stable Diffusion steps.')
  width: int = Field(..., description='The width of the image.')
  height: int = Field(..., description='The height of the image.')


class SimpleWorkflowResponse(BaseModel):
  job_id: str = Field(..., description='The job_id of the workflow.')
  output_b64: str = Field(
      ..., description='The base64 encoded output of the workflow.')
