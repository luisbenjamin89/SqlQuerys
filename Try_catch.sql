------ try  y cath 

begin try 

insert into Products (ProductID,ProductID) values (100,'Nuevo producto')
print 'producto insertado con exito'

update Products set ProductName='te chai'
end try 

begin catch
print 'No se puede insertar , error'
end catch  

---
declare
@orderid int,
@prodid int,
@canti int,
@precio float

set @orderid=10248
set @prodid=1
set @canti=40
set @precio=35

begin try
insert into [Order Details](OrderID,ProductID,Quantity,UnitPrice) values (@orderid,@prodid,@canti,@precio)
print 'INSERCION CORRECTA'
end try
begin catch
print 'ERROR NO SE HA PODIDO AÑADIR'
end catch
 
select * from  [Order Details]



---------transacciones en sql , commit y rollback 




begin tran
 update  Products  set Products.UnitsInStock = 10 where ProductID=1
  select @@ERROR
insert into Products values (1,1,null,17,null,10,0,0,0,0)



 if ((select @@ERROR) = 0)
	begin
			commit tran
			print 'se hizo commit'
	end	
	
else
	begin
	 print 'se hizo rollback'	
		rollback tran
			
	end



select * from  products 
 

 select @@ERROR

 select @@TRANCOUNT

 select @@VERSION



 ----------------------

 BEGIN TRY
	update Orders 
		set EmployeeID=4
		where OrderID = 20248
	print 'Actualizado'
END TRY
BEGIN CATCH
	print 'ERROR UPDATE'
END CATCH