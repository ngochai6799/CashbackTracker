#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BE_PID=""
FE_PID=""

cleanup() {
  trap - INT TERM EXIT

  echo
  echo "Stopping development servers..."

  if [[ -n "$BE_PID" ]]; then
    kill "$BE_PID" 2>/dev/null || true
  fi

  if [[ -n "$FE_PID" ]]; then
    kill "$FE_PID" 2>/dev/null || true
  fi

  wait 2>/dev/null || true
}

trap cleanup INT TERM EXIT

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm was not found. Install Node.js before running this script."
  exit 1
fi

if [[ ! -f "$ROOT_DIR/be/package.json" ]]; then
  echo "Error: BE project was not found at $ROOT_DIR/be"
  exit 1
fi

if [[ ! -f "$ROOT_DIR/fe/package.json" ]]; then
  echo "Error: FE project was not found at $ROOT_DIR/fe"
  exit 1
fi

echo "Starting BE..."
(
  cd "$ROOT_DIR/be" || exit 1
  npm run dev
) &
BE_PID=$!

echo "Starting FE..."
(
  cd "$ROOT_DIR/fe" || exit 1
  npm run dev
) &
FE_PID=$!

echo
echo "BE and FE are running. Press Ctrl+C to stop both."
echo "BE: http://localhost:3000"
echo "FE: check the Vite URL shown below."
echo

wait "$BE_PID" "$FE_PID"
