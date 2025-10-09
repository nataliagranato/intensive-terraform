# Exemplo Completo: Packer + Terraform

Este é um exemplo prático e completo de como usar o Packer para criar AMIs customizadas e o Terraform para implantar infraestrutura na AWS.

## 📋 Visão Geral

O projeto demonstra:
- **Packer**: Criação de uma AMI personalizada (Golden Image) com aplicação web
- **Terraform**: Deploy da infraestrutura completa usando a AMI criada
- **Aplicação**: Web app Node.js com Express, monitoramento e health checks
- **Infraestrutura**: VPC, Auto Scaling Group, Application Load Balancer, CloudWatch

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└─────────────────────┬───────────────────────────────────────┘
                     │
┌─────────────────────▼───────────────────────────────────────┐
│                Application Load Balancer                    │
│              (Public Subnets - Multi-AZ)                   │
└─────────────────────┬───────────────────────────────────────┘
                     │
┌─────────────────────▼───────────────────────────────────────┐
│              Auto Scaling Group                            │
│          EC2 Instances (Private Subnets)                  │
│     ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│     │   Instance  │  │   Instance  │  │   Instance  │      │
│     │   Node.js   │  │   Node.js   │  │   Node.js   │      │
│     │   Nginx     │  │   Nginx     │  │   Nginx     │      │
│     │   Docker    │  │   Docker    │  │   Docker    │      │
│     └─────────────┘  └─────────────┘  └─────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Estrutura do Projeto

```
packer/
├── webapp.pkr.hcl              # Template principal do Packer
├── scripts/                    # Scripts de provisionamento
│   ├── install-docker.sh       # Instalação do Docker
│   ├── install-nodejs.sh       # Instalação do Node.js
│   ├── install-nginx.sh        # Instalação e configuração do Nginx
│   ├── deploy-webapp.sh        # Deploy da aplicação web
│   ├── security-hardening.sh   # Hardening de segurança
│   └── install-monitoring.sh   # Ferramentas de monitoramento
├── configs/
│   └── nginx.conf              # Configuração personalizada do Nginx
├── webapp/                     # Aplicação web de exemplo
│   ├── package.json            # Dependências Node.js
│   ├── server.js               # Servidor Express.js
│   └── .env.example            # Variáveis de ambiente
└── terraform/                  # Configurações do Terraform
    ├── versions.tf             # Providers e versões
    ├── variables.tf            # Variáveis de entrada
    ├── data.tf                 # Data sources
    ├── network.tf              # VPC, subnets, security groups
    ├── compute.tf              # EC2, Auto Scaling Group
    ├── loadbalancer.tf         # Application Load Balancer
    ├── user-data.sh            # Script de inicialização
    └── outputs.tf              # Outputs de saída
```

## 🚀 Como Usar

### Pré-requisitos

1. **AWS CLI** configurado com credenciais apropriadas
2. **Packer** instalado (versão >= 1.8.0)
3. **Terraform** instalado (versão >= 1.5.0)
4. **Permissões AWS** necessárias:
   - EC2 (criar instâncias, AMIs, VPC, etc.)
   - IAM (criar roles e policies)
   - CloudWatch (logs e métricas)
   - S3 (para logs do ALB, opcional)

### Passo 1: Criar a AMI com Packer

```bash
# Navegar para o diretório do Packer
cd packer/

# Validar o template
packer validate webapp.pkr.hcl

# Construir a AMI (processo demora ~15-20 minutos)
packer build webapp.pkr.hcl
```

**Variáveis do Packer** (opcionais):
```bash
# Customizar região e tipo de instância
packer build \
  -var "region=us-west-2" \
  -var "instance_type=t3.small" \
  -var "environment=staging" \
  webapp.pkr.hcl
```

### Passo 2: Implantar Infraestrutura com Terraform

```bash
# Navegar para o diretório do Terraform
cd terraform/

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Planejar implantação
terraform plan

# Aplicar (criar infraestrutura)
terraform apply
```

**Variáveis do Terraform** (opcionais):
```bash
# Exemplo com variáveis customizadas
terraform apply \
  -var="environment=production" \
  -var="instance_type=t3.medium" \
  -var="desired_capacity=3" \
  -var="key_pair_name=my-key-pair"
```

### Passo 3: Verificar a Implantação

Após a aplicação do Terraform, você receberá outputs com:
- URL da aplicação
- URLs de health check e métricas
- Comandos úteis para monitoramento

```bash
# Exemplo de outputs
application_url = "http://webapp-alb-1234567890.us-east-1.elb.amazonaws.com"
health_check_url = "http://webapp-alb-1234567890.us-east-1.elb.amazonaws.com/health"
api_url = "http://webapp-alb-1234567890.us-east-1.elb.amazonaws.com/api"
```

## 🔧 Configuração Detalhada

### Configurações do Packer

**Principais recursos da AMI criada:**
- **SO Base**: Ubuntu 22.04 LTS
- **Docker**: Para containerização
- **Node.js**: Runtime da aplicação
- **Nginx**: Reverse proxy e servidor web
- **PM2**: Gerenciador de processos Node.js
- **CloudWatch Agent**: Monitoramento
- **Node Exporter**: Métricas para Prometheus
- **Hardening de Segurança**: Fail2ban, UFW, atualizações automáticas

### Configurações do Terraform

**Principais recursos criados:**
- **VPC**: Rede isolada com subnets públicas e privadas
- **Auto Scaling Group**: Escalonamento automático (1-3 instâncias)
- **Application Load Balancer**: Distribuição de carga
- **Security Groups**: Regras de firewall
- **CloudWatch**: Logs e alarmes
- **IAM**: Roles e policies necessárias

### Variáveis Importantes

**Packer (`webapp.pkr.hcl`):**
- `region`: Região AWS (padrão: us-east-1)
- `instance_type`: Tipo da instância para build (padrão: t3.micro)
- `environment`: Ambiente (dev/staging/prod)
- `app_version`: Versão da aplicação

**Terraform (`variables.tf`):**
- `aws_region`: Região AWS (padrão: us-east-1)
- `instance_type`: Tipo das instâncias EC2 (padrão: t3.micro)
- `desired_capacity`: Número desejado de instâncias (padrão: 2)
- `key_pair_name`: Key pair para SSH (opcional)
- `allowed_cidr_blocks`: IPs permitidos para HTTP/HTTPS
- `ssh_allowed_cidr_blocks`: IPs permitidos para SSH

## 📊 Monitoramento e Logs

### Endpoints Disponíveis

- **`/`**: Página principal da aplicação
- **`/health`**: Health check da aplicação
- **`/ready`**: Readiness check
- **`/metrics`**: Métricas no formato Prometheus
- **`/api/status`**: Status da API
- **`/api/info`**: Informações da aplicação
- **`/api/users`**: Exemplo de endpoint da API

### CloudWatch Logs

Logs são automaticamente enviados para:
- `/aws/ec2/nginx/access`: Logs de acesso do Nginx
- `/aws/ec2/nginx/error`: Logs de erro do Nginx
- `/aws/ec2/webapp/app`: Logs da aplicação Node.js
- `/aws/ec2/auth`: Logs de autenticação
- `/aws/ec2/syslog`: Logs do sistema

### Monitoramento

- **CloudWatch Alarms**: CPU alto/baixo para Auto Scaling
- **Target Group Health**: Monitoramento de saúde das instâncias
- **ALB Metrics**: Tempo de resposta, targets não saudáveis
- **Node Exporter**: Métricas detalhadas do sistema (porta 9100)

## 🔐 Segurança

### Hardening Aplicado
- **Firewall**: UFW configurado com regras restritivas
- **Fail2ban**: Proteção contra brute force
- **SSH**: Configuração segura, sem root login
- **Atualizações**: Automáticas para patches de segurança
- **AIDE**: Detecção de intrusão
- **Auditoria**: Logs de segurança com auditd
- **Kernel**: Parâmetros de segurança otimizados

### Security Groups
- **ALB**: Apenas HTTP (80) e HTTPS (443) da internet
- **EC2**: Apenas tráfego do ALB e SSH (se configurado)
- **Outbound**: Permitido para atualizações e APIs

### IAM Roles
- **Princípio do menor privilégio**: Apenas permissões necessárias
- **CloudWatch**: Para envio de logs e métricas
- **EC2**: Para tags e metadados da instância

## 🧪 Testes e Validação

### Testes Automáticos

```bash
# Testar conectividade da aplicação
curl -f http://<ALB-DNS>/health

# Verificar métricas
curl http://<ALB-DNS>/metrics

# Testar API
curl http://<ALB-DNS>/api/status
```

### Comandos de Diagnóstico

```bash
# Verificar instâncias no ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names <ASG-NAME>

# Verificar saúde dos targets
aws elbv2 describe-target-health \
  --target-group-arn <TARGET-GROUP-ARN>

# Conectar via SSM (sem SSH)
aws ssm start-session --target <INSTANCE-ID>
```

## 🚀 Expansões e Melhorias

### Possíveis Melhorias

1. **SSL/TLS**: Adicionar certificado HTTPS
2. **DNS**: Route 53 com domínio personalizado
3. **Database**: RDS para persistência
4. **Cache**: ElastiCache Redis
5. **CDN**: CloudFront para conteúdo estático
6. **Secrets**: AWS Secrets Manager
7. **Backup**: Snapshots automáticos
8. **Multi-Region**: Deploy em múltiplas regiões

### Configurações Avançadas

```hcl
# Exemplo: Adicionar RDS
resource "aws_db_instance" "webapp" {
  identifier = "${var.project_name}-db"
  engine     = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  
  db_name  = "webapp"
  username = "admin"
  password = random_password.db_password.result
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_window = "03:00-04:00"
  backup_retention_period = 7
  
  skip_final_snapshot = true
}
```

## 🧹 Limpeza

### Destruir Infraestrutura

```bash
# Destruir recursos do Terraform
cd terraform/
terraform destroy

# Remover AMI criada pelo Packer (manual)
aws ec2 deregister-image --image-id <AMI-ID>
aws ec2 delete-snapshot --snapshot-id <SNAPSHOT-ID>
```

## 📚 Referências

- [Documentação do Packer](https://www.packer.io/docs)
- [Documentação do Terraform](https://www.terraform.io/docs)
- [AWS Provider do Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Best Practices AWS](https://aws.amazon.com/architecture/well-architected/)

## ⚠️ Considerações Importantes

1. **Custos**: Monitore os custos, especialmente NAT Gateways e instâncias EC2
2. **Regiões**: Ajuste availability zones conforme a região escolhida
3. **Limites**: Verifique limites da conta AWS (VPCs, Elastic IPs, etc.)
4. **Segurança**: Revise security groups e IAM policies antes de produção
5. **Backup**: Implemente estratégia de backup para dados importantes

## 🐛 Troubleshooting

### Problemas Comuns

**Packer falha na criação da AMI:**
- Verificar credenciais AWS
- Confirmar permissões EC2
- Checar se a região tem a AMI base disponível

**Terraform falha na aplicação:**
- Verificar se a AMI existe na região
- Confirmar limites da conta AWS
- Validar syntax com `terraform validate`

**Aplicação não responde:**
- Verificar logs no CloudWatch
- Testar conectividade dos security groups
- Verificar user-data script execution

**Health checks falhando:**
- Verificar se a aplicação está rodando na porta correta
- Confirmar path do health check
- Checar logs da aplicação