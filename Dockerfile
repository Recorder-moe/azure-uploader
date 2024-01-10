# syntax=docker/dockerfile:1
ARG UID=1001

FROM alpine:3 as final

ARG UID

RUN install -d -m 774 -o $UID -g 0 /app
WORKDIR /app

# Use dumb-init to handle signals
RUN apk add --no-cache dumb-init \
    # Our script uses these
    openssl curl file

# Copy the shell script into the container
COPY --chown=$UID:0 --chmod=774 \
    azure-uploader.sh .

# Set environment variables
ENV STORAGE_ACCOUNT_NAME=
ENV STORAGE_ACCOUNT_KEY=
ENV CONTAINER_NAME=
ENV DESTINATION_DIRECTORY=
ENV REMOVE_SUCCESS_FILES=true

USER $UID
VOLUME [ "/sharedvolume" ]

ENTRYPOINT [ "dumb-init", "--", "./azure-uploader.sh" ]