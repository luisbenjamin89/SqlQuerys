/* cursores */

Declare @idproducto int,
@precioUnitario MONEy,
@categoria int

Declare CProducto cursor 
for 
select ProductID,UnitPrice,CategoryID from Products where CategoryID =3
open CProducto 
fetch next from CProducto
into @idproducto,@precioUnitario,@categoria

while @@FETCH_STATUS =0
begin 
 set @precioUnitario=@precioUnitario*1.10
 update Products set UnitPrice= @precioUnitario where current of CProducto
 fetch next from CProducto
 into @idproducto,@precioUnitario,@categoria
 end
 close CProducto
 deallocate CProducto

 select * from Products where CategoryID=3


 ---actualizar el precio de venta de las ordenes de ventas que pertenecen al cliente ALFKI

 select * from Orders
 select * from [Order Details]

 declare 
 @orderid int ,
 @precio float
  
 Declare CAumentos cursor 
for 
select o.OrderID,od.UnitPrice  from orders o inner join [Order Details] od on o.OrderID=od.OrderID where o.CustomerID='ALFKI'

open CAumentos 
fetch next from CAumentos
into @orderid,@precio
while @@FETCH_STATUS =0 
begin 
 
	 update [Order Details] set UnitPrice= UnitPrice*1.30 where current of CAumentos

	 fetch next from CAumentos
	 into @orderid,@precio

 end
 close CAumentos
 deallocate CAumentos

 ---- para la orden 10248 , anadimos los productos que no estan en la orden los metemos en un cursor 
 ----recorro el cursor y para cada lienea ejecuto  proc productosnuevos
 go

 declare @idproc int,
 @canti int,
@precio float

  Declare Cproductosnuevos cursor 
for 
select productID ,UnitPrice,UnitsInStock from Products where productID  not in  (select p.ProductID from Products p inner join [Order Details] od on p.ProductID=od.ProductID where od.OrderID=10248)

open Cproductosnuevos 
fetch next from Cproductosnuevos
into @idproc,@canti,@precio
while @@FETCH_STATUS =0
begin 
EXEC productosnuevos 10248,@idproc,@canti,@precio

 fetch next from Cproductosnuevos
	 into @idproc,@canti,@precio

 end
 close Cproductosnuevos
 deallocate Cproductosnuevos


 select * from [Order Details] where OrderID=10248

 select * from Products

 go 
 
 --curosores con first , last , relative ,prior ,absolute

 DECLARE @IdEmpleado INT,
	@Nombre nvarchar(20),
	@Apellido nvarchar(10),
	@FNacimiento DATETIME

DECLARE C_CURSOR SCROLL CURSOR FOR
	SELECT EmployeeID, FirstName, LastName, BirthDate
		FROM Employees

Open C_CURSOR
FETCH NEXT FROM C_CURSOR
into @IdEmpleado, @Nombre, @Apellido, @FNacimiento
	WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM C_CURSOR
		into @IdEmpleado, @Nombre, @Apellido, @FNacimiento
		-- print @IdEmpleado + @Nombre -- Esto nos falla porque no hemos convertido el tipo de la variable, si vamos a mezclar distintos formatos, los convertimos a cadena de caracteres para poderlo mostrar
		print Cast(@IdEmpleado as char(2)) + ' ' + @Nombre + ' ' + @Apellido + ' ' + cast(@FNacimiento as varchar(10))
	END

FETCH FIRST FROM C_CURSOR
FETCH ABSOLUTE 4 FROM C_CURSOR
FETCH PRIOR FROM C_CURSOR
FETCH RELATIVE 2 FROM C_CURSOR

CLOSE C_CURSOR
DEALLOCATE C_CURSOR

--- cursor para leer los empleados y decir uno por uno si es mayor que en empleado anterior

--select * from Employees

declare @employeeID int ,@edad int, @employeeID2 int ,@edad2 int

DECLARE C_Años SCROLL CURSOR FOR
	SELECT EmployeeID,DATEDIFF(YEAR, BirthDate, GETDATE()) edad
		FROM Employees

Open C_Años
FETCH NEXT FROM C_Años
into @employeeID, @edad
	WHILE @@FETCH_STATUS = 0
	BEGIN

	FETCH PRIOR FROM  C_Años
    into @employeeID2, @edad2
	print'estoy en ' + Cast(@employeeID as char(2))
	if (@edad >= @edad2) and (@employeeID !=@employeeID2)
	begin
		print 'EL mepleado con id '+ Cast(@employeeID as char(2))+'es mayor que el empleado '+Cast(@employeeID2 as char(2))
	print 'EL mepleado con id '+ Cast(@employeeID as char(2))+ 'tiene ' + Cast(@edad as char(2))
    end 

	else 
	begin
		print 'EL mepleado con id '+ Cast(@employeeID2 as char(2))+'es mayor que el empleado '+Cast(@employeeID as char(2))
	print 'EL mepleado con id '+ Cast(@employeeID2 as char(2))+ 'tiene ' + Cast(@edad2 as char(2))
	end

		FETCH NEXT FROM C_Años
	FETCH NEXT FROM C_Años
	into @employeeID, @edad
	END


	CLOSE C_Años
DEALLOCATE C_Años
go
--- lo mismo pero con consulta 

declare @employeeID int ,@edad int, @employeeID2 int ,@edad2 int,@total int ,@contador int
set @total= (select count(*)from Employees)
set @contador = 1

while @contador < = @total

begin
SELECT @employeeID = EmployeeID,@edad =DATEDIFF(YEAR, BirthDate, GETDATE()) 
		FROM Employees where EmployeeID =@contador

SELECT @employeeID2 = EmployeeID,@edad2 =DATEDIFF(YEAR, BirthDate, GETDATE()) 
		FROM Employees where EmployeeID =@contador-1
print'estoy en ' + Cast(@contador as char(2))
if (@edad >= @edad2) and (@employeeID !=@employeeID2)
	begin
		print 'EL mepleado con id '+ Cast(@employeeID as char(2))+'es mayor que el empleado '+Cast(@employeeID2 as char(2))
	print 'EL mepleado con id '+ Cast(@employeeID as char(2))+ 'tiene ' + Cast(@edad as char(2))
    end 

	else 
	begin
		print 'EL mepleado con id '+ Cast(@employeeID2 as char(2))+'es mayor que el empleado '+Cast(@employeeID as char(2))
	print 'EL mepleado con id '+ Cast(@employeeID2 as char(2))+ 'tiene ' + Cast(@edad2 as char(2))
	end

	 set @contador=@contador+1

end

