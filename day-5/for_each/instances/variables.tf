variable "nome" {
  type        = string
  description = "Nome da instância."
}

variable "environment" {
  type        = string
  description = "Ambiente da instância."
  default     = "dev"
}

variable "instancias" {
  type = map(object({
    instance_type = string
    environment   = string
    })
  )
  description = "Mapa de instâncias."
  default     = {}
}
