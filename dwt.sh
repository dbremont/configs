#!/usr/bin/env bash
# dwt.sh — rebuild and redeploy the "Don't Waste Time" interception page.
# Idempotent: removes the old container/image if they exist, rebuilds, reruns.
# Publishes on a random uncommon host port (21000-29999), verified available.
#
# Usage:
#   ./dwt.sh              rebuild + redeploy on a random available port
#   PORT=21432 ./dwt.sh   force a specific host port
#   ./dwt.sh logs         follow the container logs after deploy

set -euo pipefail

IMAGE="dwt"
CONTAINER="dwt"
PORT_MIN=21000
PORT_MAX=29999
MAX_TRIES=10
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

# 1. Remove existing container
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  say "Removing existing container '$CONTAINER'"
  docker rm -f "$CONTAINER" >/dev/null
else
  say "No existing container '$CONTAINER'"
fi

# 2. Remove existing image
if docker images --format '{{.Repository}}' | grep -qx "$IMAGE"; then
  say "Removing existing image '$IMAGE'"
  docker rmi -f "$IMAGE" >/dev/null
else
  say "No existing image '$IMAGE'"
fi

# 3. Rebuild
say "Building image '$IMAGE'"
docker build -t "$IMAGE" "$SCRIPT_DIR/bin/dwt" >/dev/null

# 4. Pick a host port: explicit PORT if given, else a random uncommon one.
#    Collect every port currently in use by any process (TCP + UDP, v4 + v6)
#    plus every port Docker has published, then choose outside that set.
used_ports() {
  {
    # all listening TCP and UDP ports, any address family
    ss -H -ltnu 2>/dev/null | awk '{ print $4 }' | awk -F: '{ print $NF }'
    # ports docker has published on the host
    docker ps --format '{{.Ports}}' | tr ' ' '\n' | sed -n 's/.*:\([0-9]*\)->.*/\1/p'
  } | grep -E '^[0-9]+$' | sort -u
}

port_in_use() {
  grep -qx "$1" <<<"$USED"
}

pick_port() {
  local port tried=0
  while (( tried < MAX_TRIES )); do
    port=$(( RANDOM % (PORT_MAX - PORT_MIN + 1 ) + PORT_MIN ))
    tried=$(( tried + 1 ))
    port_in_use "$port" || { echo "$port"; return 0; }
  done
  return 1
}

USED="$(used_ports)"
PORT="${PORT:-$(pick_port)}" || { echo "No free port in $PORT_MIN-$PORT_MAX" >&2; exit 1; }

# 5. Redeploy
run_container() {
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  docker run -d \
    --name "$CONTAINER" \
    --restart unless-stopped \
    -p "$1:80" \
    "$IMAGE" >/dev/null 2>&1
}

say "Running container '$CONTAINER' on host port $PORT -> container 80"
if ! run_container "$PORT"; then
  # Lost the race for the port — refresh the in-use set and retry
  USED="$(used_ports)"
  PORT="$(pick_port)" || { echo "No free port in $PORT_MIN-$PORT_MAX" >&2; exit 1; }
  say "Port taken mid-deploy — retrying on $PORT"
  run_container "$PORT" || true
fi

# 6. Verify
sleep 1
if docker ps --filter "name=$CONTAINER" --filter "status=running" --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  say "Deployed: http://127.0.0.1:$PORT"
else
  printf '\033[1;31mContainer failed to start:\033[0m\n' >&2
  docker logs "$CONTAINER" >&2 || true
  exit 1
fi

if [[ "${1:-}" == "logs" ]]; then
  docker logs -f "$CONTAINER"
fi
