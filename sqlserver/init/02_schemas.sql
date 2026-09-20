USE agropacayales_db;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'agropacayales')
BEGIN
    EXEC('CREATE SCHEMA agropacayales');
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'finanzas')
BEGIN
    EXEC('CREATE SCHEMA finanzas');
END
GO
