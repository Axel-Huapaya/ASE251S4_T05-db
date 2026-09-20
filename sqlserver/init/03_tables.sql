USE agropacayales_db;
GO

-- 1. Tabla: Personal y Usuarios
CREATE TABLE agropacayales.usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
);

-- 2. Tabla: Stock / Kardex de Insumos (con costo promedio)
CREATE TABLE finanzas.stock_insumos (
    id_insumo VARCHAR(24) PRIMARY KEY, -- Clave compartida con MongoDB insumos._id
    nombre_insumo VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    stock_disponible DECIMAL(10,2) NOT NULL DEFAULT 0,
    costo_promedio DECIMAL(10,2) NOT NULL,
    ultima_act DATETIME NOT NULL DEFAULT GETDATE()
);

-- 3. Tabla: Facturas de Compras de Insumos (Egresos Contables)
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

-- 4. Tabla: Asignación de Labores (Costeo de Insumos aplicado a cada Parcela)
CREATE TABLE agropacayales.asignacion_labores (
    id_labor INT IDENTITY(1,1) PRIMARY KEY,
    id_parcela VARCHAR(24) NOT NULL, -- Clave compartida con MongoDB parcelas._id
    id_usuario INT NOT NULL,
    id_insumo VARCHAR(24) NOT NULL,
    cantidad_usada DECIMAL(10,2) NOT NULL,
    costo_aplicado DECIMAL(10,2) NOT NULL, -- Snapshot del costo unitario al aplicar
    tipo_labor VARCHAR(50) NOT NULL,
    fecha_aplicacion DATETIME NOT NULL DEFAULT GETDATE(),
    estado VARCHAR(20) NOT NULL DEFAULT 'Ejecutado'
);

-- 5. Tabla: Liquidación Comercial de Cosechas (Ingresos por Venta de Fruta)
CREATE TABLE finanzas.liquidacion_cosechas (
    id_liquidacion INT IDENTITY(1,1) PRIMARY KEY,
    id_cosecha VARCHAR(24) NOT NULL, -- Clave compartida con MongoDB cosechas._id
    id_parcela VARCHAR(24) NOT NULL, -- Clave para cruzar directamente con la parcela
    cliente_comprador VARCHAR(100) NOT NULL,
    num_factura_venta VARCHAR(30) NOT NULL,
    kilos_facturados DECIMAL(10,2) NOT NULL,
    precio_kilo DECIMAL(10,2) NOT NULL, -- Snapshot inmutable del precio de venta
    total_liquidado DECIMAL(10,2) NOT NULL,
    fecha_facturacion DATETIME NOT NULL DEFAULT GETDATE()
);
GO
