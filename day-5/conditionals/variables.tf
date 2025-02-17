variable "nome" {
  type        = string
  description = "Nome da instância."
}

variable "environment" {
  type        = string
  description = "Ambiente da instância."
  default     = "dev"
}

variable "create_instance" {
  type        = bool
  description = "Criar instância?"
  default     = false
}
