# FASTAPI routes
#
# In the routes.py file, we define the routes for the FASTAPI application.

# Path: src/routes.py

from base64 import b64encode
from copy import deepcopy

import aiofiles
import anyio
from comfy_catapult.api_client import ComfyAPIClient
from comfy_catapult.catapult import ComfyCatapult
from comfy_catapult.remote_file_api_comfy import ComfySchemeRemoteFileAPI
from fastapi import APIRouter
from fastapi import HTTPException
from fastapi import Request
from slugify import slugify

from .api_schema import SimpleWorkflowRequest
from .api_schema import SimpleWorkflowResponse
from .settings import Settings
from .workflow_templates import WorkflowTemplates
from .workflows.simple_worfklow import ExecuteSimpleWorkflow
from .workflows.simple_worfklow import SimpleWorkflowInfo


router = APIRouter()


@router.get("/")
async def read_root():
  return {"Hello": "World"}


@router.post("/simple-workflow")
async def post_simple_workflow(request: Request, inputs: SimpleWorkflowRequest
                               ) -> SimpleWorkflowResponse:
  settings: Settings = request.app.state.settings

  if slugify(inputs.job_id) != inputs.job_id:
    raise HTTPException(
        status_code=400,
        detail=
        f"Invalid job_id {repr(inputs.job_id)} Must be slugified. Got {slugify(inputs.job_id)}."
    )
  # TODO: For security purposes, we should make this name a bit more
  # complicated, so that collisions are impossible.
  job_id = inputs.job_id

  if inputs.steps > settings.MAX_STEPS:
    raise HTTPException(
        status_code=400,
        detail=f"Too many steps. {inputs.steps} > {settings.MAX_STEPS}")

  async with ComfyAPIClient(
      comfy_api_url=settings.COMFY_API_URL) as comfy_client:
    async with ComfyCatapult(
        comfy_client=comfy_client,
        debug_path=anyio.Path(settings.CATAPULT_DEBUG_PATH),
    ) as comfy_catapult:
      comfy_catapult_debug_path = anyio.Path(settings.CATAPULT_DEBUG_PATH)
      # All the workflows this API will serve.
      workflow_templates: WorkflowTemplates = request.app.state.workflow_templates
      workflow_template_dict: dict = workflow_templates.simple_workflow

      async with aiofiles.tempfile.TemporaryDirectory() as tmpdir:

        job_info = SimpleWorkflowInfo(
            comfy_api_url=settings.COMFY_API_URL,
            comfy_catapult=comfy_catapult,
            remote=ComfySchemeRemoteFileAPI(
                comfy_api_urls=[settings.COMFY_API_URL], overwrite=False),
            job_id=job_id,
            job_debug_path=comfy_catapult_debug_path / job_id,
            workflow_template_dict=workflow_template_dict,
            prepared_workflow_dict=deepcopy(workflow_template_dict),
            debug_save_prepared_workflow=settings.DEBUG_SAVE_PREPARED_WORKFLOW,
            job_history_dict=None,
            important=[],
            params=inputs,
            output_path=anyio.Path(tmpdir) / 'output.png')
        await ExecuteSimpleWorkflow(job_info=job_info)

        async with aiofiles.open(job_info.output_path, "rb") as f:
          image_bytes = await f.read()
          image_b64 = b64encode(image_bytes).decode("utf-8")
          return SimpleWorkflowResponse(job_id=job_id, output_b64=image_b64)
