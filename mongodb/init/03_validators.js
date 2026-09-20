// 03_validators.js - Reglas estrictas de validación $jsonSchema
db = db.getSiblingDB('agropacayales_db');

print("[js] Executing 03_validators.js");

// 1. Validador para parcelas
db.runCommand({
  collMod: "parcelas",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "nombre", "hectareas"],
      properties: {
        _id: { bsonType: ["string", "int", "double"], description: "ID único de parcela" },
        nombre: { bsonType: "string", description: "Nombre obligatorio" },
        hectareas: { bsonType: ["double", "int", "decimal"], minimum: 0.1, description: "Hectáreas > 0" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 2. Validador para insumos
db.runCommand({
  collMod: "insumos",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "nombre", "categoria", "unidadMedida"],
      properties: {
        _id: { bsonType: "string", description: "Código del insumo compartido con SQL Server" },
        nombre: { bsonType: "string", description: "Nombre del insumo obligatorio" },
        categoria: {
          enum: ["Biologico", "Biológico", "Quimico / Nutricional", "Químico / Nutricional", "Fertilizante", "Insecticida", "Herramienta"]
        },
        unidadMedida: {
          enum: ["Litros", "Sacos (50kg)", "Kilos", "Unidades"]
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 3. Validador para cosechas
db.runCommand({
  collMod: "cosechas",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "id_parcela", "cultivo", "totalKilosCampo"],
      properties: {
        _id: { bsonType: "string", description: "Código de cosecha compartido con SQL Server" },
        id_parcela: { bsonType: "string", description: "ID de la parcela cosechada" },
        cultivo: { bsonType: "string" },
        totalKilosCampo: { bsonType: ["double", "int", "decimal"], minimum: 0.1 }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 4. Validador para fichas_campo
db.runCommand({
  collMod: "fichas_campo",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["fechaEvaluacion", "evaluador", "parcela", "tipoFicha"],
      properties: {
        evaluador: { bsonType: "string" },
        parcela: { bsonType: "string" },
        tipoFicha: { enum: ["PLAGAS", "RIEGO_Y_SUELO", "FERTILIZACION", "EVALUACION_FITOSANITARIA"] }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

print("[SUCCESS] Validadores $jsonSchema aplicados correctamente.");
