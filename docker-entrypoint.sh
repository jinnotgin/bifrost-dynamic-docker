#!/bin/sh
set -e

: "${APP_HOST:=0.0.0.0}"
: "${APP_PORT:=8080}"
: "${APP_DIR:=/app/data}"

exec /app/main \
  -host "$APP_HOST" \
  -port "$APP_PORT" \
  -app-dir "$APP_DIR" \
  "$@"
