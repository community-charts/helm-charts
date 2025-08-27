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

COUNT=0

function fib() {
  if [ $1 -le 0 ]; then
    echo 0
  elif [ $1 -eq 1 ]; then
    echo 1
  else
    echo $(( $(fib $(($1 - 1)) ) + $(fib $(($1 - 2)) ) ))
  fi
}

echo "[INFO] Waiting for Database to become ready..."

until nc -z -w 2 $HOST $PORT; do
  COUNT=$((COUNT + 1));
  SLEEP_TIME=$(fib $COUNT);
  echo "[WARNING] Unable to access database! Sleeping $SLEEP_TIME seconds. Waiting for $HOST to listen on $PORT...";
  sleep $SLEEP_TIME;
done;

echo "[INFO] Database OK ✓"
