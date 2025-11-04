#!/bin/bash
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBESPRAY_VERSION="v2.28.1"
LOG_FILE="$ROOT_DIR/cluster_setup_output.txt"


# echo "Initializing Terraform..."
cd $ROOT_DIR/terraform
terraform init
terraform apply -auto-approve


echo "Preparing Kubespray repository..."
cd $ROOT_DIR
if [ ! -d "kubespray" ]; then
    git clone https://github.com/kubernetes-sigs/kubespray.git
fi
cd $ROOT_DIR/kubespray
git fetch --tags
git checkout $KUBESPRAY_VERSION


echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt 


echo "Preparing Kubespray inventory and configs..."
cp -rfp inventory/sample inventory/mycluster
cp $ROOT_DIR/terraform/kubespray-inventory.ini ./inventory/mycluster/inventory.ini
cp -f $ROOT_DIR/kubespray_configs/addons.yml $ROOT_DIR/kubespray/inventory/mycluster/group_vars/k8s_cluster/addons.yml
cp -f $ROOT_DIR/kubespray_configs/k8s-cluster.yml $ROOT_DIR/kubespray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

echo "Running Kubespray playbook (this may take a while)..."
ansible-playbook -i ./inventory/mycluster/inventory.ini --become --become-user=root cluster.yml | tee $LOG_FILE

echo "Setting up kubeconfig..."
mkdir -p ~/.kube
cp ./inventory/mycluster/artifacts/admin.conf ~/.kube/config
rm -rf ./inventory/mycluster/artifacts/admin.conf
chmod 600 ~/.kube/config

echo "Please Run the following steps manually:"
echo "Apply cloudflare-api-token-secret.yaml, cluster-issuer.yaml argocd-ingress.yaml argocd-configmap.yaml"
echo "Apply argocd-certificate.yaml and run kubectl rollout restart deployment argocd-server -n argocd"
