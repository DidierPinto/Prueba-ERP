CREATE PROCEDURE GetUserPermissions
    @entitycatalog_id INT,
    @user_id BIGINT
AS
BEGIN
    -- Obtener permisos a nivel de entidad (por usuario directamente)
    SELECT 
        u.user_username,                          -- Nombre de usuario
        p.name AS permiso,                        -- Tipo de permiso (leer, escribir, etc.)
        ec.entit_name,                            -- Nombre de la entidad
        NULL AS record_id,                        -- No hay ID de registro en este nivel
        CASE
            WHEN pu.peusr_include = 1 THEN 'Asignado'  -- Estado del permiso sobre la entidad
            ELSE 'No Asignado'
        END AS estado_permiso
    FROM 
        PermiUser pu
    JOIN 
        UserCompany uc ON pu.usercompany_id = uc.id_useco
    JOIN 
        [User] u ON uc.user_id = u.id_user
    JOIN 
        Permission p ON pu.permission_id = p.id_permi
    JOIN 
        EntityCatalog ec ON pu.entitycatalog_id = ec.id_entit
    WHERE 
        pu.entitycatalog_id = @entitycatalog_id
        AND u.id_user = @user_id
        AND pu.peusr_include = 1  -- Permiso asignado a nivel de entidad

    UNION

    -- Obtener permisos a nivel de entidad (por rol)
    SELECT 
        u.user_username,                          -- Nombre de usuario
        p.name AS permiso,                        -- Tipo de permiso (leer, escribir, etc.)
        ec.entit_name,                            -- Nombre de la entidad
        NULL AS record_id,                        -- No hay ID de registro en este nivel
        CASE
            WHEN pr.perol_include = 1 THEN 'Asignado'  -- Estado del permiso sobre la entidad
            ELSE 'No Asignado'
        END AS estado_permiso
    FROM 
        PermiRole pr
    JOIN 
        Role r ON pr.role_id = r.id_role          -- Unir por 'role_id' en PermiRole
    JOIN 
        UserCompany uc ON uc.company_id = r.company_id  -- Relacionar con la compañía en UserCompany
    JOIN 
        [User] u ON uc.user_id = u.id_user
    JOIN 
        Permission p ON pr.permission_id = p.id_permi
    JOIN 
        EntityCatalog ec ON pr.entitycatalog_id = ec.id_entit
    WHERE 
        pr.entitycatalog_id = @entitycatalog_id
        AND u.id_user = @user_id
        AND pr.perol_include = 1  -- Permiso asignado a nivel de entidad

    UNION

    -- Obtener permisos a nivel de registros (más granular)
    SELECT 
        u.user_username,                          -- Nombre de usuario
        p.name AS permiso,                        -- Tipo de permiso (leer, escribir, etc.)
        ec.entit_name,                            -- Nombre de la entidad
        pur.record_id,                            -- ID del registro específico
        CASE
            WHEN pur.peusre_include = 1 THEN 'Asignado'  -- Estado del permiso sobre el registro
            ELSE 'No Asignado'
        END AS estado_permiso
    FROM 
        PermiUserRecord pur
    JOIN 
        UserCompany uc ON pur.usercompany_id = uc.id_useco
        JOIN 
        [User] u ON uc.user_id = u.id_user
    JOIN 
        Permission p ON pur.permission_id = p.id_permi
    JOIN 
        EntityCatalog ec ON pur.entitycatalog_id = ec.id_entit
    WHERE 
        pur.entitycatalog_id = @entitycatalog_id
        AND u.id_user = @user_id
        AND pur.peusre_include = 1  -- Permiso asignado a nivel de registro

    UNION

    -- Obtener permisos a nivel de registros (más granular, por rol)
    SELECT 
        u.user_username,                          -- Nombre de usuario
        p.name AS permiso,                        -- Tipo de permiso (leer, escribir, etc.)
        ec.entit_name,                            -- Nombre de la entidad
        prr.record_id,                            -- ID del registro específico
        CASE
            WHEN prr.perore_include = 1 THEN 'Asignado'  -- Estado del permiso sobre el registro
            ELSE 'No Asignado'
        END AS estado_permiso
    FROM 
        PermiRoleRecord prr
    JOIN 
        Role r ON prr.role_id = r.id_role       -- Unir por 'role_id' en PermiRoleRecord
    JOIN 
        UserCompany uc ON uc.company_id = r.company_id  -- Relacionar con la compañía en UserCompany
    JOIN 
        [User] u ON uc.user_id = u.id_user
    JOIN 
        Permission p ON prr.permission_id = p.id_permi
    JOIN 
        EntityCatalog ec ON prr.entitycatalog_id = ec.id_entit
    WHERE 
        prr.entitycatalog_id = @entitycatalog_id
        AND u.id_user = @user_id
        AND prr.perore_include = 1  -- Permiso asignado a nivel de registro
END;


-- Ejecutar el procedimiento para un usuario y entidad específicos
EXEC GetUserPermissions 
    @entitycatalog_id = 1,  -- ID de la entidad (Sucursal)
    @user_id = 123;         -- ID del usuario (ej. Juan Pérez)

