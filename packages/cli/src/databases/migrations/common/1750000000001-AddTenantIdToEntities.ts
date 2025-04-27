import type { MigrationContext, ReversibleMigration } from '@/databases/types';

export class AddTenantIdToEntities1750000000001 implements ReversibleMigration {
	async up({ runQuery, escape }: MigrationContext) {
		const tables = ['user', 'project', 'workflow_entity', 'credentials_entity'];
		for (const table of tables) {
			const tableName = escape.tableName(table);
			const columnName = escape.columnName('tenantId');
			await runQuery(
				`ALTER TABLE ${tableName} ADD COLUMN ${columnName} varchar(36) NOT NULL DEFAULT ''`,
			);
			await runQuery(
				`CREATE INDEX ${escape.indexName(table + '_tenantId')} ON ${tableName}(${columnName});`,
			);
		}
	}

	async down({ runQuery, escape }: MigrationContext) {
		const tables = ['user', 'project', 'workflow_entity', 'credentials_entity'];
		for (const table of tables) {
			const tableName = escape.tableName(table);
			const columnName = escape.columnName('tenantId');
			await runQuery(`ALTER TABLE ${tableName} DROP COLUMN ${columnName}`);
		}
	}
}
