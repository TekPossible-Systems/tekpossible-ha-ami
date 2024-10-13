import yaml
import sys

# WHAT DO WE NEED TO SWAP?
key = str(sys.argv[1])
value = str(sys.argv[2])


with open('./ansible/inventory/localsetup/hosts.yml', 'r') as hosts_file:
    hosts_ansible = yaml.safe_load(hosts_file)
    hosts_ansible['localhost'][key] = value
    with open('./ansible/inventory/localsetup/hosts.yml', 'w') as write_hosts:
        yaml.dump(hosts_ansible, write_hosts)
