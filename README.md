<!--

WARNING: This file is auto-generated. Do not edit directly.
SOURCE: `README.md.jinja2`.

-->
# Comfy Catapult FastAPI Demo

This is a demo of how to use the ComfyUI to serve workflows to public facing
users using the ComfyUI API, Comfy Catapult, your workflows, and FastAPI.

See:
[github.com/realazthat/comfy-catapult](https://github.com/realazthat/comfy-catapult).

```
ComfyUI API Endpoint <|   <=  Comfy Catapult <=>  FastAPI server <| <=      Public users
                     <|                                          <|
                     <|          Your python program             <|      Your Webui/JS frontend
                     <|                                          <|
                     <|            Your workflows                <|
                     <|                                          <|
```

## Running the server with docker

```bash

docker run -p 59090:80 realazthat/comfy-catapult-fastapi-demo:latest

# Now navigate to http://localhost:59090/docs, and you should see the FastAPI
# documentation for the exposed workflow.

# Navigate to http://localhost:59090/static/demo an example website that might
# use this API.


```

## Running the server directly

```bash
HOSTNAME="0.0.0.0"
PORT=59091
python -m src.main

# Navigate to http://localhost:59091/docs, and you should see the FastAPI
# documentation for the exposed workflow.

# Navigate to http://localhost:59091/static/demo an example website that might
# use this API.
```

## To add workflows

## For contributors

### Building docker image

### Release instructions
