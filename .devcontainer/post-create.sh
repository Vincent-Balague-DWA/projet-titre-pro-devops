#!/bin/bash
# post-create.sh - Configuration du dev container

echo "🚀 Configuration du dev container DevOps"
echo "========================================"

# Mise à jour du système
echo "📦 Mise à jour des paquets..."
sudo apt-get update

# Installation d'Ansible
echo "📦 Installation d'Ansible..."
pip3 install ansible ansible-core

# Installation des dépendances Python pour Ansible
echo "📦 Installation des dépendances Python..."
pip3 install pymysql kubernetes pyyaml jinja2

# Installation d'outils supplémentaires utiles
echo "📦 Installation d'outils supplémentaires..."
sudo apt-get install -y \
    jq \
    tree \
    htop \
    vim \
    nano \
    curl \
    wget \
    git \
    make

# Configuration des permissions SSH
echo "🔐 Configuration SSH..."
if [ -d "/home/vscode/.ssh" ]; then
    chmod 700 /home/vscode/.ssh
    chmod 600 /home/vscode/.ssh/id_rsa 2>/dev/null || true
    chmod 644 /home/vscode/.ssh/id_rsa.pub 2>/dev/null || true
fi

# Configuration Git
echo "📝 Configuration Git..."
git config --global user.name "DevOps Student"
git config --global user.email "student@devops.local"

# Création de la structure du projet si elle n'existe pas
echo "📁 Création de la structure du projet..."
mkdir -p ~/terraform ~/ansible ~/k8s

# Alias utiles
echo "⚡ Configuration des alias..."
cat >> ~/.bashrc << 'EOF'

# Alias DevOps
alias tf='terraform'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias ap='ansible-playbook'

# Fonctions utiles
tfplan() {
    terraform fmt && terraform plan
}

tfapply() {
    terraform fmt && terraform apply
}

# Prompt coloré
PS1='\[\033[01;32m\]DevOps@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# Afficher les versions installées
echo ""
echo "✅ Installation terminée !"
echo ""
echo "📋 Versions installées :"
echo "========================"
echo -n "Terraform : " && terraform version | head -n1
echo -n "AWS CLI : " && aws --version
echo -n "Ansible : " && ansible --version | head -n1
echo -n "kubectl : " && kubectl version --client --short
echo -n "Python : " && python3 --version

echo ""
echo "🎉 Dev container prêt !"
echo ""
echo "💡 Commandes utiles :"
echo "  - terraform init/plan/apply"
echo "  - ansible-playbook -i inventory.yml install.yml"
echo "  - kubectl get nodes"
echo ""
echo "📁 Structure du projet :"
echo "  ~/terraform - Infrastructure AWS"
echo "  ~/ansible   - Configuration des serveurs"
echo "  ~/k8s       - Manifestes Kubernetes"