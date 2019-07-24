#!/bin/bash
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook install-openvpn.yml -i inventory
