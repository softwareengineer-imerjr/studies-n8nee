# ----------------------------
# Dockerfile para n8n Enterprise Hack
# ----------------------------
	FROM node:20-alpine

	# Aumenta o heap para 8GB
ENV NODE_OPTIONS="--max-old-space-size=8192"

	# Instala utilitários e cliente psql (opcional)
	RUN apk add --no-cache bash git python3 make g++ postgresql-client

	# Variáveis para pular hooks no build, dar mais heap e apontar módulos
	ENV DOCKER_BUILD=true \
			NODE_OPTIONS=--max-old-space-size=4096 \
			NODE_PATH=/usr/src/app/node_modules \
			N8N_SKIP_LICENSE_CHECK=true

	WORKDIR /usr/src/app

	# 1️⃣ Copia todo o repositório
	COPY . .

	# 2️⃣ Instala pnpm, dependências e faz o build do monorepo
	RUN npm install -g pnpm \
	 && pnpm install --frozen-lockfile \
	 && pnpm run build

	# 3️⃣ Ajusta o script binário (remove CRLF e dá permissão)
	RUN sed -i 's/\r$//' packages/cli/bin/n8n \
	 && chmod +x packages/cli/bin/n8n

	# 4️⃣ Cria um link global para o comando n8n
	RUN ln -s /usr/src/app/packages/cli/bin/n8n /usr/local/bin/n8n

	# Expondo a porta padrão do n8n
	EXPOSE 5678

	# Inicia o n8n (já rodando com o hack de licença)
	CMD ["n8n","start"]
