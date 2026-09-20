FROM mongo:8.0.32-noble

# Copiar scripts de inicialización ordenados
COPY ./init/*.js /docker-entrypoint-initdb.d/

EXPOSE 27017
