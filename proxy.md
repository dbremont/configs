# Proxy (dwt)

Block distracting sites in the browser by serving a local page instead.
That's the whole mechanism:

```
browser (manual proxy) ──> mitmproxy ──> blocked?  -> bin/dwt/index.html
                                        else      -> forwarded untouched
```

## Pieces (that's all of them)

- `redirect.py` — mitmproxy addon. Serves `bin/dwt/index.html` for any
  host matching `bin/dwt/domains.txt` (suffix match: `youtube.com` also
  blocks `m.youtube.com`). Everything else passes through.
- `bin/dwt/index.html` — the self-contained interception page (no
  external assets, system fonts).

## Run

```bash
./dwt.sh        # (re)create + start the container (kills a manual proxy on 8080)
./dwt.sh logs   # follow logs
./dwt.sh stop   # remove it
```

`dwt.sh` runs `mitmdump -s bin/redirect.py` in the `mitmproxy/mitmproxy`
image, published on `127.0.0.1:8080`. Config (`redirect.py`, `bin/dwt/`) is
bind-mounted — no rebuilds; the CA persists in `~/.mitmproxy` so browser
trust survives. `--restart unless-stopped` + enabled docker service bring
it back after reboots.

## Blocklist

Edit `bin/dwt/domains.txt` — one domain per line, subdomains included.
Reload after edits: `docker restart dwt`.

## Firefox (docs only)

- Settings → Network Settings → **Manual proxy**: HTTP `127.0.0.1:8080`.
- https needs the proxy CA trusted once: import
  `~/.mitmproxy/mitmproxy-ca-cert.pem` (Certificates → Import).
- Secure DNS/DoH is irrelevant: with a manual proxy the browser hands the
  hostname straight to the proxy — it never resolves it itself.
