create database ERP;
go
use ERP;
-- Crear tabla Permission
CREATE TABLE Permission (
    -- Clave primaria
    id_permi BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el permiso
    -- Información básica
    name NVARCHAR(255) NOT NULL,                              -- Nombre descriptivo del permiso
    description NVARCHAR(MAX) NULL,                           -- Descripción detallada del permiso y su propósito
    -- Permisos CRUD
    can_create BIT NOT NULL DEFAULT 0,                        -- Permite crear nuevos registros
    can_read BIT NOT NULL DEFAULT 0,                          -- Permite ver registros existentes
    can_update BIT NOT NULL DEFAULT 0,                        -- Permite modificar registros existentes
    can_delete BIT NOT NULL DEFAULT 0,                        -- Permite eliminar registros existentes
    -- Permisos de transferencia de datos
    can_import BIT NOT NULL DEFAULT 0,                        -- Permite importar datos masivamente
    can_export BIT NOT NULL DEFAULT 0                         -- Permite exportar datos del sistema
);
go 
use ERP;
CREATE TABLE [User] (
    -- Primary Key
    id_user BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- Identificador único para el usuario
    -- Authentication Information
    user_username NVARCHAR(255) NOT NULL,                     -- Nombre de usuario para iniciar sesión
    user_password NVARCHAR(255) NOT NULL,                     -- Contraseña encriptada del usuario
    -- Contact Information
    user_email NVARCHAR(255) NOT NULL,                        -- Dirección de correo electrónico del usuario
    user_phone NVARCHAR(255) NULL,                            -- Número de teléfono del usuario
    -- Access Control
    user_is_admin BIT NOT NULL DEFAULT 0,                     -- Indica si el usuario es Administrador (1) o normal (0)
    user_is_active BIT NOT NULL DEFAULT 1,                    -- Indica si el usuario está activo (1) o inactivo (0)
    -- Unique Constraints
    CONSTRAINT UQ_User_Username UNIQUE (user_username),
    CONSTRAINT UQ_User_Email UNIQUE (user_email)
);
go 
use ERP;
CREATE TABLE Company (
    -- Primary Key
    id_compa BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para la compañía
    -- Company Information
    compa_name NVARCHAR(255) NOT NULL,                        -- Nombre legal completo de la compañía
    compa_tradename NVARCHAR(255) NOT NULL,                   -- Nombre comercial o marca de la compañía
    -- Document Information
    compa_doctype NVARCHAR(2) NOT NULL                        -- Tipo de documento de identificación de la compañía
        CONSTRAINT CK_Company_DocType 
        CHECK (compa_doctype IN ('NI', 'CC', 'CE', 'PP', 'OT')), -- Restricción de valores permitidos
    compa_docnum NVARCHAR(255) NOT NULL,                      -- Número de identificación fiscal o documento legal de la compañía
    -- Location Information
    compa_address NVARCHAR(255) NOT NULL,                     -- Dirección física de la compañía
    compa_city NVARCHAR(255) NOT NULL,                        -- Ciudad donde está ubicada la compañía
    compa_state NVARCHAR(255) NOT NULL,                       -- Departamento o estado donde está ubicada la compañía
    compa_country NVARCHAR(255) NOT NULL,                     -- País donde está ubicada la compañía
    -- Contact Information
    compa_industry NVARCHAR(255) NOT NULL,                    -- Sector industrial al que pertenece la compañía
    compa_phone NVARCHAR(255) NOT NULL,                       -- Número de teléfono principal de la compañía
    compa_email NVARCHAR(255) NOT NULL,                       -- Dirección de correo electrónico principal de la compañía
    compa_website NVARCHAR(255) NULL,                         -- Sitio web oficial de la compañía
    -- Media
    compa_logo NVARCHAR(MAX) NULL,                            -- Logo oficial de la compañía
    -- Status
    compa_active BIT NOT NULL DEFAULT 1                       -- Indica si la compañía está activa (1) o inactiva (0)
);
go 
use ERP;
CREATE TABLE UserCompany (
    -- Primary Key
    id_useco BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para la relación usuario-compañía
    -- Foreign Keys
    user_id BIGINT NOT NULL,                                  -- Usuario asociado a la compañía
    company_id BIGINT NOT NULL,                               -- Compañía asociada al usuario
    -- Status
    useco_active BIT NOT NULL DEFAULT 1,                      -- Indica si la relación usuario-compañía está activa (1) o inactiva (0
    -- Unique constraint for user and company combination
    CONSTRAINT UQ_User_Company UNIQUE (user_id, company_id),  -- Combinación única de usuario y compañía
    -- Foreign Key Constraints
    CONSTRAINT FK_UserCompany_User FOREIGN KEY (user_id) REFERENCES [User](id_user),
    CONSTRAINT FK_UserCompany_Company FOREIGN KEY (company_id) REFERENCES Company(id_compa)
);

go
use ERP;
-- Crear tabla EntityCatalog con relaciones
CREATE TABLE EntityCatalog (
    -- Primary Key
    id_entit INT IDENTITY(1,1) PRIMARY KEY,                    -- Identificador único para el elemento del catálogo de entidades
    -- Entity Information
    entit_name NVARCHAR(255) NOT NULL UNIQUE,                  -- Nombre del modelo Django asociado
    entit_descrip NVARCHAR(255) NOT NULL,                      -- Descripción del elemento del catálogo de entidades
    -- Status
    entit_active BIT NOT NULL DEFAULT 1,                       -- Indica si el elemento del catálogo está activo (1) o inactivo (0)
    -- Configuration
    entit_config NVARCHAR(MAX) NULL,                           -- Configuración adicional para el elemento del catálogo
    -- Relationships
    usercompany_id BIGINT NOT NULL,                            -- Relación con UserCompany
    permission_id BIGINT NOT NULL,                             -- Relación con Permisos
    -- Foreign Keys
    CONSTRAINT FK_EntityCatalog_UserCompany FOREIGN KEY (usercompany_id) REFERENCES UserCompany(id_useco),
    CONSTRAINT FK_EntityCatalog_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi)
);
go
use ERP;
-- Crear tabla PermiUser con relaciones ajustadas
CREATE TABLE PermiUser (
    id_peusr BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- ID único del permiso de usuario
    usercompany_id BIGINT NOT NULL,                           -- Usuario asociado al permiso
    permission_id BIGINT NOT NULL,                            -- Permiso asignado
    entitycatalog_id INT NOT NULL,                         -- Entidad asociada
    peusr_include BIT NOT NULL DEFAULT 1,                     -- 1: incluir, 0: excluir

    -- Foreign Keys
    CONSTRAINT FK_PermiUser_UserCompany FOREIGN KEY (usercompany_id) REFERENCES UserCompany(id_useco),
    CONSTRAINT FK_PermiUser_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiUser_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    -- Unique Constraint
    CONSTRAINT UQ_UserCompany_Permission_Entity UNIQUE (usercompany_id, permission_id, entitycatalog_id)
);
go
use ERP;
CREATE TABLE Role (
    -- Primary Key
    id_role BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- Identificador único para el rol
    -- Foreign Keys
    company_id BIGINT NOT NULL,                               -- Compañía a la que pertenece este rol
    CONSTRAINT FK_Role_Company FOREIGN KEY (company_id) REFERENCES Company(id_compa),
    -- Basic Information
    role_name NVARCHAR(255) NOT NULL,                         -- Nombre descriptivo del rol
    role_code NVARCHAR(255) NOT NULL,                         -- Código del rol (agregado basado en unique_together)
    role_description NVARCHAR(MAX) NULL,                      -- Descripción detallada del rol y sus responsabilidades
    -- Status
    role_active BIT NOT NULL DEFAULT 1,                       -- Indica si el rol está activo (1) o inactivo (0)
    -- Unique constraint for company and role code combination
    CONSTRAINT UQ_Company_RoleCode UNIQUE (company_id, role_code)
);
go
use ERP;
CREATE TABLE PermiRole (
    id_perol BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID único del permiso de rol
    role_id BIGINT NOT NULL,                  -- Rol asociado al permiso
    permission_id BIGINT NOT NULL,            -- Permiso asignado
    entitycatalog_id INT NOT NULL,         -- Entidad asociada
    perol_include BIT NOT NULL DEFAULT 1,     -- 1: incluir, 0: excluir
    CONSTRAINT FK_PermiRole_Role FOREIGN KEY (role_id) REFERENCES Role(id_role),
    CONSTRAINT FK_PermiRole_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiRole_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_Role_Permission_Entity UNIQUE (role_id, permission_id, entitycatalog_id)
);
go 
use ERP;
CREATE TABLE PermiRoleRecord (
    id_perore BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID único del permiso de rol
    role_id BIGINT NOT NULL,                   -- Rol asociado al permiso
    permission_id BIGINT NOT NULL,             -- Permiso asignado
    entitycatalog_id INT NOT NULL,          -- Entidad asociada
    record_id BIGINT NOT NULL,                 -- Registro específico
    perore_include BIT NOT NULL DEFAULT 1,     -- 1: incluir, 0: excluir
    CONSTRAINT FK_PermiRoleRecord_Role FOREIGN KEY (role_id) REFERENCES Role(id_role),
    CONSTRAINT FK_PermiRoleRecord_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiRoleRecord_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_Role_Permission_Entity_Record UNIQUE (role_id, permission_id, entitycatalog_id, record_id)
);
go 
use ERP;
CREATE TABLE PermiUserRecord (
    id_peusre BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID único del permiso de usuario
    usercompany_id BIGINT NOT NULL,            -- Usuario asociado al permiso
    permission_id BIGINT NOT NULL,             -- Permiso asignado
    entitycatalog_id INT NOT NULL,          -- Entidad asociada
    record_id BIGINT NOT NULL,                 -- Registro específico
    peusre_include BIT NOT NULL DEFAULT 1,     -- 1: incluir, 0: excluir
    CONSTRAINT FK_PermiUserRecord_UserCompany FOREIGN KEY (usercompany_id) REFERENCES UserCompany(id_useco),
    CONSTRAINT FK_PermiUserRecord_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiUserRecord_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_UserCompany_Permission_Entity_Record UNIQUE (usercompany_id, permission_id, entitycatalog_id, record_id)
);
go
use ERP;
-- Crear tabla Sucursal
CREATE TABLE BranchOffice (
    id_branch BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID de la sucursal
    branch_name NVARCHAR(255) NOT NULL,        -- Nombre de la sucursal
    branch_code NVARCHAR(50) NOT NULL UNIQUE,  -- Código único de la sucursal
    branch_active BIT NOT NULL DEFAULT 1       -- Estado de la sucursal
);

-- Crear tabla Centro de Costos
CREATE TABLE CostCenter (
    id_costcenter BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID del centro de costos
    costcenter_name NVARCHAR(255) NOT NULL,        -- Nombre del centro de costos
    costcenter_code NVARCHAR(50) NOT NULL UNIQUE,  -- Código único del centro de costos
    costcenter_active BIT NOT NULL DEFAULT 1       -- Estado del centro de costos
);


---- Consulta para Permisos de Usuarios sobre Entidades (Sucursales, Centros de Costos, etc.) 
SELECT 
    u.user_username,                     -- Nombre de usuario
    p.name AS permiso,                   -- Tipo de permiso (leer, escribir, etc.)
    ec.entit_name,                       -- Nombre de la entidad (Sucursal, Centro de Costos, etc.)
    CASE
        WHEN pu.peusr_include = 1 THEN 'Asignado'  -- Estado del permiso
        ELSE 'No Asignado'
    END AS estado_permiso,
    c.compa_name                         -- Nombre de la compañía desde la tabla 'Company'
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
JOIN
    Company c ON uc.company_id = c.id_compa    -- Relación con la tabla 'Company'
WHERE 
    pu.peusr_include = 1;                -- Permiso asignado

------Consulta para Permisos Específicos de Usuario sobre Registros (por ejemplo, sucursales o centros de costos específicos)
SELECT 
    u.user_username,                     -- Nombre de usuario
    p.name AS permiso,                   -- Tipo de permiso (leer, escribir, etc.)
    ec.entit_name,                       -- Nombre de la entidad (Sucursal, Centro de Costos, etc.)
    pur.record_id,                        -- ID del registro específico (Sucursal específica, Centro de Costos específico)
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
    pur.peusre_include = 1;                -- Permiso asignado

-- Consulta para Permisos de Roles sobre Entidades
	SELECT 
    r.role_name,                         -- Nombre del rol
    p.name AS permiso,                   -- Tipo de permiso (leer, escribir, etc.)
    ec.entit_name,                       -- Nombre de la entidad (Sucursal, Centro de Costos, etc.)
    CASE
        WHEN pr.perol_include = 1 THEN 'Asignado'  -- Estado del permiso
        ELSE 'No Asignado'
    END AS estado_permiso
FROM 
    PermiRole pr
JOIN 
    Role r ON pr.role_id = r.id_role
JOIN 
    Permission p ON pr.permission_id = p.id_permi
JOIN 
    EntityCatalog ec ON pr.entitycatalog_id = ec.id_entit
WHERE 
    pr.perol_include = 1;                 -- Permiso asignado


--Consulta para Permisos Específicos de Roles sobre Registros
SELECT 
    r.role_name,                         -- Nombre del rol
    p.name AS permiso,                   -- Tipo de permiso (leer, escribir, etc.)
    ec.entit_name,                       -- Nombre de la entidad (Sucursal, Centro de Costos, etc.)
    prr.record_id,                        -- ID del registro específico (Sucursal específica, Centro de Costos específico)
    CASE
        WHEN prr.perore_include = 1 THEN 'Asignado'  -- Estado del permiso sobre el registro
        ELSE 'No Asignado'
    END AS estado_permiso
FROM 
    PermiRoleRecord prr
JOIN 
    Role r ON prr.role_id = r.id_role
JOIN 
    Permission p ON prr.permission_id = p.id_permi
JOIN 
    EntityCatalog ec ON prr.entitycatalog_id = ec.id_entit
WHERE 
    prr.perore_include = 1;               -- Permiso asignado

--Verificacion de roles disponibles
SELECT id_role, role_name 
FROM Role;
--Verificacion de permisos 
SELECT id_permi, name 
FROM Permission;
--Verificar entidades disponibles
SELECT id_entit, entit_name 
FROM EntityCatalog;

----Consultar datos de las tablas creadas---
select * from UserCompany;
select * from PermiUser;
select * from Company;
select * from EntityCatalog;
select * from Permission;
select * from PermiRole;
select * from BranchOffice;
select * from [User];
select * from Role;


---Validar Permisos Asginados----
SELECT 
    u.user_username,                     -- Nombre del usuario
    c.compa_name,                        -- Nombre de la compañía
    ec.entit_name AS entidad,            -- Nombre de la entidad (BranchOffice, CostCenter, etc.)
    r.record_id AS registro,             -- ID del registro específico
    CASE 
        WHEN r.peusre_include = 1 THEN 'Asignado'
        ELSE 'No Asignado'
    END AS estado_permiso,
    p.name AS permiso                    -- Nombre del permiso (Lectura, Escritura, etc.)
FROM 
    PermiUserRecord r
JOIN 
    UserCompany uc ON r.usercompany_id = uc.id_useco
JOIN 
    [User] u ON uc.user_id = u.id_user
JOIN 
    Permission p ON r.permission_id = p.id_permi
JOIN 
    EntityCatalog ec ON r.entitycatalog_id = ec.id_entit
JOIN 
    Company c ON uc.company_id = c.id_compa;

-- Validar registros de sucursales
SELECT id_branch, branch_name, branch_code FROM BranchOffice;

-- Validar registros de centros de costos
SELECT id_costcenter, costcenter_name, costcenter_code FROM CostCenter;

-- Validar permisos de roles sobre registros
SELECT 
    r.role_name, 
    ec.entit_name AS entidad,
    prr.record_id AS registro,
    CASE 
        WHEN prr.perore_include = 1 THEN 'Asignado'
        ELSE 'No Asignado'
    END AS estado_permiso,
    p.name AS permiso
FROM 
    PermiRoleRecord prr
JOIN 
    Role r ON prr.role_id = r.id_role
JOIN 
    Permission p ON prr.permission_id = p.id_permi
JOIN 
    EntityCatalog ec ON prr.entitycatalog_id = ec.id_entit;

-- Validar registros disponibles en BranchOffice
SELECT 
    id_branch AS id_branch, 
    branch_name, 
    branch_code 
FROM 
    BranchOffice;

-- Validar registros disponibles en CostCenter
SELECT 
    id_costcenter AS id_costcenter, 
    costcenter_name, 
    costcenter_code 
FROM 
    CostCenter;
