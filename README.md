# atomic-openshift-system-containers (Not ready for production)

(Dirty) script to convert some OpenShift images to system containers and push them.

Used to run OpenShift images Master, Node and OpenVSWitch as system containers.

## Installation

These images can be easily installed with: https://github.com/giuseppe/openshift-ansible/tree/system-containers

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
etcd

[OSEv3:vars]

ansible_ssh_user=cloud-user
ansible_become=yes
deployment_type=openshift-enterprise

openshift_use_dnsmasq=False

deployment_type=openshift-enterprise
#deployment_subtype=registry
#deployment_type=origin

openshift_router_selector='router=true'
openshift_registry_selector='registry=true'

openshift_image_tag=v3.3.0.26

openshift_master_default_subdomain=localorigin.io

openshift_docker_additional_registries=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888
openshift_docker_insecure_registries=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888
system_images_registry=192.168.125.1:5000
use_openvswitch_system_container=True

registry_url=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888

containerized=True
openshift_uninstall_images=False

# enable htpasswd auth
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_htpasswd_users={'admin': '$apr1$zgSjCrLt$1KSuj66CggeWSv.D.BXOA1', 'user': '$apr1$.gw8w9i1$ln9bfTRiD6OwuNTG5LvW50'}

# host group for masters
[masters]
192.168.125.89 openshift_schedulable=true

[etcd]
192.168.125.89

# host group for nodes
[nodes]
192.168.125.89  openshift_schedulable=true openshift_node_labels="{'router':'true','registry':'true'}"
```
