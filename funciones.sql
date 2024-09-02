alter function mi_funcion
(
@variable1 int,
@variable2 int
)
returns int 
as 
begin
declare  @variable3 int

set @variable3=@variable1+@variable2

return  @variable3
end 

select dbo.mi_funcion (6,5)


----------traducir el dia de la semana

alter function dia_semana
(
@date date
)
returns varchar (50)
as 
begin
declare @result varchar (50)

 select @result = ( case datepart(WEEKDAY,@date)
      when 1 then 'LUNES'
     when 2 then 'MARTES'
     when 3 then 'MIERCOLES'
     when 4 then 'JUEVES'
     when 5 then 'VIERNES'
     when 6 then 'SABADO'
     when 7 then 'DOMINGO'
	 end )
return @result
end


select dbo.dia_semana ('22/07/2024')


select datename(dw,datepart(WEEKDAY,GETDATE()))

select datepart(WEEKDAY,GETDATE())



------funcion que retorna una tabla
create function nombrecompleto
(
@codigoempl varchar(125)
)returns table
as 
return ( select FirstName+' '+LastName as nombreapelli FROM Employees where EmployeeID=@codigoempl)

select * from nombrecompleto (4)

-----

declare @mi_table table(nombrecompleto varchar(125),fechanacimiento varchar(10), ordenventa int )

insert into @mi_table
select FirstName+' '+LastName as nombre,dbo.dia_semana(birthdate),OrderID FROM Employees
inner join orders on  Employees.EmployeeID = Orders.EmployeeID

select * from @mi_table


----------funcion que calcule el total de una orden pasando el id de la orden
go
create function total_invoice
(
@ordenid int 

)returns int
as 
begin
declare @resul int 

select @resul =sum(UnitPrice) from Orders o inner join [Order Details] od
 on o.OrderID = od.OrderID
 where o.orderid= @ordenid
 group by o.OrderID

return @resul

end

select dbo.total_invoice(10248)
 

 ------funcion que genera numero de factura
alter function create_num(@orderid int)
 returns @data table (id int, idorder int ,factura varchar(50))
 as
begin
 declare @forden date

select @forden=orderdate from orders where OrderID=@orderid

insert into @data select    ROW_NUMBER()over(partition by  OrderDate order by OrderDate asc) as id ,OrderID, format (OrderDate,'ddMMyyyy')+'-'+FORMAT( ROW_NUMBER()over(partition by  orderdate  order by orderdate asc),'00000' ) as factura from Orders
  where OrderDate = @forden

return 
  
end

 select * from dbo.create_num(10250)

 select * from orders









