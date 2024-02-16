from pydantic import BaseModel


class Lora(BaseModel):
  name: str
  """The name of the lora."""
  strength: float


class SimpleWorkflowRequest(BaseModel):
  job_id: str
  """The job_id of the workflow."""
  positive_prompt: str
  """The postive prompt."""
  negative_prompt: str
  """The negative prompt."""
  ckpt_name: str
  """The model."""
  # TODO: This should be a list.
  lora: Lora
  """List of LoRas to apply to model."""

  hires: bool
  """High resolution toggle."""

  seed: int
  """The seed value."""

  cfg: float
  """The Stable Diffusion cfg value."""
  denoise: float
  """The Stable Diffusion denoise value."""

  steps: int
  """The number of Stable Diffusion steps."""

  width: int
  """The width of the image."""
  height: int
  """The height of the image."""


class SimpleWorkflowResponse(BaseModel):
  job_id: str
  """The job_id of the workflow."""
  output_b64: str
  """The base64 encoded output of the workflow."""
