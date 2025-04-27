# Script para adicionar um novo usuário ao n8n com um tenantId específico
# Uso: .\inserir-usuario.ps1 [nome] [sobrenome] [email] [tenantId]

# Valores padrão
$nome = if ($args[0]) { $args[0] } else { "Teste" }
$sobrenome = if ($args[1]) { $args[1] } else { "Usuario" }
$email = if ($args[2]) { $args[2] } else { "teste$((Get-Random -Minimum 1000 -Maximum 9999))@exemplo.com" }
$tenantId = if ($args[3]) { $args[3] } else { "2" }

# Exibir informações
Write-Host "Criando usuário: $nome $sobrenome ($email) com tenantId: $tenantId"

# Hash da senha (Senha123!)
$senhaHash = '$2a$10$UlEwKG4fgRVkjt3fgBl9.OXXa1yENUZpOrZ/jOmQNnFn3tZVTGE5W'

# Gerar UUIDs
$userId = [guid]::NewGuid().ToString()
$projectId = [guid]::NewGuid().ToString()
$relationId = [guid]::NewGuid().ToString()

# Criar arquivos temporários para os dados
$userFile = New-TemporaryFile
$projectFile = New-TemporaryFile
$relationFile = New-TemporaryFile

# Preparar os dados para o usuário
$userData = "$userId`t$email`t$nome`t$sobrenome`t$senhaHash`t`t`t`t$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`tglobal-admin`temail`tfalse`t$tenantId"
$userData | Out-File -FilePath $userFile -Encoding utf8

# Preparar os dados para o projeto
$projectData = "$projectId`t$nome Personal Project`tpersonal`t$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$tenantId"
$projectData | Out-File -FilePath $projectFile -Encoding utf8

# Preparar os dados para a relação
$relationData = "$relationId`t$userId`t$projectId`tproject-owner`t$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$relationData | Out-File -FilePath $relationFile -Encoding utf8

# Copiar os arquivos para o contêiner
docker cp $userFile n8n-teste-novo-db-1:/tmp/user.txt
docker cp $projectFile n8n-teste-novo-db-1:/tmp/project.txt
docker cp $relationFile n8n-teste-novo-db-1:/tmp/relation.txt

# Inserir os dados no banco de dados
Write-Host "Inserindo usuário no banco de dados..."
docker exec n8n-teste-novo-db-1 bash -c "psql -U n8n -d n8n -c ""COPY \"\"user\"\" (id, email, \"\"firstName\"\", \"\"lastName\"\", password, \"\"resetPasswordToken\"\", \"\"resetPasswordTokenExpiration\"\", \"\"personalizationAnswers\"\", \"\"createdAt\"\", \"\"updatedAt\"\", \"\"globalRoleId\"\", \"\"signInType\"\", disabled, \"\"tenantId\"\") FROM '/tmp/user.txt'"""
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao inserir usuário." -ForegroundColor Red
    exit 1
}

Write-Host "Inserindo projeto no banco de dados..."
docker exec n8n-teste-novo-db-1 bash -c "psql -U n8n -d n8n -c ""COPY project (id, name, type, \"\"createdAt\"\", \"\"updatedAt\"\", \"\"tenantId\"\") FROM '/tmp/project.txt'"""
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao inserir projeto." -ForegroundColor Red
    exit 1
}

Write-Host "Inserindo relação no banco de dados..."
docker exec n8n-teste-novo-db-1 bash -c "psql -U n8n -d n8n -c ""COPY \"\"project_relation\"\" (id, \"\"userId\"\", \"\"projectId\"\", \"\"roleId\"\", \"\"createdAt\"\", \"\"updatedAt\"\") FROM '/tmp/relation.txt'"""
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao inserir relação." -ForegroundColor Red
    exit 1
}

# Limpar arquivos temporários
Remove-Item -Path $userFile, $projectFile, $relationFile

Write-Host "Usuário criado com sucesso!" -ForegroundColor Green
Write-Host "Detalhes:"
Write-Host "- ID: $userId"
Write-Host "- Email: $email"
Write-Host "- Senha: Senha123!"
Write-Host "- TenantId: $tenantId"
Write-Host "- Projeto ID: $projectId"
