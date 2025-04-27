# Script para criar um novo usuário no n8n com multitenancy
# Uso: .\create-user.ps1 [nome] [sobrenome] [email] [senha] [tenantId]

# Valores padrão
$NOME = if ($args[0]) { $args[0] } else { "Teste" }
$SOBRENOME = if ($args[1]) { $args[1] } else { "Usuario" }
$EMAIL = if ($args[2]) { $args[2] } else { "teste$(Get-Random)@exemplo.com" }
$SENHA = if ($args[3]) { $args[3] } else { "Senha123!" }
$TENANT_ID = if ($args[4]) { $args[4] } else { "2" }

# Exibir informações
Write-Host "Criando usuário: $NOME $SOBRENOME ($EMAIL) com tenantId: $TENANT_ID"

# Código JavaScript a ser executado no contêiner
$jsCode = @"
const { Container } = require('typedi');

// Função para inicializar o ambiente n8n
async function init() {
  // Importar os módulos necessários usando caminhos relativos ao diretório de trabalho do n8n
  const { UserRepository } = require('./packages/cli/dist/databases/repositories/user.repository');
  
  try {
    // Obter o repositório de usuários
    const userRepository = Container.get(UserRepository);
    
    // Criar o usuário com seu projeto pessoal
    const user = await userRepository.createUserWithProject({
      firstName: '$NOME',
      lastName: '$SOBRENOME',
      email: '$EMAIL',
      password: '$SENHA',
      projectName: '$NOME Personal Project',
      tenantId: '$TENANT_ID'
    });

    console.log('Usuário criado com sucesso:');
    console.log('ID:', user.id);
    console.log('Email:', user.email);
    console.log('TenantId:', user.tenantId);
  } catch (error) {
    console.error('Erro ao criar usuário:', error.message);
    console.error(error.stack);
  }
}

// Executar a função
init().catch(error => {
  console.error('Erro não tratado:', error);
});
"@

# Escapar aspas duplas no código JavaScript
$jsCode = $jsCode -replace '"', '\"'

# Executar o script no contêiner n8n
docker exec -it n8n-teste-novo-n8n-1 node -e "$jsCode"
