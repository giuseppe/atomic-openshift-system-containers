# atomic-openshift-system-containers (Not ready for production)

(Dirty) script to convert some OpenShift images to system containers and push them.

Used to run OpenShift images Master, Node and OpenVSWitch as system containers.

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

The same machine `192.168.125.89` in the following inventory file is
used both for Master and Node.  A local Docker registry running on
`192.168.125.1:5000`.

The resulting file `my_inventory` looks like:

```
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=cloud-user
ansible_become=yes
deployment_type=openshift-enterprise

openshift_docker_additional_registries=192.168.125.1:5000
openshift_docker_insecure_registries=192.168.125.1:5000
openshift_use_dnsmasq=False

deployment_type=openshift-enterprise

openshift_image_tag=latest

containerized=True
system_images_registry=192.168.125.1:5000
use_system_containers=True

openshift_uninstall_images=False

# host group for masters
[masters]
192.168.125.89 openshift_schedulable=true

# host group for nodes
[nodes]
192.168.125.89
```
