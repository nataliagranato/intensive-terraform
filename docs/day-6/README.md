# O uso de for loop no Terraform

O for loop é uma maneira de iterar sobre uma sequência de elementos, como uma lista, tupla, dicionário, conjunto ou string. O loop for é usado para executar um bloco de código várias vezes.

## Exemplo de uso

No arquivo de variáveis, declare uma variável do tipo lista com os valores que deseja iterar.

```hcl
variable "servers" {
  type = list
  default = ["web1", "web2", "web3"]
}
```

## Utilizando Loops para Criar Recursos

Com a variável `servers` definida, podemos agora iterar sobre ela para criar múltiplas instâncias AWS EC2. Utilizamos o atributo `count` junto com a função `length(var.servers)` para determinar o número de instâncias a serem criadas. Para cada elemento na lista `servers`, uma instância EC2 será provisionada.

```hcl
resource "aws_instance" "web" {
  count = length(var.servers)
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = var.servers[count.index]
  }
}
```

Este exemplo ilustra como você pode utilizar variáveis e loops no Terraform para gerenciar recursos de forma dinâmica e eficiente. Através da declaração de variáveis e do uso de loops, é possível simplificar a configuração e o provisionamento de infraestrutura na nuvem, tornando o processo mais automatizado e menos propenso a erros.

## Dynamic Blocks

Se você precisar de mais flexibilidade ao criar recursos com base em variáveis, pode usar blocos dinâmicos. Os blocos dinâmicos permitem que você crie recursos com base em uma lista de objetos, em vez de apenas um valor escalar.

```hcl
resource "aws_instance" "web" {
  for_each = toset(var.servers)
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = each.key
  }
}
```

O `for_each` atributo é usado para iterar sobre a lista de servidores e criar uma instância EC2 para cada um. O `each.key` é usado para acessar a chave do objeto atual na iteração, que neste caso é o nome do servidor.
