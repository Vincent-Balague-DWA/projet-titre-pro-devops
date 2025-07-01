#!/bin/bash
# deploy-simple-fixed.sh - Script de déploiement corrigé

echo "🚀 Déploiement Architecture Simple (3 instances)"
echo "=============================================="

# Vérifier qu'on est dans le bon dossier
if [ ! -f deploy-apps.yml ]; then
    echo "❌ Erreur : deploy-apps.yml non trouvé"
    echo "Assurez-vous d'être dans le dossier ansible-simple"
    exit 1
fi

# Mise à jour de l'inventaire avec les IPs Terraform
echo "📍 Récupération des IPs..."
cd ../terraform
FRONTEND_IP=$(terraform output -raw frontend_public_ip 2>/dev/null)
BACKEND_IP=$(terraform output -raw backend_public_ip 2>/dev/null)
DATABASE_IP=$(terraform output -raw database_public_ip 2>/dev/null)

cd ../ansible

if [ -z "$FRONTEND_IP" ] || [ -z "$BACKEND_IP" ] || [ -z "$DATABASE_IP" ]; then
    echo "❌ Impossible de récupérer les IPs"
    echo "Assurez-vous que Terraform a créé les instances"
    exit 1
fi

# Créer l'inventaire avec les BONS noms de groupes
cat > inventory.yml << EOF
all:
  children:
    database:
      hosts:
        database-server:
          ansible_host: $DATABASE_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa_devops

    backend:
      hosts:
        backend-server:
          ansible_host: $BACKEND_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa_devops

    frontend:
      hosts:
        frontend-server:
          ansible_host: $FRONTEND_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa_devops

  vars:
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF

echo "✅ Inventaire créé avec :"
echo "   Frontend : $FRONTEND_IP"
echo "   Backend  : $BACKEND_IP"
echo "   Database : $DATABASE_IP"

# Test de connexion
echo ""
echo "🔗 Test de connexion aux instances..."
ansible all -i inventory.yml -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "⚠️  Problème de connexion détecté"
    echo "Vérification des clés SSH..."

    # Essayer de trouver une clé qui fonctionne
    for key in ~/.ssh/id_rsa ~/.ssh/id_rsa_new ~/.ssh/id_ed25519; do
        if [ -f "$key" ]; then
            echo "Test avec $key..."
            sed -i "s|ansible_ssh_private_key_file:.*|ansible_ssh_private_key_file: $key|g" inventory.yml
            if ansible all -i inventory.yml -m ping -o &>/dev/null; then
                echo "✅ Clé fonctionnelle trouvée : $key"
                break
            fi
        fi
    done
fi

# Afficher l'inventaire pour debug
echo ""
echo "📋 Inventaire utilisé :"
cat inventory.yml
echo ""

# Déploiement
echo "📦 Déploiement des applications..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml deploy-apps.yml -v \
  -e "db_name=${DB_NAME}" \
  -e "db_user=${DB_USER}" \
  -e "db_password=${DB_PASSWORD}"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Déploiement terminé avec succès !"
    echo ""
    echo "🌐 Accès à votre application :"
    echo "   Frontend : http://$FRONTEND_IP"
    echo "   API Test : http://$FRONTEND_IP/api"
    echo "   Backend direct : http://$BACKEND_IP:3000/api"
else
    echo ""
    echo "❌ Erreur lors du déploiement"
    echo ""
    echo "🔍 Pour debugger :"
    echo "1. Vérifiez que les instances sont bien créées :"
    echo "   cd ../terraform && terraform output"
    echo ""
    echo "2. Testez la connexion SSH manuellement :"
    echo "   ssh -i ~/.ssh/id_rsa ubuntu@$FRONTEND_IP"
    echo ""
    echo "3. Relancez avec plus de détails :"
    echo "   ansible-playbook -i inventory.yml deploy-apps.yml -vvv"
fi
