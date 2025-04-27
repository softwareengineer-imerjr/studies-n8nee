import { Container } from 'typedi';
import { UserRepository } from '../databases/repositories/user.repository';
import { randomUUID } from 'crypto';
import { init as initDb } from '../db';
import { Logger } from 'n8n-core';

// Configuração para o novo usuário
interface UserConfig {
	firstName: string;
	lastName: string;
	email: string;
	password: string;
	tenantId?: string;
}

async function createUser(userConfig: UserConfig): Promise<void> {
	const logger = Container.get(Logger);
	logger.info('Iniciando criação de usuário');

	try {
		// Inicializar o banco de dados
		await initDb();
		logger.info('Banco de dados inicializado');

		// Obter o repositório de usuários
		const userRepository = Container.get(UserRepository);

		// Definir o tenantId (se não for fornecido, será definido como '1' pelo subscriber)
		const tenantId = userConfig.tenantId || '1';

		// Criar o usuário com seu projeto pessoal
		const result = await userRepository.createUserWithProject({
			firstName: userConfig.firstName,
			lastName: userConfig.lastName,
			email: userConfig.email,
			password: userConfig.password,
			tenantId,
		});

		logger.info(`Usuário criado com sucesso: ${result.user.email} (ID: ${result.user.id})`);
		logger.info(`TenantId atribuído: ${result.user.tenantId}`);

		// Encerrar o processo
		process.exit(0);
	} catch (error) {
		logger.error('Erro ao criar usuário:', error);
		process.exit(1);
	}
}

// Obter parâmetros da linha de comando
const args = process.argv.slice(2);
const firstName = args[0] || 'Teste';
const lastName = args[1] || 'Usuário';
const email = args[2] || `teste${randomUUID().substring(0, 8)}@exemplo.com`;
const password = args[3] || 'Senha123!';
const tenantId = args[4] || '2'; // Usar tenant ID diferente para testar multitenancy

// Executar a função
createUser({
	firstName,
	lastName,
	email,
	password,
	tenantId,
}).catch((error) => {
	console.error('Erro não tratado:', error);
	process.exit(1);
});
