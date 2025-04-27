-- Script para criar um novo usuário com tenantId específico
-- Este script deve ser executado diretamente no banco de dados PostgreSQL

-- Inserir um novo usuário
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
  "tenantId"
) VALUES (
  gen_random_uuid(), -- ID aleatório
  'maria@exemplo.com', -- Email
  'Maria', -- Nome
  'Silva', -- Sobrenome
  '$2a$10$UlEwKG4fgRVkjt3fgBl9.OXXa1yENUZpOrZ/jOmQNnFn3tZVTGE5W', -- Senha (hash de 'Senha123!')
  NULL, -- resetPasswordToken
  NULL, -- resetPasswordTokenExpiration
  NULL, -- personalizationAnswers
  NOW(), -- createdAt
  NOW(), -- updatedAt
  'global-admin', -- globalRoleId (admin)
  'email', -- signInType
  false, -- disabled
  '2' -- tenantId (diferente do usuário padrão)
) RETURNING "id";

-- Criar um projeto pessoal para o usuário
-- Nota: Substitua 'USER_ID_HERE' pelo ID retornado da consulta anterior
INSERT INTO "project" (
  "id",
  "name",
  "type",
  "createdAt",
  "updatedAt",
  "tenantId"
) VALUES (
  gen_random_uuid(), -- ID aleatório
  'Maria Personal Project', -- Nome do projeto
  'personal', -- Tipo (pessoal)
  NOW(), -- createdAt
  NOW(), -- updatedAt
  '2' -- tenantId (mesmo do usuário)
) RETURNING "id";

-- Criar a relação entre o usuário e o projeto
-- Nota: Substitua 'USER_ID_HERE' e 'PROJECT_ID_HERE' pelos IDs retornados das consultas anteriores
INSERT INTO "project_relation" (
  "id",
  "userId",
  "projectId",
  "roleId",
  "createdAt",
  "updatedAt"
) VALUES (
  gen_random_uuid(), -- ID aleatório
  'USER_ID_HERE', -- ID do usuário
  'PROJECT_ID_HERE', -- ID do projeto
  'project-owner', -- Papel (dono do projeto)
  NOW(), -- createdAt
  NOW() -- updatedAt
);
