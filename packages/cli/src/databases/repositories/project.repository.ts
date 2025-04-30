import { Service } from '@n8n/di';
import type { EntityManager } from '@n8n/typeorm';
import { DataSource, Repository } from '@n8n/typeorm';

import { tenantContext } from '@/multitenancy/context';

import { Project } from '../entities/project';

@Service()
export class ProjectRepository extends Repository<Project> {
	constructor(dataSource: DataSource) {
		super(Project, dataSource.manager);
	}

	async getPersonalProjectForUser(userId: string, entityManager?: EntityManager) {
		const tenantId = tenantContext.getStore()?.tenantId ?? '1';
		const em = entityManager ?? this.manager;

		return await em.findOne(Project, {
			where: {
				type: 'personal',
				tenantId,
				projectRelations: { userId, role: 'project:personalOwner' },
			},
		});
	}

	async getPersonalProjectForUserOrFail(userId: string, entityManager?: EntityManager) {
		const tenantId = tenantContext.getStore()?.tenantId ?? '1';
		const em = entityManager ?? this.manager;

		return await em.findOneOrFail(Project, {
			where: {
				type: 'personal',
				tenantId,
				projectRelations: { userId, role: 'project:personalOwner' },
			},
		});
	}

	async getAccessibleProjects(userId: string) {
		const tenantId = tenantContext.getStore()?.tenantId ?? '';
		return await this.find({
			where: [
				{ type: 'personal', tenantId },
				{ projectRelations: { userId }, tenantId },
			],
		});
	}

	async getProjectCounts() {
		const tenantId = tenantContext.getStore()?.tenantId ?? '';
		return {
			personal: await this.count({ where: { type: 'personal', tenantId } }),
			team: await this.count({ where: { type: 'team', tenantId } }),
		};
	}
}
