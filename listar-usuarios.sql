-- Listar todos os usuários e seus tenantIds
SELECT id, email, "firstName", "lastName", "tenantId" FROM "user";

-- Listar todos os projetos e seus tenantIds
SELECT id, name, type, "tenantId" FROM project;

-- Listar as relações entre usuários e projetos
SELECT pr.id, u.email, p.name, pr."roleId", u."tenantId" as user_tenant, p."tenantId" as project_tenant
FROM "project_relation" pr
JOIN "user" u ON pr."userId" = u.id
JOIN project p ON pr."projectId" = p.id;
