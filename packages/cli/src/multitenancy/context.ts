import { AsyncLocalStorage } from 'async_hooks';

export interface TenantStore {
	tenantId: string;
}

export const tenantContext = new AsyncLocalStorage<TenantStore>();
