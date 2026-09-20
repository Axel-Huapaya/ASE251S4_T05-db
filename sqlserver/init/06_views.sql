USE agropacayales_db;
GO

-- ==========================================================================
-- VISTA DE DECISIÓN GERENCIAL: Comparativa de Costos vs Ganancias por Parcela
-- ==========================================================================
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
