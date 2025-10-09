# O que é o Terratest?

O [Terratest](https://terratest.gruntwork.io/) é uma biblioteca Go que facilita a escrita de testes automatizados para infraestrutura como código (IaC). Desenvolvido pela [Gruntwork](https://gruntwork.io/), ele fornece uma variedade de funções auxiliares e padrões para tarefas comuns de testes de infraestrutura.

## Principais características

O Terratest oferece suporte para testar diversos tipos de infraestrutura:

- **Código Terraform**: Teste seus módulos e configurações Terraform
- **Templates Packer**: Valide suas imagens personalizadas
- **Imagens Docker**: Teste containers e Dockerfiles
- **Clusters Kubernetes**: Valide deployments e configurações K8s
- **Helm Charts**: Teste instalações e configurações de charts
- **APIs de Cloud Providers**: Integração com AWS, Azure, GCP
- **Conexões SSH**: Execute comandos remotos em servidores
- **Requisições HTTP**: Teste endpoints e APIs web
- **Comandos shell**: Execute e valide scripts
- **Políticas OPA**: Teste políticas de segurança e compliance

## Por que usar o Terratest?

### 1. **Testes de infraestrutura real**
- Executa ferramentas reais (Terraform, Packer, etc.)
- Deploy de infraestrutura real em ambientes reais
- Validação completa do comportamento em produção

### 2. **Integração com Go testing**
- Usa o framework nativo de testes do Go
- Padrões familiares para desenvolvedores Go
- Execução com `go test` padrão

### 3. **Padrão de teste completo**
1. **Deploy**: Provisiona recursos usando IaC
2. **Validate**: Testa se a infraestrutura funciona corretamente
3. **Undeploy**: Limpa todos os recursos automaticamente

### 4. **Robustez e confiabilidade**
- Retry automático para operações que podem falhar temporariamente
- Timeouts configuráveis para operações longas
- Cleanup automático mesmo em caso de falhas
- Logging detalhado para debugging

## Requisitos

Para usar o Terratest, você precisa ter instalado:

- **Go** (versão >= 1.21.1)
- **Ferramentas de IaC** que você quer testar (Terraform, Packer, Docker, etc.)
- **Credenciais** para os provedores de cloud que serão testados

## Como começar?

### 1. **Estrutura do projeto**

Organize seu projeto da seguinte forma:

```text
meu-projeto/
├── examples/           # Exemplos de código IaC
│   └── terraform-basic/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── test/              # Testes automatizados
│   ├── go.mod
│   ├── go.sum
│   └── terraform_basic_test.go
└── modules/           # Módulos reutilizáveis
    └── meu-modulo/
```

### 2. **Configuração inicial**

No diretório `test/`, inicialize o módulo Go:

```bash
cd test
go mod init "github.com/meuusuario/meu-projeto"
go mod tidy
```

### 3. **Exemplo básico: "Hello World" do Terraform**

**Código Terraform** (`examples/hello-world/main.tf`):

```hcl
variable "example" {
  description = "Exemplo de variável"
  type        = string
  default     = "Hello, World!"
}

output "example" {
  description = "Saída de exemplo"
  value       = var.example
}
```

**Teste Terratest** (`test/terraform_hello_world_test.go`):

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformHelloWorldExample(t *testing.T) {
    // Configura as opções do Terraform
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        // Caminho para o código Terraform
        TerraformDir: "../examples/hello-world",
    })

    // Cleanup: destrói recursos no final do teste
    defer terraform.Destroy(t, terraformOptions)

    // Deploy: executa terraform init e apply
    terraform.InitAndApply(t, terraformOptions)

    // Validate: verifica o output
    output := terraform.Output(t, terraformOptions, "example")
    assert.Equal(t, "Hello, World!", output)
}
```

### 4. **Executando o teste**

```bash
cd test
go test -v -timeout 30m
```

**Nota importante**: Sempre use timeout longo (30m) para evitar que o teste seja interrompido antes do cleanup.

## Exemplo avançado: Testando EC2 na AWS

**Código Terraform** (`examples/terraform-aws-hello-world/main.tf`):

```hcl
variable "aws_region" {
  description = "Região AWS onde criar recursos"
  type        = string
  default     = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "terratest-example"
  }
}

resource "aws_security_group" "example" {
  name_prefix = "terratest-example"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  # ... configuração anterior ...
  vpc_security_group_ids = [aws_security_group.example.id]
}

output "public_ip" {
  description = "IP público da instância"
  value       = aws_instance.example.public_ip
}
```

**Teste correspondente** (`test/terraform_aws_hello_world_test.go`):

```go
package test

import (
    "fmt"
    "testing"
    "time"

    http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/stretchr/testify/assert"
)

func TestTerraformAwsHelloWorldExample(t *testing.T) {
    // Escolhe uma região AWS aleatória para o teste
    awsRegion := aws.GetRandomStableRegion(t, nil, nil)

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/terraform-aws-hello-world",
        
        // Variáveis para passar ao Terraform
        Vars: map[string]interface{}{
            "aws_region": awsRegion,
        },
        
        // Variáveis de ambiente
        EnvVars: map[string]string{
            "AWS_DEFAULT_REGION": awsRegion,
        },
    })

    // Cleanup no final
    defer terraform.Destroy(t, terraformOptions)

    // Deploy da infraestrutura
    terraform.InitAndApply(t, terraformOptions)

    // Obtém o IP público da instância
    publicIp := terraform.Output(t, terraformOptions, "public_ip")
    url := fmt.Sprintf("http://%s:8080", publicIp)

    // Testa o endpoint HTTP com retry
    // A instância pode demorar alguns minutos para inicializar
    http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)
}
```

## Testando Docker

**Dockerfile** (`examples/docker-hello-world/Dockerfile`):

```dockerfile
FROM ubuntu:18.04
RUN echo "Hello, World!" > /tmp/file.txt
```

**Teste Docker** (`test/docker_hello_world_test.go`):

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/docker"
    "github.com/stretchr/testify/assert"
)

func TestDockerHelloWorldExample(t *testing.T) {
    tag := "gruntwork/terratest-example"
    buildOptions := &docker.BuildOptions{
        Tags: []string{tag},
    }

    // Build da imagem Docker
    docker.Build(t, "../examples/docker-hello-world", buildOptions)

    // Run do container
    opts := &docker.RunOptions{Remove: true}
    output := docker.Run(t, tag, opts, "cat", "/tmp/file.txt")

    // Verifica o conteúdo
    assert.Equal(t, "Hello, World!", output)
}
```

## Testando Kubernetes

**Manifest K8s** (`examples/kubernetes-hello-world/hello-world-deployment.yml`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
spec:
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: training/webapp:latest
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  type: LoadBalancer
  ports:
  - port: 5000
    targetPort: 5000
  selector:
    app: hello-world
```

**Teste Kubernetes** (`test/kubernetes_hello_world_test.go`):

```go
package test

import (
    "fmt"
    "testing"
    "time"

    http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
    "github.com/gruntwork-io/terratest/modules/k8s"
    "github.com/gruntwork-io/terratest/modules/random"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestKubernetesHelloWorldExample(t *testing.T) {
    // Gera um nome único para evitar conflitos
    uniqueId := random.UniqueId()
    
    // Configura opções do kubectl
    options := k8s.NewKubectlOptions("", "", "default")
    
    // Deploy do manifest
    defer k8s.KubectlDelete(t, options, "../examples/kubernetes-hello-world")
    k8s.KubectlApply(t, options, "../examples/kubernetes-hello-world")

    // Aguarda o serviço ficar disponível
    k8s.WaitUntilServiceAvailable(t, options, "hello-world-service", 10, 1*time.Second)

    // Obtém o endpoint do serviço
    service := k8s.GetService(t, options, "hello-world-service")
    endpoint := k8s.GetServiceEndpoint(t, options, service, 5000)

    // Testa o endpoint
    url := fmt.Sprintf("http://%s", endpoint)
    http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello world!", 30, 5*time.Second)
}
```

## Melhores práticas

### 1. **Sempre use timeouts longos**
```bash
go test -v -timeout 30m
```

### 2. **Use namespacing para evitar conflitos**
```go
uniqueId := random.UniqueId()
resourceName := fmt.Sprintf("test-resource-%s", uniqueId)
```

### 3. **Sempre faça cleanup**
```go
defer terraform.Destroy(t, terraformOptions)
```

### 4. **Use retry para operações flaky**
```go
http_helper.HttpGetWithRetry(t, url, nil, 200, expectedBody, 30, 5*time.Second)
```

### 5. **Teste em paralelo quando possível**
```go
func TestMultipleTerraformModules(t *testing.T) {
    t.Parallel()
    // ... resto do teste
}
```

### 6. **Use estágios de teste para desenvolvimento iterativo**
```go
// Para pular o deploy durante desenvolvimento
defer test_structure.RunTestStage(t, "teardown", func() {
    terraform.Destroy(t, terraformOptions)
})

test_structure.RunTestStage(t, "deploy", func() {
    terraform.InitAndApply(t, terraformOptions)
})
```

## Executando testes

### Executar todos os testes
```bash
go test -v -timeout 30m
```

### Executar teste específico
```bash
go test -v -run TestTerraformHelloWorldExample -timeout 30m
```

### Executar testes em paralelo
```bash
go test -v -timeout 30m -parallel 10
```

### Desabilitar cache de teste (importante para testes de infraestrutura)
```bash
go test -v -timeout 30m -count=1
```

## Debugging

### Habilitar logs detalhados
```bash
export TF_LOG=DEBUG
go test -v -timeout 30m
```

### Parser de logs interleaved
```bash
go install github.com/gruntwork-io/terratest/cmd/terratest_log_parser@latest
go test -v -timeout 30m | terratest_log_parser
```

## Integração com CI/CD

### GitHub Actions
```yaml
name: Terratest
on: [push, pull_request]

jobs:
  terratest:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - uses: actions/setup-go@v3
      with:
        go-version: 1.21
    
    - name: Install Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Run Terratest
      run: |
        cd test
        go mod download
        go test -v -timeout 30m
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Vantagens do Terratest

1. **Confiança**: Testa infraestrutura real, não simulações
2. **Automação**: Integra facilmente com pipelines CI/CD
3. **Flexibilidade**: Suporta múltiplas ferramentas de IaC
4. **Robustez**: Retry automático e cleanup garantido
5. **Comunidade**: Bem documentado e amplamente usado
6. **Exemplos reais**: Usado para manter 300.000+ linhas de código IaC da Gruntwork

## Limitações e considerações

1. **Custo**: Testes provisionam recursos reais que geram custos
2. **Tempo**: Testes podem demorar vários minutos para executar
3. **Dependências**: Requer credenciais e permissões adequadas
4. **Complexity**: Requer conhecimento de Go para testes avançados
5. **Quota limits**: Pode esbarrar em limites de APIs dos cloud providers

## Recursos adicionais

- [Documentação oficial](https://terratest.gruntwork.io/docs/)
- [Exemplos no GitHub](https://github.com/gruntwork-io/terratest/tree/main/examples)
- [Biblioteca de módulos Gruntwork](https://gruntwork.io/infrastructure-as-code-library/)
- [Apresentação: "How to test infrastructure code"](https://www.slideshare.net/brikis98/how-to-test-infrastructure-code-automated-testing-for-terraform-kubernetes-docker-packer-and-more)

O Terratest oferece uma abordagem robusta e abrangente para testar infraestrutura como código, garantindo que suas configurações funcionem corretamente antes de chegarem à produção.

