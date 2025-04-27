# Script para adicionar um novo usuário ao n8n com um tenantId específico
# Uso: .\adicionar-usuario.ps1 [nome] [sobrenome] [email] [senha] [tenantId]

# Valores padrão
$nome = if ($args[0]) { $args[0] } else { "Teste" }
$sobrenome = if ($args[1]) { $args[1] } else { "Usuario" }
$email = if ($args[2]) { $args[2] } else { "teste$((Get-Random -Minimum 1000 -Maximum 9999))@exemplo.com" }
$senha = if ($args[3]) { $args[3] } else { "Senha123!" }
$tenantId = if ($args[4]) { $args[4] } else { "2" }

# Exibir informações
Write-Host "Criando usuário: $nome $sobrenome ($email) com tenantId: $tenantId"

# Gerar hash da senha (usando bcrypt)
# Nota: Estamos usando um hash pré-gerado para simplificar
$senhaHash = '$2a$10$UlEwKG4fgRVkjt3fgBl9.OXXa1yENUZpOrZ/jOmQNnFn3tZVTGE5W'  # Hash para 'Senha123!'

# Criar SQL para inserir o usuário
$sqlUsuario = @"
INSERT INTO "user" (
  "id", 
  "email", 
  "firstName", 
  "lastName", 
  "password", 
  "resetPasswordToken", 
  "resetPasswordTokenExpiration", 
  "personalizationAnswers", 
  "createdAt", 
  "updatedAt", 
  "globalRoleId", 
  "signInType", 
  "disabled", 
  "tenantId",
  "role"
) VALUES (
  gen_random_uuid(), 
  '$email', 
  '$nome', 
  '$sobrenome', 
  '$senhaHash', 
  NULL, 
  NULL, 
  NULL, 
  NOW(), 
  NOW(), 
  'global-admin', 
  'email', 
  false, 
  '$tenantId',
  'global:member'
) RETURNING "id";
"@

# Executar SQL para criar o usuário e obter o ID
Write-Host "Criando usuário no banco de dados..."
$userId = docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -t -c "$sqlUsuario"

if (-not $userId) {
    Write-Host "Erro: Não foi possível criar o usuário." -ForegroundColor Red
    exit 1
}

$userId = $userId.Trim()
Write-Host "Usuário criado com ID: $userId" -ForegroundColor Green

# Criar SQL para inserir o projeto pessoal
$sqlProjeto = @"
INSERT INTO "project" (
  "id",
  "name",
  "type",
  "createdAt",
  "updatedAt",
  "tenantId"
) VALUES (
  gen_random_uuid(),
  '$nome''s Personal Project',
  'personal',
  NOW(),
  NOW(),
  '$tenantId'
) RETURNING "id";
"@

# Executar SQL para criar o projeto e obter o ID
Write-Host "Criando projeto pessoal..."
$projectId = docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -t -c "$sqlProjeto"

if (-not $projectId) {
    Write-Host "Erro: Não foi possível criar o projeto pessoal." -ForegroundColor Red
    exit 1
}

$projectId = $projectId.Trim()
Write-Host "Projeto criado com ID: $projectId" -ForegroundColor Green

# Criar SQL para relacionar o usuário ao projeto
$sqlRelacao = @"
INSERT INTO "project_relation" (
  "id",
  "userId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  '$userId',
  '$projectId',
  'project:personalOwner',
  NOW(),
  NOW()
);
"@

# Executar SQL para criar a relação
Write-Host "Relacionando usuário ao projeto..."
docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -c "$sqlRelacao" | Out-Null

# Criar um workflow vazio para o usuário
$sqlWorkflow = @"
INSERT INTO "workflow_entity" (
  "id",
  "name",
  "active",
  "createdAt",
  "updatedAt",
  "versionId",
  "tenantId"
) VALUES (
  gen_random_uuid(),
  'Meu Primeiro Workflow',
  false,
  NOW(),
  NOW(),
  gen_random_uuid(),
  '$tenantId'
) RETURNING "id";
"@

# Executar SQL para criar o workflow e obter o ID
Write-Host "Criando workflow inicial..."
$workflowId = docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -t -c "$sqlWorkflow"

if (-not $workflowId) {
    Write-Host "Aviso: Não foi possível criar o workflow inicial." -ForegroundColor Yellow
} 
else {
    $workflowId = $workflowId.Trim()
    Write-Host "Workflow criado com ID: $workflowId" -ForegroundColor Green

    # Criar SQL para relacionar o workflow ao projeto
    $sqlSharedWorkflow = @"
INSERT INTO "shared_workflow" (
  "id",
  "workflowId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  '$workflowId',
  '$projectId',
  'workflow:owner',
  NOW(),
  NOW()
);
"@

    # Executar SQL para criar a relação do workflow
    Write-Host "Relacionando workflow ao projeto..."
    docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -c "$sqlSharedWorkflow" | Out-Null
}

# Verificar se existem workflows existentes que precisam ser compartilhados com o usuário
$sqlExistingWorkflows = @"
SELECT "id" FROM "workflow_entity" WHERE "tenantId" = '$tenantId' AND "id" != '$workflowId';
"@

$existingWorkflowIds = docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -t -c "$sqlExistingWorkflows"

if ($existingWorkflowIds) {
    Write-Host "Compartilhando workflows existentes com o usuário..."
    foreach ($wfId in $existingWorkflowIds.Trim() -split '\r?\n' | Where-Object { $_ -match '\S' }) {
        $wfId = $wfId.Trim()
        $sqlShareExisting = @"
INSERT INTO "shared_workflow" (
  "id",
  "workflowId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  '$wfId',
  '$projectId',
  'workflow:owner',
  NOW(),
  NOW()
);
"@
        
        docker exec n8n-teste-novo-db-1 psql -U n8n -d n8n -c "$sqlShareExisting" | Out-Null
        Write-Host "  - Workflow $wfId compartilhado" -ForegroundColor Green
    }
}

Write-Host "Usuário criado com sucesso e configurado completamente!" -ForegroundColor Green
Write-Host "Detalhes:"
Write-Host "- ID: $userId"
Write-Host "- Email: $email"
Write-Host "- Senha: $senha"
Write-Host "- TenantId: $tenantId"
Write-Host "- Projeto ID: $projectId"
if ($workflowId) {
    Write-Host "- Workflow ID: $workflowId"
}

Write-Host "`nAgora você pode fazer login com esse usuário na interface do n8n."
