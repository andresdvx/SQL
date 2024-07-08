IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'CrearReserva') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE  CrearReserva
END
GO
CREATE PROCEDURE CrearReserva
@HabitacionId INT,
@FechaEntrada DATE,
@FechaSalida DATE,
@Cantidad INT
AS
BEGIN
    BEGIN TRY

        BEGIN TRANSACTION

            IF NOT EXISTS (SELECT 1 FROM Habitaciones WHERE HabitacionID = @HabitacionId)
                BEGIN
                    RAISERROR('LA HABITACIÓN NO EXISTE', 16,1);
                    ROLLBACK TRANSACTION;
                    RETURN;
                END; 
                
            
            DECLARE @Disponibilidad INT
            SELECT @Disponibilidad = (SELECT Disponibilidad FROM Habitaciones WHERE HabitacionID = @HabitacionId)


            IF @Disponibilidad < @Cantidad
                BEGIN
                    RAISERROR('NO HAY SUFICIENTE DISPONIBILIDAD EN LA HABITACIÓN', 16, 1);
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;
                    
            UPDATE Habitaciones SET Disponibilidad = @Disponibilidad - @Cantidad
            WHERE HabitacionID = @HabitacionId;
                    
            INSERT INTO Reservas (HabitacionID, FechaEntrada, FechaSalida, Cantidad)
            VALUES (@HabitacionId, @FechaEntrada, @FechaSalida, @Cantidad);
                    

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
     
        DECLARE @ERROR_MESSAGE VARCHAR(MAX),
        @ERROR_SEVERITY INT,
        @ERROR_STATUS INT

        SELECT @ERROR_MESSAGE = ERROR_MESSAGE(),
        @ERROR_SEVERITY = ERROR_SEVERITY(),
        @ERROR_STATUS = ERROR_STATE();

        ROLLBACK TRANSACTION;

        RAISERROR(@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATUS);

    END CATCH;
END;