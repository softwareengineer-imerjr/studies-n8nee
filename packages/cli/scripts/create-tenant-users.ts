import { v4 as uuid } from 'uuid';
import { In } from '@n8n/typeorm';
import { randomBytes, createHash } from 'crypto';
import { Container } from '@n8n/di';
import { User } from '@/databases/entities/user';
import { AuthIdentity } from '@/databases/entities/auth-identity';
import { Project } from '@/databases/entities/project';
import { logger } from '@/logger';
import { encryptPassword } from '@/auth/encryption';
import { getApiServer } from '../src/api-server';
import config from '../src/config';

/**
 * Create test tenant users
 */
export async function createTenantUsers() {
	const server = await getApiServer();
	await server.start();

	const dataSource = Container.get(
		config.getEnv('database.type') === 'postgresdb' ? 'postgres' : 'sqlite',
	);

	// Check if users already exist
	const userRepository = dataSource.getRepository(User);
	const existingUsers = await userRepository.find({
		where: {
			email: In(['tenant1@example.com', 'tenant2@example.com']),
		},
	});

	if (existingUsers.length > 0) {
		logger.info(`Tenant users already exist: ${existingUsers.map((u) => u.email).join(', ')}`);
		return;
	}

	// Create users for different tenants
	await createTenantUser(
		{
			firstName: 'Tenant1',
			lastName: 'User',
			email: 'tenant1@example.com',
			password: 'password123',
			tenantId: '1',
		},
		dataSource,
	);

	await createTenantUser(
		{
			firstName: 'Tenant2',
			lastName: 'User',
			email: 'tenant2@example.com',
			password: 'password123',
			tenantId: '2',
		},
		dataSource,
	);

	logger.info('✅ Created tenant test users');
	await server.stop();
}

interface CreateUserData {
	firstName: string;
	lastName: string;
	email: string;
	password: string;
	tenantId: string;
}

async function createTenantUser(userData: CreateUserData, dataSource: any) {
	const { firstName, lastName, email, password, tenantId } = userData;

	const userRepository = dataSource.getRepository(User);
	const authIdentityRepository = dataSource.getRepository(AuthIdentity);
	const projectRepository = dataSource.getRepository(Project);

	// Hash password
	const salt = randomBytes(16).toString('hex');
	const hashedPassword = await encryptPassword(password, salt);

	// Create user
	const user = new User();
	user.id = uuid();
	user.firstName = firstName;
	user.lastName = lastName;
	user.email = email;
	user.password = hashedPassword;
	user.role = 'global:admin';
	user.tenantId = tenantId;

	// Create auth identity
	const authIdentity = new AuthIdentity();
	authIdentity.userId = user.id;
	authIdentity.providerId = email;
	authIdentity.providerType = 'email';

	// Create personal project
	const project = new Project();
	project.id = uuid();
	project.name = `${firstName} ${lastName}`;
	project.type = 'personal';
	project.tenantId = tenantId;

	try {
		// Save entities
		await userRepository.save(user);
		await authIdentityRepository.save(authIdentity);
		await projectRepository.save(project);

		logger.info(`Created user ${email} with tenant ID: ${tenantId}`);
	} catch (error) {
		logger.error(`Failed to create tenant user ${email}:`, error);
	}
}

// Execute if this script is run directly
if (require.main === module) {
	void createTenantUsers()
		.then(() => {
			process.exit(0);
		})
		.catch((err) => {
			console.error('Error creating tenant users:', err);
			process.exit(1);
		});
}
