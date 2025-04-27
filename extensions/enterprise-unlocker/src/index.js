"use strict";

module.exports = async function(app) {
  // Registrar a extensão
  console.log('🔓 Extensão Enterprise Unlocker carregada');
  
  try {
    // Obter a instância do License Manager
    const licenseManager = global.licenseMgr;
    
    if (licenseManager) {
      console.log('✅ License Manager encontrado, aplicando patch...');
      
      // Substituir os métodos do License Manager para simular licença Enterprise
      licenseManager.hasFeatureEnabled = () => true;
      licenseManager.getFeatureValue = () => Infinity;
      licenseManager.getMainPlan = () => ({ productId: 'enterprise', planName: 'enterprise' });
      
      console.log('🎉 Recursos Enterprise desbloqueados com sucesso!');
    } else {
      console.log('❌ License Manager não encontrado. Tentando outra abordagem...');
      
      // Tentar encontrar o License Manager no módulo CLI
      const n8nCli = require('n8n');
      if (n8nCli && n8nCli.License && n8nCli.License.prototype) {
        console.log('✅ License class encontrada via n8n-cli, aplicando patch...');
        
        // Guardar a implementação original
        const originalInit = n8nCli.License.prototype.init;
        
        // Substituir o método init para injetar nosso código
        n8nCli.License.prototype.init = async function(...args) {
          // Chamar o método original primeiro
          await originalInit.apply(this, args);
          
          // Aplicar nosso patch após a inicialização
          if (this.manager) {
            console.log('⚠️ Pulando checagem de licença (via extensão)');
            this.manager.hasFeatureEnabled = () => true;
            this.manager.getFeatureValue = () => Infinity;
            this.manager.getMainPlan = () => ({ productId: 'enterprise', planName: 'enterprise' });
            console.log('🎉 Recursos Enterprise desbloqueados com sucesso!');
          }
        };
      }
    }
  } catch (error) {
    console.error('❌ Erro ao aplicar patch de licença:', error);
  }
};
