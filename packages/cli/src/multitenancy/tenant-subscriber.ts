import { EntitySubscriberInterface, InsertEvent, EventSubscriber, UpdateEvent } from '@n8n/typeorm';
import { tenantContext } from './context';

/**
 * Subscriber para automaticamente atribuir o tenantId a entidades
 * antes de serem inseridas ou atualizadas no banco de dados.
 */
@EventSubscriber()
export class TenantSubscriber implements EntitySubscriberInterface {
	/**
	 * Chamado antes de inserir uma entidade no banco de dados.
	 * Atribui o tenantId do contexto atual à entidade, se a entidade tiver essa propriedade.
	 */
	beforeInsert(event: InsertEvent<any>): void {
		this.setTenantId(event.entity);
	}

	/**
	 * Chamado antes de atualizar uma entidade no banco de dados.
	 * Atribui o tenantId do contexto atual à entidade, se a entidade tiver essa propriedade.
	 */
	beforeUpdate(event: UpdateEvent<any>): void {
		this.setTenantId(event.entity);
	}

	/**
	 * Atribui o tenantId do contexto atual à entidade, se a entidade tiver essa propriedade.
	 */
	private setTenantId(entity: any): void {
		// Verifica se a entidade tem a propriedade tenantId
		if (entity && 'tenantId' in entity) {
			const context = tenantContext.getStore();

			// Se o contexto existir e tiver um tenantId não vazio, use-o
			if (context && context.tenantId && context.tenantId !== '') {
				entity.tenantId = context.tenantId;
			}
			// Se o tenantId da entidade não estiver definido, defina como '1' (padrão)
			else if (!entity.tenantId) {
				entity.tenantId = '1';
			}
			// Se o tenantId já estiver definido na entidade, mantenha-o
		}
	}
}
