-- Script para criar um novo usuário com tenantId específico
-- Este script deve ser executado diretamente no banco de dados PostgreSQL

-- Variáveis (serão substituídas pelo script PowerShell)
\set email 'maria@exemplo.com'
\set nome 'Maria'
\set sobrenome 'Silva'
\set senha_hash '$2a$10$UlEwKG4fgRVkjt3fgBl9.OXXa1yENUZpOrZ/jOmQNnFn3tZVTGE5W'
\set tenant_id '2'

-- Inserir um novo usuário
INSERT INTO "user" (
  id, 
  email, 
  "firstName", 
  "lastName", 
  password, 
  "personalizationAnswers",
  "createdAt", 
  "updatedAt", 
  settings,
  disabled, 
  "mfaEnabled",
  "mfaSecret",
  "mfaRecoveryCodes",
  role,
  "tenantId"
) VALUES (
  gen_random_uuid(), 
  :'email', 
  :'nome', 
  :'sobrenome', 
  :'senha_hash', 
  '{}',
  NOW(), 
  NOW(), 
  '{}',
  false, 
  false,
  NULL,
  NULL,
  'global:admin',
  :'tenant_id'
);

-- Obter o ID do usuário recém-criado
SELECT id AS user_id FROM "user" WHERE email = :'email' \gset

-- Criar um projeto pessoal para o usuário
INSERT INTO project (
  id,
  name,
  type,
  "createdAt",
  "updatedAt",
  "tenantId"
) VALUES (
  gen_random_uuid(),
  :'nome' || ' Personal Project',
  'personal',
  NOW(),
  NOW(),
  :'tenant_id'
);

-- Obter o ID do projeto recém-criado
SELECT id AS project_id FROM project WHERE name = :'nome' || ' Personal Project' AND "tenantId" = :'tenant_id' ORDER BY "createdAt" DESC LIMIT 1 \gset

-- Criar a relação entre o usuário e o projeto
INSERT INTO "project_relation" (
  id,
  "userId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(),
  :'user_id',
  :'project_id',
  'project-owner',
  NOW(),
  NOW()
);

-- Exibir informações do usuário criado
SELECT 'Usuário criado com sucesso!' AS mensagem;
SELECT id, email, "firstName", "lastName", "tenantId" FROM "user" WHERE email = :'email';
SELECT id, name, type, "tenantId" FROM project WHERE id = :'project_id';
