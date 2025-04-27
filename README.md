# n8n Enterprise Hack

Este projeto contém uma configuração personalizada do n8n que desbloqueia recursos Enterprise sem necessidade de licença paga.

## Recursos Habilitados

- Suporte a múltiplos usuários
- Recursos Enterprise
- Gerenciamento de usuários
- Isolamento de workflows e credenciais entre usuários

## Como Usar

### Pré-requisitos

- Docker
- Docker Compose

### Instalação

1. Crie um arquivo `docker-compose.yml` com o seguinte conteúdo:

```yaml
version: '3.8'
services:
  db:
    image: postgres:14
    restart: unless-stopped
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: n8n
      POSTGRES_DB: n8n
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n"]
      interval: 5s
      timeout: 5s
      retries: 5

  n8n:
    image: flaviokosta/n8n-enterprise-hack:latest
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: db
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: n8n

      GENERIC_TIMEZONE: America/Sao_Paulo
      N8N_DATABASE_MIGRATE: 'true'

      # Básico Auth
      N8N_BASIC_AUTH_ACTIVE: 'true'
      N8N_BASIC_AUTH_USER: admin
      N8N_BASIC_AUTH_PASSWORD: secret
      N8N_SKIP_LICENSE_CHECK: 'true'

      N8N_PORT: '5678'
    ports:
      - '5678:5678'
    volumes:
      - ./data/n8n:/home/node/.n8n
```

2. Inicie os contêineres:
```bash
docker-compose up -d
```

3. Acesse o n8n em:
```
http://localhost:5678
```

Credenciais padrão:
- Usuário: admin
- Senha: secret

## Modificações Principais

- Modificação do arquivo `license.ts` para ignorar verificações de licença
- Configuração do Docker para construir o n8n a partir do código fonte
- Ajustes no controlador de convites para permitir adicionar usuários além do limite
- Configuração do PostgreSQL como banco de dados para suportar múltiplos usuários

## Observações

Este projeto é apenas para fins educacionais e de desenvolvimento. Não use em ambiente de produção sem uma licença válida do n8n.

## Autor

Flavio Costa
