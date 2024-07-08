IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'RegistrarVenta') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE  RegistrarVenta
END
GO
CREATE PROCEDURE  RegistrarVenta 
    @ProductoID int,
    @Cantidad int
AS
BEGIN
   BEGIN TRY

    BEGIN TRANSACTION
    
        DECLARE @cantidadDisponible INT
        SELECT @cantidadDisponible = (SELECT Cantidad FROM Productos WHERE ProductoId = @ProductoID)

        IF @cantidadDisponible < @Cantidad
        BEGIN
            RAISERROR('No hay suficientes productos', 16,1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Productos SET Cantidad = @cantidadDisponible - @Cantidad WHERE ProductoID = @ProductoID
             
        INSERT INTO HistorialVentas (ProductoID, Cantidad, Fecha) VALUES (@ProductoID, @Cantidad, GETDATE())
        

        COMMIT TRANSACTION

   END TRY
   BEGIN CATCH
        ROLLBACK TRANSACTION

        DECLARE @ERROR_MESSAGE VARCHAR(MAX),
        @ERROR_SEVERITY INT,
        @ERROR_STATUS INT

        SELECT @ERROR_MESSAGE = ERROR_MESSAGE(),
        @ERROR_SEVERITY = ERROR_SEVERITY(),
        @ERROR_STATUS = ERROR_STATE()

        RAISERROR(@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATUS)

   END CATCH
END 