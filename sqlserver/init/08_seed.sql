USE agropacayales_db;
GO

-- 1. Usuarios
INSERT INTO agropacayales.usuarios (nombre_completo, email, rol) VALUES
('Carlos Mendoza', 'carlos@agro.com', 'Supervisor de Campo'),
('Hugo Fernandez', 'hugo@agro.com', 'Ingeniero Agrónomo'),
('Ana Felix', 'ana@agro.com', 'Administrador'),
('Axel Huapaya', 'axel@agro.com', 'Supervisor de Campo');

-- 2. Stock inicial de insumos con su costo promedio
INSERT INTO finanzas.stock_insumos (id_insumo, nombre_insumo, unidad_medida, stock_disponible, costo_promedio) VALUES
('INS-BIO-001', 'Insecticida BioProtect Pro', 'Litros', 45.00, 120.00),
('INS-FERT-002', 'Fertilizante Foliar NPK 20-20-20', 'Sacos (50kg)', 66.00, 85.00);

-- 3. Compras registradas con factura legal
INSERT INTO finanzas.compras_insumos (id_insumo, proveedor, num_factura, cantidad, precio_unitario, total_compra) VALUES
('INS-BIO-001', 'Bayer CropScience', 'F002-004512', 50.00, 120.00, 6000.00),
('INS-FERT-002', 'Yara Fertilizers Peru', 'F003-008910', 80.00, 85.00, 6800.00);

-- 4. Labores de aplicación (Costeo real por parcela)
INSERT INTO agropacayales.asignacion_labores (id_parcela, id_usuario, id_insumo, cantidad_usada, costo_aplicado, tipo_labor) VALUES
('PARC-NORTE-A1', 1, 'INS-BIO-001', 5.00, 120.00, 'Control Fitosanitario'),   -- Costo: $600.00
('PARC-NORTE-A1', 2, 'INS-FERT-002', 10.00, 85.00, 'Fertilización Foliar'),   -- Costo: $850.00
('PARC-SUR-B2', 4, 'INS-FERT-002', 4.00, 85.00, 'Fertirriego Inicial');        -- Costo: $340.00

-- 5. Liquidaciones de cosechas (Ingresos facturados)
INSERT INTO finanzas.liquidacion_cosechas (id_cosecha, id_parcela, cliente_comprador, num_factura_venta, kilos_facturados, precio_kilo, total_liquidado) VALUES
('COS-2026-001', 'PARC-NORTE-A1', 'AgroExportadora Rotterdam', 'F001-000890', 4400.00, 3.20, 14080.00);
GO
