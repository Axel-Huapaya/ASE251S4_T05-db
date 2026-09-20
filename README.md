# ASE251S4_T05-db — Agro Pacayales S.A.C.
**Plataforma de Persistencia Políglota como Código (Database-as-Code)**  
**Curso:** ASE251S4 | **Equipo:** Grupo 05 (T05)  
**Propósito del Sistema:** Comparativa de Costos vs Ganancias para la Toma de Decisiones Estratégicas

---

## 👥 Equipo de Trabajo y Roles (Gitflow)

| Integrante | Rol | Asignación / Rama Gitflow |
| :--- | :--- | :--- |
| **Hugo Fernández** | **DevOps / Líder Técnico** | Estructura base, `.env.example`, `.gitignore`, `compose.yaml`, `docs/` (`main` / `develop`) |
| **Ana Félix** | **Database Developer (SQL Server)** | Módulo SQL Server 2022, kardex y vista de costos (`feature/sqlserver-finanzas`) |
| **Axel Huapaya** | **Database Developer (MongoDB)** | Módulo MongoDB 8.0, GeoJSON satelital y validadores (`feature/mongodb-catalog`) |

---

## 🌾 1. Propósito y Valor del Negocio
Agro Pacayales S.A.C. es una empresa agroexportadora líder en palto Hass y arándanos. Esta plataforma resuelve la necesidad crítica de la gerencia: **calcular con rigor financiero y matemático cuánto cuesta mantener cada parcela en insumos y labores versus cuánto genera su cosecha en el mercado internacional**.

* **Microsoft SQL Server (Kardex e Inmutabilidad Financiera):** Controla compras de insumos, inventario físico, costeo promedio de labores por parcela y facturación final de exportación.
* **MongoDB (Catálogo Dinámico y Georreferenciación):** Almacena geometrías satelitales GeoJSON (`Polygon`), fichas técnicas variables (NPK, SENASA, periodo de carencia) y trazabilidad de lotes cosechados.

---

## 📂 2. Estructura del Repositorio

```text
ASE251S4-db/
├── .env.example              # Variables de configuración y credenciales
├── .gitignore                # Reglas de exclusión de archivos locales
├── .gitattributes            # Normalización de saltos de línea LF para Docker
├── README.md                 # Guía técnica de arquitectura y despliegue
├── compose.yaml              # Orquestación multi-contenedor del sistema
├── docs/
│   ├── architecture.md       # Arquitectura de persistencia desacoplada
│   └── data-ownership.md     # Matriz de propiedad de entidades y regla de oro
├── sqlserver/
│   ├── Dockerfile            # Imagen personalizada de SQL Server 2022
│   ├── docker/
│   │   ├── entrypoint.sh     # Orquestador del servicio mssql
│   │   └── init.sh           # Ejecutor secuencial y bloqueante de scripts
│   └── init/
│       ├── 01_database.sql   # Creación de BD agropacayales_db
│       ├── 02_schemas.sql    # Esquemas agropacayales y finanzas
│       ├── 03_tables.sql     # Tablas maestras, stock, labores y liquidación
│       ├── 04_constraints.sql# Restricciones CHECK, UNIQUE y FKs
│       ├── 05_indexes.sql    # Índices optimizados para reportes
│       ├── 06_views.sql      # Vista comparativa Costos vs Ganancias
│       ├── 07_procedures.sql # Procedimiento gerencial de rentabilidad
│       └── 08_seed.sql       # Datos iniciales con costos e ingresos
└── mongodb/
    ├── Dockerfile            # Imagen personalizada de MongoDB 8.0
    └── init/
        ├── 01_database.js    # Inicialización de agropacayales_db
        ├── 02_collections.js # Colecciones: parcelas, insumos, cosechas, fichas
        ├── 03_validators.js  # Reglas estrictas $jsonSchema
        ├── 04_indexes.js     # Índices geoespaciales 2dsphere y de búsqueda
        └── 05_seed.js        # Semilla inicial enlazada con SQL Server
```

---

## 🔨 3. Construcción de Imágenes Independientes (Etapa 3)

Ejecuta desde la raíz del repositorio:

```bash
# 1. Construir imagen de SQL Server
docker build -t ase251s4-db-sqlserver:1.0 ./sqlserver

# 2. Construir imagen de MongoDB
docker build -t ase251s4-db-mongodb:1.0 ./mongodb

# 3. Verificar las imágenes creadas
docker images
```

---

## 🚀 4. Despliegue de Contenedores y Prueba Funcional

```bash
# 1. Levantar contenedor de SQL Server
docker run -d --name sqlserver-db -p 1433:1433 -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=AgroPacayales2026!" ase251s4-db-sqlserver:1.0

# 2. Levantar contenedor de MongoDB
docker run -d --name mongodb-db -p 27017:27017 ase251s4-db-mongodb:1.0

# 3. Verificar estado de los contenedores
docker ps
```

---

## 🔍 5. Verificación de Logs de Inicialización

Comprueba que las dependencias bloqueantes se hayan ejecutado en estricto orden determinista:

```bash
# Logs de SQL Server
docker logs sqlserver-db

# Logs de MongoDB
docker logs mongodb-db
```

---

## 📊 6. Consulta Clave: Toma de Decisiones (Costos vs Ganancias)

Conéctate a SQL Server (mediante SSMS, Azure Data Studio o `sqlcmd`) y ejecuta:

```sql
USE agropacayales_db;
GO

-- Consulta comparativa de rentabilidad por parcela
SELECT * FROM finanzas.vw_comparativa_costos_ganancias;

-- Informe gerencial con veredicto de inversión para una parcela
EXEC finanzas.sp_analizar_rentabilidad_parcela 'PARC-NORTE-A1';
GO
```

### Resultado que apoya la toma de decisiones:
* **Inversión en Insumos:** \$1,450.00 USD (Insecticida BioProtect Pro + NPK 20-20-20).
* **Ingreso por Exportación:** \$14,080.00 USD (4,400 kg de Palta Hass Cat 1 a Rotterdam).
* **Ganancia Neta:** +\$12,630.00 USD.
* **Retorno de Inversión (ROI):** **871%**.
* **Veredicto Gerencial:** **`ALTA RENTABILIDAD (EXPANDIR CULTIVO)`**.
