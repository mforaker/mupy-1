-- test db --
use master
go
use TestDB

if DB_ID('TestDB') is not null
drop database TestDB
go

create database TestDB
go
use TestDB
go

create table tblTest (
	testID	int		primary key	  Identity,
	Message	varchar(255)
)

insert into tblTest
values ('more')

go
create procedure spTest
AS
select Message from tblTest
go


Exec spTest

go
create procedure spTestArgs
@msg varchar(31),
@id	 int
as
select * from tblTest where Message = @msg and testID = @id

exec spTestArgs 'success', 1

drop procedure spTestArgs