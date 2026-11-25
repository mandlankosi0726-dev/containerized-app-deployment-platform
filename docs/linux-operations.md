# Linux host operations

The project binds development and Compose ports to loopback. Useful host diagnostics include `ps aux`, `top`, `free -h`, `df -h`, `du -sh <path>`, `ss -tulpn`, `ip addr`, `ip route`, `dig`, and `curl -v`. For service management where permissions permit, inspect `systemctl status docker` and `journalctl -u docker`; do not restart system services without understanding workstation impact. `docker info`, `docker ps`, `docker inspect`, `docker logs`, `docker exec`, and `docker stats` diagnose daemon/container state.

No firewall, SSH, user, package or systemd configuration is changed by the project. The only automation is a read-only Ansible preflight that reports required executables. This keeps host setup idempotent without modifying a developer workstation or assuming a particular distribution.
