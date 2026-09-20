// 02_collections.js - Creación explícita de colecciones
db = db.getSiblingDB('agropacayales_db');

print("[js] Executing 02_collections.js");

db.createCollection("parcelas");
db.createCollection("insumos");
db.createCollection("cosechas");
db.createCollection("fichas_campo");

print("[SUCCESS] Colecciones creadas: parcelas, insumos, cosechas, fichas_campo");
