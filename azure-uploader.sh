#!/bin/sh

# Check if the search filter argument is provided
if [ -z "$1" ]; then
    echo "Please provide a search filter as an argument."
    exit 1
fi

# Set the search filter from the command-line argument
SEARCH_FILTER="$1"

# Check if the container name environment variable is set
if [ -z "$CONTAINER_NAME" ]; then
    echo "Please set the CONTAINER_NAME environment variable."
    exit 1
fi

# Check if the destination directory environment variable is set
if [ -z "$DESTINATION_DIRECTORY" ]; then
    echo "Please set the DESTINATION_DIRECTORY environment variable."
    exit 1
fi

# Check if the storage account name environment variable is set
if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
    echo "Please set the STORAGE_ACCOUNT_NAME environment variable."
    exit 1
fi

# Check if the storage account key environment variable is set
if [ -z "$STORAGE_ACCOUNT_KEY" ]; then
    echo "Please set the STORAGE_ACCOUNT_KEY environment variable."
    exit 1
fi

# Find files matching the search filter and store them in a temporary file
find "/toUpload" -name "*$SEARCH_FILTER*.mp4" >temp.txt

# Check if any matching files were found
if [ ! -s "temp.txt" ]; then
    echo "No matching files found."
    rm temp.txt
    exit 1
fi

echo "Uploading files..."

# Upload files matching the search filter to Azure Blob Storage using the Azure CLI
az storage blob upload-batch --destination "$CONTAINER_NAME" --destination-path "$DESTINATION_DIRECTORY" --account-name "$STORAGE_ACCOUNT_NAME" --account-key "$STORAGE_ACCOUNT_KEY" --type block --source "/toUpload" --pattern "*$SEARCH_FILTER*.mp4"

# Delete the uploaded files
while IFS= read -r file_path; do
    rm "$file_path"
done <temp.txt

# Remove the temporary file
rm temp.txt
