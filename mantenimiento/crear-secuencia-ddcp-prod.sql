USE DDCP;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.SEQ_DECOMISO', N'SO') IS NULL
    BEGIN
        DECLARE @inicio bigint;
        SELECT @inicio = COALESCE(MAX(CONVERT(bigint, ID_DISPOSITIVO_DECOMISADO)), 0) + 1
        FROM dbo.DISPOSITIVOS_DECOMISADOS WITH (TABLOCKX, HOLDLOCK);

        IF @inicio > 2147483647
            THROW 50001, 'Se agoto el rango de IDs de decomiso.', 1;

        DECLARE @sql nvarchar(max) =
            N'CREATE SEQUENCE dbo.SEQ_DECOMISO AS int START WITH '
            + CONVERT(nvarchar(20), @inicio)
            + N' INCREMENT BY 1 NO CYCLE;';
        EXEC sys.sp_executesql @sql;
    END;

    EXEC(N'GRANT UPDATE ON OBJECT::dbo.SEQ_DECOMISO TO [DDCP_MELKART];');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT name, start_value, current_value
FROM sys.sequences
WHERE object_id = OBJECT_ID(N'dbo.SEQ_DECOMISO', N'SO');
