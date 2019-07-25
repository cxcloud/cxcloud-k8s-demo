# OpenVPN setup

CX Cloud demo uses OpenVPN for accessing services running in the private subnets of the VPC. The terraform setup has has already installed the OpenVPN instance in one of the public subnets. This guide is about installing and configuring OpenVPN on the instance with help of Ansible.

## Requirements

The OpenVPN module requires that an Ubuntu machine is running with a public IP-address.

For AWS there is an [OpenVPN terraform module](https://github.com/tieto-cem/terraform-aws-openvpn) that provision an Ubuntu machine in the public subnet of the VPC.

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) is requred in order to use the OpenVPN roles
- SSH key pair

## Install OpenVPN on the Server

Ansible automatically install OpenVPN with all dependencies and configurations.

### Ansible playbook

Get the OpenVPN Ansible dependencies with the following command:

```bash
ansible-galaxy install git+https://github.com/tieto-cem/openvpn-server-role.git,v1.1.0
ansible-galaxy install git+https://github.com/tieto-cem/openvpn-client-role.git,v1.1.0
```

Redefine the inventory file, [cxcloud-demo-inventory](inventory/cxcloud-demo-inventory), use the public IP address of the Ubuntu machine. Also modify the location to the projects private SSH key.

```bash
[example-project]
203.0.113.117

[all:vars]
ansible_connection=ssh
ansible_ssh_private_key_file=~/.ssh/cxcloud-demo.pem
ansible_ssh_user=ubuntu
ansible_python_interpreter=/usr/bin/python3.5
```

Redefine the group variables in the group_vars file, [cxcloud-demo](inventory/group_vars/cxcloud-demo).

| Variable | Description |
| --- | --- |
| VpnClients | List of VPN keys that should be generated |
| ServerName | Name of the server, will be part of keys etc |
| RedrirectTraffic | If `true` all traffic will get routed trough the VPN server. Normally this can be `false` |
| ServerNetwork | Network reserved for the server |
| LocalNetworks | Clients will route all traffic trough the VPN server within these IP-ranges |
| NetworkInterface | Network interface for the public IP |

### Run ansible

The following command will install/update the OpenVPN server. It's required to run every time a modification for the Ansible playbook, e.g. new client keys.

```bash
cd openvpn-ansible
./install.sh
```

## Create a new OpenVPN user

Modify the group vars file, [cxcloud-demo](openvpn-ansible/inventory/group_vars/cxcloud-demo). Add the new user to the `VpnClients` section and update Ansible with the command above.

Obtain the OpenvVPN client keys for the new user with the following command.

```bash
cd openvpn-ansible
./obtain-keys.sh -i /location/to/private/cxcloud-demo.pem -s ubuntu@203.0.113.117 -c new-user
```

## Client installation for OpenVPN

Follow the [OpenVPN Client installation](https://github.com/tieto-cem/openvpn-server-role/blob/master/README.md#client-installation-for-openvpn) instructions on order to install the client keys for the users.
