# Matriz de Propiedad de Datos — Agro Pacayales S.A.C.
**Curso:** ASE251S4 - Implementación de Base de Datos como Código  
**Objetivo del Sistema:** Comparación de Costos vs Ganancias para la Toma de Decisiones Estratégicas

---

## 📊 1. Matriz de Propiedad de Entidades

| Entidad de Negocio | Motor de Persistencia | Justificación Arquitectónica |
| :--- | :---: | :--- |
| **Venta / Liquidación de Cosecha** | **SQL Server** | Requiere transacción estricta (ACID), registro fiscal inmutable y cobro en moneda oficial. |
| **Compra de Insumos (Egresos)** | **SQL Server** | Requiere consistencia financiera absoluta contra facturas de proveedores. |
| **Kardex de Inventario** | **SQL Server** | Evita sobreconsumos con restricción `CHECK (stock_disponible >= 0)`. |
| **Costeo de Labores por Parcela** | **SQL Server** | Acumula el costo real invertido por hectárea/parcela (`cantidad_usada * costo_promedio`). |
| **Snapshot de Venta y Costo** | **SQL Server** | Conserva la historia inmutable del precio pactado al momento de liquidar. |
| **Parcela (Geometría Satelital)** | **MongoDB** | Maneja polígonos GPS GeoJSON (`Polygon`), altitud y propiedades de suelo variables. |
| **Insumo (Catálogo Técnico)** | **MongoDB** | Posee atributos químicos y biológicos dinámicos (fórmula NPK, SENASA, carencia). |
| **Cosecha de Campo (Trazabilidad)**| **MongoDB** | Almacena calibres exportables, análisis de laboratorio (Brix, materia seca) y certificaciones. |
| **Ficha de Campo** | **MongoDB** | Registro flexible de evaluaciones fitosanitarias, fotos de plagas y recomendaciones. |

---

## ⚖️ 2. Regla de Arquitectura de Oro (Inmutabilidad Financiera)

> **Regla de Arquitectura:** Si el precio de un insumo o el valor de mercado de la palta varía en el catálogo vivo (MongoDB), la liquidación histórica y el costo registrado en las labores ya ejecutadas **no se alteran**. El **snapshot inmutable de costos y ganancias vive exclusivamente en SQL Server** para garantizar auditoría contable y estados financieros fidedignos.

---

## 📈 3. Ecuación de Toma de Decisiones (Rentabilidad por Parcela)

Para que el directorio de Agro Pacayales S.A.C. tome decisiones sobre qué cultivos expandir o qué parcelas requieren optimización:

$$\text{Costo Total de Inversión} = \sum (\text{Cantidad Usada de Insumo} \times \text{Costo Promedio Unitario})$$

$$\text{Ingreso Bruto de Venta} = \text{Kilos Facturados de Fruta} \times \text{Precio por Kilo}$$

$$\text{Ganancia Neta (Margen)} = \text{Ingreso Bruto} - \text{Costo Total de Inversión}$$

$$\text{Rentabilidad (\%)} = \left( \frac{\text{Ganancia Neta}}{\text{Costo Total de Inversión}} \right) \times 100$$
