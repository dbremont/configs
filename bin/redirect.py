import os

from mitmproxy import http

ROOT = os.path.dirname(os.path.abspath(__file__))
PAGE = os.path.join(ROOT, "dwt", "index.html")
LIST = os.path.join(ROOT, "dwt", "domains.txt")


def load_domains(path: str) -> set[str]:
    with open(path, encoding="utf-8") as f:
        return {
            line.strip().lower().lstrip(".")
            for line in f
            if line.strip() and not line.startswith("#")
        }


DOMAINS = load_domains(LIST)


def is_blocked(host: str) -> bool:
    host = (host or "").lower().rstrip(".")
    return any(host == d or host.endswith("." + d) for d in DOMAINS)


def request(flow: http.HTTPFlow):
    if is_blocked(flow.request.pretty_host):
        with open(PAGE, "rb") as f:
            flow.response = http.Response.make(
                200,
                f.read(),
                {"Content-Type": "text/html; charset=utf-8"},
            )
