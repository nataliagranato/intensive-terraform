# Exemplo simples para demonstrar testes com Terratest
# Este exemplo cria apenas outputs para serem testados

variable "example_text" {
  description = "Texto de exemplo para testar"
  type        = string
  default     = "Hello, World from Terratest!"
}

variable "example_number" {
  description = "Número de exemplo para testar"
  type        = number
  default     = 42
}

variable "example_list" {
  description = "Lista de exemplo para testar"
  type        = list(string)
  default     = ["item1", "item2", "item3"]
}

# Outputs que podem ser testados
output "example_text_output" {
  description = "Output do texto de exemplo"
  value       = var.example_text
}

output "example_number_output" {
  description = "Output do número de exemplo"
  value       = var.example_number
}

output "example_list_output" {
  description = "Output da lista de exemplo"
  value       = var.example_list
}

output "example_map_output" {
  description = "Output de um mapa de exemplo"
  value = {
    environment = "test"
    project     = "terratest-example"
    created_by  = "terraform"
  }
}

# Local values para demonstrar processamento
locals {
  processed_text = upper(var.example_text)
  doubled_number = var.example_number * 2
  list_length    = length(var.example_list)
}

output "processed_outputs" {
  description = "Outputs processados para testar lógica"
  value = {
    upper_text     = local.processed_text
    doubled_number = local.doubled_number
    list_length    = local.list_length
  }
}
