/*PROCEDIMIENTOS ALMACENADOS*/

/*Ejercicio 1*/

GO

CREATE PROCEDURE dbo.spu_operaciones
	@m1 smallint, @m2 smallint, @resultadoSuma smallint OUTPUT, @resultadoMultiplicacion smallint OUTPUT

AS
	SET @resultadoMultiplicacion = @m1*@m2
	SET @resultadoSuma = @m1+@m2
GO

DECLARE @respuestaSuma smallint, @respuestaMultiplicacion smallint;
EXEC dbo.spu_operaciones 5, 6, @respuestaSuma OUTPUT, @respuestaMultiplicacion OUTPUT;
print 'El resultado de la suma es: ' + cast(@respuestaSuma as varchar) + ' y el de la multiplicación es: ' + cast(@respuestaMultiplicacion as varchar);

/*Ejercicio 2*/

use EMPLEADOS;

GO 

CREATE PROCEDURE dbo.agregar_oficina
	@ciudad varchar(15),
	@region varchar(10),
	@director int,
	@objetivo numeric(18,0),
	@ventas numeric(18, 0)
AS
	IF @ciudad IS NULL or @region IS NULL or @ventas IS NULL
		BEGIN
			print 'Se requieren todos los datos obligatorios!'
			return
		END
	IF NOT EXISTS (SELECT * FROM REPVENTAS WHERE DIRECTOR=@director)
		BEGIN
			RAISERROR('El código de director introducido no es correcto', 14, 1)
		END
	DECLARE @numeroOficina int;

	SELECT @numeroOficina = MAX(OFICINA) FROM OFICINA
	SET @numeroOficina = @numeroOficina+1

	BEGIN TRY
		BEGIN TRANSACTION 
	 
			INSERT INTO OFICINA(OFICINA, CIUDAD, REGION, DIR, OBJETIVO, VENTAS)
			VALUES(@numeroOficina, @ciudad, @region, @director, @objetivo, @ventas)

			IF @@ERROR = 0
				COMMIT
			ELSE
				ROLLBACK
				return 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
        ROLLBACK;
	END CATCH

GO

EXEC dbo.agregar_oficina 'Santiago de Compostela', null, 104, 15000, 14000;
EXEC dbo.agregar_oficina 'Santiago de Compostela', 'NOROESTE', 123123123, 15000, 14000;

/*Ejercicio 3*/

GO 
	
CREATE PROCEDURE dbo.spu_agregar_pedido
	@numPedido numeric(18,0), @fechaPedido datetime, @cliente int, @vendedor int, @fabricante varchar(3), @producto varchar(5), @cantidad int, @importe numeric(18,0)
WITH ENCRYPTION
AS

	IF @numPedido IS NULL OR @fechaPedido IS NULL OR @cliente IS NULL OR @vendedor IS NULL OR @fabricante IS NULL OR @producto IS NULL OR @cantidad IS NULL OR @importe IS NULL
		BEGIN 
				print 'Faltan datos necesarios, intentalo de nuevo!'
				return
		END
	IF @cantidad - (SELECT EXISTENCIAS FROM PRODUCTO WHERE DESCRIPCION = @producto) < 0
		BEGIN
			PRINT 'No hay suficientes existencias'
			return 
		END
	BEGIN TRY
		BEGIN TRANSACTION
			BEGIN 
				INSERT INTO PEDIDO(NUM_PEDIDO, FECHA_PEDIDO, CLIE, REP, FAB, PRODUCTO, CANT, IMPORTE)
				VALUES(@numPedido, @fechaPedido, @cliente, @vendedor, @fabricante, @producto, @cantidad, @importe);

				UPDATE PRODUCTO SET EXISTENCIAS = EXISTENCIAS-@cantidad WHERE ID_PRODUCTO=@producto;
				UPDATE REPVENTAS SET VENTAS = VENTAS + @cantidad WHERE NUM_EMPL = @vendedor;
				UPDATE OFICINA SET OFICINA.VENTAS = OFICINA.VENTAS + @cantidad FROM OFICINA JOIN REPVENTAS ON OFICINA.OFICINA = REPVENTAS.OFICINA_REP WHERE REPVENTAS.NUM_EMPL = @vendedor;
			END

			IF @@ERROR = 0
				COMMIT
			ELSE
				ROLLBACK	
	END TRY
	BEGIN CATCH
		RAISERROR('Se ha producido un error', 14, 1)
	END CATCH

GO

execute dbo.spu_agregar_pedido 10001, '2002-04-02 15:30:00', NULL, 101, 'ACI', '41002', 100, 76


/*Ejercicio 4*/

use SOCIOS;

GO

CREATE PROCEDURE dbo.spu_aumentar_salario 
	@gastoSalarial numeric OUTPUT
WITH ENCRYPTION

AS
BEGIN TRANSACTION
	UPDATE EMPREGADO SET salario_mes=salario_mes*1.05

	IF (SELECT SUM(salario_mes) FROM EMPREGADO) > 15000
		BEGIN
			SET @gastoSalarial = (SELECT SUM(salario_mes) FROM EMPREGADO) 
			ROLLBACK
		END
	ELSE
		SET @gastoSalarial = (SELECT SUM(salario_mes) FROM EMPREGADO)

GO

DECLARE @gastoSalarial numeric

EXECUTE spu_aumentar_salario @gastoSalarial OUTPUT

print 'El gasto salarial es ' + cast(@gastoSalarial as varchar) + '€';

select * from EMPREGADO

/*Ejercicio 5*/

GO

CREATE PROCEDURE dbo.spu_actualizar_salario_empleado
	@codigoEmpleado int, @cantidad numeric
WITH ENCRYPTION
AS

	IF @codigoEmpleado IS NULL OR @cantidad IS NULL
		BEGIN
			print 'Se necesitan datos'
			return 
		END

	IF (SELECT COUNT(*) FROM EMPREGADO WHERE numero=@codigoEmpleado) = 0
		BEGIN
			print 'El empleado no existe'
			return 
		END

	BEGIN TRANSACTION
		BEGIN
			UPDATE EMPREGADO 
			SET salario_mes=salario_mes-@cantidad 
			WHERE @codigoEmpleado=numero

			SAVE TRANSACTION antesDeBorrar;

			IF (SELECT SUM(salario_mes) FROM EMPREGADO) < 10000
				BEGIN
					DELETE FROM EMPREGADO WHERE numero = @codigoEmpleado
					COMMIT
				END
			ELSE
				ROLLBACK TRANSACTION antesDeBorrar
		END
	DECLARE @salarioTotal numeric
	SET @salarioTotal = (SELECT SUM(salario_mes) FROM EMPREGADO)

	print 'Salario total: ' + cast(@salarioTotal as varchar) + '€'

GO

EXECUTE dbo.spu_actualizar_salario_empleado 100, 400

/*Ejercicio 6*/

use EMPLEADOS

GO 

CREATE PROCEDURE dbo.spu_insertar_cliente
	@numCliente int, @empresa varchar(20), @repCliente int, @limiteCredito numeric
WITH ENCRYPTION
AS

	IF @numCliente IS NULL OR @empresa IS NULL 
		BEGIN
			RAISERROR('Faltan datos necesarios', 14, 1)
			return
		END

	IF (SELECT COUNT(*) FROM CLIENTE WHERE EMPRESA=@empresa) != 0
		BEGIN
			RAISERROR('La empresa ya es socia', 14, 1)
			return 
		END

	IF @@ERROR = 0
		BEGIN
			INSERT INTO CLIENTE(NUM_CLIE, EMPRESA, REPCLIE, LIMITE_CREDITO)
			VALUES(@numCliente, @empresa, @repCliente, @limiteCredito)
			print 'Cliente ' + @empresa + ' añadido con éxito'
		END
	ELSE
		print 'Algo ha ocurrido...'
GO

GO
DECLARE @numMaryJones int
SET @numMaryJones = (SELECT NUM_EMPL FROM REPVENTAS WHERE NOMBRE = 'MARY JONES');

EXECUTE dbo.spu_insertar_cliente 3333, 'EMPRESA_DAW', @numMaryJones, 35000 WITH RECOMPILE
GO

SELECT * FROM CLIENTE

/*Ejercicio 7*/

use EMPLEADOS;

GO 

CREATE PROCEDURE spu_supera_importe_medio
	@numeroRep int
AS

	IF EXISTS (SELECT 1 FROM REPVENTAS WHERE NUM_EMPL=@numeroRep)
		BEGIN
			DECLARE @cantidad_importe_total numeric, @importe_medio_pedidos numeric, @nombreVendedor varchar(100)

			SET @nombreVendedor = (SELECT NOMBRE FROM REPVENTAS WHERE NUM_EMPL=@numeroRep)
			SET @importe_medio_pedidos = (SELECT AVG(IMPORTE) FROM PEDIDO)
			SET @cantidad_importe_total = (SELECT SUM(IMPORTE) FROM PEDIDO WHERE REP=@numeroRep)

			IF(@cantidad_importe_total > @importe_medio_pedidos)
				print 'El importe total ' + cast(@cantidad_importe_total as varchar) + ' de los pedidos del vendedor ' + @nombreVendedor + ' supera el importe medio ' + cast(@importe_medio_pedidos as varchar)
			ELSE
				BEGIN
					DECLARE @mensaje_final varchar(200)
					SET @mensaje_final = 'El importe total de los pedidos del vendedor ' + @nombreVendedor + ' NO supera el importe medio de los pedidos de la BD'

					RAISERROR(@mensaje_final, 16, 1)
				END	
		END
	ELSE
		BEGIN 
			print 'El número no corresponde a ningún empleado'
			return 
		END

GO


EXECUTE dbo.spu_supera_importe_medio 978 

/*Ejercicio 7.1*/

GO 

CREATE PROCEDURE spu_supera_importe_medio_v2
	@numeroRep int, @mensaje_final varchar(200) OUTPUT
WITH RECOMPILE
AS

	IF EXISTS (SELECT 1 FROM REPVENTAS WHERE NUM_EMPL=@numeroRep)
		BEGIN
			DECLARE @cantidad_importe_total numeric, @importe_medio_pedidos numeric, @nombreVendedor varchar(100)

			SET @nombreVendedor = (SELECT NOMBRE FROM REPVENTAS WHERE NUM_EMPL=@numeroRep)
			SET @importe_medio_pedidos = (SELECT AVG(IMPORTE) FROM PEDIDO)
			SET @cantidad_importe_total = (SELECT SUM(IMPORTE) FROM PEDIDO WHERE REP=@numeroRep)

			IF(@cantidad_importe_total > @importe_medio_pedidos)
				SET @mensaje_final = 'El importe total ' + cast(@cantidad_importe_total as varchar) + ' de los pedidos del vendedor ' + @nombreVendedor + ' supera el importe medio ' + cast(@importe_medio_pedidos as varchar)
			ELSE
				BEGIN
					SET @mensaje_final = 'El importe total de los pedidos del vendedor ' + @nombreVendedor + ' NO supera el importe medio de los pedidos de la BD'
				END	
		END
	ELSE
		BEGIN 
			print 'El número no corresponde a ningún empleado'
			return 
		END

GO

DECLARE @resultado1 varchar(200);
EXECUTE dbo.spu_supera_importe_medio_v2 101, @mensaje_final = @resultado1 OUTPUT;
print @resultado1;

DECLARE @resultado2 varchar(200);
EXECUTE dbo.spu_supera_importe_medio_v2 103, @mensaje_final = @resultado2 OUTPUT;
print @resultado2;

/*Ejercicio 7.2*/

EXEC dbo.spu_supera_importe_medio 101 WITH RECOMPILE

/*Ejercicio 7.3*/

EXEC sp_helptext 'spu_supera_importe_medio'

/*Ejercicio 7.4*/

DECLARE @viejo NVARCHAR(MAX);
SELECT @viejo = definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('spu_supera_importe_medio'); 


DECLARE @nuevo NVARCHAR(MAX);
SET @nuevo = REPLACE(@viejo, 'CREATE PROCEDURE', 'CREATE PROCEDURE WITH ENCRYPTION');


PRINT @nuevo;

/*Ejercicio 7.5*/

DECLARE @numEmpleado int, @mensajeFinal varchar(200)

DECLARE cursorImporteMedio CURSOR FOR
SELECT NUM_EMPL FROM REPVENTAS ORDER BY NOMBRE;

OPEN cursorImporteMedio;

FETCH NEXT FROM cursorImporteMedio INTO @numEmpleado

WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.spu_supera_importe_medio_v2 @numEmpleado, @mensajeFinal OUTPUT
		print @mensajeFinal
		FETCH NEXT FROM cursorImporteMedio INTO @numEmpleado
	END

CLOSE cursorImporteMedio
DEALLOCATE cursorImporteMedio

/*Ejercicio 8*/

USE SOCIOS;

GO
	
CREATE PROCEDURE dbo.spu_socio_moroso
	@numero_socio int
AS
	IF EXISTS(SELECT * FROM SOCIO WHERE numero = @numero_socio)
		BEGIN
			DECLARE @nombre_completo varchar(200)
			SET @nombre_completo = (SELECT CONCAT(nome, ' ', ape1, ' ', ape2) as 'Nombre Completo' FROM SOCIO WHERE numero = @numero_socio)
			IF (SELECT abonada FROM SOCIO WHERE numero = @numero_socio) != 'S'
				BEGIN
					DECLARE @N int
					SET @N = (SELECT COUNT(*) FROM SOCIO WHERE abonada != 'S')
					print 'El socio ' + @nombre_completo + ' debe ' + cast(@N as varchar) + ' actividades';
				END
			ELSE
				BEGIN
					DECLARE @mensajeFinal varchar(200)
					SET @mensajeFinal = 'El socio ' + @nombre_completo + ' NO debe actividades'
					RAISERROR(@mensajeFinal, 16, 1)
				END
			END
	ELSE
		BEGIN 
			print 'El número no corresponde a ningún socio'
			return 
		END
GO

EXECUTE dbo.spu_socio_moroso 1000 WITH RECOMPILE
EXECUTE dbo.spu_socio_moroso 1001
EXECUTE dbo.spu_socio_moroso 3388

/*Ejercicio 8.1*/

GO
	
CREATE PROCEDURE dbo.spu_socio_moroso_v2
	@numero_socio int, @mensajeResultado varchar(200) OUTPUT
WITH RECOMPILE
AS
	IF EXISTS(SELECT * FROM SOCIO WHERE numero = @numero_socio)
		BEGIN
			DECLARE @nombre_completo varchar(200)
			SET @nombre_completo = (SELECT CONCAT(nome, ' ', ape1, ' ', ape2) as 'Nombre Completo' FROM SOCIO WHERE numero = @numero_socio)
			IF (SELECT abonada FROM SOCIO WHERE numero = @numero_socio) != 'S'
				BEGIN
					DECLARE @N int
					SET @N = (SELECT COUNT(*) FROM SOCIO WHERE abonada != 'S')
					SET @mensajeResultado = 'El socio ' + @nombre_completo + ' debe ' + cast(@N as varchar) + ' actividades';
				END
			ELSE
				BEGIN
					SET @mensajeResultado = 'El socio ' + @nombre_completo + ' NO debe actividades'
				END
			END
	ELSE
		BEGIN 
			SET @mensajeResultado = 'El número no corresponde a ningún socio'
			return 
		END
GO

DECLARE @mensajeFinal varchar(200)

EXECUTE dbo.spu_socio_moroso_v2 1000, @mensajeResultado = @mensajeFinal OUTPUT

print @mensajeFinal

DECLARE @mensajeFinal2 varchar(200)

EXECUTE dbo.spu_socio_moroso_v2 1001, @mensajeResultado = @mensajeFinal2 OUTPUT

print @mensajeFinal2


/*Ejericio 8.2*/

EXEC dbo.spu_socio_moroso 101 WITH RECOMPILE

/*Ejercicio 8.3*/

EXEC sp_helptext 'spu_socio_moroso'

/*Ejercicio 8.4*/

DECLARE @viejo NVARCHAR(MAX);
SELECT @viejo = definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('spu_socio_moroso'); 


DECLARE @nuevo NVARCHAR(MAX);
SET @nuevo = REPLACE(@viejo, 'CREATE PROCEDURE', 'CREATE PROCEDURE WITH ENCRYPTION');


PRINT @nuevo;

/*Ejercicio 8.5*/

GO

DECLARE @numSocio int, @mensajeFinall varchar(200)

DECLARE cursorMoroso CURSOR FOR
SELECT numero FROM SOCIO ORDER BY nome;

OPEN cursorMoroso;

FETCH NEXT FROM cursorMoroso INTO @numSocio

WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.spu_socio_moroso_v2 @numSocio, @mensajeFinall OUTPUT
		print @mensajeFinall
		FETCH NEXT FROM cursorMoroso INTO @numSocio
	END

CLOSE cursorMoroso
DEALLOCATE cursorMoroso

GO






	