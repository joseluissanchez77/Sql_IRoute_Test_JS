/**
Nombre : Jose Luis Sanchez Baque
Fecha : 11 enero 2024
**/
--Creacion de base de datos 

-- Crear una nueva base de datos
CREATE DATABASE TEST_IR_JS;

-- usar la base datos
use TEST_IR_JS;

-- Crear la tabla con los campos especificados
CREATE TABLE cliente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    primerNombre NVARCHAR(50) NOT NULL,
    segundoNombre NVARCHAR(50),
    apellidos NVARCHAR(100) NOT NULL,
    identificacion NVARCHAR(20) NOT NULL,
    correo NVARCHAR(100) NOT NULL,
    estado INT DEFAULT 1 NOT NULL
);

--PROCEDIMIENTO TRX
--drop procedure sp_trx_clientes
CREATE PROCEDURE [dbo].[sp_trx_clientes]( 
@opcion VARCHAR(2), 
@id											INT=NULL, 
@primerNombre								VARCHAR (50)=NULL,  
@segundoNombre							    VARCHAR (50) =NULL,  
@apellidos							        VARCHAR (100)=NULL,   
@identificacion                             VARCHAR (20)=NULL,   
@correo									    VARCHAR (100)=NULL,    
@estado										int = 1,
@ctrl                                       INT output, 
@msj_ctrl                                   VARCHAR(500) output, 
@dato_1                                     VARCHAR(500) output, 
@dato_2                                     VARCHAR(500) output) 
AS 
  BEGIN 
    BEGIN try 
      BEGIN TRAN trx_clientes 
      IF @opcion='AA' 
      BEGIN 
        INSERT INTO cliente 
                    ( 
                        primerNombre,
						segundoNombre,
						apellidos,
						identificacion,
						correo,
						estado
                    ) 
                    VALUES 
                    ( 
                        @primerNombre,
						@segundoNombre,
						@apellidos,
						@identificacion,
						@correo,
						@estado
                    ) 
  
        SET @ctrl=7 
        SET @msj_ctrl = 'Se ha insertado cliente ' 
        SET @dato_1 = SCOPE_IDENTITY()
        SET @dato_2 = SCOPE_IDENTITY()
      END 

	  IF @opcion='AB' 
      BEGIN 
	   IF (SELECT COUNT(1) from cliente where id = @id ) = 0
	   BEGIN
	    SET @ctrl=5 
        SET @msj_ctrl = 'Cliente no existe' 
        SET @dato_1 = @id 
        SET @dato_2 = @id
	   END
	   ELSE IF (SELECT COUNT(1) from cliente where id = @id and estado = 0) >= 1
	   BEGIN
		SET @ctrl=4
        SET @msj_ctrl = 'Cliente ya esta inactivo ' 
        SET @dato_1 = @id 
        SET @dato_2 = @id
	   END
	   ELSE
	   BEGIN
	    UPDATE cliente 
        SET estado = 0
        WHERE  id = @id
      
        SET @ctrl=7
        SET @msj_ctrl = 'Se ha Borrado de cliente ' 
        SET @dato_1 = @id 
        SET @dato_2 = @id
	   END
      END 
      COMMIT TRAN trx_clientes 
    END try 
    BEGIN catch 
      SET @ctrl = 6 
      SET @msj_ctrl = 'ERROR EN PROCEDIMIENTO sp_trx_clientes ' + CONVERT(VARCHAR(10), Error_line()) + ' ' + Error_message()
      SELECT Error_number()    AS errNumber , 
             Error_severity()  AS errSeverity , 
             Error_state()     AS errState , 
             Error_procedure() AS errProcedure , 
             Error_line()      AS errLine , 
             Error_message()   AS errMessage , 
             @ctrl             AS ctrl , 
             @msj_ctrl         AS msj_ctrl 
      SET @dato_1 = '6' 
      SET @dato_2 = '6' ROLLBACK TRAN trx_clientes 
    END catch 
  END

--ejecutar procedimiento
USE [TEST_IR_JS]
GO
-- Con la opcion AA se peude crear un cliente
DECLARE	@return_value int,
		@ctrl int,
		@msj_ctrl varchar(500),
		@dato_1 varchar(500),
		@dato_2 varchar(500)

EXEC	@return_value = [dbo].[sp_trx_clientes]
		@opcion = N'AA',
		@primerNombre = N'jose',
		@segundoNombre =  N'luis',
		@apellidos = N'sabchez',
		@identificacion = N'0931147289',
		@correo = N'jose@gmail.com',
		@estado = 1,
		@ctrl = @ctrl OUTPUT,
		@msj_ctrl = @msj_ctrl OUTPUT,
		@dato_1 = @dato_1 OUTPUT,
		@dato_2 = @dato_2 OUTPUT

SELECT	@ctrl as N'@ctrl',
		@msj_ctrl as N'@msj_ctrl',
		@dato_1 as N'@dato_1',
		@dato_2 as N'@dato_2'

SELECT	'Return Value' = @return_value

GO

-- select * from cliente

USE [TEST_IR_JS]
GO
-- Con la opcion AB se puede inactivar un cliente 
DECLARE	@return_value int,
		@ctrl int,
		@msj_ctrl varchar(500),
		@dato_1 varchar(500),
		@dato_2 varchar(500)

EXEC	@return_value = [dbo].[sp_trx_clientes]
		@opcion = N'AB',
		@id =44,
		@ctrl = @ctrl OUTPUT,
		@msj_ctrl = @msj_ctrl OUTPUT,
		@dato_1 = @dato_1 OUTPUT,
		@dato_2 = @dato_2 OUTPUT

SELECT	@ctrl as N'@ctrl',
		@msj_ctrl as N'@msj_ctrl',
		@dato_1 as N'@dato_1',
		@dato_2 as N'@dato_2'

SELECT	'Return Value' = @return_value

GO


---------------------------------------------------------------
--procedimiento de consulta
CREATE PROCEDURE [dbo].[sp_con_clientes]( 
@identificacion                             VARCHAR (20)=NULL) 
AS 
  BEGIN 

      BEGIN TRAN con_clientes 
      IF @identificacion is not null 
      BEGIN 
        SELECT 
				id,
				primerNombre,
				segundoNombre,
				apellidos,
				identificacion,
				correo,
				estado
		FROM cliente
		WHERE identificacion LIKE '%' + @identificacion + '%'

      END 
	  ELSE
	  BEGIN
		  SELECT 
				id,
				primerNombre,
				segundoNombre,
				apellidos,
				identificacion,
				correo,
				estado
		FROM cliente
	  END
	 
      COMMIT TRAN con_clientes 


  END

 --ejecutar procedimiento 
 ---- consultar todos los registros por idendificacion
exec sp_con_clientes '0931147289';
--consultar todos los clientes
exec sp_con_clientes;

--delete from cliente where id >= 16