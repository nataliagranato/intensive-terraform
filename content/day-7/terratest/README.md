# Exemplo de Terratest

Este diretório contém um exemplo prático de como usar o Terratest para testar código Terraform.

## Estrutura do projeto

```
terratest/
├── main.tf                    # Código Terraform a ser testado
├── test/                      # Diretório com os testes
│   ├── go.mod                 # Configuração do módulo Go
│   ├── go.sum                 # Checksums das dependências
│   └── terraform_basic_test.go # Arquivo de teste
└── README.md                  # Este arquivo
```

## O que está sendo testado

O arquivo `main.tf` contém:
- Variáveis de entrada com valores padrão
- Processamento de dados usando locals
- Outputs que podem ser testados

Os testes verificam:
- ✅ Outputs com valores customizados
- ✅ Outputs com valores padrão  
- ✅ Processamento de dados (maiúsculas, multiplicação, etc.)
- ✅ Estruturas de dados complexas (listas, mapas)
- ✅ Validação de planos sem aplicar

## Pré-requisitos

- Go 1.21 ou superior
- Terraform instalado

## Como executar os testes

### 1. Preparar o ambiente

```bash
cd test
go mod download
```

### 2. Executar todos os testes

```bash
go test -v -timeout 30m
```

### 3. Executar teste específico

```bash
go test -v -run TestTerraformBasicExample -timeout 30m
```

### 4. Executar testes em paralelo

```bash
go test -v -timeout 30m -parallel 3
```

### 5. Desabilitar cache (recomendado para testes de infraestrutura)

```bash
go test -v -timeout 30m -count=1
```

## Outputs esperados

Quando os testes são executados, você verá:

```
=== RUN   TestTerraformBasicExample
    terraform_basic_test.go:xx: Running command terraform with args [init]
    terraform_basic_test.go:xx: Initializing the backend...
    terraform_basic_test.go:xx: Terraform has been successfully initialized!
    ...
    terraform_basic_test.go:xx: Running command terraform with args [apply -auto-approve]
    terraform_basic_test.go:xx: Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
    ...
    terraform_basic_test.go:xx: Running command terraform with args [destroy -auto-approve]
    terraform_basic_test.go:xx: Destroy complete! Resources: 0 destroyed.
--- PASS: TestTerraformBasicExample (5.23s)
```

## Exemplos de testes

### Teste básico com valores customizados

```go
func TestTerraformBasicExample(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "example_text": "Hello from Terratest!",
            "example_number": 100,
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    actualText := terraform.Output(t, terraformOptions, "example_text_output")
    assert.Equal(t, "Hello from Terratest!", actualText)
}
```

### Teste com valores padrão

```go
func TestTerraformBasicExampleWithDefaults(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    actualText := terraform.Output(t, terraformOptions, "example_text_output")
    assert.Equal(t, "Hello, World from Terratest!", actualText)
}
```

### Teste apenas do plano

```go
func TestTerraformPlanOnly(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
    }

    terraform.Init(t, terraformOptions)
    planStruct := terraform.InitAndPlan(t, terraformOptions)
    assert.NotNil(t, planStruct)
}
```

## Debugging

### Habilitar logs detalhados do Terraform

```bash
export TF_LOG=DEBUG
go test -v -timeout 30m
```

### Parser de logs interleaved

```bash
go install github.com/gruntwork-io/terratest/cmd/terratest_log_parser@latest
go test -v -timeout 30m | terratest_log_parser
```

## Próximos passos

Este é um exemplo básico. Para cenários mais avançados, considere:

1. **Testes com recursos reais**: EC2, RDS, etc.
2. **Testes de conectividade**: HTTP endpoints, SSH, etc.
3. **Testes de integração**: Múltiplos módulos trabalhando juntos
4. **Testes de performance**: Verificar tempos de resposta
5. **Testes de compliance**: Verificar configurações de segurança

## Recursos adicionais

- [Documentação oficial do Terratest](https://terratest.gruntwork.io/)
- [Exemplos no GitHub](https://github.com/gruntwork-io/terratest/tree/main/examples)
- [Melhores práticas](https://terratest.gruntwork.io/docs/#testing-best-practices)