-- Script para criar a usuária Maria com todas as configurações necessárias
-- Este script cria um usuário, um projeto pessoal, uma relação entre eles e um workflow inicial

-- Inserir a usuária Maria
INSERT INTO "user" (
  "id", 
  "email", 
  "firstName", 
  "lastName", 
  "password", 
  "resetPasswordToken", 
  "resetPasswordTokenExpiration", 
  "personalizationAnswers", 
  "createdAt", 
  "updatedAt", 
  "globalRoleId", 
  "signInType", 
  "disabled", 
  "tenantId",
  "role"
) VALUES (
  gen_random_uuid(), 
  'maria@exemplo.com', 
  'Maria', 
  'Silva', 
  '$2a$10$UlEwKG4fgRVkjt3fgBl9.OXXa1yENUZpOrZ/jOmQNnFn3tZVTGE5W', -- Hash para 'Senha123!'
  NULL, 
  NULL, 
  NULL, 
  NOW(), 
  NOW(), 
  'global-admin', 
  'email', 
  false, 
  '2',
  'global:member'
) RETURNING "id" \gset

-- Criar um projeto pessoal para a usuária
INSERT INTO "project" (
  "id",
  "name",
  "type",
  "createdAt",
  "updatedAt",
  "tenantId"
) VALUES (
  gen_random_uuid(),
  'Maria''s Personal Project',
  'personal',
  NOW(),
  NOW(),
  '2'
) RETURNING "id" \gset project_

-- Relacionar a usuária ao projeto
INSERT INTO "project_relation" (
  "id",
  "userId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  :"id",
  :"project_id",
  'project:personalOwner',
  NOW(),
  NOW()
);

-- Criar um workflow inicial
INSERT INTO "workflow_entity" (
  "id",
  "name",
  "active",
  "createdAt",
  "updatedAt",
  "versionId",
  "tenantId"
) VALUES (
  gen_random_uuid(),
  'Meu Primeiro Workflow',
  false,
  NOW(),
  NOW(),
  gen_random_uuid(),
  '2'
) RETURNING "id" \gset workflow_

-- Relacionar o workflow ao projeto
INSERT INTO "shared_workflow" (
  "id",
  "workflowId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  :"workflow_id",
  :"project_id",
  'workflow:owner',
  NOW(),
  NOW()
);

-- Mostrar os IDs criados
SELECT 'Usuária Maria criada com sucesso!' AS resultado;
SELECT 'ID da usuária: ' || :"id" AS user_id;
SELECT 'ID do projeto: ' || :"project_id" AS project_id;
SELECT 'ID do workflow: ' || :"workflow_id" AS workflow_id;
