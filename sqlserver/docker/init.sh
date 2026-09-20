#!/bin/bash
# Esperar a que SQL Server esté listo
echo "[INFO] Starting Microsoft SQL Server..."

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
if [ ! -f "$SQLCMD" ]; then
    SQLCMD="/opt/mssql-tools/bin/sqlcmd"
fi

for i in {1..60}; do
    $SQLCMD -C -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 2
done

# Ejecutar scripts en orden de dependencia bloqueante
for script in /docker-entrypoint-initdb.d/*.sql; do
    if [ -f "$script" ]; then
        filename=$(basename "$script")
        echo "[INFO] Executing $filename"
        $SQLCMD -C -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -i "$script" > /dev/null 2>&1
    fi
done

echo "[SUCCESS] All initialization scripts executed."
