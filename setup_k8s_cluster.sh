#!/bin/bash
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $ROOT_DIR/terraform
terraform init
terraform apply -auto-approve

cd $ROOT_DIR
if [ ! -d "kubespray" ]; then
    git clone https://github.com/kubernetes-sigs/kubespray.git
fi

cd kubespray
git checkout v2.28.1
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt 
cp -rfp inventory/sample inventory/mycluster
cp $ROOT_DIR/terraform/kubespray-inventory.ini ./inventory/mycluster/inventory.ini
sed -i 's/^\(argocd_enabled:\).*/\1 true/' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i 's/^\(metrics_server_enabled:\).*/\1 true/' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
ansible-playbook -i ./inventory/mycluster/inventory.ini --become --become-user=root cluster.yml | tee ../cluster_setup_output.txt
mkdir -p ~/.kube
cp ./inventory/mycluster/artifacts/admin.conf ~/.kube/config
