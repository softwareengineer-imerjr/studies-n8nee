#!/bin/bash

# Script para criar um novo usuário no n8n com multitenancy
# Uso: ./create-user.sh [nome] [sobrenome] [email] [senha] [tenantId]

# Valores padrão
NOME=${1:-"Teste"}
SOBRENOME=${2:-"Usuario"}
EMAIL=${3:-"teste$(date +%s)@exemplo.com"}
SENHA=${4:-"Senha123!"}
TENANT_ID=${5:-"2"}

# Executar o script no contêiner n8n
echo "Criando usuário: $NOME $SOBRENOME ($EMAIL) com tenantId: $TENANT_ID"
docker exec -it n8n-teste-novo-n8n-1 node -e "
const { UserRepository } = require('@/databases/repositories/user.repository');
const { Container } = require('typedi');

async function createUser() {
  try {
    const userRepository = Container.get(UserRepository);
    
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
  }
}

createUser();
"
