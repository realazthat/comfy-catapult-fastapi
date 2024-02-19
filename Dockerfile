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

COPY scripts/ci/docker/install-docker-prereqs-inside.sh "/install-docker-prereqs-inside.sh"

# Give execution rights on the script.
# Run the script to install the prerequisites.
RUN apk add --no-cache bash=5.2.21-r0 \
    && addgroup -S "${TARGET_GROUP}" \
    && adduser -S "${TARGET_USER}" -G "${TARGET_GROUP}" -s /bin/bash \
    && chown -R "${TARGET_USER}:${TARGET_GROUP}" "/home/${TARGET_USER}/" \
    && chmod a+x "/install-docker-prereqs-inside.sh" \
    && bash "/install-docker-prereqs-inside.sh"

################################################################################
# Copy the entire project to the container.
COPY . "/home/${TARGET_USER}/project"
# Change owner and permissions of project
USER root
RUN chown -R "${TARGET_USER}:${TARGET_GROUP}" "/home/${TARGET_USER}/project"
################################################################################
USER "${TARGET_USER}"
WORKDIR "/home/${TARGET_USER}/project"
RUN bash scripts/install.sh
################################################################################
ENV SERVING_PORT=${SERVING_PORT}
EXPOSE ${SERVING_PORT}
# Command to run when starting the container
CMD /bin/bash -c "SERVING_PORT=${SERVING_PORT} scripts/serve.sh"
