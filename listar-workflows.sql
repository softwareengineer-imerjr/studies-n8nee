-- Listar todos os workflows e seus tenantIds
SELECT w.id, w.name, w."tenantId"
FROM workflow_entity w
ORDER BY w."tenantId";
