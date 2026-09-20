# Arquitectura de Persistencia Políglota — Agro Pacayales S.A.C.
**Curso:** ASE251S4 - Implementación de Base de Datos como Código

---

## 🏛️ 1. Visión General de la Plataforma

La solución implementa una arquitectura desacoplada de persistencia políglota encapsulada en contenedores Docker inmutables y versionados (`1.0`):

```
                               ┌────────────────────────────────────────┐
                               │           AGRO PACAYALES APP           │
                               │        (Comparador de Rentabilidad)    │
                               └──────────────────┬─────────────────────┘
                                                  │
                                 ┌────────────────┴────────────────┐
                                 ▼                                 ▼
                     (Transaccional / Kardex)          (Geoespacial / Catálogo)
                  ┌─────────────────────────────┐   ┌─────────────────────────────┐
                  │ 🗄️ SQL SERVER 2022          │   │ 🍃 MONGODB 8.0              │
                  │ Puerto: 1433                │   │ Puerto: 27017               │
                  │ Imagen:                     │   │ Imagen:                     │
                  │ ase251s4-db-sqlserver:1.0   │   │ ase251s4-db-mongodb:1.0     │
                  └──────────────┬──────────────┘   └──────────────┬──────────────┘
                                 │                                 │
                   (Costo Invertido vs Ganancia)       (Parcelas, Insumos, Cosechas)
```

---

## ⛓️ 2. Dependencias Bloqueantes de Inicialización

Ambos motores ejecutan sus scripts de inicialización en orden determinista y bloqueante:

### A. SQL Server (`sqlserver/init/`)
1. `01_database.sql` ➔ Crea la base de datos `agropacayales_db`.
2. `02_schemas.sql` ➔ Crea el esquema `agropacayales` y `finanzas`.
3. `03_tables.sql` ➔ Crea las tablas: `usuarios`, `stock_insumos`, `compras_insumos`, `asignacion_labores`, `liquidacion_cosechas`.
4. `04_constraints.sql` ➔ Agrega claves foráneas, restricciones `CHECK (stock_disponible >= 0)` y restricciones `UNIQUE`.
5. `05_indexes.sql` ➔ Índices de búsqueda para optimizar consultas de costos por parcela.
6. `06_views.sql` ➔ Vista `vw_comparativa_costos_ganancias` que cruza inversión en insumos contra facturación de cosecha.
7. `07_procedures.sql` ➔ Procedimiento `sp_analisis_rentabilidad_parcela` para toma de decisiones gerenciales.
8. `08_seed.sql` ➔ Carga la semilla inicial de insumos, compras, labores y liquidación.

### B. MongoDB (`mongodb/init/`)
1. `01_database.js` ➔ Conexión a la base de datos `agropacayales_db`.
2. `02_collections.js` ➔ Creación explícita de `parcelas`, `insumos`, `cosechas` y `fichas_campo`.
3. `03_validators.js` ➔ Aplicación de validadores estrictos `$jsonSchema`.
4. `04_indexes.js` ➔ Índices geoespaciales `2dsphere` para parcelas y únicos para códigos.
5. `05_seed.js` ➔ Inserción de documentos semilla vinculados a las claves de SQL Server.

---

## 🎯 3. Toma de Decisiones y Análisis Financiero

El sistema responde a las preguntas críticas del negocio:
* ¿Cuánto invertimos exactamente en fertilizantes e insecticidas en el *Sector Norte A1*?
* ¿Cuánto dinero ingresó por la exportación de la fruta de esa misma parcela?
* ¿Cuál fue el margen neto y la tasa de retorno de inversión (ROI)?
* ¿Conviene cambiar de variedad de cultivo en la próxima campaña?
