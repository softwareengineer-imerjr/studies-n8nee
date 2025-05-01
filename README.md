# n8n Enterprise Hack

Este projeto aplica customizações ao n8n Community para desbloquear recursos Enterprise sem necessidade de licença paga, além de preparar o caminho para multitenancy via `tenantId`.

---

## 🚀 Recursos Habilitados

- **Pular checagem de licença** (`N8N_SKIP_LICENSE_CHECK=true`)
- **Suporte a múltiplos usuários** (convite por e-mail, roles)
- **Recursos Enterprise** (admin, compartilhamento, etc.)
- **Base para isolação por tenantId** (futura implementação)

---

## 🔧 Principais Modificações no Código

1. **`packages/cli/src/license/license.service.ts`**
   - Stub das funções de licença quando `N8N_SKIP_LICENSE_CHECK=true`:
     - `hasFeatureEnabled() → true`
     - `getFeatureValue() → Infinity`
     - `getCurrentEntitlements() → []`
     - `getMainPlan() → { productId: 'enterprise', planName: 'enterprise' }`

2. **`packages/cli/src/services/license.service.ts`**
   - Bypass de renovação em local (`renew`) se `N8N_SKIP_LICENSE_CHECK=true`.
   - Mapeamento de erros de ativação/renovação (AxiosError → BadRequestError).

3. **`packages/cli/src/controllers/invitation.controller.ts`**
   - Bypass do limite de usuários: permite convidar além da cota se `N8N_SKIP_LICENSE_CHECK=true`.
   - Lógica de convite por e-mail com checagem de permissão de admin.

4. **`packages/frontend/editor-ui/src/stores/settings.store.ts`**
   - Exposição de flags de licença (enterprise) ao frontend.

5. **`packages/frontend/editor-ui/src/stores/settings.store.ts`** *(nova modificação)*
   - **HACK**: remove o banner “não-produção” configurando
     ```ts
     if (settings.value.enterprise) {
       settings.value.enterprise.showNonProdBanner = false;
     }
     ```
     dentro de `setSettings()`, para não exibir a mensagem “This n8n instance is not licensed for production purposes.”

---

## 🐳 Dockerfile Funcional

```dockerfile
# ----------------------------
# Dockerfile para n8n Enterprise Hack
# ----------------------------
FROM node:20-alpine

# Aumenta heap para até 8 GB
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Instala utilitários e cliente PostgreSQL
RUN apk add --no-cache bash git python3 make g++ postgresql-client

# Variáveis de ambiente para build e hack de licença
ENV DOCKER_BUILD=true \
    NODE_PATH=/usr/src/app/node_modules \
    N8N_SKIP_LICENSE_CHECK=true

WORKDIR /usr/src/app

# 1️⃣ Copia todo o código-fonte
COPY . .

# 2️⃣ Instala pnpm, dependências e build do monorepo
RUN npm install -g pnpm \
 && pnpm install --frozen-lockfile \
 && pnpm run build

# 3️⃣ Ajusta script binário (CRLF → LF + permissão)
RUN sed -i 's/\r$//' packages/cli/bin/n8n \
 && chmod +x packages/cli/bin/n8n

# 4️⃣ Link global para comando n8n
RUN ln -s /usr/src/app/packages/cli/bin/n8n /usr/local/bin/n8n

# Porta padrão do n8n
EXPOSE 5678

# Inicia o n8n com hack de licença
CMD ["n8n", "start"]


---


## 🐙 docker-compose Funcional

```docker-compose.yml
# ----------------------------
# docker-compose.yml para n8n Enterprise Hack
# ----------------------------
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
    build: .
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    environment:
      # Conexão com Postgres
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: db
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: n8n

      # Timezone e migrações
      GENERIC_TIMEZONE: America/Sao_Paulo
      N8N_DATABASE_MIGRATE: 'true'

      # Basic Auth
      N8N_BASIC_AUTH_ACTIVE: 'true'
      N8N_BASIC_AUTH_USER: admin
      N8N_BASIC_AUTH_PASSWORD: secret

      # Hack Enterprise
      N8N_SKIP_LICENSE_CHECK: 'true'

      # Porta interna
      N8N_PORT: '5678'

    ports:
      - '5678:5678'
    volumes:
      - ./data/n8n:/home/node/.n8n


📦 Como Executar em nodeJs


Coloque Dockerfile e docker-compose.yml na raiz do repositório. (somente os serviços de postgres e o adminer)

Execute na raiz do repositório:

docker-compose up -d --build
pnpm install
pnpm build

execute na pasta packages/cli
pnpm install
npx n8n

-----

📦 Como Executar em Docker


Coloque Dockerfile e docker-compose.yml na raiz do repositório.

Execute na raiz do repositório:

pnpm install

docker-compose up -d --build

Acesse via browser:
http://localhost:5678

⚠️ Atenção: Este hack é para fins de desenvolvimento ou testes. Em ambiente de produção, adquira a licença oficial do n8n Enterprise para garantir suporte e conformidade.
