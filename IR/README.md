# Incident Response

# Ansible Setup
## ssh, share key
ssh-keygen -t ed25519 -C "" -N ""
cat ~/.ssh/id_ed25519.pub

## use pip
apt install python3.11-venv

## venv
python3 -m venv venv
source venv/bin/activate
pip install ansible

## config
1. adjust hosts.ini with appropriate hosts and make sure the users are right. set ir_headnode group to localhost ansible_connection=local
2. make sure ssh key path in config is right
3. check ansible connection. ansible [group_name] -m ping -i [inventory file]

# Velociraptor Setup
## on host node, run server setup script on the ir_headnode (local)
ansible-playbook -i hosts.ini ccdc.yml --limit ir_headnode -e "server:true"

## run client on debian group
## this doesnt work yet
ansible-playbook -i hosts.ini ccdc.yml -e "client:true" --limit debian 

Tools and scripts for incident response

TODO:
- windows event logs artifact 
- velociraptor syslog receive
- good velocirpator oconfig
- include action plugin has been removed
- velociraptor config is auto made and then adjusted with ansible script i think