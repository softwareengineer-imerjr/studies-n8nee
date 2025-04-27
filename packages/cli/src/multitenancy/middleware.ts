import { Request, Response, NextFunction } from 'express';
import { tenantContext } from './context';

// Estender a interface Request para incluir o campo user
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
 * Middleware para configurar o contexto de tenant para cada requisição.
 * Permite login de qualquer tenant e depois usa o tenantId do usuário autenticado.
 */
export function tenantMiddleware(req: Request, _res: Response, next: NextFunction): void {
	// Verificar se é uma requisição de login
	const isLoginRequest = req.path === '/rest/login' && req.method === 'POST';

	if (isLoginRequest) {
		// Para requisições de login, não aplicamos filtro de tenant
		// Isso permite que usuários de qualquer tenant façam login
		tenantContext.run({ tenantId: '' }, () => {
			next();
		});
		return;
	}

	// Verificar se o usuário está autenticado
	if (req.user && req.user.tenantId) {
		// Se o usuário estiver autenticado, usar o tenantId do usuário
		tenantContext.run({ tenantId: req.user.tenantId }, () => {
			next();
		});
		return;
	}

	// Para todas as outras requisições, usar o tenantId padrão
	const tenantId = '1'; // ID de tenant padrão

	// Executar o próximo middleware no contexto do tenant
	tenantContext.run({ tenantId }, () => {
		next();
	});
}
