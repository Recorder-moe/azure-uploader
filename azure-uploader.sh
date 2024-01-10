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
find "/sharedvolume" -name "*$SEARCH_FILTER*.mp4" >temp.txt

# Check if any matching files were found
if [ ! -s "temp.txt" ]; then
    echo "No matching files found."
    rm temp.txt
    exit 1
fi

while IFS= read -r FILEPATH; do
    echo "Uploading file: ${FILEPATH}"

    # https://gist.github.com/rtyler/30e51dc72bed23718388c43f9c11da76
    FILENAME=$(basename "$FILEPATH")

    authorization="SharedKey"

    HTTP_METHOD="PUT"
    request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
    storage_service_version="2015-02-21"

    # HTTP Request headers
    x_ms_date_h="x-ms-date:$request_date"
    x_ms_version_h="x-ms-version:$storage_service_version"
    x_ms_blob_type_h="x-ms-blob-type:BlockBlob"

    FILE_LENGTH=$(wc -c <"${FILEPATH}")
    FILE_TYPE=$(file --mime-type -b "${FILEPATH}")

    # Build the signature string
    canonicalized_headers="${x_ms_blob_type_h}\n${x_ms_date_h}\n${x_ms_version_h}"
    canonicalized_resource="/${STORAGE_ACCOUNT_NAME}/${CONTAINER_NAME}${DESTINATION_DIRECTORY}/${FILENAME}"
    string_to_sign="${HTTP_METHOD}\n\n\n${FILE_LENGTH}\n\n${FILE_TYPE}\n\n\n\n\n\n\n${canonicalized_headers}\n${canonicalized_resource}"

    # Decode the Base64 encoded access key, convert to Hex.
    decoded_hex_key="$(printf "%s" "$STORAGE_ACCOUNT_KEY" | base64 -d -w0 | xxd -p -c256)"

    # Create the HMAC signature for the Authorization header
    # shellcheck disable=SC2059
    signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary | base64 -w0)

    authorization_header="Authorization: $authorization $STORAGE_ACCOUNT_NAME:$signature"
    OUTPUT_FILE="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}${DESTINATION_DIRECTORY}/${FILENAME}"

    if curl -X ${HTTP_METHOD} \
        -T "${FILEPATH}" \
        -H "$x_ms_date_h" \
        -H "$x_ms_version_h" \
        -H "$x_ms_blob_type_h" \
        -H "$authorization_header" \
        -H "Content-Type: ${FILE_TYPE}" \
        "${OUTPUT_FILE}"; then
        echo "Uploaded to:" "${OUTPUT_FILE}"

        if [ "$REMOVE_SUCCESS_FILES" = "true" ]; then
            rm "$FILEPATH"
            echo "Removed file:" "${FILEPATH}"
        fi
    fi
done <temp.txt

# Remove the temporary file
rm temp.txt
