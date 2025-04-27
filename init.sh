#!/bin/bash

# Encontrar o arquivo license.ts
LICENSE_FILE=$(find /usr/local/lib/node_modules/n8n -name "license.ts" -type f | head -n 1)

if [ -z "$LICENSE_FILE" ]; then
  echo "❌ Arquivo license.ts não encontrado!"
  exit 1
fi

echo "✅ Arquivo license.ts encontrado em: $LICENSE_FILE"

# Backup do arquivo original
cp "$LICENSE_FILE" "${LICENSE_FILE}.bak"

# Aplicar o patch
PATCH_POINT=$(grep -n "this.manager = new LicenseManager" "$LICENSE_FILE" | cut -d: -f1)
NEXT_LINE=$((PATCH_POINT + 1))

if [ -z "$PATCH_POINT" ]; then
  echo "❌ Ponto de inserção não encontrado no arquivo license.ts!"
  exit 1
fi

echo "✅ Ponto de inserção encontrado na linha $PATCH_POINT"

# Criar arquivo temporário com o conteúdo modificado
awk -v patch_point="$PATCH_POINT" '
  NR == patch_point {
    print $0
    print ""
    print "      // === HACK: forçar \"Enterprise\" em modo local ==="
    print "      if (process.env.N8N_SKIP_LICENSE_CHECK === \"true\") {"
    print "        this.logger.warn(\"⚠️ Pulando checagem de licença (N8N_SKIP_LICENSE_CHECK=true)\");"
    print "        // habilita todas as features"
    print "        this.manager.hasFeatureEnabled = () => true;"
    print "        // aumenta cotas ilimitadas (exemplo para time-project limit)"
    print "        this.manager.getFeatureValue = (_feature) => Infinity;"
    print "        // força plano enterprise"
    print "        this.manager.getMainPlan = () => ({ productId: \"enterprise\", planName: \"enterprise\" } as any);"
    print "      }"
  }
  { print $0 }
' "$LICENSE_FILE" > "${LICENSE_FILE}.new"

# Substituir o arquivo original pelo modificado
mv "${LICENSE_FILE}.new" "$LICENSE_FILE"

echo "✅ Patch aplicado com sucesso!"

# Iniciar o n8n
exec n8n start
