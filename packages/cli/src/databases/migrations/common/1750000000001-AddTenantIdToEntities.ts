import { randomUUID } from 'crypto';

import type { MigrationContext, ReversibleMigration } from '@/databases/types';

// Papel correto para projetos pessoais
const projectPersonalOwnerRole = 'project:personalOwner';

interface UserRecord {
	id: string;
	email?: string;
	firstName?: string;
	lastName?: string;
	tenantId?: string;
}

interface TableRecord {
	table_name: string;
}

interface ColumnRecord {
	column_name: string;
}

interface ExistingProjectRecord {
	id: string;
}

export class AddTenantIdToEntities1750000000001 implements ReversibleMigration {
	async up({ runQuery, escape }: MigrationContext) {
		// Obter todas as tabelas do banco de dados
		const tablesResult = await runQuery(`
			SELECT table_name 
			FROM information_schema.tables 
			WHERE table_schema = 'public' 
			AND table_type = 'BASE TABLE'
		`);

		const tables = Array.isArray(tablesResult)
			? tablesResult.map((row: TableRecord) => row.table_name)
			: [];

		console.log(`Tabelas encontradas: ${tables.join(', ')}`);

		// Adicionar coluna tenantId a todas as tabelas
		for (const table of tables) {
			try {
				const tableName = escape.tableName(table);
				const columnName = escape.columnName('tenantId');

				// Verificar se a coluna já existe
				const columnExists = await runQuery(`
					SELECT column_name 
					FROM information_schema.columns 
					WHERE table_name = '${table}' 
					AND column_name = 'tenantId'
				`);

				if (Array.isArray(columnExists) && columnExists.length === 0) {
					await runQuery(
						`ALTER TABLE ${tableName} ADD COLUMN IF NOT EXISTS ${columnName} varchar(36) NOT NULL DEFAULT '1'`,
					);

					// Criar índice para a coluna tenantId
					await runQuery(
						`CREATE INDEX IF NOT EXISTS ${escape.indexName(table + '_tenantId')} ON ${tableName}(${columnName});`,
					);

					console.log(`Adicionada coluna tenantId à tabela ${table}`);
				} else {
					console.log(`A coluna tenantId já existe na tabela ${table}`);
				}
			} catch (error) {
				console.error(`Erro ao adicionar tenantId à tabela ${table}: ${error}`);
			}
		}

		// Criar projetos pessoais para usuários que não possuem
		console.log('Verificando e criando projetos pessoais para todos os usuários...');

		// Buscar todos os usuários
		const usersResult = await runQuery(`
			SELECT id, email, "firstName", "lastName", "tenantId"
			FROM ${escape.tableName('user')}
		`);

		// Verificar se o resultado é um array
		const users = Array.isArray(usersResult) ? (usersResult as UserRecord[]) : [];

		if (users.length === 0) {
			console.log('Nenhum usuário encontrado para criar projetos pessoais.');
			return;
		}

		// Para cada usuário, verificar se já tem um projeto pessoal
		for (const user of users) {
			// Verificar se o usuário já tem um projeto pessoal
			const existingProjectsResult = await runQuery(`
				SELECT p.id
				FROM ${escape.tableName('project')} p
				JOIN ${escape.tableName('project_relation')} pr ON p.id = pr."projectId"
				WHERE pr."userId" = '${user.id}' AND p.type = 'personal'
			`);

			// Se já existe um projeto pessoal, pular
			const existingProjects = Array.isArray(existingProjectsResult)
				? (existingProjectsResult as ExistingProjectRecord[])
				: [];
			if (existingProjects.length > 0) {
				console.log(`Usuário ${user.email ?? user.id} já possui um projeto pessoal.`);
				continue;
			}

			// Gerar nome do projeto
			let projectName = 'Unnamed Project';
			if (user.firstName && user.lastName && user.email) {
				projectName = `${user.firstName} ${user.lastName} <${user.email}>`;
			} else if (user.email) {
				projectName = `<${user.email}>`;
			}

			// Gerar ID do projeto
			const projectId = randomUUID();

			// Definir tenantId (usar o do usuário ou o padrão '1')
			const tenantId = user.tenantId ?? '1';

			// Inserir o projeto
			await runQuery(`
				INSERT INTO ${escape.tableName('project')} (id, name, type, "tenantId", "createdAt", "updatedAt")
				VALUES ('${projectId}', '${projectName}', 'personal', '${tenantId}', NOW(), NOW())
			`);

			// Inserir a relação do projeto com o usuário
			await runQuery(`
				INSERT INTO ${escape.tableName('project_relation')} ("projectId", "userId", role, "createdAt", "updatedAt")
				VALUES ('${projectId}', '${user.id}', '${projectPersonalOwnerRole}', NOW(), NOW())
			`);

			console.log(`Projeto pessoal criado para o usuário ${user.email ?? user.id}`);
		}

		console.log(`Total de ${users.length} usuários processados.`);
	}

	async down({ runQuery, escape }: MigrationContext) {
		// Obter todas as tabelas do banco de dados
		const tablesResult = await runQuery(`
			SELECT table_name 
			FROM information_schema.tables 
			WHERE table_schema = 'public' 
			AND table_type = 'BASE TABLE'
		`);

		const tables = Array.isArray(tablesResult)
			? tablesResult.map((row: TableRecord) => row.table_name)
			: [];

		// Remover coluna tenantId de todas as tabelas
		for (const table of tables) {
			try {
				const tableName = escape.tableName(table);
				const columnName = escape.columnName('tenantId');

				// Verificar se a coluna existe
				const columnExists = await runQuery(`
					SELECT column_name 
					FROM information_schema.columns 
					WHERE table_name = '${table}' 
					AND column_name = 'tenantId'
				`);

				if (Array.isArray(columnExists) && columnExists.length > 0) {
					await runQuery(`ALTER TABLE ${tableName} DROP COLUMN IF EXISTS ${columnName}`);
					console.log(`Removida coluna tenantId da tabela ${table}`);
				}
			} catch (error) {
				console.error(`Erro ao remover tenantId da tabela ${table}: ${error}`);
			}
		}
	}
}
