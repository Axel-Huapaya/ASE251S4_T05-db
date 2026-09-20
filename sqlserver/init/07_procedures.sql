USE agropacayales_db;
GO

-- ==========================================================================
-- PROCEDIMIENTO ALMACENADO: Análisis Detallado de Rentabilidad por Parcela
-- Permite tomar decisiones de inversión en insumos para la siguiente campaña
-- ==========================================================================
CREATE OR ALTER PROCEDURE finanzas.sp_analizar_rentabilidad_parcela
    @id_parcela VARCHAR(24)
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '=============================================================';
    PRINT '  INFORME DE TOMA DE DECISIONES FINANCIERAS - AGRO PACAYALES ';
    PRINT '=============================================================';

    -- 1. Resumen de costos de insumos aplicados en la parcela
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

    -- 2. Resumen de ingresos por liquidación de cosecha
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

    -- 3. Balance Consolidado y Veredicto de Decisión
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
