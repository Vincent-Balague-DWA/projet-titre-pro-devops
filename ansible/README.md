Configuration Ansible - Version Simple
📁 Fichiers
ansible/
├── inventory.yml    # Liste des serveurs
├── install.yml      # Playbook d'installation
├── ansible.cfg      # Configuration minimale
├── run.sh          # Script automatique
└── README.md       # Ce fichier
🚀 Installation rapide
Option 1 : Script automatique (recommandé)
bash
chmod +x run.sh
./run.sh
Option 2 : Manuelle
bash
# 1. Récupérer l'IP
cd ../terraform && terraform output public_ip && cd ../ansible

# 2. Modifier inventory.yml (remplacer X.X.X.X par l'IP)
nano inventory.yml

# 3. Installer
ansible-playbook -i inventory.yml install.yml
📋 Ce qui est installé
K3S : Kubernetes léger
MySQL : Base de données (user: appuser, pass: DevOps123!)
Kubectl : Configuré pour ubuntu
🔍 Vérifications
bash
# Se connecter
ssh -i ~/.ssh/id_rsa ubuntu@<IP>

# Vérifier K3S
kubectl get nodes

# Vérifier MySQL
sudo systemctl status mysql
📥 Récupérer kubeconfig
bash
# Depuis votre machine locale
scp -i ~/.ssh/id_rsa ubuntu@<IP>:/home/ubuntu/.kube/config ./kubeconfig.yaml
sed -i 's/127.0.0.1/<IP>/g' ./kubeconfig.yaml
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
⏱️ Temps : ~5 minutes
C'est tout !

