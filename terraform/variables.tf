# variables.tf - Variables pour cluster K3S multi-instances

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "devops-todouxlist"
}

variable "allowed_ssh_ips" {
  description = "IPs autorisées pour SSH"
  type        = list(string)
  default     = ["88.160.144.47/32"]  # ⚠️ À restreindre !
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
  type        = string
  default     = "~/.ssh/id_rsa_devops.pub"
}

variable "db_name" {
  description = "Nom de la base de données MySQL à créer"
  type        = string
}

variable "db_user" {
  description = "Nom de l'utilisateur MySQL"
  type        = string
}

variable "db_password" {
  description = "Mot de passe de l'utilisateur MySQL"
  type        = string
  sensitive   = true
}