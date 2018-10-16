#!/bin/bash

# Get the blobs from an Azure private storage container with access key


storage_account="<storageAccountName>"
container_name="insights-logs-applicationgatewayaccesslog"
access_key="<OneOfTheAzureAccessKeysForTheStorageAccount>"


## This section is specific for api gateway access logs
dateNow=`date +%s`
dateAhourAgo=$(( dateNow - 3600 ))
year=`date -d @"$dateAhourAgo" +%Y`
month=`date -d @"$dateAhourAgo" +%m`
day=`date -d @"$dateAhourAgo" +%d`
hour=`date -d @"$dateAhourAgo" +%H`
blob_name="resourceId=/SUBSCRIPTIONS/<SUBSCRIPTION-ID>/RESOURCEGROUPS/<RG-NAME>/PROVIDERS/MICROSOFT.NETWORK/APPLICATIONGATEWAYS/<API-GATEWAY-NAME>/y=${year}/m=${month}/d=${day}/h=${hour}/m=00/PT1H.json"
##

blob_store_url="blob.core.windows.net"
authorization="SharedKey"

request_method="GET"
request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
storage_service_version="2011-08-18"

# HTTP Request headers
x_ms_date_h="x-ms-date:$request_date"
x_ms_version_h="x-ms-version:$storage_service_version"

# Build the signature string
canonicalized_headers="${x_ms_date_h}\n${x_ms_version_h}"
canonicalized_resource="/${storage_account}/${container_name}/${blob_name}"

string_to_sign="${request_method}\n\n\n\n\n\n\n\n\n\n\n\n${canonicalized_headers}\n${canonicalized_resource}"

# Decode the Base64 encoded access key, convert to Hex.
decoded_hex_key="$(echo -n $access_key | base64 -d -w0 | xxd -p -c256)"

# Create the HMAC signature for the Authorization header
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary | base64 -w0)

authorization_header="Authorization: $authorization $storage_account:$signature"
#List the blobs in a container
#URL="https://${storage_account}.${blob_store_url}/${container_name}?restype=container&comp=list"

#Download the blobs
URL="https://${storage_account}.${blob_store_url}/${container_name}/${blob_name}"

curl  \
  -H "$x_ms_date_h" \
  -H "$x_ms_version_h" \
  -H "$authorization_header" \
  "$URL" -o ${dateAhourAgo}.json
