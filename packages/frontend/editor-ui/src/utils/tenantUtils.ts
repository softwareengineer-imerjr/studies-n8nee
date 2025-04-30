import { useUsersStore } from '@/stores/users.store';
import type { RouteLocationRaw } from 'vue-router';

/**
 * Obtém o tenantId atual do usuário ou usa o padrão '1'
 */
export function getCurrentTenantId(): string {
	const usersStore = useUsersStore();
	return usersStore.currentUser?.tenantId || '1';
}

/**
 * Adiciona o tenantId às rotas que não o possuem
 * Se a rota já tiver um tenantId, mantém o existente
 */
export function addTenantIdToRoute(route: RouteLocationRaw): RouteLocationRaw {
	const tenantId = getCurrentTenantId();

	// Se for uma string, verificar se já tem o formato /:tenantId/...
	if (typeof route === 'string') {
		// Verifica se a rota já começa com /:tenantId/
		if (route.match(/^\/\d+\//)) {
			return route;
		}

		// Se começar com /, adiciona o tenantId
		if (route.startsWith('/')) {
			return `/${tenantId}${route}`;
		}

		// Caso contrário, adiciona o tenantId com /
		return `/${tenantId}/${route}`;
	}

	// Se for um objeto, verificar se já tem params.tenantId
	const routeObj = { ...route };

	// Se não tiver params, criar
	if (!routeObj.params) {
		routeObj.params = { tenantId };
	}
	// Se tiver params mas não tiver tenantId, adicionar
	else if (typeof routeObj.params === 'object' && !('tenantId' in routeObj.params)) {
		routeObj.params = { ...routeObj.params, tenantId };
	}

	return routeObj;
}
