# syntax=docker/dockerfile:1
ARG UID=1001
ARG VERSION=EDGE
ARG RELEASE=0

FROM alpine:3 as final

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Create user
ARG UID
RUN adduser -g "" -D $UID -u $UID -G root

# Create directories with correct permissions
RUN install -d -m 775 -o $UID -g 0 /app && \
    install -d -m 775 -o $UID -g 0 /licenses

# Copy licenses (OpenShift Policy)
COPY --link --chown=$UID:0 --chmod=775 LICENSE /licenses/LICENSE

RUN --mount=type=cache,id=apk-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apk \
    --mount=from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1,source=/dumb-init,target=/dumb-init,rw \
    apk update && apk add -u \
    openssl curl file

# dumb-init
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /dumb-init /usr/bin/

# Copy the shell script into the container
COPY --chown=$UID:0 --chmod=775 azure-uploader.sh /app/

# Set environment variables
ENV STORAGE_ACCOUNT_NAME=
ENV STORAGE_ACCOUNT_KEY=
ENV CONTAINER_NAME=
ENV DESTINATION_DIRECTORY=
ENV REMOVE_SUCCESS_FILES=true

WORKDIR /app

VOLUME [ "/sharedvolume" ]

USER $UID

STOPSIGNAL SIGINT

ENTRYPOINT [ "dumb-init", "--", "./azure-uploader.sh" ]

ARG VERSION
ARG RELEASE
LABEL name="Recorder-moe/azure-uploader" \
    # Authors for Recorder-moe
    vendor="Recorder-moe" \
    # Maintainer for this docker image
    maintainer="jim60105" \
    # Dockerfile source repository
    url="https://github.com/Recorder-moe/azure-uploader" \
    version=${VERSION} \
    # This should be a number, incremented with each change
    release=${RELEASE} \
    io.k8s.display-name="azure-uploader" \
    summary="Recorder-moe: A feature-rich command-line audio/video downloader." \
    description="This script automates the process of uploading *.mp4 files from a local folder to Azure Blob Storage and delete them from the local folder. For more information about this tool, please visit the following website: https://github.com/Recorder-moe/azure-uploader"
