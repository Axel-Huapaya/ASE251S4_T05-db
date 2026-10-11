# ASE251S4_T05-db — Agro Pacayales S.A.C.
**Plataforma de Persistencia Políglota y Versionamiento de Esquemas como Código (Database-as-Code)**  
**Curso:** ASE251S4 | **Equipo:** Grupo 05 (T05)  
**Propósito del Sistema:** Análisis de Rentabilidad de Costos vs Ganancias y Modelado NoSQL Avanzado para Agroexportación (Palto Hass y Arándanos)

---

## 👥 Equipo de Trabajo y Asignaciones

| Integrante | Rol | Asignación Técnica | Estrategias de Modelado NoSQL |
| :--- | :--- | :--- | :--- |
| **Hugo Fernández** | **DevOps / Líder Técnico** | Orquestación Docker, Compose, Versionador `run.sh`, Checker API | **1. Embedding:** Condiciones edáficas y análisis de suelo en `parcelas`.<br>**2. Referencing:** Telemetría IoT en `sensores_telemetria`. |
| **Ana Félix** | **Database Developer (SQL Server)** | Módulo SQL Server 2022, kardex de insumos, auditoría de labores | **1. Embedding:** Desglose inmutable de calidades en `cosechas`.<br>**2. Referencing:** Enlace foráneo `id_insumo` en `fichas_campo` hacia SQL Server. |
| **Axel Huapaya** | **Database Developer (MongoDB)** | Módulo MongoDB 8.0, validadores `$jsonSchema`, índices y migraciones | **1. Embedding:** Protocolo de certificación GlobalG.A.P. en `fichas_campo`.<br>**2. Referencing / Subset:** Histórico multianual de cosechas con subset en `parcelas`. |

---

## 🏗️ 1. Arquitectura del Repositorio (Database-as-Code)

La arquitectura sigue el estándar determinista de persistencia como código, desacoplando los motores del ciclo de vida de los datos mediante contenedores de inicialización efímeros y un servicio de diagnóstico automatizado:

```text
ASE251S4_T05-db/
├── .env.example              # Variables de configuración y credenciales maestras
├── .gitignore                # Exclusiones de Git
├── .gitattributes            # Normalización LF obligatoria para Linux/Docker
├── README.md                 # Guía técnica consolidada
├── compose.yaml              # Orquestación multi-contenedor (Motores + Init + Checker)
├── compose.build.yaml        # Definición de contextos de compilación local
├── compose.tools.yaml        # Servicios de desarrollo opcionales
├── check/                    # Microservicio de diagnóstico y verificación (Java 21 / Maven)
│   ├── Dockerfile            # Construcción multi-etapa del checker
│   ├── pom.xml               # Dependencias (MSSQL JDBC, Mongo Driver, Jackson)
│   └── src/main/java/...     # API REST nativa con Swagger UI (/swagger-ui)
├── db/
│   ├── sqlserver/            # Persistencia Relacional y Kardex (SQL Server 2022)
│   │   ├── Dockerfile        # Imagen Ubuntu con mssql-tools18
│   │   ├── run.sh            # Orquestador determinista con SHA-256
│   │   ├── bootstrap/        # V001_baseline.sql (Línea base: tablas, vistas, SPs, seed)
│   │   ├── changes/          # V002_auditoria_labores.sql (Evolución incremental)
│   │   ├── checks/           # contract.sql (Verificación de contrato por versión)
│   │   └── metadata/         # record-change.sql (Registro en dbo.schema_changes)
│   └── mongodb/              # Persistencia NoSQL y Georreferenciación (MongoDB 8.0)
│       ├── Dockerfile        # Imagen Mongo 8 con scripts compilados
│       ├── run.sh            # Orquestador con verificación de checksums
│       ├── bootstrap/        # V001__baseline.js (Línea base: 4 colecciones base)
│       ├── changes/          # V002_modelado_estrategias.js (6 estrategias de modelado)
│       ├── checks/           # contract.js (Verificación de esquemas e índices)
│       └── metadata/         # record-change.js (Registro en schema_changes)
├── demo/
│   ├── README.md             # Guía de ejecución de demos
│   ├── demo-evolucion.sh     # Demostración paso a paso del versionamiento e intercalado
│   └── demo-consumo-aislado.sh # Demostración con imágenes preconstruidas
└── docs/
    ├── MODELADO_DATOS_ESTRATEGIAS.md # Investigación teórica y detalle técnico de los 6 ejemplos
    ├── GUIA_VIDEO_DEMOSTRATIVO.md    # Guion detallado para la grabación del video grupal
    ├── EVOLUCION_MANUAL.md           # Guía para crear nuevas versiones
    ├── INICIALIZACION_NUEVA_MAQUINA.md # Despliegue en entornos nuevos
    ├── CONSUMO_SIN_REPOSITORIO.md    # Uso mediante compose sin clonar repo
    └── USO_LOCAL_SIN_CAMBIOS.md      # Guía para desarrolladores de aplicaciones
```

---

## 🚀 2. Despliegue Rápido y Construcción Local

### Paso 1: Configurar variables de entorno
```bash
cp .env.example .env
```

### Paso 2: Levantar el stack completo (Última versión disponible)
```bash
docker compose -f compose.yaml -f compose.build.yaml up -d --build
```

### Paso 3: Verificar estado de contenedores
```bash
docker compose ps
```

| Servicio | Puerto Host | Descripción |
| :--- | :--- | :--- |
| **`sqlserver`** | `1433` | Motor Microsoft SQL Server 2022 |
| **`mongodb`** | `27017` | Motor MongoDB 8.0 |
| **`sql-init`** | - | Inicializador efímero de migraciones SQL Server (Termina con código 0) |
| **`mongo-init`** | - | Inicializador efímero de migraciones MongoDB (Termina con código 0) |
| **`checker`** | `8080` | REST API de salud, contratos y Swagger UI |

---

## 🔄 3. Versionamiento de Bases de Datos e Intercalado de Versiones

El repositorio permite alternar e intercalar entre contratos versionados mediante la variable `TARGET_SCHEMA_VERSION`:

### Desplegar en Versión 1 (Baseline Inicial):
```bash
docker compose down --volumes
TARGET_SCHEMA_VERSION=1 docker compose -f compose.yaml -f compose.build.yaml up -d --build
```
* Aplica `V001_baseline.sql` y `V001__baseline.js`.
* Registra la secuencia 1 con su respectivo checksum SHA-256 en `schema_changes`.

### Evolucionar a Versión 2 (Modelado de Datos Avanzado):
```bash
TARGET_SCHEMA_VERSION=2 docker compose -f compose.yaml -f compose.build.yaml up -d --build
```
* `run.sh` detecta que V001 ya está aplicado e inalterado.
* Aplica únicamente los cambios incrementales: `V002_auditoria_labores.sql` y `V002_modelado_estrategias.js`.
* El microservicio `checker` actualiza su contrato a `contract: 2`.

---

## 🍃 4. Estrategias de Modelado de Datos NoSQL (MongoDB)

Para la presente actividad académica, se investigaron e implementaron **6 ejemplos fundamentados en el modelo de negocio de Agro Pacayales S.A.C.** (2 por integrante):

### 1. Hugo Fernández
* **Estrategia 1 (Embedding 1:1):** Subdocumento `condiciones_edaficas` (textura, pH, materia orgánica, conductividad eléctrica) incrustado en `parcelas`. Garantiza lectura atómica en una sola operación de disco al consultar la ficha satelital en campo.
* **Estrategia 2 (Referencing 1:N No Acotado):** Colección independiente `sensores_telemetria` referenciando `id_parcela`. Permite almacenar miles de lecturas IoT de sondas de humedad a 30cm/60cm y temperatura foliar sin exceder el límite BSON de 16MB.

### 2. Ana Félix
* **Estrategia 1 (Embedding 1:Few Finito):** Array `desgloseCalidades` en `cosechas` (Cat 1 Exportación Rotterdam, Nacional, Merma). Mantiene un snapshot inmutable y definitivo del pesaje de packing para cálculo financiero directo.
* **Estrategia 2 (Referencing Foráneo Políglota):** Enlace foráneo `id_insumo` en `fichas_campo` referenciando la colección `insumos`, enlazado directamente con el inventario contable y kardex de SQL Server (`finanzas.stock_insumos`).

### 3. Axel Huapaya
* **Estrategia 1 (Embedding Snapshot):** Subdocumento `protocolo_certificacion` en `fichas_campo` (GlobalG.A.P., SENASA, días de carencia cumplidos, LMR en ppm y lista de verificación). Evidencia autosuficiente e inalterable para auditorías de aduana.
* **Estrategia 2 (Referencing / Subset Pattern):** Colección `cosechas` referenciando `id_parcela` para todo el histórico multianual de 25 años de plantación, manteniendo en `parcelas` únicamente el subdocumento ligero `resumen_ultima_campana` para consultas del día a día.

> 📖 **Documentación Teórica Completa:** Consulta [MODELADO_DATOS_ESTRATEGIAS.md](file:///e:/base%20de%20datos/ASE251S4_T05-db/docs/MODELADO_DATOS_ESTRATEGIAS.md) para ver los esquemas BSON, validadores `$jsonSchema` y pipelines de agregación.

---

## 📊 5. Consulta Clave: Toma de Decisiones (Costos vs Ganancias)

Desde SQL Server (SSMS, Azure Data Studio o `sqlcmd`):

```sql
USE agropacayales_db;
GO

-- Consulta comparativa de rentabilidad por parcela
SELECT * FROM finanzas.vw_comparativa_costos_ganancias;

-- Informe gerencial con veredicto de inversión para la parcela
EXEC finanzas.sp_analizar_rentabilidad_parcela 'PARC-NORTE-A1';
GO
```

### Resultados que sustentan la decisión gerencial:
* **Inversión en Insumos:** \$1,450.00 USD (Insecticida BioProtect Pro + NPK 20-20-20).
* **Ingreso por Exportación:** \$14,080.00 USD (4,400 kg de Palta Hass Cat 1 a Rotterdam).
* **Ganancia Neta:** +\$12,630.00 USD.
* **Retorno de Inversión (ROI):** **871%**.
* **Veredicto Gerencial:** **`ALTA RENTABILIDAD (EXPANDIR CULTIVO)`**.

---

## 🩺 6. Diagnóstico y Swagger UI del Checker

El microservicio `checker` expone una suite completa de observabilidad:

* **Swagger UI:** [http://localhost:8080/swagger-ui](http://localhost:8080/swagger-ui)
* **Salud del Proceso:** `GET http://localhost:8080/health`
* **Conectividad y Latencia de Motores:** `GET http://localhost:8080/connections`
* **Versión y SHA Aplicado:** `GET http://localhost:8080/version`
* **Estructura y Contrato de Persistencia:** `GET http://localhost:8080/contract`
* **Muestras de Datos Reales:** `GET http://localhost:8080/samples`
* **Diagnóstico Consolidado:** `GET http://localhost:8080/diagnostics`

---

## 📹 7. Guía para el Video Demostrativo

Consulta la guía detallada [GUIA_VIDEO_DEMOSTRATIVO.md](file:///e:/base%20de%20datos/ASE251S4_T05-db/docs/GUIA_VIDEO_DEMOSTRATIVO.md) para las pautas de grabación con cámara activa de cada integrante, tiempos asignados y guion de sustentación.
