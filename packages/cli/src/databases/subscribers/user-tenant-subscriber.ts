import { Container } from '@n8n/di';
import type { EntitySubscriberInterface, InsertEvent } from '@n8n/typeorm';
import { EventSubscriber } from '@n8n/typeorm';
import { randomUUID } from 'crypto';
import { Logger } from 'n8n-core';

import { Project } from '../entities/project';
import { ProjectRelation } from '../entities/project-relation';
import { User } from '../entities/user';

// Papel correto para projetos pessoais
const projectPersonalOwnerRole = 'project:personalOwner'; // Usado para definir o papel do proprietário de um projeto pessoal

@EventSubscriber()
export class UserTenantSubscriber implements EntitySubscriberInterface<User> {
	private readonly logger = Container.get(Logger);

	listenTo() {
		return User;
	}

	beforeInsert(event: InsertEvent<User>) {
		// Gera um novo tenantId para cada usuário
		// Se não for o primeiro usuário (que já deve ter tenantId '1')
		if (!event.entity.tenantId) {
			// Gera um novo UUID para o tenantId
			event.entity.tenantId = randomUUID();
			this.logger.info(`Novo usuário criado com tenantId: ${event.entity.tenantId}`);
		}
	}

	async afterInsert(event: InsertEvent<User>): Promise<void> {
		try {
			// Verificar se o usuário já tem um projeto pessoal
			const user = event.entity;

			// Verificar se já existe um projeto pessoal para este usuário
			const existingProject = await event.manager.findOne(Project, {
				where: {
					type: 'personal',
					projectRelations: {
						userId: user.id,
					},
				},
			});

			if (existingProject) {
				this.logger.debug(`Usuário ${user.email} já possui um projeto pessoal`);
				return;
			}

			// Criar projeto pessoal
			const projectName = user.createPersonalProjectName();
			const projectId = randomUUID();

			// Criar o projeto
			const project = new Project();
			project.id = projectId;
			project.name = projectName;
			project.type = 'personal';
			project.tenantId = user.tenantId;

			await event.manager.save(project);

			// Criar relação do projeto com o usuário
			const projectRelation = new ProjectRelation();
			projectRelation.projectId = projectId;
			projectRelation.userId = user.id;
			projectRelation.role = projectPersonalOwnerRole; // Usando o papel correto

			await event.manager.save(projectRelation);

			this.logger.info(
				`Projeto pessoal criado automaticamente para o usuário ${user.email} com tenantId ${user.tenantId}`,
			);
		} catch (error) {
			this.logger.error('Erro ao criar projeto pessoal para o usuário', {
				error: error instanceof Error ? error.message : String(error),
			});
		}
	}
}
