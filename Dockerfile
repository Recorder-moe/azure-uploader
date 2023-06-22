FROM mcr.microsoft.com/azure-cli

# Set the working directory
WORKDIR /app

# Copy the bash script into the container
COPY azure-uploader.sh .

# Set the script as executable
RUN chmod +x azure-uploader.sh

# Set environment variables
ENV STORAGE_ACCOUNT_NAME=""
ENV STORAGE_ACCOUNT_KEY=""
ENV CONTAINER_NAME=""
ENV DESTINATION_DIRECTORY=""

VOLUME [ "/sharedvolume" ]

# Execute the script with provided settings
ENTRYPOINT ["./azure-uploader.sh"]
