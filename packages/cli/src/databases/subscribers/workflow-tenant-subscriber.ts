import { Service } from '@n8n/di';
import type { EntitySubscriberInterface, InsertEvent } from '@n8n/typeorm';
import { EventSubscriber } from '@n8n/typeorm';

import { tenantContext } from '@/multitenancy/context';

import { WorkflowEntity } from '../entities/workflow-entity';

@Service()
@EventSubscriber()
export class WorkflowTenantSubscriber implements EntitySubscriberInterface<WorkflowEntity> {
	listenTo() {
		return WorkflowEntity;
	}

	/**
	 * Executado antes da inserção de um workflow no banco de dados.
	 * Define o tenantId com base no contexto atual ou usa o valor padrão '1'.
	 */
	beforeInsert(event: InsertEvent<WorkflowEntity>): void {
		// Se o tenantId não foi definido, use o do contexto ou o padrão '1'
		if (!event.entity.tenantId) {
			const tenantId = tenantContext.getStore()?.tenantId ?? '1';
			event.entity.tenantId = tenantId;
		}
	}
}
