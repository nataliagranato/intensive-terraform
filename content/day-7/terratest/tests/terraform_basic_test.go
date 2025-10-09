package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformBasicExample testa o exemplo básico do Terratest
func TestTerraformBasicExample(t *testing.T) {
	// Configurações do Terraform para o teste
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Caminho para o código Terraform que queremos testar
		TerraformDir: "../",

		// Variáveis para passar ao Terraform
		Vars: map[string]interface{}{
			"example_text":   "Hello from Terratest!",
			"example_number": 100,
			"example_list":   []string{"test1", "test2", "test3", "test4"},
		},

		// Desabilita coloração nos logs para melhor legibilidade
		NoColor: true,
	})

	// Cleanup: destrói os recursos no final do teste
	// Usa defer para garantir que sempre será executado
	defer terraform.Destroy(t, terraformOptions)

	// Deploy: executa terraform init e apply
	terraform.InitAndApply(t, terraformOptions)

	// Validate: verifica os outputs do Terraform

	// Testa output de texto
	actualText := terraform.Output(t, terraformOptions, "example_text_output")
	assert.Equal(t, "Hello from Terratest!", actualText)

	// Testa output de número
	actualNumber := terraform.Output(t, terraformOptions, "example_number_output")
	assert.Equal(t, "100", actualNumber) // Outputs sempre retornam strings

	// Testa output de lista (convertido para JSON string)
	actualList := terraform.OutputList(t, terraformOptions, "example_list_output")
	expectedList := []string{"test1", "test2", "test3", "test4"}
	assert.Equal(t, expectedList, actualList)

	// Testa output de mapa
	actualMap := terraform.OutputMap(t, terraformOptions, "example_map_output")
	expectedMap := map[string]string{
		"environment": "test",
		"project":     "terratest-example",
		"created_by":  "terraform",
	}
	assert.Equal(t, expectedMap, actualMap)

	// Testa outputs processados
	processedOutputs := terraform.OutputMap(t, terraformOptions, "processed_outputs")

	// Verifica texto em maiúsculas
	assert.Equal(t, "HELLO FROM TERRATEST!", processedOutputs["upper_text"])

	// Verifica número dobrado
	assert.Equal(t, "200", processedOutputs["doubled_number"])

	// Verifica tamanho da lista
	assert.Equal(t, "4", processedOutputs["list_length"])
}

// TestTerraformBasicExampleWithDefaults testa usando valores padrão
func TestTerraformBasicExampleWithDefaults(t *testing.T) {
	t.Parallel() // Permite execução em paralelo com outros testes

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Testa valores padrão
	actualText := terraform.Output(t, terraformOptions, "example_text_output")
	assert.Equal(t, "Hello, World from Terratest!", actualText)

	actualNumber := terraform.Output(t, terraformOptions, "example_number_output")
	assert.Equal(t, "42", actualNumber)

	actualList := terraform.OutputList(t, terraformOptions, "example_list_output")
	expectedList := []string{"item1", "item2", "item3"}
	assert.Equal(t, expectedList, actualList)
}

// TestTerraformPlanOnly testa apenas o plano sem aplicar
func TestTerraformPlanOnly(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		NoColor:      true,
	}

	// Apenas inicializa e planeja, sem aplicar
	terraform.Init(t, terraformOptions)

	// Plan retorna informações sobre o que seria criado/modificado
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verifica que o plano seria executado sem erros
	assert.NotNil(t, planStruct)
}
