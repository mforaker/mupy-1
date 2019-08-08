/*

MuPy dB script

store user and course data

*/


/* FIRST... select sql server to connect to */
use master


/* Users - create table and procedure to add/remove users */

	create table Users (
		userId			int				primary key		identity,
		username		nvarchar(255) not null,
		email			nvarchar(255) not null,
		passHash		varbinary(64) not null
	)

	/* sp to add user */
	go
	create procedure spAddUser
		@username nvarchar(255),
		@email	  nvarchar(255),
		@password nvarchar(255),
		@response nvarchar(255)
	as
	begin
		set nocount on

		begin try

			insert into Users (username, email, passHash)
			values(@username, @email, HASHBYTES('SHA2_512', @password))

			set @response = 'Success'
	
		end try

		begin catch
			set @response = ERROR_MESSAGE()
		end catch
		set nocount on
	end

	exec spAddUser	
		@username = 'Test',
		@email = 'example@hotmail.com',
		@password = '12345',
		@response = 'null'


	/* sp to remove user */
	go
	create procedure spRemoveUser
		@responseRM nvarchar(255),
		@returnvalue int,
		@usernameRM nvarchar(255),
		@passwordRM nvarchar(255)


		as
		begin 
		begin try
			exec @returnvalue = spLoginUser
				@username = @usernameRM,
				@password = @passwordRM,
				@response = 'null'

			if (@returnvalue = 1)
			begin
				/*  delete account  and info */
				delete from Users where username = @usernameRM
			end

		end try

		begin catch
			set @responseRM = 'failed'
			set @returnvalue = -2

		end catch

		return @returnvalue

		end

	declare @returnvalueMSG int


	exec @returnvalueMSG = spRemoveUser
		@responseRM = 'null',
		@returnvalue = 0,
		@usernameRM = 'Test',
		@passwordRM = '12345'

		print @returnvalueMSG

		drop procedure spRemoveUser

	

	/* sp to login user */
	go
	create procedure spLoginUser
	@username nvarchar(255),
	@password nvarchar(255),
	@response nvarchar(255)
	
	as 
	begin

		begin try

			/* query users table for matching user name or email. then compare passwords */
			if exists (select top(1) userId from Users where username = @username or email = @username)
			begin
				if exists( select userId from Users where username = @username and passHash = HASHBYTES('SHA2_512', @password) or email = @username and passHash = HASHBYTES('SHA2_512', @password) )
				begin
					/* correct name and pass */
					set @response = 1
				end
				else
					/* correct name and  incorrect pass */
					set @response = 0
				end
			else
				set @response = -1


		end try

		begin catch

			set @response = -2

		end catch

		return @response

	end

	


	
	declare @returnvalue int;

		exec @returnvalue = spLoginUser
		@username = 'example@hotmail.com',
		@password = '12345',
		@response = 'null'

	print @returnvalue
		






/* Languages - table to language name, id , and description */
	create table Languages (
		languageId		int				primary key		identity,
		languageName	nvarchar(255),
		languageDesc	nvarchar(255)
	)




	go
	create procedure spAddLanguage
	@response nvarchar(255),
	@languageName nvarchar(255),
	@languageDesc nvarchar(255)
	as
	begin
	begin try
		insert into Languages (languageName, languageDesc)
		values(@languageName, @languageDesc)
		set @response = 'success'
	end try
	begin catch
		set @response = 'failed'
	end catch
	end


	exec spAddLanguage
	@response = 'null',
	@languageName = 'Python',
	@languageDesc = 'Python is a versitle language and is easy to learn. If you want to start your own coding proects asap, Python is the language for you.'







/* Courses table - store course info such as language type, name, desc, ect */
	create table Courses(
	courseId		int				primary key		identity,
	courseName		nvarchar(255),
	languageId		int				foreign key references Languages,
	courseDesc		nvarchar(255)
	)
	

	/* sp to add course */
	go
	create procedure spAddCourse
	@response nvarchar(255),
	@courseName nvarchar(255),
	@languageName nvarchar(255),
	@courseDesc nvarchar(255)

	as 
	begin
		begin try
			/*note... language name is automatically coneverted to language id */
			declare @languageId int
			set @languageId = (select top(1) languageId from Languages where languageName = @languageName)

			insert into Courses (courseName, languageId, courseDesc)
			values (@courseName, @languageId , @courseDesc)

			set @response = 'success'
		end try

		begin catch
			set @response = ERROR_MESSAGE()
		end catch
	end


	exec spAddCourse
	@response = 'null',
	@courseName = 'Python Basics I',
	@languageName = 'Python',
	@courseDesc = 'Python Basics will help you learn coding fundementals and get you on your way to becomeing a python expert.'

	select * from Courses







/* Modules - lessons stored inside of courses */
	create table Modules(
	moduleId		int			primary key		identity,
	courseId		int			foreign key references Courses,
	lessonNumer		int, /* what lesson is this? 1st of the course, 2nd, or so on */
	moduleDesc		nvarchar(255),
	moduleName		nvarchar(255)
	)
	

	go
	create procedure spAddModule
	@response		nvarchar(255),
	@courseName		nvarchar(255),
	@lessonNumber	int,
	@moduleDesc		nvarchar(255),
	@moduleName		nvarchar(255)

	as
	begin
		begin try
			declare @courseId int
			set @courseId = (select top(1) courseId from Courses where courseName = @courseName)

			insert into Modules (courseId, lessonNumer, moduleDesc, moduleName)
			values( @courseId, @lessonNumber, @moduleDesc, @moduleName)

			set @response = 'sucess'
		end try

		begin catch
			set @response = ERROR_MESSAGE()
		end catch
	end


	exec spAddModule
	@response = 'null',
	@courseName = 'Python Basics I',
	@lessonNumber = 1,
	@moduleDesc  = 'This lesson will help get you familiar with the python programming environment.',
	@moduleName = 'Python Basics I: Hello World'

	select * from Modules



/* User Module Data  - store usre code ect */
	create table UserModuleData(
	userModuleDataId	int				primary key		identity,
	userId				int				foreign key references Users,
	moduleId			int				foreign key references Modules,
	usersCode			varchar(max),
	isComplete			int,
	timeOnExit			datetime
	)

	


	/* sp to add user module data - e.g. user starts new module */
	go
	create procedure spAddNewUserModuleData
	@response	nvarchar(255),
	@userId		int,
	@moduleId	int,
	@usersCode	varchar(max),
	@isComplete int,
	@timeOnExit	datetime

	as
	begin
		begin try
			
			insert into UserModuleData (userId, moduleId, usersCode, isComplete, timeOnExit)
			values (@userId, @moduleId, @usersCode, @isComplete, CURRENT_TIMESTAMP)

			set @response = 'success'

		end try

		begin catch
			set @response = ERROR_MESSAGE()
		end catch

		return @response
	end


	declare @AddNewUserModuleDataResponse nvarchar(255)
	exec @AddNewUserModuleDataResponse = spAddNewUserModuleData
	@response = 'null',
	@userId = 2,
	@moduleId = 3,
	@usersCode = '',
	@isComplete = 0,
	@timeOnExit = null
	print @AddNewUserModuleDataResponse






	/* Update user module data time of exit*/
	go
	create procedure spUpdateUserModuleDataTime
	@response nvarchar(255),
	@userId		int,
	@moduleId	int

	as
	begin
		begin try	
			update UserModuleData
			set timeOnExit = CURRENT_TIMESTAMP
			where userId = @userId and moduleId = @moduleId


			set @response = 'success'
		end try

		begin catch
			set @response = ERROR_MESSAGE()
		end catch
	end

	drop procedure spUpdateUserModuleDataTime

	exec spUpdateUserModuleDataTime 
	@response = 'null',
	@userId = 2,
	@moduleId = 3




	/* update  user module data users code*/
	go
	create procedure spUpdateUserModuleDataCode
	@response	nvarchar(255),
	@userId		int,
	@moduleId	int,
	@userscode	varchar(max)

	as
	begin
		begin try
			
			update UserModuleData
			set usersCode = @userscode
			where userId = @userId and moduleId = @moduleId

			set @response = 'success'

		end try

		begin catch
			set @response = 'failed'
		end catch
	end



	exec spUpdateUserModuleDataCode
	@response = 'null',
	@userId = 2,
	@moduleId = 3,
	@userscode = 'print(''Hello World'')'






	/* update  user module data isComplete*/
	go
	create procedure spUpdateUserModuleDataComplete
	@response	nvarchar(255),
	@userId		int,
	@moduleId	int,
	@isComplete	int

	as
	begin	
		begin try
			update UserModuleData
			set isComplete = @isComplete
			where userId = @userId and moduleId = @moduleId
		end try

		begin catch
			set @response = 'failed'
		end catch
	end


	exec spUpdateUserModuleDataComplete
	@response = 'null',
	@userId = 2,
	@moduleId = 3,
	@isComplete = 1



	select * from UserModuleData