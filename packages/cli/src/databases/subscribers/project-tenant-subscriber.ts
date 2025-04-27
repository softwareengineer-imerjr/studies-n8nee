import { EventSubscriber, EntitySubscriberInterface, InsertEvent } from '@n8n/typeorm';
import { Project } from '../entities/project';

@EventSubscriber()
export class ProjectTenantSubscriber implements EntitySubscriberInterface<Project> {
	listenTo() {
		return Project;
	}

	beforeInsert(event: InsertEvent<Project>) {
		// Se não veio tenantId (fluxo de setup), atribui o valor padrão '1'
		if (!event.entity.tenantId) {
			event.entity.tenantId = '1';
		}
	}
}
