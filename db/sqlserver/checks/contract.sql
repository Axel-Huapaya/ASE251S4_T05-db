SET NOCOUNT ON;

DECLARE @requested_version INT = $(target_schema_version);

IF OBJECT_ID(N'dbo.schema_changes', N'U') IS NULL
    THROW 50001, 'No existe dbo.schema_changes en SQL Server', 1;

IF (SELECT COUNT(*) FROM dbo.schema_changes) <> @requested_version
   OR (SELECT ISNULL(MIN([sequence]), 0) FROM dbo.schema_changes) <> 1
   OR (SELECT ISNULL(MAX([sequence]), 0) FROM dbo.schema_changes) <> @requested_version
    THROW 50002, 'Historial de cambios discontinuo o distinto de la versión solicitada', 1;

-- Verificación de objetos base (V1)
IF OBJECT_ID(N'agropacayales.usuarios', N'U') IS NULL
   OR OBJECT_ID(N'finanzas.stock_insumos', N'U') IS NULL
   OR OBJECT_ID(N'finanzas.compras_insumos', N'U') IS NULL
   OR OBJECT_ID(N'agropacayales.asignacion_labores', N'U') IS NULL
   OR OBJECT_ID(N'finanzas.liquidacion_cosechas', N'U') IS NULL
   OR OBJECT_ID(N'finanzas.vw_comparativa_costos_ganancias', N'V') IS NULL
   OR OBJECT_ID(N'finanzas.sp_analizar_rentabilidad_parcela', N'P') IS NULL
    THROW 50003, 'Faltan objetos del contrato base de SQL Server (agropacayales_db)', 1;

-- Verificación de semillas
IF NOT EXISTS (SELECT 1 FROM agropacayales.usuarios WHERE email = 'carlos@agro.com')
   OR NOT EXISTS (SELECT 1 FROM finanzas.stock_insumos WHERE id_insumo = 'INS-BIO-001')
    THROW 50004, 'Faltan registros semilla requeridos en SQL Server', 1;

-- Verificación de V2 (Evolución)
IF @requested_version >= 2
BEGIN
    IF OBJECT_ID(N'agropacayales.auditoria_labores', N'U') IS NULL
        THROW 50005, 'V2 requiere la tabla agropacayales.auditoria_labores', 1;

    IF COL_LENGTH(N'agropacayales.asignacion_labores', N'alerta_fitosanitaria_iot') IS NULL
        THROW 50006, 'V2 requiere la columna alerta_fitosanitaria_iot en asignacion_labores', 1;
END;

PRINT 'SQL Server: contrato ' + CONVERT(VARCHAR(12), @requested_version) + ' verificado con éxito.';
