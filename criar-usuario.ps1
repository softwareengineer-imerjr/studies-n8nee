# Script para criar um novo usuário no n8n com um tenantId específico
# Uso: .\criar-usuario.ps1 [nome] [sobrenome] [email] [tenantId]

# Valores padrão
$nome = if ($args[0]) { $args[0] } else { "Teste" }
$sobrenome = if ($args[1]) { $args[1] } else { "Usuario" }
$email = if ($args[2]) { $args[2] } else { "teste$((Get-Random -Minimum 1000 -Maximum 9999))@exemplo.com" }
$tenantId = if ($args[3]) { $args[3] } else { "2" }

# Exibir informações
Write-Host "Criando usuário: $nome $sobrenome ($email) com tenantId: $tenantId"

# Copiar o arquivo SQL para o contêiner
docker cp .\criar-usuario.sql n8n-teste-novo-db-1:/tmp/criar-usuario.sql

# Executar o script SQL com as variáveis definidas
$comando = "psql -U n8n -d n8n -v email='$email' -v nome='$nome' -v sobrenome='$sobrenome' -v tenant_id='$tenantId' -f /tmp/criar-usuario.sql"
Write-Host "Executando comando: $comando"

docker exec n8n-teste-novo-db-1 bash -c "$comando"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Usuário criado com sucesso!" -ForegroundColor Green
    Write-Host "Você pode fazer login com:"
    Write-Host "- Email: $email"
    Write-Host "- Senha: Senha123!"
    Write-Host "- TenantId: $tenantId"
} else {
    Write-Host "Erro ao criar usuário." -ForegroundColor Red
}
