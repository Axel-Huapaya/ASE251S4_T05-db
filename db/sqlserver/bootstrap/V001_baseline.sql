-- ==============================================================================
-- V001_baseline.sql — Agro Pacayales S.A.C.
-- Línea Base (Versión 1) del Esquema Relacional de SQL Server 2022
-- ==============================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'agropacayales_db')
BEGIN
    CREATE DATABASE agropacayales_db;
END;
GO

USE agropacayales_db;
GO

-- 1. Esquemas Organizacionales
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'agropacayales')
BEGIN
    EXEC('CREATE SCHEMA agropacayales;');
END;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'finanzas')
BEGIN
    EXEC('CREATE SCHEMA finanzas;');
END;
GO

-- 2. Tablas Maestras y Operacionales
IF OBJECT_ID(N'agropacayales.usuarios', N'U') IS NULL
BEGIN
    CREATE TABLE agropacayales.usuarios (
        id_usuario INT IDENTITY(1,1) PRIMARY KEY,
        nombre_completo VARCHAR(100) NOT NULL,
        email VARCHAR(120) NOT NULL,
        rol VARCHAR(50) NOT NULL,
        fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO

IF OBJECT_ID(N'finanzas.stock_insumos', N'U') IS NULL
BEGIN
    CREATE TABLE finanzas.stock_insumos (
        id_insumo VARCHAR(24) PRIMARY KEY, -- Clave compartida con MongoDB insumos._id
        nombre_insumo VARCHAR(100) NOT NULL,
        unidad_medida VARCHAR(20) NOT NULL,
        stock_disponible DECIMAL(10,2) NOT NULL DEFAULT 0,
        costo_promedio DECIMAL(10,2) NOT NULL,
        ultima_act DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO

IF OBJECT_ID(N'finanzas.compras_insumos', N'U') IS NULL
BEGIN
    CREATE TABLE finanzas.compras_insumos (
        id_compra INT IDENTITY(1,1) PRIMARY KEY,
        id_insumo VARCHAR(24) NOT NULL,
        proveedor VARCHAR(100) NOT NULL,
        num_factura VARCHAR(30) NOT NULL,
        cantidad DECIMAL(10,2) NOT NULL,
        precio_unitario DECIMAL(10,2) NOT NULL,
        total_compra DECIMAL(10,2) NOT NULL,
        fecha_compra DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO

IF OBJECT_ID(N'agropacayales.asignacion_labores', N'U') IS NULL
BEGIN
    CREATE TABLE agropacayales.asignacion_labores (
        id_labor INT IDENTITY(1,1) PRIMARY KEY,
        id_parcela VARCHAR(24) NOT NULL, -- Clave compartida con MongoDB parcelas._id
        id_usuario INT NOT NULL,
        id_insumo VARCHAR(24) NOT NULL,
        cantidad_usada DECIMAL(10,2) NOT NULL,
        costo_aplicado DECIMAL(10,2) NOT NULL,
        tipo_labor VARCHAR(50) NOT NULL,
        fecha_aplicacion DATETIME NOT NULL DEFAULT GETDATE(),
        estado VARCHAR(20) NOT NULL DEFAULT 'Ejecutado'
    );
END;
GO

IF OBJECT_ID(N'finanzas.liquidacion_cosechas', N'U') IS NULL
BEGIN
    CREATE TABLE finanzas.liquidacion_cosechas (
        id_liquidacion INT IDENTITY(1,1) PRIMARY KEY,
        id_cosecha VARCHAR(24) NOT NULL, -- Clave compartida con MongoDB cosechas._id
        id_parcela VARCHAR(24) NOT NULL,
        cliente_comprador VARCHAR(100) NOT NULL,
        num_factura_venta VARCHAR(30) NOT NULL,
        kilos_facturados DECIMAL(10,2) NOT NULL,
        precio_kilo DECIMAL(10,2) NOT NULL,
        total_liquidado DECIMAL(10,2) NOT NULL,
        fecha_facturacion DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO

-- 3. Restricciones e Integridad Referencial
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'AK_usuarios_email')
    ALTER TABLE agropacayales.usuarios ADD CONSTRAINT AK_usuarios_email UNIQUE (email);

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_usuarios_rol')
    ALTER TABLE agropacayales.usuarios ADD CONSTRAINT CHK_usuarios_rol CHECK (rol IN ('Supervisor de Campo', 'Ingeniero Agrónomo', 'Operario', 'Administrador'));

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_stock_no_negativo')
    ALTER TABLE finanzas.stock_insumos ADD CONSTRAINT CHK_stock_no_negativo CHECK (stock_disponible >= 0);

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_stock_costo_positivo')
    ALTER TABLE finanzas.stock_insumos ADD CONSTRAINT CHK_stock_costo_positivo CHECK (costo_promedio >= 0);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_compras_stock')
    ALTER TABLE finanzas.compras_insumos ADD CONSTRAINT FK_compras_stock FOREIGN KEY (id_insumo) REFERENCES finanzas.stock_insumos(id_insumo);

IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'AK_compras_factura')
    ALTER TABLE finanzas.compras_insumos ADD CONSTRAINT AK_compras_factura UNIQUE (num_factura);

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_compras_cantidad')
    ALTER TABLE finanzas.compras_insumos ADD CONSTRAINT CHK_compras_cantidad CHECK (cantidad > 0);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_labores_usuario')
    ALTER TABLE agropacayales.asignacion_labores ADD CONSTRAINT FK_labores_usuario FOREIGN KEY (id_usuario) REFERENCES agropacayales.usuarios(id_usuario);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_labores_stock')
    ALTER TABLE agropacayales.asignacion_labores ADD CONSTRAINT FK_labores_stock FOREIGN KEY (id_insumo) REFERENCES finanzas.stock_insumos(id_insumo);

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CHK_labores_cantidad')
    ALTER TABLE agropacayales.asignacion_labores ADD CONSTRAINT CHK_labores_cantidad CHECK (cantidad_usada > 0);

IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'AK_liquidacion_cosecha')
    ALTER TABLE finanzas.liquidacion_cosechas ADD CONSTRAINT AK_liquidacion_cosecha UNIQUE (id_cosecha);

IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'AK_liquidacion_factura')
    ALTER TABLE finanzas.liquidacion_cosechas ADD CONSTRAINT AK_liquidacion_factura UNIQUE (num_factura_venta);
GO

-- 4. Índices para Optimización de Consultas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_labores_parcela')
    CREATE NONCLUSTERED INDEX IX_labores_parcela ON agropacayales.asignacion_labores(id_parcela);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_labores_insumo')
    CREATE NONCLUSTERED INDEX IX_labores_insumo ON agropacayales.asignacion_labores(id_insumo);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_liquidacion_parcela')
    CREATE NONCLUSTERED INDEX IX_liquidacion_parcela ON finanzas.liquidacion_cosechas(id_parcela);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_compras_insumo')
    CREATE NONCLUSTERED INDEX IX_compras_insumo ON finanzas.compras_insumos(id_insumo);
GO

-- 5. Vista de Decisión Gerencial (Costos vs Ganancias)
CREATE OR ALTER VIEW finanzas.vw_comparativa_costos_ganancias AS
WITH CostosPorParcela AS (
    SELECT 
        id_parcela,
        COUNT(id_labor) AS total_labores_realizadas,
        SUM(cantidad_usada * costo_aplicado) AS costo_total_insumos_usd
    FROM agropacayales.asignacion_labores
    GROUP BY id_parcela
),
IngresosPorParcela AS (
    SELECT 
        id_parcela,
        COUNT(id_liquidacion) AS total_liquidaciones,
        SUM(kilos_facturados) AS total_kilos_exportados,
        SUM(total_liquidado) AS ingreso_total_ventas_usd
    FROM finanzas.liquidacion_cosechas
    GROUP BY id_parcela
)
SELECT 
    COALESCE(c.id_parcela, i.id_parcela) AS id_parcela,
    ISNULL(c.total_labores_realizadas, 0) AS total_labores,
    ISNULL(c.costo_total_insumos_usd, 0.00) AS costo_total_invertido_usd,
    ISNULL(i.total_kilos_exportados, 0.00) AS kilos_exportados,
    ISNULL(i.ingreso_total_ventas_usd, 0.00) AS ingreso_bruto_ventas_usd,
    (ISNULL(i.ingreso_total_ventas_usd, 0.00) - ISNULL(c.costo_total_insumos_usd, 0.00)) AS ganancia_neta_usd,
    CASE 
        WHEN ISNULL(c.costo_total_insumos_usd, 0.00) > 0 THEN 
            ROUND(((ISNULL(i.ingreso_total_ventas_usd, 0.00) - c.costo_total_insumos_usd) / c.costo_total_insumos_usd) * 100, 2)
        ELSE 0.00
    END AS retorno_inversion_roi_porc,
    CASE 
        WHEN (ISNULL(i.ingreso_total_ventas_usd, 0.00) - ISNULL(c.costo_total_insumos_usd, 0.00)) > 5000 THEN 'ALTA RENTABILIDAD (EXPANDIR)'
        WHEN (ISNULL(i.ingreso_total_ventas_usd, 0.00) - ISNULL(c.costo_total_insumos_usd, 0.00)) > 0 THEN 'RENTABLE (MANTENER)'
        ELSE 'EN PERDIDA (REVISAR COSTOS)'
    END AS evaluacion_gerencial
FROM CostosPorParcela c
FULL OUTER JOIN IngresosPorParcela i ON c.id_parcela = i.id_parcela;
GO

-- 6. Procedimiento Almacenado de Análisis Gerencial
CREATE OR ALTER PROCEDURE finanzas.sp_analizar_rentabilidad_parcela
    @id_parcela VARCHAR(24)
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '=============================================================';
    PRINT '  INFORME DE TOMA DE DECISIONES FINANCIERAS - AGRO PACAYALES ';
    PRINT '=============================================================';

    -- Costos
    SELECT 
        l.id_labor,
        l.tipo_labor,
        s.nombre_insumo,
        l.cantidad_usada,
        s.unidad_medida,
        l.costo_aplicado AS costo_unitario_usd,
        (l.cantidad_usada * l.costo_aplicado) AS subtotal_costo_usd,
        l.fecha_aplicacion
    FROM agropacayales.asignacion_labores l
    INNER JOIN finanzas.stock_insumos s ON l.id_insumo = s.id_insumo
    WHERE l.id_parcela = @id_parcela;

    -- Ingresos
    SELECT 
        liq.id_liquidacion,
        liq.id_cosecha,
        liq.cliente_comprador,
        liq.num_factura_venta,
        liq.kilos_facturados,
        liq.precio_kilo,
        liq.total_liquidado AS subtotal_ingreso_usd,
        liq.fecha_facturacion
    FROM finanzas.liquidacion_cosechas liq
    WHERE liq.id_parcela = @id_parcela;

    -- Consolidado
    SELECT 
        id_parcela,
        costo_total_invertido_usd,
        ingreso_bruto_ventas_usd,
        ganancia_neta_usd,
        retorno_inversion_roi_porc,
        evaluacion_gerencial
    FROM finanzas.vw_comparativa_costos_ganancias
    WHERE id_parcela = @id_parcela;
END;
GO

-- 7. Semilla Inicial V1
IF NOT EXISTS (SELECT 1 FROM agropacayales.usuarios)
BEGIN
    INSERT INTO agropacayales.usuarios (nombre_completo, email, rol) VALUES
    ('Carlos Mendoza', 'carlos@agro.com', 'Supervisor de Campo'),
    ('Hugo Fernandez', 'hugo@agro.com', 'Ingeniero Agrónomo'),
    ('Ana Felix', 'ana@agro.com', 'Administrador'),
    ('Axel Huapaya', 'axel@agro.com', 'Supervisor de Campo');
END;

IF NOT EXISTS (SELECT 1 FROM finanzas.stock_insumos)
BEGIN
    INSERT INTO finanzas.stock_insumos (id_insumo, nombre_insumo, unidad_medida, stock_disponible, costo_promedio) VALUES
    ('INS-BIO-001', 'Insecticida BioProtect Pro', 'Litros', 45.00, 120.00),
    ('INS-FERT-002', 'Fertilizante Foliar NPK 20-20-20', 'Sacos (50kg)', 66.00, 85.00);
END;

IF NOT EXISTS (SELECT 1 FROM finanzas.compras_insumos)
BEGIN
    INSERT INTO finanzas.compras_insumos (id_insumo, proveedor, num_factura, cantidad, precio_unitario, total_compra) VALUES
    ('INS-BIO-001', 'Bayer CropScience', 'F002-004512', 50.00, 120.00, 6000.00),
    ('INS-FERT-002', 'Yara Fertilizers Peru', 'F003-008910', 80.00, 85.00, 6800.00);
END;

IF NOT EXISTS (SELECT 1 FROM agropacayales.asignacion_labores)
BEGIN
    INSERT INTO agropacayales.asignacion_labores (id_parcela, id_usuario, id_insumo, cantidad_usada, costo_aplicado, tipo_labor) VALUES
    ('PARC-NORTE-A1', 1, 'INS-BIO-001', 5.00, 120.00, 'Control Fitosanitario'),
    ('PARC-NORTE-A1', 2, 'INS-FERT-002', 10.00, 85.00, 'Fertilización Foliar'),
    ('PARC-SUR-B2', 4, 'INS-FERT-002', 4.00, 85.00, 'Fertirriego Inicial');
END;

IF NOT EXISTS (SELECT 1 FROM finanzas.liquidacion_cosechas)
BEGIN
    INSERT INTO finanzas.liquidacion_cosechas (id_cosecha, id_parcela, cliente_comprador, num_factura_venta, kilos_facturados, precio_kilo, total_liquidado) VALUES
    ('COS-2026-001', 'PARC-NORTE-A1', 'AgroExportadora Rotterdam', 'F001-000890', 4400.00, 3.20, 14080.00);
END;
GO
