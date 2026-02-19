#!/bin/bash

# Construct the JSON string with host, port, username, and password from environment variables
JSON=$(printf '{"host":"%s","port":%d,"username":"%s","password":"%s"}' \
  "$REDIS_HOST" "$REDIS_PORT" "$REDIS_USERNAME" "$REDIS_PASSWORD")

# Base64-encode the JSON string
BASE64_JSON=$(echo -n "$JSON" | base64)

# Set the REDIS_URL environment variable. You can find more information about REDIS_URL [here](https://docs.getoutline.com/s/hosting/doc/redis-LGM4BFXYp4#h-advanced)
export REDIS_URL="ioredis://$BASE64_JSON"

# Execute the original command (node build/server/index.js)
exec node build/server/index.js
