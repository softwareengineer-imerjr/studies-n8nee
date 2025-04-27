import { EventSubscriber, EntitySubscriberInterface, InsertEvent } from '@n8n/typeorm';
import { User } from '../entities/user';

@EventSubscriber()
export class UserTenantSubscriber implements EntitySubscriberInterface<User> {
	listenTo() {
		return User;
	}

	beforeInsert(event: InsertEvent<User>) {
		// Se não veio tenantId (fluxo de setup), atribui o valor padrão '1'
		if (!event.entity.tenantId) {
			event.entity.tenantId = '1';
		}
	}
}
