-- Ejecutar con la base de destino seleccionada.
SET XACT_ABORT ON;
DECLARE @UsuarioApi sysname = CONVERT(sysname, SESSION_CONTEXT(N'UsuarioApi'));
IF @UsuarioApi IS NULL OR DATABASE_PRINCIPAL_ID(@UsuarioApi) IS NULL
    THROW 50002, 'Defina SESSION_CONTEXT UsuarioApi con un usuario existente de esta base antes de ejecutar el mantenimiento.', 1;

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

    DECLARE @permiso nvarchar(max) = N'GRANT UPDATE ON OBJECT::dbo.SEQ_DECOMISO TO ' + QUOTENAME(@UsuarioApi) + N';';
    EXEC sys.sp_executesql @permiso;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT name, start_value, current_value
FROM sys.sequences
WHERE object_id = OBJECT_ID(N'dbo.SEQ_DECOMISO', N'SO');

