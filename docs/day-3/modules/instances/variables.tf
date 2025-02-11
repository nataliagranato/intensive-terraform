variable "nome" {
  type        = string
  description = "Nome da instância"
}

variable "environment" {
  type        = string
  description = "Ambiente da instância"
  default     = "dev"
}
