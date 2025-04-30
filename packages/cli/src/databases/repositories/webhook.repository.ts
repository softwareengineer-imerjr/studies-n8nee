import { Service } from '@n8n/di';
import { DataSource, Repository } from '@n8n/typeorm';
import type { FindManyOptions, FindOptionsWhere } from '@n8n/typeorm';

import { tenantContext } from '@/multitenancy/context';

import { WebhookEntity } from '../entities/webhook-entity';

@Service()
export class WebhookRepository extends Repository<WebhookEntity> {
	constructor(dataSource: DataSource) {
		super(WebhookEntity, dataSource.manager);
	}

	async findByWebhookPath(webhookPath: string): Promise<WebhookEntity[]> {
		const tenantId = tenantContext.getStore()?.tenantId ?? '';
		return await this.find({
			where: { webhookPath, tenantId },
		});
	}

	async findByWorkflowId(workflowId: string): Promise<WebhookEntity[]> {
		const tenantId = tenantContext.getStore()?.tenantId ?? '';
		return await this.find({
			where: { workflowId, tenantId },
		});
	}

	override async find(options?: FindManyOptions<WebhookEntity>): Promise<WebhookEntity[]> {
		const tenantId = tenantContext.getStore()?.tenantId ?? '';

		if (!options) {
			return await super.find({ where: { tenantId } });
		}

		const newOptions = { ...options };
		if (!newOptions.where) {
			newOptions.where = { tenantId };
		} else if (Array.isArray(newOptions.where)) {
			// Handle array of where conditions
			newOptions.where = newOptions.where.map((condition) => ({
				...condition,
				tenantId,
			}));
		} else {
			// Handle single where condition
			newOptions.where = {
				...newOptions.where,
				tenantId,
			};
		}

		return await super.find(newOptions);
	}

	// Adicionando o método findBy com suporte a multitenancy
	override async findBy(
		where: FindOptionsWhere<WebhookEntity> | Array<FindOptionsWhere<WebhookEntity>>,
	): Promise<WebhookEntity[]> {
		const tenantId = tenantContext.getStore()?.tenantId ?? '';

		if (Array.isArray(where)) {
			// Handle array of where conditions
			const whereWithTenant = where.map((condition) => ({
				...condition,
				tenantId,
			}));
			return await super.findBy(whereWithTenant);
		} else {
			// Handle single where condition
			const whereWithTenant = {
				...where,
				tenantId,
			};
			return await super.findBy(whereWithTenant);
		}
	}
}
