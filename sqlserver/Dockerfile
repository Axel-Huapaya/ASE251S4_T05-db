FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

# Crear directorios
RUN mkdir -p /docker /docker-entrypoint-initdb.d

# Copiar scripts de inicialización ordenados
COPY ./init/*.sql /docker-entrypoint-initdb.d/
COPY ./docker/*.sh /docker/

RUN chmod +x /docker/*.sh

USER mssql

ENTRYPOINT ["/docker/entrypoint.sh"]
