# Script para criar um workflow de teste para um usuário específico
# Uso: .\criar-workflow.ps1 [email] [nome_workflow] [tenantId]

# Valores padrão
$email = if ($args[0]) { $args[0] } else { "maria@exemplo.com" }
$workflowName = if ($args[1]) { $args[1] } else { "Workflow de Teste" }
$tenantId = if ($args[2]) { $args[2] } else { "2" }

# Exibir informações
Write-Host "Criando workflow: '$workflowName' para o usuário $email com tenantId: $tenantId"

# Copiar o arquivo SQL para o contêiner
docker cp .\criar-workflow.sql n8n-teste-novo-db-1:/tmp/criar-workflow.sql

# Executar o script SQL com as variáveis definidas
$comando = "psql -U n8n -d n8n -v email='$email' -v workflow_name='$workflowName' -v tenant_id='$tenantId' -f /tmp/criar-workflow.sql"
Write-Host "Executando comando: $comando"

docker exec n8n-teste-novo-db-1 bash -c "$comando"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Workflow criado com sucesso!" -ForegroundColor Green
    Write-Host "Detalhes:"
    Write-Host "- Nome: $workflowName"
    Write-Host "- Usuário: $email"
    Write-Host "- TenantId: $tenantId"
} else {
    Write-Host "Erro ao criar workflow." -ForegroundColor Red
}
