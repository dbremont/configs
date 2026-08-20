#!/usr/bin/env bash
# dwt.sh — run the dwt proxy (mitmdump + bin/redirect.py) in a container.
#
#   browser (manual proxy 127.0.0.1:8080)
#     -> dwt container (mitmproxy/mitmproxy image, port 8080)
#          blocked host (bin/dwt/domains.txt)  -> bin/dwt/index.html
#          everything else                     -> forwarded untouched
#
# - Config is bind-mounted: edit domains.txt / index.html, then
#   `docker restart dwt` (domains load at startup).
# - CA persists in ~/.mitmproxy: browser trust survives recreations.
# - --restart unless-stopped: container returns after reboots
#   (docker service is enabled; see `systemctl is-enabled docker`).
#
# Usage:
#   ./dwt.sh          (re)create + start the container
#   ./dwt.sh logs     follow the proxy logs
#   ./dwt.sh stop     remove the container

set -euo pipefail

IMAGE="mitmproxy/mitmproxy:latest"
CONTAINER="dwt"
PROXY_PORT="8080"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CA_DIR="$HOME/.mitmproxy"

say() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

case "${1:-}" in
  stop)
    docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
    say "Removed '$CONTAINER'"
    exit 0
    ;;
esac

# 1. Free the port if a manual mitmdump/mitmproxy is holding it
if ss -tlnp 2>/dev/null | grep -q ":$PROXY_PORT "; then
  pids="$(ss -tlnp 2>/dev/null | grep ":$PROXY_PORT " | grep -oP '(?<=pid=)\d+' | sort -u)"
  for pid in $pids; do
    if ps -p "$pid" -o cmd= | grep -qE 'mitm(proxy|dump).*bin/redirect\.py'; then
      kill "$pid" && say "Stopped manual proxy (pid $pid)"
    else
      echo "Port $PROXY_PORT held by unrelated process (pid $pid):" >&2
      ps -p "$pid" -o cmd= >&2
      exit 1
    fi
  done
  sleep 1
fi

# 2. CA dir must be writable by the image's user (uid resolved at runtime)
mkdir -p "$CA_DIR"
CA_UID="$(docker run --rm --entrypoint id "$IMAGE" -u)"
if [[ "$CA_UID" != "0" && "$(stat -c %u "$CA_DIR")" != "$CA_UID" ]]; then
  docker run --rm --user 0 -v "$CA_DIR":/ca --entrypoint chown "$IMAGE" -R "$CA_UID:$CA_UID" /ca
fi

# 3. (Re)create the container
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker run -d \
  --name "$CONTAINER" \
  --restart unless-stopped \
  -p 127.0.0.1:"$PROXY_PORT":"$PROXY_PORT" \
  -v "$SCRIPT_DIR/bin/redirect.py":/app/redirect.py:ro \
  -v "$SCRIPT_DIR/bin/dwt":/app/dwt:ro \
  -v "$CA_DIR":/mitmproxy-ca \
  "$IMAGE" \
  mitmdump -s /app/redirect.py \
    --listen-host 0.0.0.0 --listen-port "$PROXY_PORT" \
    --set confdir=/mitmproxy-ca >/dev/null

# 4. Verify
sleep 3
docker ps --filter "name=$CONTAINER" --filter "status=running" --format '{{.Names}}' \
  | grep -qx "$CONTAINER" || { docker logs "$CONTAINER" >&2; exit 1; }
ss -tlnH | awk '{print $4}' | grep -qx "127.0.0.1:$PROXY_PORT" \
  || { echo "Not listening on 127.0.0.1:$PROXY_PORT" >&2; docker logs "$CONTAINER" >&2; exit 1; }
say "dwt proxy on 127.0.0.1:$PROXY_PORT (restarts on reboot)"
say "Blocked domains: bin/dwt/domains.txt (reload: docker restart $CONTAINER)"

if [[ "${1:-}" == "logs" ]]; then
  docker logs -f "$CONTAINER"
fi
