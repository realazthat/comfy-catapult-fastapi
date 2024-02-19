# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
#
# The Comfy Catapult project requires contributions made to this file be licensed
# under the MIT license or a compatible open source license. See LICENSE.md for
# the license text.

import asyncio
import json
import pathlib
import sys

import anyio
import hypercorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from hypercorn.asyncio import serve
from pydantic import ValidationError
from rich.console import Console

from .routes import router as api_router
from .settings import Settings
from .workflow_templates import WorkflowTemplates


async def initialize_app(settings: Settings):
  app = FastAPI(title=settings.PROJECT_NAME,
                version=settings.VERSION,
                description=settings.DESCRIPTION,
                docs_url=settings.DOCS_URL,
                redoc_url=settings.REDOC_URL,
                debug=settings.DEBUG)
  app.state.settings = settings
  app.state.comfy_catapult_debug_path = anyio.Path(settings.CATAPULT_DEBUG_PATH)
  app.state.workflow_templates = WorkflowTemplates(simple_workflow=json.loads(
      pathlib.Path(settings.SIMPLE_WORKFLOW_JSON_API_PATH).read_text()))

  app.mount('/static', StaticFiles(directory='static'), name='static')

  # Add the routes to the app
  app.include_router(api_router)

  # Add CORS middleware
  app.add_middleware(
      CORSMiddleware,
      allow_origins=settings.ALLOWED_HOSTS,
      allow_credentials=True,
      allow_methods=['*'],
      allow_headers=['*'],
  )
  # Get hostname -I from system
  # hostname = (await anyio.run_process("hostname -I")).stdout.strip().decode()
  # console.print(f"`hostname -I`: {hostname}", style="bold green")
  return app


async def run(*, app: FastAPI, settings: Settings):
  hconfig = hypercorn.config.Config()

  # hostnames = [(await anyio.run_process("hostname -I")).stdout.strip().decode()]

  bind = []
  # for hostname in hostnames:
  bind += [f'{settings.HOSTNAME}:{settings.PORT}']

  hconfig.bind = bind
  hconfig.loglevel = 'debug' if settings.DEBUG else 'warning'

  await serve(app, hconfig)  # type: ignore


console = Console(file=sys.stderr)
try:
  settings = Settings()
except ValidationError as e:
  console.print(e, style='bold red')
  console.print(
      'Note, this usually means you need to specify the missing variable via an environment variable.',
      style='bold yellow')
  sys.exit(1)

app = asyncio.run(initialize_app(settings))
asyncio.run(run(app=app, settings=settings))
