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

## LICENSE

> [!CAUTION]
> A GPLv3 licensed Dockerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute a image that uses code from this repository.
> - Or **distribute a image based on this image**. (`FROM ghcr.io/recorder-moe/azure-uploader` in your Dockerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.

<img src="https://github.com/jim60105/Dockerfile-template/assets/16995691/ea799bbb-d531-4514-baee-13874322ec48" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
