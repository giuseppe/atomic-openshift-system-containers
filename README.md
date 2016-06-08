# atomic-openshift-system-containers (Not ready for production)

(Dirty) script to convert some OpenShift images to system containers and push them.

Used to run OpenShift images Master, Node and OpenVSWitch as system containers.

These images are already uploaded to Docker Hub as `gscrivano/aep`, `gscrivano/node` and `gscrivano/openvswitch` so you can just use the images without rebuilding them.  In facts the Ansible playbook will use them from Docker Hub.

## Installation

These images can be easily installed with: https://github.com/giuseppe/openshift-ansible/tree/atomic-openshift-system-containers

Ensure /dev/atomicos/root has enough space to pull these images, you will need to run for an additional GB:
```
# lvextend -L+1G /dev/atomicos/root
```

Then you can use the `playbooks/byo/config.yml` playbook in `openshift-ansible`:

```
# ansible-playbook -vvv -i my_inventory playbooks/byo/config.yml
```

I have used the same machine, 192.168.125.89` both for Master and Node.

The resulting file `my_inventory` looks like:

```
# This is an example of a bring your own (byo) host inventory

# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=cloud-user

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=yes

# See DEPLOYMENT_TYPES.md
deployment_type=atomic-enterprise

# Pre-release registry URL; note that in the future these images 
# may have an atomicenterprise/aep- prefix or so.
oreg_url=rcm-img-docker:5001/openshift3/ose-${component}:${version}

# Pre-release additional repo
openshift_additional_repos=[{'id': 'ose-devel', 'name': 'ose-devel', 'baseurl': 'http://buildvm/puddle/build/AtomicOpenShift/3.1/2015-10-27.1', 'enabled': 1, 'gpgcheck': 0}]

# host group for masters
[masters]
192.168.125.69

# host group for nodes
[nodes]
192.168.125.69
```

