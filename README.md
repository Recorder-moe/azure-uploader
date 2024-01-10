# Azure Blob Storage Uploader

This script automates the process of uploading *.mp4 files from a local folder to Azure Blob Storage **and delete them** from the local folder. It utilizes the Azure CLI to perform the upload.

## Getting Started

1. Pull the Docker image from the registry:

   ```bash
   docker pull ghcr.io/recorder-moe/azure-uploader:latest
   ```

1. Run the Docker container, providing the search filter as a command:

   ```bash
   docker run -e STORAGE_ACCOUNT_NAME="your-storage-account-name" \
              -e STORAGE_ACCOUNT_KEY="your-storage-account-key" \
              -e CONTAINER_NAME="your-container-name" \
              -e DESTINATION_DIRECTORY="your/destination/directory" \
              -e REMOVE_SUCCESS_FILES="true" \
              ghcr.io/recorder-moe/azure-uploader:latest video
   ```

   Replace `your-container-name`, `your/destination/directory`, `your-storage-account-name`, and `your-storage-account-key` with your desired values. The `video` argument is the search filter for the *.mp4 files to upload.

   The environment variables:
   - `STORAGE_ACCOUNT_NAME`: The name of the Azure Storage account.
   - `STORAGE_ACCOUNT_KEY`: The access key for the Azure Storage account.
   - `CONTAINER_NAME`: The name of the Azure Blob Storage container.
   - `DESTINATION_DIRECTORY`: The destination directory in the Azure Blob Storage container.
   - `REMOVE_SUCCESS_FILES`: Remove the files that have been uploaded successfully. The default value is `true`. If you want to keep the files, set it to `false`.

1. The script will upload the matching files to Azure Blob Storage and **delete them** from the local folder.

> **Note**\
> Take a look at the [docker-compose.yml](docker-compose.yml) file for an example of how to run the container with Docker Compose.

## Notes

- This script is written in sh syntax and has been tested in docker image only.
- I am a novice in sh script, and [I used ChatGPT to create it, including this README file](https://chat.openai.com/share/c694c95d-21ed-4d04-afb4-b650e0c43688).😎

## License

This project is licensed under the [MIT License](LICENSE).
