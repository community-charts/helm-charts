#!/bin/sh

if [[ -z "${PGHOST}" && -z "${MYSQL_HOST}" && -z "${MSSQL_HOST}" ]]; then
  HOST="localhost"
elif [[ -z "${PGHOST}" && -z "${MSSQL_HOST}" ]]; then
  HOST="${MYSQL_HOST}"
elif [[ -z "${MSSQL_HOST}" && -z "${MYSQL_HOST}" ]]; then
  HOST="${PGHOST}"
else
  HOST="${MSSQL_HOST}"
fi

if [[ -z "${PGPORT}" && -z "${MYSQL_TCP_PORT}" && -z "${MSSQL_TCP_PORT}" ]]; then
  PORT="5432"
elif [[ -z "${PGPORT}" && -z "${MSSQL_TCP_PORT}" ]]; then
  PORT="${MYSQL_TCP_PORT}"
elif [[ -z "${MSSQL_TCP_PORT}" && -z "${MYSQL_TCP_PORT}" ]]; then
  PORT="${PGPORT}"
else
  PORT="${MSSQL_TCP_PORT}"
fi

# Retry with an iterative Fibonacci backoff (1, 1, 2, 3, 5, 8, ...) clamped to
# MAX_SLEEP seconds, so a database that comes back after a long outage is
# noticed within MAX_SLEEP seconds instead of after an ever-growing sleep.
MAX_SLEEP=30
PREV_SLEEP=0
SLEEP_TIME=1

echo "[INFO] Waiting for Database to become ready..."

until nc -z -w 2 $HOST $PORT; do
  echo "[WARNING] Unable to access database! Sleeping $SLEEP_TIME seconds. Waiting for $HOST to listen on $PORT...";
  sleep $SLEEP_TIME;
  NEXT_SLEEP=$((PREV_SLEEP + SLEEP_TIME));
  PREV_SLEEP=$SLEEP_TIME;
  SLEEP_TIME=$NEXT_SLEEP;
  if [ $SLEEP_TIME -gt $MAX_SLEEP ]; then
    SLEEP_TIME=$MAX_SLEEP;
  fi
done;

echo "[INFO] Database OK ✓"
