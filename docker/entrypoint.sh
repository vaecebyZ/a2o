#!/bin/sh
set -eu

json_escape() {
  # Escape backslash, quote, and newlines for safe JSON string interpolation.
  printf '%s' "$1" | sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g'
}

: "${A2O_DEBUG_LEVEL:=info}"
: "${A2O_TIMEOUT_SECONDS:=300}"
: "${A2O_AUTH_TOKEN:=}"
: "${A2O_COMMENT:=Docker Service}"
: "${A2O_LISTEN_ADDRESS:=0.0.0.0:11001}"
: "${A2O_OPENAI_BASE_URL:=https://api.openai.com/v1/chat/completions}"
: "${A2O_OPENAI_API_KEY:=}"
: "${A2O_FORCE_MODEL:=}"
: "${A2O_UPSTREAM_PROXY:=}"

# Build runtime config from environment variables.
cat > /tmp/config.json <<CONFIG_EOF
{
  "debug_level": "$(json_escape "$A2O_DEBUG_LEVEL")",
  "timeout_seconds": ${A2O_TIMEOUT_SECONDS},
  "auth_token": "$(json_escape "$A2O_AUTH_TOKEN")",
  "services": [
    {
      "comment": "$(json_escape "$A2O_COMMENT")",
      "listen_address": "$(json_escape "$A2O_LISTEN_ADDRESS")",
      "openai_base_url": "$(json_escape "$A2O_OPENAI_BASE_URL")",
      "openai_api_key": "$(json_escape "$A2O_OPENAI_API_KEY")",
      "force_model": "$(json_escape "$A2O_FORCE_MODEL")",
      "upstream_proxy": "$(json_escape "$A2O_UPSTREAM_PROXY")"
    }
  ]
}
CONFIG_EOF

exec /app/a2o -config /tmp/config.json
