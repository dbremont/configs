FROM nginx:1.27-alpine

# Serves the Don't Waste Time interception page on port 80 so that
# /etc/hosts entries (e.g. 127.0.0.1 reddit.com) land here.
COPY index.html style.css script.js /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
