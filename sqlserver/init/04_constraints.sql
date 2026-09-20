USE agropacayales_db;
GO

-- Restricciones para usuarios
ALTER TABLE agropacayales.usuarios
ADD CONSTRAINT AK_usuarios_email UNIQUE (email),
    CONSTRAINT CHK_usuarios_rol CHECK (rol IN ('Supervisor de Campo', 'Ingeniero Agrónomo', 'Operario', 'Administrador'));

-- Restricciones para stock_insumos
ALTER TABLE finanzas.stock_insumos
ADD CONSTRAINT CHK_stock_no_negativo CHECK (stock_disponible >= 0),
    CONSTRAINT CHK_stock_costo_positivo CHECK (costo_promedio >= 0);

-- Restricciones para compras_insumos
ALTER TABLE finanzas.compras_insumos
ADD CONSTRAINT FK_compras_stock FOREIGN KEY (id_insumo) REFERENCES finanzas.stock_insumos(id_insumo),
    CONSTRAINT AK_compras_factura UNIQUE (num_factura),
    CONSTRAINT CHK_compras_cantidad CHECK (cantidad > 0),
    CONSTRAINT CHK_compras_precio CHECK (precio_unitario > 0);

-- Restricciones para asignacion_labores
ALTER TABLE agropacayales.asignacion_labores
ADD CONSTRAINT FK_labores_usuario FOREIGN KEY (id_usuario) REFERENCES agropacayales.usuarios(id_usuario),
    CONSTRAINT FK_labores_stock FOREIGN KEY (id_insumo) REFERENCES finanzas.stock_insumos(id_insumo),
    CONSTRAINT CHK_labores_cantidad CHECK (cantidad_usada > 0),
    CONSTRAINT CHK_labores_costo CHECK (costo_aplicado >= 0);

-- Restricciones para liquidacion_cosechas
ALTER TABLE finanzas.liquidacion_cosechas
ADD CONSTRAINT AK_liquidacion_cosecha UNIQUE (id_cosecha),
    CONSTRAINT AK_liquidacion_factura UNIQUE (num_factura_venta),
    CONSTRAINT CHK_liquidacion_kilos CHECK (kilos_facturados > 0),
    CONSTRAINT CHK_liquidacion_precio CHECK (precio_kilo > 0);
GO
