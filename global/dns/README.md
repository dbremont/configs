# DNS

- How /etc/hosts works? Is this user land based?
- `getent hosts reddit.com`

```bash
application
    │
    ▼
getaddrinfo()
    │
    ▼
NSS
    │
    ├── /etc/hosts  --> 127.0.0.1
    │
    └── DNS  (not reached if /etc/hosts matched)
```

## Refernces

- [Name Service Switch](https://en.wikipedia.org/wiki/Name_Service_Switch)
