from typing import List

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
  PROJECT_NAME: str = "ComfyUI Catapult Demo App"
  DESCRIPTION: str = "A demo for the ComfyUI Catapult library."
  DEBUG: bool = True
  HOSTNAME: str
  PORT: int = 50080
  VERSION: str = "0.1.0"
  DOCS_URL: str = "/docs"
  REDOC_URL: str = "/redoc"
  ALLOWED_HOSTS: List[str] = ["*"]
  COMFY_API_URL: str
  CATAPULT_DEBUG_PATH: str = ".deleteme/debug"
  CATAPULT_DEBUG_SAVE_ALL: bool = True
  DEBUG_SAVE_PREPARED_WORKFLOW: bool = True
  SIMPLE_WORKFLOW_JSON_API_PATH: str = "assets/simple_workflow_api.json"
  MAX_STEPS: int = 80
