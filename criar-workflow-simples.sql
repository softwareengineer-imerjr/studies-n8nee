-- Inserir um workflow com tenantId específico
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
  "tenantId"
) VALUES (
  gen_random_uuid(),
  'Workflow da Maria',
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
  '2'
);
