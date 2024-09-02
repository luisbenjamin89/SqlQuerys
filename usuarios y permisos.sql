
create schema mi_esquema

create table mi_esquema.employes(
id_empleado int primary key 
)

---cambiar esquemas

alter schema mi_esquema transfer dbo.Region

------login

create login Sese3 with password = '1234' 

---
SELECT * FROM fn_my_permissions(NULL, 'SERVER');
GO

-----create user en northwind
create user usersese4  for login sese4

--- comando grant y revoke
grant select on orders to usersese3
