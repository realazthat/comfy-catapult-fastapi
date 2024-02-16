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
COPY scripts/ci/docker/install-docker-prereqs-inside.sh "/project/scripts/ci/docker/install-docker-prereqs-inside.sh"
# Give execution rights on the script.
# Run the script to install the prerequisites.
# Change the owner of the project to the user.
RUN apk add --no-cache bash \
    && addgroup -S "${TARGET_GROUP}" \
    && adduser -S "${TARGET_USER}" -G "${TARGET_GROUP}" -s /bin/bash \
    && chown -R "${TARGET_USER}:${TARGET_GROUP}" "/home/${TARGET_USER}/" \
    && chmod a+x "/project/scripts/ci/docker/install-docker-prereqs-inside.sh" \
    && bash "/project/scripts/ci/docker/install-docker-prereqs-inside.sh" \

################################################################################
USER "${TARGET_USER}"
WORKDIR "/home/${TARGET_USER}/"

CMD ["bash"]
