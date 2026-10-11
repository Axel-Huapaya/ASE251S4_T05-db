# Scripts de Demostración — Agro Pacayales S.A.C. (Team 05)

Esta carpeta contiene los scripts para la grabación y sustentación del video demostrativo:

1. **`demo-evolucion.sh`**:
   - Muestra el ciclo completo de versionamiento de bases de datos.
   - Despliega en **Versión 1** (`TARGET_SCHEMA_VERSION=1`) con los datos iniciales y baseline.
   - Ejecuta la evolución a **Versión 2** (`TARGET_SCHEMA_VERSION=2`), demostrando cómo el sistema detecta que el baseline ya se aplicó y ejecuta en orden secuencial el script de cambios `V002_modelado_estrategias.js` y `V002_auditoria_labores.sql`.
   - Verifica la alineación de ambos motores mediante el servicio `checker`.

2. **`demo-consumo-aislado.sh`**:
   - Demuestra el despliegue del stack utilizando únicamente las imágenes publicadas en el registro de contenedores (Docker Hub), sin requerir clonar ni compilar el código fuente.
