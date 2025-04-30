-- Adicionar a coluna tenantId à tabela execution_entity se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'execution_entity' AND column_name = 'tenantid'
    ) THEN
        ALTER TABLE execution_entity ADD COLUMN "tenantId" varchar(36) NOT NULL DEFAULT '1';
        CREATE INDEX "IDX_execution_entity_tenantId" ON execution_entity("tenantId");
    END IF;
END $$;

-- Criar projetos pessoais para usuários que não possuem
DO $$
DECLARE
    user_record RECORD;
    project_id uuid;
    project_name text;
    tenant_id varchar(36);
BEGIN
    FOR user_record IN 
        SELECT u.id, u.email, u."firstName", u."lastName", u."tenantId"
        FROM "user" u
        WHERE NOT EXISTS (
            SELECT 1 FROM project p
            JOIN project_relation pr ON p.id = pr."projectId"
            WHERE pr."userId" = u.id AND p.type = 'personal'
        )
    LOOP
        -- Gerar UUID para o projeto
        project_id := gen_random_uuid();
        
        -- Criar nome do projeto
        IF user_record."firstName" IS NOT NULL AND user_record."lastName" IS NOT NULL AND user_record.email IS NOT NULL THEN
            project_name := user_record."firstName" || ' ' || user_record."lastName" || ' <' || user_record.email || '>';
        ELSIF user_record.email IS NOT NULL THEN
            project_name := '<' || user_record.email || '>';
        ELSE
            project_name := 'Unnamed Project';
        END IF;
        
        -- Definir tenant_id (usar o do usuário ou o padrão '1')
        tenant_id := COALESCE(user_record."tenantId", '1');
        
        -- Inserir o projeto
        INSERT INTO project (id, name, type, "tenantId", "createdAt", "updatedAt")
        VALUES (project_id, project_name, 'personal', tenant_id, NOW(), NOW());
        
        -- Inserir a relação do projeto com o usuário
        INSERT INTO project_relation ("projectId", "userId", role, "createdAt", "updatedAt")
        VALUES (project_id, user_record.id, 'project:admin', NOW(), NOW());
        
        RAISE NOTICE 'Projeto pessoal criado para o usuário %', user_record.email;
    END LOOP;
END $$;
