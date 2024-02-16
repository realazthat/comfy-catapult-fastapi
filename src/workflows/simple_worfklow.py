from dataclasses import dataclass
import json
from typing import List

import aiofiles
from anyio import Path
from comfy_catapult.catapult_base import ComfyCatapultBase
from comfy_catapult.comfy_schema import APIHistoryEntry
from comfy_catapult.comfy_schema import APIWorkflow
from comfy_catapult.comfy_schema import NodeID
from comfy_catapult.comfy_utils import DownloadPreviewImage
from comfy_catapult.comfy_utils import GetNodeByTitle
from comfy_catapult.remote_file_api_base import RemoteFileAPIBase

from ..api_schema import SimpleWorkflowRequest


@dataclass
class SimpleWorkflowInfo:
  comfy_api_url: str
  comfy_catapult: ComfyCatapultBase
  remote: RemoteFileAPIBase

  workflow_template_dict: dict
  prepared_workflow_dict: dict
  debug_save_prepared_workflow: bool
  job_debug_path: Path
  job_id: str

  job_history_dict: dict | None

  important: List[NodeID]

  params: SimpleWorkflowRequest
  output_path: Path


async def ExecuteSimpleWorkflow(*, job_info: SimpleWorkflowInfo):

  await PrepareWorkflow(job_info=job_info)

  if job_info.debug_save_prepared_workflow:
    prepared_workflow_path = job_info.job_debug_path / "prepared_workflow.json"
    await prepared_workflow_path.parent.mkdir(parents=True, exist_ok=True)
    async with aiofiles.open(prepared_workflow_path, "w") as f:
      await f.write(json.dumps(job_info.prepared_workflow_dict, indent=2))
      print(f"Saved prepared_workflow.json to {prepared_workflow_path}")

  job_info.job_history_dict = await job_info.comfy_catapult.Catapult(
      important=job_info.important,
      job_debug_path=job_info.job_debug_path,
      job_id=job_info.job_id,
      prepared_workflow=job_info.prepared_workflow_dict)

  await DownloadWorkflow(job_info=job_info)


async def PrepareWorkflow(*, job_info: SimpleWorkflowInfo):
  workflow = APIWorkflow.model_validate(job_info.prepared_workflow_dict)

  ##############################################################################
  _, ckpt_loader = GetNodeByTitle(workflow=workflow, title="Load Checkpoint")
  ckpt_loader.inputs['ckpt_name'] = job_info.params.ckpt_name
  ##############################################################################
  _, positive_prompt = GetNodeByTitle(workflow=workflow, title="PositivePrompt")
  positive_prompt.inputs['text'] = job_info.params.positive_prompt
  _, negative_prompt = GetNodeByTitle(workflow=workflow, title="NegativePrompt")
  negative_prompt.inputs['text'] = job_info.params.negative_prompt
  ##############################################################################
  _, ksampler = GetNodeByTitle(workflow=workflow, title="KSampler")
  ksampler.inputs['cfg'] = job_info.params.cfg
  ksampler.inputs['steps'] = job_info.params.steps
  ksampler.inputs['seed'] = job_info.params.seed
  ksampler.inputs['denoise'] = job_info.params.denoise
  ##############################################################################
  _, lora_loader = GetNodeByTitle(workflow=workflow, title="Load LoRA")
  lora_loader.inputs['lora_name'] = job_info.params.lora.name
  lora_loader.inputs['strength_model'] = job_info.params.lora.strength
  # lora_loader.inputs['strength_clip'] = ?
  ##############################################################################
  _, empty_latent_image = GetNodeByTitle(workflow=workflow,
                                         title="Empty Latent Image")
  empty_latent_image.inputs['width'] = job_info.params.width
  empty_latent_image.inputs['height'] = job_info.params.height

  ##############################################################################
  save_image_id, _ = GetNodeByTitle(workflow=workflow, title="Save Image")
  job_info.important.append(save_image_id)
  ##############################################################################
  job_info.prepared_workflow_dict = workflow.model_dump()


async def DownloadWorkflow(*, job_info: SimpleWorkflowInfo):
  job_history = APIHistoryEntry.model_validate(job_info.job_history_dict)
  workflow = APIWorkflow.model_validate(job_info.prepared_workflow_dict)

  save_image_id, _ = GetNodeByTitle(workflow=workflow, title="Save Image")

  assert job_history.outputs is not None
  print(job_history.outputs[save_image_id].model_dump())
  await DownloadPreviewImage(
      node_id=save_image_id,
      job_history=job_history,
      field_path='images[0]',
      comfy_api_url=job_info.comfy_api_url,
      remote=job_info.remote,
      local_dst_path=job_info.output_path,
  )
