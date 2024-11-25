create database ERP;
go
use ERP;
-- Crear tabla Permission
CREATE TABLE Permission (
    -- Clave primaria
    id_permi BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador �nico para el permiso
    -- Informaci�n b�sica
    name NVARCHAR(255) NOT NULL,                              -- Nombre descriptivo del permiso
    description NVARCHAR(MAX) NULL,                           -- Descripci�n detallada del permiso y su prop�sito
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
    id_user BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- Identificador �nico para el usuario
    -- Authentication Information
    user_username NVARCHAR(255) NOT NULL,                     -- Nombre de usuario para iniciar sesi�n
    user_password NVARCHAR(255) NOT NULL,                     -- Contrase�a encriptada del usuario
    -- Contact Information
    user_email NVARCHAR(255) NOT NULL,                        -- Direcci�n de correo electr�nico del usuario
    user_phone NVARCHAR(255) NULL,                            -- N�mero de tel�fono del usuario
    -- Access Control
    user_is_admin BIT NOT NULL DEFAULT 0,                     -- Indica si el usuario es Administrador (1) o normal (0)
    user_is_active BIT NOT NULL DEFAULT 1,                    -- Indica si el usuario est� activo (1) o inactivo (0)
    -- Unique Constraints
    CONSTRAINT UQ_User_Username UNIQUE (user_username),
    CONSTRAINT UQ_User_Email UNIQUE (user_email)
);
go 
use ERP;
CREATE TABLE Company (
    -- Primary Key
    id_compa BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador �nico para la compa��a
    -- Company Information
    compa_name NVARCHAR(255) NOT NULL,                        -- Nombre legal completo de la compa��a
    compa_tradename NVARCHAR(255) NOT NULL,                   -- Nombre comercial o marca de la compa��a
    -- Document Information
    compa_doctype NVARCHAR(2) NOT NULL                        -- Tipo de documento de identificaci�n de la compa��a
        CONSTRAINT CK_Company_DocType 
        CHECK (compa_doctype IN ('NI', 'CC', 'CE', 'PP', 'OT')), -- Restricci�n de valores permitidos
    compa_docnum NVARCHAR(255) NOT NULL,                      -- N�mero de identificaci�n fiscal o documento legal de la compa��a
    -- Location Information
    compa_address NVARCHAR(255) NOT NULL,                     -- Direcci�n f�sica de la compa��a
    compa_city NVARCHAR(255) NOT NULL,                        -- Ciudad donde est� ubicada la compa��a
    compa_state NVARCHAR(255) NOT NULL,                       -- Departamento o estado donde est� ubicada la compa��a
    compa_country NVARCHAR(255) NOT NULL,                     -- Pa�s donde est� ubicada la compa��a
    -- Contact Information
    compa_industry NVARCHAR(255) NOT NULL,                    -- Sector industrial al que pertenece la compa��a
    compa_phone NVARCHAR(255) NOT NULL,                       -- N�mero de tel�fono principal de la compa��a
    compa_email NVARCHAR(255) NOT NULL,                       -- Direcci�n de correo electr�nico principal de la compa��a
    compa_website NVARCHAR(255) NULL,                         -- Sitio web oficial de la compa��a
    -- Media
    compa_logo NVARCHAR(MAX) NULL,                            -- Logo oficial de la compa��a
    -- Status
    compa_active BIT NOT NULL DEFAULT 1                       -- Indica si la compa��a est� activa (1) o inactiva (0)
);
go 
use ERP;
CREATE TABLE UserCompany (
    -- Primary Key
    id_useco BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador �nico para la relaci�n usuario-compa��a
    -- Foreign Keys
    user_id BIGINT NOT NULL,                                  -- Usuario asociado a la compa��a
    company_id BIGINT NOT NULL,                               -- Compa��a asociada al usuario
    -- Status
    useco_active BIT NOT NULL DEFAULT 1,                      -- Indica si la relaci�n usuario-compa��a est� activa (1) o inactiva (0
    -- Unique constraint for user and company combination
    CONSTRAINT UQ_User_Company UNIQUE (user_id, company_id),  -- Combinaci�n �nica de usuario y compa��a
    -- Foreign Key Constraints
    CONSTRAINT FK_UserCompany_User FOREIGN KEY (user_id) REFERENCES [User](id_user),
    CONSTRAINT FK_UserCompany_Company FOREIGN KEY (company_id) REFERENCES Company(id_compa)
);

go
use ERP;
-- Crear tabla EntityCatalog con relaciones
CREATE TABLE EntityCatalog (
    -- Primary Key
    id_entit INT IDENTITY(1,1) PRIMARY KEY,                    -- Identificador �nico para el elemento del cat�logo de entidades
    -- Entity Information
    entit_name NVARCHAR(255) NOT NULL UNIQUE,                  -- Nombre del modelo Django asociado
    entit_descrip NVARCHAR(255) NOT NULL,                      -- Descripci�n del elemento del cat�logo de entidades
    -- Status
    entit_active BIT NOT NULL DEFAULT 1,                       -- Indica si el elemento del cat�logo est� activo (1) o inactivo (0)
    -- Configuration
    entit_config NVARCHAR(MAX) NULL,                           -- Configuraci�n adicional para el elemento del cat�logo
    -- Relationships
    usercompany_id BIGINT NOT NULL,                            -- Relaci�n con UserCompany
    permission_id BIGINT NOT NULL,                             -- Relaci�n con Permisos
    -- Foreign Keys
    CONSTRAINT FK_EntityCatalog_UserCompany FOREIGN KEY (usercompany_id) REFERENCES UserCompany(id_useco),
    CONSTRAINT FK_EntityCatalog_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi)
);
go
use ERP;
-- Crear tabla PermiUser con relaciones ajustadas
CREATE TABLE PermiUser (
    id_peusr BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- ID �nico del permiso de usuario
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
    id_role BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- Identificador �nico para el rol
    -- Foreign Keys
    company_id BIGINT NOT NULL,                               -- Compa��a a la que pertenece este rol
    CONSTRAINT FK_Role_Company FOREIGN KEY (company_id) REFERENCES Company(id_compa),
    -- Basic Information
    role_name NVARCHAR(255) NOT NULL,                         -- Nombre descriptivo del rol
    role_code NVARCHAR(255) NOT NULL,                         -- C�digo del rol (agregado basado en unique_together)
    role_description NVARCHAR(MAX) NULL,                      -- Descripci�n detallada del rol y sus responsabilidades
    -- Status
    role_active BIT NOT NULL DEFAULT 1,                       -- Indica si el rol est� activo (1) o inactivo (0)
    -- Unique constraint for company and role code combination
    CONSTRAINT UQ_Company_RoleCode UNIQUE (company_id, role_code)
);
go
use ERP;
CREATE TABLE PermiRole (
    id_perol BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID �nico del permiso de rol
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
    id_perore BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID �nico del permiso de rol
    role_id BIGINT NOT NULL,                   -- Rol asociado al permiso
    permission_id BIGINT NOT NULL,             -- Permiso asignado
    entitycatalog_id INT NOT NULL,          -- Entidad asociada
    record_id BIGINT NOT NULL,                 -- Registro espec�fico
    perore_include BIT NOT NULL DEFAULT 1,     -- 1: incluir, 0: excluir
    CONSTRAINT FK_PermiRoleRecord_Role FOREIGN KEY (role_id) REFERENCES Role(id_role),
    CONSTRAINT FK_PermiRoleRecord_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiRoleRecord_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_Role_Permission_Entity_Record UNIQUE (role_id, permission_id, entitycatalog_id, record_id)
);

go 
use ERP;
CREATE TABLE PermiUserRecord (
    id_peusre BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID �nico del permiso de usuario
    usercompany_id BIGINT NOT NULL,            -- Usuario asociado al permiso
    permission_id BIGINT NOT NULL,             -- Permiso asignado
    entitycatalog_id INT NOT NULL,          -- Entidad asociada
    record_id BIGINT NOT NULL,                 -- Registro espec�fico
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
    branch_code NVARCHAR(50) NOT NULL UNIQUE,  -- C�digo �nico de la sucursal
    branch_active BIT NOT NULL DEFAULT 1       -- Estado de la sucursal
);

-- Crear tabla Centro de Costos
CREATE TABLE CostCenter (
    id_costcenter BIGINT IDENTITY(1,1) PRIMARY KEY, -- ID del centro de costos
    costcenter_name NVARCHAR(255) NOT NULL,        -- Nombre del centro de costos
    costcenter_code NVARCHAR(50) NOT NULL UNIQUE,  -- C�digo �nico del centro de costos
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
    c.compa_name                         -- Nombre de la compa��a desde la tabla 'Company'
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
    Company c ON uc.company_id = c.id_compa    -- Relaci�n con la tabla 'Company'
WHERE 
    pu.peusr_include = 1;                -- Permiso asignado

------Consulta para Permisos Espec�ficos de Usuario sobre Registros (por ejemplo, sucursales o centros de costos espec�ficos)
SELECT 
    u.user_username,                     -- Nombre de usuario
    p.name AS permiso,                   -- Tipo de permiso (leer, escribir, etc.)
    ec.entit_name,                       -- Nombre de la entidad (Sucursal, Centro de Costos, etc.)
    pur.record_id,                        -- ID del registro espec�fico (Sucursal espec�fica, Centro de Costos espec�fico)
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


--Consulta para Permisos Espec�ficos de Roles sobre Registros
SELECT 
    r.role_name,                         -- Nombre del rol
    p.name AS permiso,                   -- Tipo de permiso (leer, escribir, etc.)
    ec.entit_name,                       -- Nombre de la entidad (Sucursal, Centro de Costos, etc.)
    prr.record_id,                        -- ID del registro espec�fico (Sucursal espec�fica, Centro de Costos espec�fico)
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


