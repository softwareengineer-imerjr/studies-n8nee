<!-- 
  Componente que verifica se a URL atual inclui o tenantId e redireciona se necessário.
  Este componente deve ser incluído no App.vue para garantir que todas as URLs incluam o tenantId.
-->
<script setup lang="ts">
import { onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useUsersStore } from '@/stores/users.store';
import { useSettingsStore } from '@/stores/settings.store';
import { redirectToTenantUrl } from '@/utils/redirectWithTenant';
import { VIEWS } from '@/constants';

const route = useRoute();
const router = useRouter();
const usersStore = useUsersStore();
const settingsStore = useSettingsStore();

// Função para verificar e redirecionar se necessário
function checkAndRedirect() {
	// Verificar se precisa configurar o usuário global:owner
	if (settingsStore.showSetupPage) {
		if (route.name !== VIEWS.SETUP) {
			try {
				void router.push({ name: VIEWS.SETUP });
			} catch (error) {
				// Silenciar erro de navegação
			}
		}
		return;
	}

	// Ignorar rotas de autenticação e setup
	if (
		route.path.includes('/signin') ||
		route.path.includes('/setup') ||
		route.path.includes('/signout') ||
		route.path === '/' ||
		!usersStore.currentUser // Ignorar se o usuário não estiver autenticado
	) {
		return;
	}

	// Se a URL não incluir o tenantId, redirecionar
	if (!route.path.match(/^\/\d+\//)) {
		// Usar o tenantId do usuário ou o padrão '1'
		const tenantId = usersStore.currentUser?.tenantId ?? '1';
		const newPath = redirectToTenantUrl(route.path, tenantId);

		// Só redireciona se o caminho for diferente
		if (newPath !== route.path) {
			try {
				void router.push({
					path: newPath,
					query: route.query,
					hash: route.hash,
				});
			} catch (error) {
				// Silenciar erro de navegação
			}
		}
	}
}

// Verificar quando o componente é montado
onMounted(() => {
	checkAndRedirect();
});

// Verificar quando a rota muda
watch(
	() => route.path,
	() => {
		checkAndRedirect();
	},
);

// Verificar quando o usuário é autenticado
watch(
	() => usersStore.currentUser,
	() => {
		checkAndRedirect();
	},
);

// Verificar quando o status de setup muda
watch(
	() => settingsStore.showSetupPage,
	() => {
		checkAndRedirect();
	},
);
</script>

<template>
	<!-- Componente invisível, apenas para lógica de redirecionamento -->
	<div style="display: none"></div>
</template>
