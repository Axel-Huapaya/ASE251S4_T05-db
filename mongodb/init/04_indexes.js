// 04_indexes.js - Índices de optimización y geoespaciales
db = db.getSiblingDB('agropacayales_db');

print("[js] Executing 04_indexes.js");

// Índice geoespacial para consultas satelitales de parcelas
db.parcelas.createIndex({ geometriaGeoJSON: "2dsphere" }, { name: "geo_parcelas_polygon" });

// Índice de búsqueda para cosechas por parcela
db.cosechas.createIndex({ id_parcela: 1 }, { name: "idx_cosechas_parcela" });

// Índice de trazabilidad para fichas de campo
db.fichas_campo.createIndex({ parcela: 1, fechaEvaluacion: -1 }, { name: "idx_fichas_parcela_fecha" });

print("[SUCCESS] Índices creados exitosamente.");
