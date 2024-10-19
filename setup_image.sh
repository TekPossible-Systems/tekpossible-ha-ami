#!/bin/bash

# Prep work for RHEL 9 STIG Role From DISA. Note: I did not modify  the DISA role so it should be modular for when there is an update to it.
cd ansible
sed -i 's/do_reboot/do_notify_reboot/g' roles/rhel9STIG/tasks/main.yml
echo "- name: do_notify_reboot\n  debug:\n    msg: 'AMI does not need reboot.'" >> ./roles/rhel9STIG/handlers/main.yml

# Run ansible local setup
ansible-galaxy collection install community.general ansible.posix
ansible-playbook playbooks/site.yml -c local -vv -i inventory/localsetup
