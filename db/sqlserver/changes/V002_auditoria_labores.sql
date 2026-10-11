-- ==============================================================================
-- V002_auditoria_labores.sql — Agro Pacayales S.A.C.
-- Evolución de Esquema (Versión 2): Auditoría y Trazabilidad de Labores
-- ==============================================================================

USE agropacayales_db;
GO

-- 1. Tabla de Auditoría Inmutable de Labores Agrícolas
IF OBJECT_ID(N'agropacayales.auditoria_labores', N'U') IS NULL
BEGIN
    CREATE TABLE agropacayales.auditoria_labores (
        id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
        id_labor INT NOT NULL,
        id_parcela VARCHAR(24) NOT NULL,
        id_insumo VARCHAR(24) NOT NULL,
        accion VARCHAR(20) NOT NULL,
        detalles_modificacion NVARCHAR(MAX) NULL,
        fecha_auditoria DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
        usuario_sistema NVARCHAR(100) NOT NULL DEFAULT SUSER_SNAME()
    );
END;
GO

-- 2. Nueva Columna de Integración con Telemetría IoT (Alerta Fitosanitaria)
IF COL_LENGTH(N'agropacayales.asignacion_labores', N'alerta_fitosanitaria_iot') IS NULL
BEGIN
    ALTER TABLE agropacayales.asignacion_labores
    ADD alerta_fitosanitaria_iot BIT NOT NULL CONSTRAINT DF_labores_alerta DEFAULT 0;
END;
GO

-- 3. Trigger de Trazabilidad Automática
CREATE OR ALTER TRIGGER agropacayales.trg_auditar_labores
ON agropacayales.asignacion_labores
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO agropacayales.auditoria_labores (id_labor, id_parcela, id_insumo, accion, detalles_modificacion)
    SELECT 
        i.id_labor,
        i.id_parcela,
        i.id_insumo,
        CASE WHEN d.id_labor IS NULL THEN 'REGISTRO_INICIAL' ELSE 'ACTUALIZACION_COSTO' END,
        CONCAT('Cantidad: ', i.cantidad_usada, ' | Costo aplicado: USD ', i.costo_aplicado, ' | Tipo: ', i.tipo_labor)
    FROM inserted i
    LEFT JOIN deleted d ON i.id_labor = d.id_labor;
END;
GO

-- 4. Registrar auditoría retroactiva de las labores existentes en V1
IF NOT EXISTS (SELECT 1 FROM agropacayales.auditoria_labores)
BEGIN
    INSERT INTO agropacayales.auditoria_labores (id_labor, id_parcela, id_insumo, accion, detalles_modificacion)
    SELECT id_labor, id_parcela, id_insumo, 'MIGRACION_V002', CONCAT('Migracion inicial de labor ', tipo_labor)
    FROM agropacayales.asignacion_labores;
END;
GO

PRINT 'SQL Server: V002 aplicado con éxito (Auditoría de labores y alerta IoT integrada).';
