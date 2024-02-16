FROM alpine:3.19.1

ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

ARG TARGET_USER=user
ENV TARGET_USER="${TARGET_USER}"
ARG TARGET_GROUP="${TARGET_USER}"

ARG DEFAULT_SERVING_PORT=80
ENV SERVING_PORT="${DEFAULT_SERVING_PORT}"


################################################################################
USER root
# Copy the entire project to the container.
COPY . "/project"
# Give execution rights on the script.
# Run the script to install the prerequisites.
# Change the owner of the project to the user.
RUN apk add --no-cache bash \
    && addgroup -S "${TARGET_GROUP}" \
    && adduser -S "${TARGET_USER}" -G "${TARGET_GROUP}" -s /bin/bash \
    && chown -R "${TARGET_USER}:${TARGET_GROUP}" "/home/${TARGET_USER}/" \
    && cp -r "/project" "/home/${TARGET_USER}/" \
    && chown -R "${TARGET_USER}:${TARGET_GROUP}" "/home/${TARGET_USER}/project" \
    && cd "/home/${TARGET_USER}/project" \
    && chmod a+x "scripts/ci/docker/install-docker-prereqs-inside.sh" \
    && bash "scripts/ci/docker/install-docker-prereqs-inside.sh" \
    && su - "${TARGET_USER}" -s /bin/sh -c "cd /home/${TARGET_USER}/project && /bin/bash scripts/install-inside-repo.sh"

################################################################################
USER "${TARGET_USER}"
WORKDIR "/home/${TARGET_USER}/project"
################################################################################
ENV SERVING_PORT=${SERVING_PORT}
EXPOSE ${SERVING_PORT}
# Command to run when starting the container
CMD /bin/bash -c "SERVING_PORT=${SERVING_PORT} scripts/serve-inside-repo.sh"


