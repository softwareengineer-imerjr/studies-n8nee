-- Script para criar um workflow de teste para um usuário específico
-- Este script deve ser executado diretamente no banco de dados PostgreSQL

-- Variáveis (serão substituídas pelo script PowerShell)
\set email 'maria@exemplo.com'
\set workflow_name 'Workflow de Teste'
\set tenant_id '2'

-- Obter o ID do usuário
SELECT id AS user_id FROM "user" WHERE email = :'email' \gset

-- Obter o ID do projeto pessoal do usuário
SELECT p.id AS project_id 
FROM project p 
JOIN "project_relation" pr ON p.id = pr."projectId" 
WHERE pr."userId" = :'user_id' AND p.type = 'personal' \gset

-- Criar um workflow para o usuário
INSERT INTO workflow_entity (
  id,
  name,
  active,
  nodes,
  connections,
  "createdAt",
  "updatedAt",
  "pinData",
  settings,
  "staticData",
  "versionId",
  "triggerCount",
  "shared",
  "ownerId",
  "tenantId"
) VALUES (
  gen_random_uuid(),
  :'workflow_name',
  false,
  '[]',
  '{}',
  NOW(),
  NOW(),
  '{}',
  '{}',
  '{}',
  NULL,
  0,
  false,
  :'user_id',
  :'tenant_id'
) RETURNING id AS workflow_id \gset

-- Compartilhar o workflow com o projeto pessoal do usuário
INSERT INTO "shared_workflow" (
  id,
  "roleId",
  "userId",
  "workflowId",
  "projectId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  'workflow-owner',
  :'user_id',
  :'workflow_id',
  :'project_id',
  NOW(),
  NOW()
);

-- Exibir informações do workflow criado
SELECT 'Workflow criado com sucesso!' AS mensagem;
SELECT id, name, "ownerId", "tenantId" FROM workflow_entity WHERE id = :'workflow_id';
