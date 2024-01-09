# syntax=docker/dockerfile:1
ARG UID=1001

FROM mcr.microsoft.com/azure-cli:latest as final

ARG UID

RUN install -d -m 774 -o $UID -g 0 /app && \
    install -d -m 774 -o $UID -g 0 /.azure
WORKDIR /app

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /bin/dumb-init 
RUN chmod +x /bin/dumb-init

# Copy the bash script into the container
COPY --chown=$UID:0 --chmod=774 \
    azure-uploader.sh .

# Set environment variables
ENV STORAGE_ACCOUNT_NAME=""
ENV STORAGE_ACCOUNT_KEY=""
ENV CONTAINER_NAME=""
ENV DESTINATION_DIRECTORY=""

USER $UID
VOLUME [ "/sharedvolume" ]

ENTRYPOINT [ "dumb-init", "--", "./azure-uploader.sh" ]