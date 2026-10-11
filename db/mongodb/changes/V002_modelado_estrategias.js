// ==============================================================================
// V002_modelado_estrategias.js — Agro Pacayales S.A.C.
// EVOLUCIÓN DE ESQUEMA V2: MODELADO DE DATOS MEDIANTE EMBEDDING (INCRUSTACIÓN)
// Implementación: 3 Ejemplos de Embedding por Integrante (9 Ejemplos en Total)
//
// 👥 ASIGNACIÓN DE INTEGRANTES — TEMA: EMBEDDING (1 - 5)
// 1. HUGO FERNÁNDEZ:
//    - Ejemplo 1 (Embedding 1:1): Condiciones edáficas y análisis físico-químico en 'parcelas'
//    - Ejemplo 2 (Embedding 1:Few): Array de nodos sensores IoT instalados en 'parcelas'
//    - Ejemplo 3 (Embedding 1:1): Subdocumento de sistema de riego tecnificado en 'parcelas'
// 2. ANA FÉLIX:
//    - Ejemplo 1 (Embedding 1:Few): Desglose inmutable de calidades y destinos en 'cosechas'
//    - Ejemplo 2 (Embedding 1:1): Subdocumento de control de calidad de laboratorio en 'cosechas'
//    - Ejemplo 3 (Embedding 1:Few): Array de dosificación técnica por cultivo en 'insumos'
// 3. AXEL HUAPAYA:
//    - Ejemplo 1 (Embedding 1:1): Protocolo y auditoría de certificación GlobalG.A.P. en 'fichas_campo'
//    - Ejemplo 2 (Embedding 1:Few): Array de hallazgos y conteo de plagas en 'fichas_campo'
//    - Ejemplo 3 (Embedding Subset): Resumen de rendimiento de última campaña en 'parcelas'
// ==============================================================================

var adminDb = db.getSiblingDB('admin');
if (!adminDb.auth(process.env.MONGO_ADMIN_USER, process.env.MONGO_ADMIN_PASSWORD)) {
  throw Error('Autenticación MongoDB fallida para V002_modelado_estrategias');
}

db = db.getSiblingDB(process.env.MONGO_DATABASE || 'agropacayales_db');
print('[V002] Aplicando migración V002: Modelado de Datos con Estrategia EMBEDDING (9 Ejemplos)...');

// ==============================================================================
// 1. INTEGRANTE 1: HUGO FERNÁNDEZ (3 Ejemplos en 'parcelas')
// ==============================================================================

db.runCommand({
  collMod: 'parcelas',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['_id', 'nombre', 'hectareas', 'condiciones_edaficas', 'sistema_riego'],
      properties: {
        _id: { bsonType: 'string' },
        nombre: { bsonType: 'string' },
        fundo: { bsonType: 'string' },
        hectareas: { bsonType: ['double', 'int', 'decimal'], minimum: 0.1 },
        geometriaGeoJSON: { bsonType: 'object' },
        cultivoActual: { bsonType: 'object' },
        // EJEMPLO 1 (Hugo Fernández - 1:1): Condiciones edáficas de suelo
        condiciones_edaficas: {
          bsonType: 'object',
          required: ['textura', 'ph_promedio', 'materia_organica_pct'],
          properties: {
            textura: { bsonType: 'string' },
            ph_promedio: { bsonType: ['double', 'int', 'decimal'] },
            materia_organica_pct: { bsonType: ['double', 'int', 'decimal'] },
            conductividad_electrica_dS_m: { bsonType: ['double', 'int', 'decimal'] },
            capacidad_intercambio_cationico_meq: { bsonType: ['double', 'int', 'decimal'] },
            fecha_ultimo_analisis: { bsonType: 'date' }
          }
        },
        // EJEMPLO 2 (Hugo Fernández - 1:Few): Nodos sensores IoT acotados físicamente
        dispositivos_iot_instalados: {
          bsonType: 'array',
          items: {
            bsonType: 'object',
            required: ['id_nodo', 'tipo_sensor', 'estado_bateria_pct'],
            properties: {
              id_nodo: { bsonType: 'string' },
              tipo_sensor: { bsonType: 'string' },
              profundidad_instalacion_cm: { bsonType: ['int', 'double'] },
              fecha_calibracion: { bsonType: 'date' },
              estado_bateria_pct: { bsonType: ['double', 'int'] }
            }
          }
        },
        // EJEMPLO 3 (Hugo Fernández - 1:1): Especificación técnica de riego
        sistema_riego: {
          bsonType: 'object',
          required: ['tipo', 'caudal_lph', 'sector_valvula'],
          properties: {
            tipo: { bsonType: 'string' },
            caudal_lph: { bsonType: ['double', 'int', 'decimal'] },
            numero_lineas_por_hilera: { bsonType: 'int' },
            emisor_espaciamiento_m: { bsonType: ['double', 'int'] },
            sector_valvula: { bsonType: 'string' }
          }
        },
        // EJEMPLO 3 (Axel Huapaya - Subset Pattern): Resumen de última campaña
        resumen_ultima_campana: {
          bsonType: 'object',
          properties: {
            ano_campana: { bsonType: 'int' },
            total_kilos_cosechados: { bsonType: ['double', 'int', 'decimal'] },
            rendimiento_kg_ha: { bsonType: ['double', 'int', 'decimal'] },
            calidad_cat1_pct: { bsonType: ['double', 'int', 'decimal'] }
          }
        }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
});

// Actualizar parcelas existentes con los 3 embeddings de Hugo Fernández y el subset de Axel Huapaya
db.parcelas.updateOne(
  { _id: 'PARC-NORTE-A1' },
  {
    $set: {
      condiciones_edaficas: {
        textura: 'Franco-arenoso',
        ph_promedio: 6.8,
        materia_organica_pct: 2.45,
        conductividad_electrica_dS_m: 1.20,
        capacidad_intercambio_cationico_meq: 18.5,
        fecha_ultimo_analisis: new Date('2026-01-15T00:00:00Z')
      },
      dispositivos_iot_instalados: [
        { id_nodo: 'IOT-FDR-01', tipo_sensor: 'Sonda Humedad Volumétrica', profundidad_instalacion_cm: 30, fecha_calibracion: new Date('2026-01-10T00:00:00Z'), estado_bateria_pct: 98 },
        { id_nodo: 'IOT-FDR-02', tipo_sensor: 'Sonda Humedad Profunda', profundidad_instalacion_cm: 60, fecha_calibracion: new Date('2026-01-10T00:00:00Z'), estado_bateria_pct: 95 }
      ],
      sistema_riego: {
        tipo: 'Goteo Automatizado Doble Línea',
        caudal_lph: 1.6,
        numero_lineas_por_hilera: 2,
        emisor_espaciamiento_m: 0.5,
        sector_valvula: 'VALV-SEC-NORTE-01'
      },
      resumen_ultima_campana: {
        ano_campana: 2025,
        total_kilos_cosechados: 52000.0,
        rendimiento_kg_ha: 4160.0,
        calidad_cat1_pct: 84.6
      }
    }
  }
);

db.parcelas.updateOne(
  { _id: 'PARC-SUR-B2' },
  {
    $set: {
      condiciones_edaficas: {
        textura: 'Franco-arcilloso',
        ph_promedio: 5.2, // pH ácido idóneo para arándano Biloxi
        materia_organica_pct: 3.10,
        conductividad_electrica_dS_m: 0.90,
        capacidad_intercambio_cationico_meq: 22.0,
        fecha_ultimo_analisis: new Date('2026-02-10T00:00:00Z')
      },
      dispositivos_iot_instalados: [
        { id_nodo: 'IOT-SUR-01', tipo_sensor: 'Sonda Humedad y Salinidad', profundidad_instalacion_cm: 20, fecha_calibracion: new Date('2026-02-01T00:00:00Z'), estado_bateria_pct: 92 }
      ],
      sistema_riego: {
        tipo: 'Microaspersión y Fertirriego Pulso',
        caudal_lph: 2.2,
        numero_lineas_por_hilera: 1,
        emisor_espaciamiento_m: 0.75,
        sector_valvula: 'VALV-SEC-SUR-02'
      },
      resumen_ultima_campana: {
        ano_campana: 2025,
        total_kilos_cosechados: 36000.0,
        rendimiento_kg_ha: 4500.0,
        calidad_cat1_pct: 88.2
      }
    }
  }
);
print('[V002][Hugo Fernández] 3 Ejemplos de Embedding aplicados en coleccion parcelas.');

// ==============================================================================
// 2. INTEGRANTE 2: ANA FÉLIX (2 Ejemplos en 'cosechas' + 1 Ejemplo en 'insumos')
// ==============================================================================

// Actualizar validación de 'cosechas' con los 2 embeddings de Ana Félix
db.runCommand({
  collMod: 'cosechas',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['_id', 'id_parcela', 'cultivo', 'totalKilosCampo', 'desgloseCalidades', 'control_calidad_laboratorio'],
      properties: {
        _id: { bsonType: 'string' },
        id_parcela: { bsonType: 'string' },
        cultivo: { bsonType: 'string' },
        fechaCosecha: { bsonType: 'date' },
        totalKilosCampo: { bsonType: ['double', 'int', 'decimal'], minimum: 0.1 },
        // EJEMPLO 1 (Ana Félix - 1:Few): Desglose inmutable de calidades y destinos comerciales
        desgloseCalidades: {
          bsonType: 'array',
          minItems: 1,
          items: {
            bsonType: 'object',
            required: ['calidad', 'kilos'],
            properties: {
              calidad: { enum: ['Exportación Cat 1', 'Nacional', 'Merma / Descarte', 'Industrial'] },
              kilos: { bsonType: ['double', 'int', 'decimal'], minimum: 0 },
              calibre: { bsonType: 'string' },
              empaque_formato: { bsonType: 'string' },
              puerto_destino: { bsonType: 'string' },
              precio_referencial_usd_kg: { bsonType: ['double', 'int', 'decimal'] }
            }
          }
        },
        // EJEMPLO 2 (Ana Félix - 1:1): Control de calidad de laboratorio pre-embarque
        control_calidad_laboratorio: {
          bsonType: 'object',
          required: ['grados_brix', 'materia_seca_pct', 'estado_fitosanitario'],
          properties: {
            grados_brix: { bsonType: ['double', 'int', 'decimal'] },
            materia_seca_pct: { bsonType: ['double', 'int', 'decimal'] },
            firmeza_presion_lb: { bsonType: ['double', 'int', 'decimal'] },
            temperatura_pulpa_c: { bsonType: ['double', 'int', 'decimal'] },
            estado_fitosanitario: { enum: ['APROBADO_EXPORTACION', 'RECHAZADO', 'OBSERVADO'] }
          }
        }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
});

db.cosechas.updateOne(
  { _id: 'COS-2026-001' },
  {
    $set: {
      desgloseCalidades: [
        {
          calidad: 'Exportación Cat 1',
          kilos: 4400.00,
          calibre: 'Calibre 16-18',
          empaque_formato: 'Cajas de 4.0 kg con atmósfera controlada',
          puerto_destino: 'Puerto de Rotterdam (Países Bajos)',
          precio_referencial_usd_kg: 3.20
        },
        {
          calidad: 'Nacional',
          kilos: 600.00,
          calibre: 'Calibre 22-24',
          empaque_formato: 'Jabas plásticas de 20 kg',
          puerto_destino: 'Mercado Mayorista de Lima',
          precio_referencial_usd_kg: 1.10
        },
        {
          calidad: 'Merma / Descarte',
          kilos: 200.00,
          empaque_formato: 'A granel para compostaje orgánico',
          precio_referencial_usd_kg: 0.00
        }
      ],
      control_calidad_laboratorio: {
        grados_brix: 11.5,
        materia_seca_pct: 23.8,
        firmeza_presion_lb: 14.2,
        temperatura_pulpa_c: 5.5,
        estado_fitosanitario: 'APROBADO_EXPORTACION'
      }
    }
  }
);

// EJEMPLO 3 (Ana Félix - 1:Few): Dosificación técnica por cultivo embebida en 'insumos'
db.runCommand({
  collMod: 'insumos',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['_id', 'nombre', 'categoria', 'unidadMedida', 'tabla_dosificacion_cultivo'],
      properties: {
        _id: { bsonType: 'string' },
        nombre: { bsonType: 'string' },
        categoria: { bsonType: 'string' },
        unidadMedida: { bsonType: 'string' },
        especificaciones: { bsonType: 'object' },
        tabla_dosificacion_cultivo: {
          bsonType: 'array',
          minItems: 1,
          items: {
            bsonType: 'object',
            required: ['cultivo', 'etapa_fenologica', 'dosis'],
            properties: {
              cultivo: { bsonType: 'string' },
              etapa_fenologica: { bsonType: 'string' },
              dosis: { bsonType: 'string' },
              volumen_gasto_agua_ha: { bsonType: 'string' }
            }
          }
        }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
});

db.insumos.updateOne(
  { _id: 'INS-BIO-001' },
  {
    $set: {
      tabla_dosificacion_cultivo: [
        { cultivo: 'Palto Hass', etapa_fenologica: 'Floración y Cuajado', dosis: '2.5 L/ha', volumen_gasto_agua_ha: '1,000 L/ha' },
        { cultivo: 'Arándano Biloxi', etapa_fenologica: 'Crecimiento de Brotes', dosis: '1.8 L/ha', volumen_gasto_agua_ha: '800 L/ha' }
      ]
    }
  }
);

db.insumos.updateOne(
  { _id: 'INS-FERT-002' },
  {
    $set: {
      tabla_dosificacion_cultivo: [
        { cultivo: 'Palto Hass', etapa_fenologica: 'Llenado de Fruto', dosis: '25 kg/ha por inyección', volumen_gasto_agua_ha: 'Fertirriego' },
        { cultivo: 'Arándano Biloxi', etapa_fenologica: 'Producción Continua', dosis: '15 kg/ha semanal', volumen_gasto_agua_ha: 'Fertirriego' }
      ]
    }
  }
);
print('[V002][Ana Félix] 3 Ejemplos de Embedding aplicados en colecciones cosechas e insumos.');

// ==============================================================================
// 3. INTEGRANTE 3: AXEL HUAPAYA (2 Ejemplos en 'fichas_campo' + 1 Ejemplo en 'parcelas')
// ==============================================================================

db.runCommand({
  collMod: 'fichas_campo',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['fechaEvaluacion', 'evaluador', 'parcela', 'tipoFicha', 'protocolo_certificacion', 'monitoreo_plagas_evaluadas'],
      properties: {
        fechaEvaluacion: { bsonType: 'date' },
        evaluador: { bsonType: 'string' },
        parcela: { bsonType: 'string' },
        tipoFicha: { enum: ['PLAGAS', 'RIEGO_Y_SUELO', 'FERTILIZACION', 'EVALUACION_FITOSANITARIA'] },
        // EJEMPLO 1 (Axel Huapaya - 1:1): Protocolo inmutable GlobalG.A.P. / SENASA
        protocolo_certificacion: {
          bsonType: 'object',
          required: ['norma', 'codigo_auditor', 'carencia_cumplida', 'cumple_lmr'],
          properties: {
            norma: { enum: ['GlobalG.A.P. IFA v6', 'SENASA-BPA', 'GRASP Social', 'Rainforest Alliance'] },
            codigo_auditor: { bsonType: 'string' },
            dias_carencia_esperados: { bsonType: 'int' },
            dias_carencia_reales: { bsonType: 'int' },
            carencia_cumplida: { bsonType: 'bool' },
            limite_maximo_residuos_ppm: { bsonType: ['double', 'int', 'decimal'] },
            cumple_lmr: { bsonType: 'bool' },
            checklist_puntos_criticos: {
              bsonType: 'array',
              items: { bsonType: 'string' }
            }
          }
        },
        // EJEMPLO 2 (Axel Huapaya - 1:Few): Hallazgos de plagas en campo
        monitoreo_plagas_evaluadas: {
          bsonType: 'array',
          minItems: 1,
          items: {
            bsonType: 'object',
            required: ['plaga', 'organo_afectado', 'nivel_infestacion'],
            properties: {
              plaga: { bsonType: 'string' },
              organo_afectado: { bsonType: 'string' },
              nivel_infestacion: { enum: ['Nulo', 'Bajo', 'Medio', 'Severo'] },
              individuos_por_trampa: { bsonType: ['double', 'int', 'decimal'] }
            }
          }
        }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
});

db.fichas_campo.updateOne(
  { parcela: 'PARC-NORTE-A1' },
  {
    $set: {
      protocolo_certificacion: {
        norma: 'GlobalG.A.P. IFA v6',
        codigo_auditor: 'AUD-SGS-9941',
        dias_carencia_esperados: 3,
        dias_carencia_reales: 7,
        carencia_cumplida: true,
        limite_maximo_residuos_ppm: 0.02,
        cumple_lmr: true,
        checklist_puntos_criticos: [
          'EPP completo utilizado por aplicador certificado',
          'Triple lavado de envases ejecutado y registrado',
          'Cuaderno de campo verificado por agrónomo colegiado'
        ]
      },
      monitoreo_plagas_evaluadas: [
        { plaga: 'Mosca de la fruta (Ceratitis capitata)', organo_afectado: 'Fruto', nivel_infestacion: 'Bajo', individuos_por_trampa: 0.4 },
        { plaga: 'Queresa coma (Fiorinia fioriniae)', organo_afectado: 'Ramas', nivel_infestacion: 'Nulo', individuos_por_trampa: 0.0 }
      ]
    }
  }
);
print('[V002][Axel Huapaya] 2 Ejemplos de Embedding aplicados en fichas_campo (el tercero es el subset pattern en parcelas).');
print('[V002] Migración V002 completada con éxito: 9 Ejemplos de EMBEDDING activos y validados con $jsonSchema.');
