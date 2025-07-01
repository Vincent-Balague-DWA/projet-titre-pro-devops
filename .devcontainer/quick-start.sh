#!/bin/bash
# quick-start.sh - Démarrage rapide du projet dans le dev container

echo "🚀 Démarrage rapide du projet DevOps"
echo "===================================="

# Vérifier que nous sommes dans le container
if [ ! -f /.dockerenv ]; then
    echo "⚠️  Ce script doit être exécuté dans le dev container !"
    exit 1
fi

# Vérifier AWS CLI
echo "1️⃣ Vérification AWS CLI..."
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI non configuré"
    echo "Lancez: aws configure"
    exit 1
fi
echo "✅ AWS CLI configuré"

# Vérifier les clés SSH
echo "2️⃣ Vérification des clés SSH..."
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "❌ Clé SSH non trouvée"
    echo "Vérifiez le montage depuis Windows"
    exit 1
fi
chmod 600 ~/.ssh/id_rsa
echo "✅ Clés SSH OK"

# # Structure du projet
# echo "3️⃣ Création de la structure..."
# mkdir -p ~/terraform ~/ansible ~/k8s
# echo "✅ Structure créée"

# # Résumé
# echo ""
# echo "✅ Environnement prêt !"
# echo ""
# echo "📋 Prochaines étapes :"
# echo "1. cd terraform"
# echo "2. Créez vos fichiers Terraform"
# echo "3. terraform init && terraform apply"
# echo "4. cd ../ansible"
# echo "5. ./run.sh"
# echo ""
# echo "💡 Alias disponibles : tf, k, ap"
