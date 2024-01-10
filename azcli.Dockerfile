# syntax=docker/dockerfile:1
ARG UID=1001
ARG BUILD_VERSION=2.56.0

FROM python:3.11-alpine as build

ARG BUILD_VERSION

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install build dependencies
RUN apk add --no-cache build-base libffi-dev

WORKDIR /app

# Install under /root/.local
ENV PIP_USER="true"
ARG PIP_NO_WARN_SCRIPT_LOCATION=0
ARG PIP_ROOT_USER_ACTION="ignore"

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    pip install azure-cli==$BUILD_VERSION && \
    # Cleanup
    find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ;

FROM python:3.11-alpine as final

ARG UID

# Use dumb-init to handle signals
RUN apk add --no-cache dumb-init

# Create user
RUN addgroup -g $UID $UID && \
    adduser -g "" -D $UID -u $UID -G $UID

# Copy dist and support arbitrary user ids (OpenShift best practice)
# https://docs.openshift.com/container-platform/4.14/openshift_images/create-images.html#use-uid_create-images
COPY --chown=$UID:0 --chmod=774 \
    --from=build /root/.local /home/$UID/.local
ENV PATH="/home/$UID/.local/bin:$PATH"

# Azure CLI needs this directory writable
RUN install -d -m 774 -o $UID -g 0 /.azure

USER $UID
WORKDIR /

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "az" ]
CMD [ "interactive" ]

# Note: Override the entrypoint to utilize with the shell
# ENTRYPOINT [ "dumb-init", "--", "bash" ]