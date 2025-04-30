import { EventSubscriber, EntitySubscriberInterface, InsertEvent } from '@n8n/typeorm';
import { ExecutionEntity } from '../entities/execution-entity';

@EventSubscriber()
export class ExecutionTenantSubscriber implements EntitySubscriberInterface<ExecutionEntity> {
	listenTo() {
		return ExecutionEntity;
	}

	beforeInsert(event: InsertEvent<ExecutionEntity>) {
		// Se não veio tenantId (fluxo de setup), atribui o valor padrão '1'
		if (!event.entity.tenantId) {
			event.entity.tenantId = '1';
		}
	}
}
