import type { Request, Response, NextFunction } from 'express';

import { tenantContext } from './context';

// Extend the Request interface to include the user field
declare global {
	namespace Express {
		interface Request {
			user?: {
				tenantId?: string;
			};
		}
	}
}

/**
 * Middleware to configure tenant context for each request.
 * Extracts tenant ID from URLs in the format /:tenantId/... and configures the context.
 * Allows login from any tenant and then uses the authenticated user's tenantId.
 */
export function tenantMiddleware(req: Request, _res: Response, next: NextFunction): void {
	const { path } = req;
	const defaultTenantId = '1';

	// Rota de setup não precisa de tenant
	if (path === '/setup' || path.startsWith('/setup/')) {
		tenantContext.run({ tenantId: defaultTenantId }, () => {
			next();
		});
		return;
	}

	// Rotas de login não precisam de tenant
	if (
		path === '/signin' ||
		path.startsWith('/signin/') ||
		path === '/signout' ||
		path.startsWith('/signout/')
	) {
		tenantContext.run({ tenantId: defaultTenantId }, () => {
			next();
		});
		return;
	}

	// Rotas de API não precisam de tenant no URL
	if (path.startsWith('/api/') || path.startsWith('/rest/')) {
		tenantContext.run({ tenantId: defaultTenantId }, () => {
			next();
		});
		return;
	}

	// Extrai o tenantId da URL
	const match = path.match(/^\/(\d+)(?:\/|$)/);
	if (match) {
		const [, tenantId] = match;
		// Reescreve a URL para remover o tenantId
		req.url = req.url.replace(/^\/\d+/, '');
		if (req.url === '') {
			req.url = '/';
		}

		tenantContext.run({ tenantId }, () => {
			next();
		});
	} else {
		// Se não tem tenantId na URL, usa o padrão
		tenantContext.run({ tenantId: defaultTenantId }, () => {
			next();
		});
	}
}
