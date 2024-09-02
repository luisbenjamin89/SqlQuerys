use Northwind

select * from Employees

----procedimientos almacenado
go 
create procedure prc_001(

@id_cli nchar(5)
)
as 
begin
select c.CompanyName from Customers c where CustomerID = @id_cli
end
go 

exec prc_001 "mm"

-------procedimiento con parametros de entrada y salida
go 

create proc proc_xx (
@producid  int,
@productname varchar(50) output,
@preciounitario money output
)
as
begin
 select  @productname =  p.ProductName, @preciounitario = p.UnitPrice from Products p 
 where p.ProductID = @producid

end
 
 /*ejecucion */
 declare @producname varchar(50) ,@unitprice money
exec proc_xx 1,@producname output , @unitprice output
select @producname, @unitprice

----modificacion del proc anterior 
go

alter proc proc_xx_mod (
@producid  int,
@productname varchar(50) output,
@suplyname varchar(50) output
)
as
begin
 select  @productname =  p.ProductName, @suplyname = s.CompanyName from Products p 
 inner join Suppliers s on p.SupplierID =s.SupplierID
 where p.ProductID = @producid

end
go
 declare @productname varchar(50) ,@suplyname varchar(50)
exec proc_xx_mod 1,@productname output , @suplyname output
select @productname as product_name, @suplyname as supplier


----nuevo procedimientos con valor de retorno

go 

alter proc procejercicio 
(
@productname varchar(10) 

)
as 
begin
select p.ProductName from Products  p
where p.ProductName  like @productname + '%'
end

exec procejercicio 's'


---el numero de productos por una determinada letra
go

alter proc pronumero 
(
@productname varchar(10) ,
@nuemro int output

)
as 
begin
 select @nuemro = COUNT(*) from Products  p
where p.ProductName  like @productname + '%'

return @nuemro

end

declare @numero  int
exec pronumero 's',@numero output
select @numero

go
------nuevo procedimiento 

create proc totalventa(
@idventa int
)
as
begin
select sum(p.UnitPrice) from Orders o 
inner join [Order Details] od on o.OrderID= od.OrderID
inner join Products p on od.ProductID =p.UnitPrice
where o.OrderID = @idventa
end
go

exec totalventa 10249


----- preocedimiento de dia de la semana 
go

alter proc PDiasemana(
@Dia varchar(10) output
)
as 
begin
declare @Ndia int
set @Ndia = datepart(DW,GETDATE())

select case (@Ndia)
when 1 then 'Lunes'
when 2 then 'Martes'
when 3 then 'Miercoles'
when 4 then 'Jueves'
when 5 then 'Viernes'
when 6 then 'Sabado'
when 7 then 'Domingo'
end
end
go
declare @Dia  varchar(10) 
exec PDiasemana @Dia output
go 
----procedimiento
update products set UnitPrice =
case  
when UnitPrice <= 20 then UnitPrice+10
when UnitPrice >20 and UnitPrice <=50 then UnitPrice +20
else UnitPrice +30
end


----procedimiento que recibe un producto por nombre y una categoria y si el producto no exite lo insertara el en table producto
--- si exite el producto pero no lleva categoria le informara 

go

alter proc prodcatego
(
@nombre varchar (50),
@categoria varchar(50)
)
as
begin 
declare @maxid int

if (NOT EXISTS(select ProductName from Products p where p.ProductName= @nombre) and NOT EXISTS(select CategoryName from categories c where c.CategoryName= @categoria))
begin
print 'El producto y la categoria no exiten , se procedera a ingresar'
insert into Categories values (@categoria,'nueva categoria',null)
set @maxid = (select c.CategoryID from categories c where c.CategoryName=@categoria)
insert into  Products values (@nombre,null,@maxid,null,null,0,0,0,0)
end

else 

if exists (select ProductName from Products p where p.ProductName= @nombre) and NOT EXISTS(select CategoryName from categories c where c.CategoryName= @categoria)
begin

print 'El producto existe pero la categoria no  , se procedera a ingresar la categoria';
insert into Categories values (@categoria,'nueva categoria',null);

end

else 

print 'El producto y la categoria existen por tanto no se tomara ninguna accion';

end




exec prodcatego Chai,Beverages


select * from Products p inner join Categories c on p.CategoryID= c.CategoryID

delete Categories where Picture is null
delete products where CategoryID is null

select * from products
select * from Categories

go
/*
Crear procedimiento para añadir un nuevo producto asociado a una orden de venta
Este procedimiento deberá controlar:
	- Si la orden existe
	- Si el producto existe en la tabla Products
	- Si el producto ya está en la orden de venta
	- Si la cantidad pedida supera el stock
Como parámetros de entrada deberemos indicar:
	- Numero de Orden
	- Id Producto
	- Cantidad a vender
	- Precio de venta
El procedimiento devolverá un mensaje de: producto añadido a la orden
En caso de error (si no existe la orden, si el producto ya está en esa orden, si la cantidad super orden de stock:
'ERROR NO SE HA PODIDO AÑADIR'
*/
go 

create proc productosnuevos
(
@orderid int,
@prodid int,
@canti int,
@precio float
)
as 
begin
if exists (select orderid from Orders where orderid =@orderid) and exists (select ProductID  from Products p where ProductID=@prodid) 
and not exists (select * from [Order Details] o where o.ProductID=@prodid and o.OrderID=@orderid) and (@canti <= (select UnitsInStock from Products where ProductID=@prodid))
begin 
print 'TODO ESTA BIEN , SE PROCEDERA CON LA INSERCION EN LA VENTA '
insert into [Order Details](OrderID,ProductID,Quantity,UnitPrice) values (@orderid,@prodid,@canti,@precio)
print 'INSERCION CORRECTA'
end
else
print 'ERROR NO SE HA PODIDO AÑADIR'
end

EXEC productosnuevos 10248,3,5,20

/*
Crear procedimiento para añadir un nuevo producto asociado a una orden de venta
Este procedimiento deberá controlar:
	- Si la orden existe: error no se puede insertar 

	- Si el producto existe en la tabla Products añadir ala tabla productos con un idcategoria =17 

	- Si el producto ya está en la orden de venta up date a la cantidad y precion pasado por parametros

	- Si la cantidad pedida supera el stock error
	-en caso de exito debemos  debemos actualizar la tabla productos  la unidades en stock  y las unidades en orden 
Como parámetros de entrada deberemos indicar:
	- Numero de Orden
	- Id Producto
	- Cantidad a vender
	- Precio de venta
El procedimiento devolverá un mensaje de: producto añadido a la orden
En caso de error (si no existe la orden, si el producto ya está en esa orden, si la cantidad super orden de stock:
'ERROR NO SE HA PODIDO AÑADIR'
*/

go 

alter proc productosnewsorden
(
@orderid int,
@procd varchar(50),
@canti int,
@precio float
)
as 
declare @prodid int
set @prodid = (select ProductID from Products where ProductName=@procd)
begin
	if not exists (select orderid from Orders where orderid =@orderid) 
		begin 
		print 'No se puede insertar datos al orden por que no existe'

	end
	else
	
		if not exists (select ProductID  from Products p where ProductName=@procd) 
			begin
				print 'El producto no existe se procedera a insertar el producto en tabla producto'
				insert into Products values (@procd,null,17,null,@precio,0,0,0,0)
			end
    else 
	     if (exists (select * from [Order Details] o where o.ProductID=@prodid and o.OrderID=@orderid) and (@canti <= (select UnitsInStock from Products where ProductID=@prodid)))
			begin
				 print 'El producto exite en la orden se procedrea a actuilzar  la cantidad en STCOK y candias en ORDEN'
				 update  Products  set Products.UnitsInStock = (Products.UnitsInStock-@canti) ,Products.UnitsOnOrder=(Products.UnitsOnOrder+@canti) where ProductID=@prodid
				 update [Order Details] set Quantity= (Quantity+@canti) where ProductID=@prodid and OrderID = @orderid
			end

			else 

			print 'ERROR NO SE HA PODIDO AÑADIR POR QUE LA CANTIDAD ES MAYO DE LA DISPOLIBEL EN STOCK' 
end

go

EXEC productosnewsorden 10248,'chocolate',1,20


select* from Products where ProductID = 83
select * from [Order Details] where OrderID = 10248


---crear un procedimiento que va a resibur un para remetro el cual va indicar que se haga un insert un update o un delete en la tabla order
go

alter proc P_opciones
(
@opcion int ,
@custumer nchar(5),
@Employid int
)
as
begin

if @opcion =1
begin
exec insertorder @custumer,@Employid
end
else 

end



go

alter proc insertorder
(
@custumer nchar(5),
@Employid int
)
as
begin
insert into Orders(CustomerID,EmployeeID) values (@custumer,@Employid)
end
go



exec P_opciones 1,'VINET',4

/*
----procedimiento factura cliente 
crear un nuevo procedimiento que reciba como parametros una fecha, codigo de empleado,
prudcto 'factuara mes' y el total de la factura

El procedmiento creara una orden  de venta en el dia indicado 

*/
go 
select ROW_NUMBER()over(order by CustomerID asc)posicion,CustomerID into temp from Customers 
go

alter proc P_factura
(
@fecha datetime
)
as 
declare @rowtotal int,@contador int,@orderidnew int,@cliente nchar(5)
begin
 set @rowtotal= (select count(*)from Customers)
set @contador = 1


while @contador < = @rowtotal
begin


		set @cliente=(
					select CustomerID from temp where posicion = @contador
		)

		insert into  orders (CustomerID,EmployeeID,OrderDate) values(@cliente,5,@fecha)

		set @orderidnew = (select max(OrderID)from orders)

		insert into [Order Details](OrderID,ProductID,UnitPrice) values (@orderidnew,87,20)

      set @contador =@contador+1
  end
end 

declare @fechas datetime
set @fechas= getdate()
exec P_factura @fechas


select * from Orders
select * from [Order Details] where ProductID=87
select * from Products

/* procedimiento reparte productos

Este procedimiento no lleva parametro de entreda.
Dividira el numero de productos entre los proveedores tomando el numero entero
en el caso de que salgan decimales.
al ultimo proveedor se le asignara el numero de productos restanes.
*/

go

alter proc reparto
as 
begin
declare 
@contador int,
@totalprod int ,
@totalsuply int,@idpant int,
@division float,@idpost int
begin tran
set @contador = 1
set @totalprod=(select count(*) from products)
set @totalsuply = (select count(*) from [dbo].[Suppliers])
set @division = FLOOR( @totalprod/@totalsuply)
set @idpost = @division
set @idpant =1

	begin try

				while @contador <= @totalsuply
					begin
								     
							      update products  set SupplierID = @contador
	                                    where ProductID between @idpant and @idpost

                               
							   set @contador = @contador+1
							   set @idpant =@idpant+@division
							   set @idpost = @idpost+@division
							   
							if (@contador = @totalsuply)
							set @idpost = @totalprod
                                      
					end 
					commit tran

		end try
		 begin catch
		 rollback tran
		 print 'error por favor validar bien'
		 end catch
end

exec reparto



select * from products order by SupplierID

select * from Suppliers



go

/*Añadir una nueva columna a la tabla productos para almacenar un código
	alfanumérico cuyo patrón debe ser AAA-NNNN.
	Los tres primeros caracteres estarán formados por las tres primeras
	letras del nombre del producto. Los últimos 4 caracteres es un número
	aleatorio de 4 dígitos. No importa que el código se repita.
	Se debe añadir este campo cuando se inserte un nuevo producto
*/

declare @aleatorio int, @codigo nvarchar(20)

select @codigo = SUBSTRING(UPPER(ProductName),1,3) from Products

set @aleatorio = (select FLOOR(RANd()*10000))

set @codigo = @codigo+'-'+cast(@aleatorio as char(4))

--set @codigo=trim(@codigo)+ +format(@aleatorio,'0000')

select @codigo


--------procedmiento para poner el numero de facturaen la tabla orders 
--1.añadir nueva columna en la tabla orders :NFactura 
--2.La factura tiene que seguir el mismo patron  DIA(2caracteres),mes(2caracteres),año(4caracteres)+ 5 digitos 
--NFactura = 2207202400000
--Nfacrura debe ser consecutivo por la fecha
--3.procedmientos  que se encargue de informar el numero de factura , que recibira el id_orden
--4.El numero dela factura lo debe de dar una funcion que recibe la orden 

go 

alter proc num_invoice
(
@orderid int
)
as 
begin
declare @forden date,@factura nvarchar(50),@id int,@contador int
select @forden=orderdate from orders where OrderID=@orderid
set @id=(select count(*) from  dbo.create_num(@orderid))
set @contador= 1
while @contador <= @id
    begin
			update Orders set num_invoice = (select factura from  dbo.create_num(@orderid)  where id = @contador )
			   where OrderID = (select idorder from  dbo.create_num(@orderid)  where id = @contador) 

			   set @contador = @contador+1
	end
                          

end

exec num_invoice 10251

select * from Orders where num_invoice is not null
select * from Orders where OrderID=10250

select factura from dbo.create_num(10250) where idorder = 10251

/*Ejercio re-estructurar la base de datos 

normalizacion de la tabla products 
 
 El campo suppliersid es un campo qaue sobra en dicha tabla ya que el proveedor no define a un producto , eleminarl el campo suppliersid  y enlazar la tabla productoscon 
 suppliers mediente una tabla auxiliar  el campo quantity no es atomico . sustituirlo por campos embalaje y unidades 
 
 el campo  precio tampoco define el producto . añadirlo a prescions de proveedor 
 */

 select * from products

 select *  from inventario
 insert into [dbo].[Inventario] 
 select SUBSTRING(productName,1,3)+'-'+ format(ROW_NUMBER()over(partition by   SUBSTRING(productName,1,3)  order by  SUBSTRING(productName,1,3) asc),'00000')id_inventario,ProductID,SupplierID,UnitPrice
 from Products

 insert into dbo.embalaje (id_producto,descripcion)  
 select ProductID,QuantityPerUnit from Products
 

select * from Products where QuantityPerUnit is null  

select * from pedido
select * from detalle_pedido

create table warehouse
(
id_warehouse int primary key ,
nombre nvarchar(50)
)


select * from inventario


------------------with
go

with clintes  as 
(select Customerid,ContactName from Customers) ,

empleado as (select FirstName,EmployeeID from Employees)

select * from clintes , empleado

exec sp_renamedb 'Northwind','Northwindold'

go
-- GENERAR EAN INVENTADO.

-- CREAR UN PROCEDIMIENTO O FUNCIÓN QUE GENERE UN CÓDIGO EAN.
-- EL CÓDIGO EAN, SERÁ TENDRÁ EL SIGUIENTE PATRÓN:
-- LO GUARDAREMOS EN UN NUEVO CAMPO DE LA TABLA PRODUCTOS: Codigo_EAN
--
--	(NNN(VARIABLE))NNNNNN(NNN)NNNNNN
--
-- DONDE N ES UN NÚMERO DEL 0 AL 9
--
-- LOS TRES PRIMEROS REPRESENTAN LA SUMA DEL NOMBRE DE LA CATEGORÍA EN CÓDIGO ASCII
-- LOS SEIS DÍGITOS SIGUIENTES REPRESENTAN UNA FECHA QUE LE VAMOS A PASAR.

-- LOS TRES DÍGITOS SIGUIENTES SON UN NÚMERO DE CONTROL.

-- LOS SEIS ÚLTIMOS SON UN NUMERO ALEATORIO ENTRE O Y 999999. NO SE PUEDE REPETIR.

-- EL NÚMERO DE CONTROL SE CALCULA DE LA SIGUIENTE FORMA:
-- SE SUMAN LOS NUMEROS SITUADOS EN LAS POSICIONES IMPARES DEL NUMERO ALEATORIO
-- SE MULTIPLICAN POR 3
-- SE SUMAN LOS NUMEROS EN LAS POSICIONES PARES DEL NUMERO ALEATORIO Y SE MULTIPLICAN
-- POR 2.
-- AL FINAL SE SUMAN AMBOS NÚMEROS Y ESO NOS DA EL DIGITOS DE CONTROL.

-- EL NUMERO FINAL DE 6 DIGITOS ESTÁ FORMADO POR LOS NUMEROS EN 
-- POSICIONES PARES SIN MOVER Y LOS NUMEROS EN POSICIONES IMPARES PUESTOS DEL REVÉS.


alter proc generar_EAN
(
@categoria nvarchar(50),
@fecha date
)
as 
begin

	declare @i int ,
	@suma int ,@date nvarchar(6),
	@codigo nvarchar(50),@n_random1 int,
	@n_random2 int ,@random int , @n_control int,@n_c_par int , @n_c_impar int

	set @suma = 0
	set @i = 1
	set @date = cast ( format(@fecha,'ddMMyy') as nvarchar(6))
	set @n_random1 =FLOOR(RAND()*(100000-1000000)+1000000)
	set @n_random2 =FLOOR(RAND()*(100000-1000000)+1000000)
	set @n_control = 0

		while @i <= len(@categoria)
			begin 
				set @suma  = ascii ( substring(@categoria,@i, 1) ) + @suma
				set @i = @i +1
			end 

		if (@n_random1 <> @n_random2)
				begin
				set @random = @n_random1
				end
			else 
				begin
				set @random = FLOOR(RAND()*(100000-1000000)+1000000)
				 end

    set @n_c_impar=  (cast(substring (cast(@random as nvarchar(6)),1,1)as int)) + cast(substring (cast(@random as nvarchar(6)),3,1)as int) +cast(substring (cast(@random as nvarchar(6)),5,1)as int)
	set @n_c_par=  cast(substring (cast(@random as nvarchar(6)),2,1)as int) + cast(substring (cast(@random as nvarchar(6)),4,1)as int)+cast(substring (cast(@random as nvarchar(6)),6,1)as int)
	set @n_control=@n_c_par+@n_c_impar
    set @codigo = '('+cast(@suma as nvarchar(20))+')'+ @date+'('+ +cast(@n_control as nvarchar(10))+')'+cast(@random as nvarchar(6))

	select @codigo


end 

go 

  

select * from products
select * from Categories