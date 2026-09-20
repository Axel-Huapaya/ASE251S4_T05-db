// 05_seed.js - Carga de datos iniciales enlazados con SQL Server
db = db.getSiblingDB('agropacayales_db');

print("[js] Executing 05_seed.js");

// 1. Parcelas
db.parcelas.insertMany([
  {
    _id: "PARC-NORTE-A1",
    nombre: "Sector Norte A1",
    fundo: "Fundo Principal",
    hectareas: 12.50,
    geometriaGeoJSON: {
      type: "Polygon",
      coordinates: [[
        [-77.0282, -12.0432],
        [-77.0275, -12.0435],
        [-77.0278, -12.0442],
        [-77.0285, -12.0439],
        [-77.0282, -12.0432]
      ]]
    },
    condicionesSuelo: { textura: "Franco-arenoso", phPromedio: 6.8, materiaOrganicaPorc: 2.4 },
    cultivoActual: { variedad: "Palto Hass", anoPlantacion: 2021 }
  },
  {
    _id: "PARC-SUR-B2",
    nombre: "Sector Sur B2",
    fundo: "Fundo Valle",
    hectareas: 8.00,
    geometriaGeoJSON: {
      type: "Polygon",
      coordinates: [[
        [-77.0310, -12.0510],
        [-77.0302, -12.0515],
        [-77.0305, -12.0522],
        [-77.0315, -12.0518],
        [-77.0310, -12.0510]
      ]]
    },
    condicionesSuelo: { textura: "Franco-arcilloso", phPromedio: 7.1 },
    cultivoActual: { variedad: "Arándano Biloxi", anoPlantacion: 2022 }
  }
]);

// 2. Insumos (Catálogo técnico)
db.insumos.insertMany([
  {
    _id: "INS-BIO-001",
    nombre: "Insecticida BioProtect Pro",
    categoria: "Biológico",
    unidadMedida: "Litros",
    especificaciones: {
      ingredienteActivo: "Bacillus thuringiensis 15%",
      dosisHectarea: "2.0 - 2.5 L/ha",
      periodoCarenciaDias: 3,
      plagasObjetivo: ["Mosca de la fruta", "Polilla del racimo"],
      registroSenasa: "SENASA-0982-F",
      toxicidad: "Banda Verde"
    }
  },
  {
    _id: "INS-FERT-002",
    nombre: "Fertilizante Foliar NPK 20-20-20",
    categoria: "Químico / Nutricional",
    unidadMedida: "Sacos (50kg)",
    especificaciones: {
      composicionQuimica: "Nitrógeno 20%, Fósforo 20%, Potasio 20%",
      solubilidad: "100% Soluble",
      metodoAplicacion: "Fertirriego / Aspersión foliar"
    }
  }
]);

// 3. Cosechas
db.cosechas.insertOne({
  _id: "COS-2026-001",
  id_parcela: "PARC-NORTE-A1",
  cultivo: "Palto Hass",
  fechaCosecha: new Date(),
  totalKilosCampo: 5200.00,
  desgloseCalidades: [
    { calidad: "Exportación Cat 1", kilos: 4400.00, calibre: "Calibre 16-18", destino: "Mercado Europeo" },
    { calidad: "Nacional", kilos: 600.00 },
    { calidad: "Merma", kilos: 200.00 }
  ],
  analisisLaboratorio: { materiaSeca: "23.8%", gradosBrix: "11.5" },
  certificaciones: ["GlobalG.A.P.", "GRASP"]
});

// 4. Fichas de Campo
db.fichas_campo.insertOne({
  fechaEvaluacion: new Date(),
  evaluador: "carlos@agro.com",
  parcela: "PARC-NORTE-A1",
  tipoFicha: "PLAGAS",
  hallazgos: { insecto: "Mosca de la fruta", severidad: "Media" },
  recomendacionAccion: "Aplicar BioProtect Pro"
});

print("[SUCCESS] MongoDB initialization complete.");
