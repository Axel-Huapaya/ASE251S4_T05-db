#!/bin/bash
# Iniciar el script de inicialización en segundo plano
/docker/init.sh &

# Iniciar el servicio oficial de SQL Server
/opt/mssql/bin/sqlservr
