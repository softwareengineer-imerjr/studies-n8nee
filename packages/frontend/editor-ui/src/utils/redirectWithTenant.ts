/**
 * Utilitário para redirecionar URLs para incluir o tenantId
 */

/**
 * Redireciona para a URL com o tenantId incluído
 * @param path Caminho atual (sem o tenantId)
 * @param tenantId ID do tenant (padrão: '1')
 */
export function redirectToTenantUrl(path: string, tenantId: string = '1'): string {
	// Se o caminho já começar com /:tenantId/, não faz nada
	if (path.match(/^\/\d+\//)) {
		return path;
	}

	// Remove a barra inicial se existir
	const cleanPath = path.startsWith('/') ? path.substring(1) : path;

	// Retorna o caminho com o tenantId
	return `/${tenantId}/${cleanPath}`;
}
