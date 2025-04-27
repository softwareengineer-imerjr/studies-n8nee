import { GlobalConfig } from '@n8n/config';
import { Container } from '@n8n/di';
import type { DataSourceOptions, LoggerOptions } from '@n8n/typeorm';
import type { PostgresConnectionOptions } from '@n8n/typeorm/driver/postgres/PostgresConnectionOptions';
import type { TlsOptions } from 'tls';

import { entities } from './entities';
import { postgresMigrations } from './migrations/postgresdb';
import { subscribers } from './subscribers';

const getCommonOptions = () => {
	const { tablePrefix: entityPrefix, logging: loggingConfig } =
		Container.get(GlobalConfig).database;

	let loggingOption: LoggerOptions = loggingConfig.enabled;
	if (loggingOption) {
		const optionsString = loggingConfig.options.replace(/\s+/g, '');
		if (optionsString === 'all') {
			loggingOption = optionsString;
		} else {
			loggingOption = optionsString.split(',') as LoggerOptions;
		}
	}

	return {
		entityPrefix,
		entities: Object.values(entities),
		subscribers: Object.values(subscribers),
		migrationsTableName: `${entityPrefix}migrations`,
		migrationsRun: false,
		synchronize: false,
		maxQueryExecutionTime: loggingConfig.maxQueryExecutionTime,
		logging: loggingOption,
	};
};

export const getOptionOverrides = () => {
	const globalConfig = Container.get(GlobalConfig);
	const dbConfig = globalConfig.database.postgresdb;
	return {
		database: dbConfig.database,
		host: dbConfig.host,
		port: dbConfig.port,
		username: dbConfig.user,
		password: dbConfig.password,
	};
};

const getPostgresConnectionOptions = (): PostgresConnectionOptions => {
	const postgresConfig = Container.get(GlobalConfig).database.postgresdb;
	const {
		ssl: { ca: sslCa, cert: sslCert, key: sslKey, rejectUnauthorized: sslRejectUnauthorized },
	} = postgresConfig;

	let ssl: TlsOptions | boolean = postgresConfig.ssl.enabled;
	if (sslCa !== '' || sslCert !== '' || sslKey !== '' || !sslRejectUnauthorized) {
		ssl = {
			ca: sslCa || undefined,
			cert: sslCert || undefined,
			key: sslKey || undefined,
			rejectUnauthorized: sslRejectUnauthorized,
		};
	}

	return {
		type: 'postgres',
		...getCommonOptions(),
		...getOptionOverrides(),
		migrations: postgresMigrations,
		connectTimeoutMS: postgresConfig.connectionTimeoutMs,
		ssl,
		schema: postgresConfig.schema,
	};
};

export function getConnectionOptions(): DataSourceOptions {
	return getPostgresConnectionOptions();
}

export function arePostgresOptions(
	options: DataSourceOptions,
): options is PostgresConnectionOptions {
	return options.type === 'postgres';
}
