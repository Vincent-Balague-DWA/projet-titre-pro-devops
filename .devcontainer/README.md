🐳 Dev Container pour Projet DevOps
Ce dev container fournit un environnement Debian complet avec tous les outils nécessaires pour votre projet DevOps.

📋 Outils inclus
Terraform : Infrastructure as Code
Ansible : Configuration Management
AWS CLI : Gestion AWS
kubectl : Client Kubernetes
Docker : Containerisation
Python 3.10 : Pour Ansible et scripts
Git : Gestion de version
🚀 Démarrage rapide
1. Prérequis
Visual Studio Code
Extension "Dev Containers" (ms-vscode-remote.remote-containers)
Docker Desktop
2. Ouvrir dans le container
Ouvrez VS Code dans le dossier racine du projet
Appuyez sur F1 et tapez "Dev Containers: Reopen in Container"
Ou cliquez sur l'icône verte en bas à gauche >< et choisissez "Reopen in Container"
3. Première utilisation
Le container va :

Télécharger l'image Debian
Installer tous les outils
Configurer l'environnement
Monter vos clés SSH depuis Windows
⏱️ Temps : 3-5 minutes la première fois

🔑 Configuration SSH
Vos clés SSH Windows sont automatiquement montées dans /home/vscode/.ssh/

Si vous avez des problèmes :

bash
# Dans le container
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
📁 Structure dans le container
/workspaces/votre-projet/
├── terraform/      # Infrastructure AWS
├── ansible/        # Playbooks Ansible
├── k8s/           # Manifestes Kubernetes
└── .devcontainer/ # Config du container
💻 Commandes disponibles
Terraform
bash
cd terraform
terraform init
terraform plan
terraform apply
Ansible
bash
cd ansible
ansible-playbook -i inventory.yml install.yml
AWS
bash
aws configure
aws s3 ls
Kubernetes
bash
kubectl get nodes
kubectl apply -f k8s/
🎯 Workflow typique
Phase Terraform :
bash
cd terraform
terraform init
terraform apply
Phase Ansible :
bash
cd ../ansible
./run.sh
Phase Kubernetes :
bash
./get-kubeconfig.sh
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
⚡ Alias disponibles
tf → terraform
k → kubectl
kgp → kubectl get pods
kgs → kubectl get svc
ap → ansible-playbook
🐛 Troubleshooting
Le container ne démarre pas
Vérifiez que Docker Desktop est lancé
Essayez : Dev Containers: Rebuild Container
Permission denied sur les clés SSH
bash
chmod 600 ~/.ssh/id_rsa
AWS CLI non configuré
bash
aws configure
# Entrez vos Access Key ID et Secret Access Key
🔄 Rebuild du container
Si vous modifiez devcontainer.json :

F1 → "Dev Containers: Rebuild Container"
Ou Command Palette → "Rebuild Container"
💡 Tips
Persistance : Tout ce qui est dans /workspaces/ est persisté
Performance : Le container est plus rapide que WSL pour certaines opérations
Extensions : Les extensions VS Code sont installées automatiquement
📚 Ressources
Dev Containers docs
Available Features
🎉 Profitez de votre environnement DevOps complet !

