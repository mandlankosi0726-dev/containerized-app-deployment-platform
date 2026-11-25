# Ansible host preflight

Ansible is used only for a read-only local prerequisite check. It does not configure Kubernetes, install packages, change firewall or SSH settings, or require privilege escalation. Run `ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/preflight.yml`. The role reports Docker, kubectl, Kind, Helm and Python availability. If host installation automation becomes necessary, add distribution-specific roles and explicit review rather than silently changing workstation state.
