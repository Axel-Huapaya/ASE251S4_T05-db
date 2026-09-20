USE agropacayales_db;
GO

-- Índices de optimización para consultas de costos por parcela
CREATE NONCLUSTERED INDEX IX_labores_parcela ON agropacayales.asignacion_labores(id_parcela);
CREATE NONCLUSTERED INDEX IX_labores_insumo ON agropacayales.asignacion_labores(id_insumo);

-- Índices de optimización para consultas de ingresos por parcela
CREATE NONCLUSTERED INDEX IX_liquidacion_parcela ON finanzas.liquidacion_cosechas(id_parcela);

-- Índice de compras por insumo
CREATE NONCLUSTERED INDEX IX_compras_insumo ON finanzas.compras_insumos(id_insumo);
GO
