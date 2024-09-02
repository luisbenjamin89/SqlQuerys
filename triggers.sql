
<Sintaxis para la creación del trigger:
GO
CREATE TRIGGER Nombre_Trigger 
ON Nombre_Tabla
FOR | AFTER | INSTEAD OF
INSERT | UPDATE | DELETE
AS   
BEGIN
-- Aquí iría la acción a ejecutar 
De los INSERT -> encontraremos los datos en la tabla temporal: inserted
De los DELETE -> deleted
Y de los UPDATE -> deleted, inserted
END

MODIFICAR / ELIMINAR TRIGGERS:
Ejemplo: Si queremos cambiar un trigger ya existente que era "FOR INSERT" por "INSTEAD OF":
GO
ALTER TRIGGER T_Region_I_I
ON Region
INSTEAD OF INSERT
AS
PRINT 'TRIGGER CAMBIADO A INSTEAD OF'
GO
--> En este caso no nos ha dejado porque ya teníamos un tercer trigger que ya era instead of insert. Tendríamos que cambiar el tercer trigger o eliminarlo para crear otro
DROP TRIGGER T_Region_I_III
GO
ALTER TRIGGER T_Region_I_I
ON Region
INSTEAD OF INSERT
AS
PRINT 'TRIGGER CAMBIADO A INSTEAD OF'
GO


TABLAS DE LOGS
--CREAR TABLA LOGS para guardar datos del usuario que haga cualquier insert en Region

CREATE TABLE Log_Region(
Cod_Usuario VARCHAR(10),
F_Insert DATETIME,
Id_Region INT
)

GO
CREATE TRIGGER T_Region_I_V
ON Region
FOR INSERT
AS
BEGIN
INSERT INTO Log_Region(Cod_Usuario, F_Insert, Id_Region)
select CURRENT_USER, GETDATE(), I.RegionID from inserted I
PRINT 'REGISTRO GUARDADO'
END
GO


----trigger de validacion


create trigger detallepedido on dbo.detalle_pedido  instead of insert 
as 
begin
declare @id_prod int , @id_suply int 

set @id_prod = (select ProductID from inserted)

set @id_suply = ( select id_suppliers from inventario where id_producto= @id_prod)

end

select * from inventario order by id_producto