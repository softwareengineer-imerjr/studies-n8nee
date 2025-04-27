#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');

// Caminho para o diretório raiz do projeto
const projectRoot = path.resolve(__dirname, '..', '..');

// Executar o script TypeScript com ts-node
try {
	console.log('Compilando e executando o script de criação de usuário...');

	// Obter argumentos da linha de comando
	const args = process.argv.slice(2);

	// Comando para executar o script com ts-node
	const command = `npx ts-node "${path.join(projectRoot, 'src', 'scripts', 'create-user.ts')}" ${args.join(' ')}`;

	// Executar o comando
	execSync(command, { stdio: 'inherit' });
} catch (error) {
	console.error('Erro ao executar o script:', error.message);
	process.exit(1);
}
