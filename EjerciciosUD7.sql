use EMPLEADOS;
/*Ej. 1.1*/
GO
DECLARE @miNombre varchar(20);
SET @miNombre = 'Julio';
PRINT 'Mi nombre es ' + @miNombre;

/*Ej. 1.2*/

GO
DECLARE @maxObjVentas varchar(100);
SELECT TOP 1 @maxObjVentas = CIUDAD
FROM OFICINA
ORDER BY OBJETIVO DESC;

print 'La oficina con el mayor objetivo de ventas es la de ' + @maxObjVentas;

/*OR*/

GO 
DECLARE @maxObjVentas varchar(100);
SELECT @maxObjVentas = CIUDAD
FROM OFICINA
WHERE OBJETIVO = (SELECT MAX(OBJETIVO) FROM OFICINA);

print 'La oficina con el mayor objetivo de ventas es la de ' + @maxObjVentas;

/*Se hai varias oficinas co mesmo obxectivo de ventas e son as primeiras, sería interesante usar cursores para percorrer fila por fila o resultado.*/

/*Ej. 1.3*/

GO 
DECLARE @maxObjVentas varchar(100);
DECLARE @ventas numeric;

SELECT @maxObjVentas = CIUDAD
FROM OFICINA
WHERE OBJETIVO = (SELECT MAX(OBJETIVO) FROM OFICINA);

SELECT @ventas = OBJETIVO
FROM OFICINA
WHERE CIUDAD = @maxObjVentas;

print 'Con objetivo de ' + cast(@ventas as varchar) + '€ la oficina con el mayor objetivo de ventas es la de ' + @maxObjVentas;

/*Ej. 1.4*/

GO
DECLARE @idioma varchar(50);
SELECT @idioma = @@LANGUAGE;

IF @idioma = 'Español'
	print 'Hola';
ELSE
	print 'Hello';

/*Ej. 1.5*/

GO

IF @@LANGUAGE = 'Español'
	print 'Hola';
ELSE
	print 'Hello';

/*Ej. 1.6*/

GO

DECLARE @nEmpleado numeric;
DECLARE @nombreCompleto varchar(100);
DECLARE @fechaContrato datetime;

SELECT @nEmpleado = 102;

IF EXISTS(SELECT * FROM REPVENTAS WHERE NUM_EMPL=@nEmpleado)
	BEGIN
		SELECT @nombreCompleto = NOMBRE, @fechaContrato = CONTRATO
		FROM REPVENTAS
		WHERE NUM_EMPL = @nEmpleado;
		print 'El empleado con Nº' + cast(@nEmpleado as varchar) + ' se llama ' + @nombreCompleto + ' y su contrato consta de esta fecha: ' + cast(@fechaContrato as varchar);
	END
ELSE
	print 'El empleado con Nº' + cast(@nEmpleado as varchar) + ' no existe en la base de datos!';

/*Ej. 1.7*/

GO

SELECT * INTO #CLIENTE2
FROM CLIENTE;

SELECT * FROM #CLIENTE2;

DECLARE @max numeric;

SELECT @max = MAX(NUM_CLIE)
FROM #CLIENTE2;

WHILE((SELECT COUNT(NUM_CLIE) FROM #CLIENTE2)> 1)
BEGIN 
	DELETE FROM #CLIENTE2	
	WHERE NUM_CLIE=@max;
	SET @max-=1;
END

SELECT * FROM #CLIENTE2;

/*Ej. 1.8*/

GO

print 'Ejemplo de uso de CASE';

SELECT NUM_EMPL, NOMBRE, CUOTA,
	(case 
		when cuota is null then 'Sin cuota'
		when cuota > 300000 then 'Cuota alta'
		when cuota = 300000 then 'Cuota perfecta'
		else 'Cuota baja'
	end) as DESCRIPCION_CUOTA
FROM REPVENTAS;

/*Ej. 1.9*/

GO

DECLARE @cadenaDecenas varchar(100);
DECLARE @count numeric;

SELECT @cadenaDecenas = '';
SELECT @count = 10;

WHILE(@count <= 100)
	BEGIN	
		SELECT @cadenaDecenas += '-' + cast(@count as varchar);
		SELECT @count+=10;
	END

print @cadenaDecenas;

/*Ej. 1.10*/









