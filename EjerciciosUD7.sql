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

/*Ej. 1.17*/

GO

DECLARE @num_pedido numeric=110088, @fecha_pedido datetime=getdate(),
	@cliente numeric = 2107, @rep numeric = 105, @producto char(5) = '4100Z',
	@cant numeric = 10, @importe numeric = 4000, @fab char(5) = 'ACI';

IF @num_pedido is null or @fecha_pedido is null or @cliente is null or @rep is null or @producto is null or
@cant is null or @importe is null or @fab is null
	print 'No se han proporcionado todos los datos del pedido! Inténtelo de nuevo:';
ELSE
BEGIN 
	BEGIN TRANSACTION
		IF @cant > (SELECT EXISTENCIAS FROM PRODUCTO WHERE ID_PRODUCTO = @producto and ID_FAB=@fab)
			BEGIN
				print 'No hay stock disponible';
			END
		ELSE
			BEGIN
				INSERT INTO PEDIDO(NUM_PEDIDO, FECHA_PEDIDO, CLIE, REP, FAB, PRODUCTO, CANT, IMPORTE) VALUES(@num_pedido, @fecha_pedido, @cliente, @rep, @fab, @producto, @cant, @importe);

				IF @@ERROR != 0
					BEGIN
						raiserror('No se ha podido insertar el pedido...', 12, 1) with log;
						ROLLBACK;
					END
				ELSE
					BEGIN
						print 'Pedido insertado con éxito!';

						UPDATE PRODUCTO SET EXISTENCIAS -= @cant WHERE ID_PRODUCTO = @producto and ID_FAB = @fab;
						UPDATE REPVENTAS SET VENTAS+=@importe WHERE NUM_EMPL = @rep;
						COMMIT;
					END
			END
END

/*Ej. 1.18*/

GO

DECLARE @num int, @nombre varchar(200), @oficina int;

DECLARE mi_cursor CURSOR for
select NUM_EMPL, NOMBRE, OFICINA_REP FROM REPVENTAS ORDER BY NOMBRE DESC; /*por algunha razón non os ordena por orde descendente*/

OPEN mi_cursor;

FETCH NEXT FROM mi_cursor INTO @num, @nombre, @oficina;

print '--------INFORME DE EMPLEADOS--------';

WHILE @@FETCH_STATUS = 0
	BEGIN
		print 'Empleado Nº: ' + cast(@num as varchar) + CHAR(13) + 'Nombre: ' + @nombre + CHAR(13) + 'Oficina: ' + cast(@oficina as varchar);

		FETCH NEXT FROM mi_cursor INTO @num, @nombre, @oficina;

		print '--------------------------------------'
	END

CLOSE mi_cursor;

/*Ej. 1.19*/

GO

DECLARE @num int, @nombre varchar(200), @oficina int;

DECLARE mi_cursor CURSOR for
select NUM_EMPL, NOMBRE, OFICINA_REP FROM REPVENTAS ORDER BY NOMBRE DESC; /*por algunha razón non os ordena por orde descendente*/

OPEN mi_cursor;

FETCH NEXT FROM mi_cursor INTO @num, @nombre, @oficina;

print '--------INFORME DE EMPLEADOS--------';

WHILE @@FETCH_STATUS = 0
	BEGIN
		print 'Empleado Nº: ' + cast(@num as varchar) + CHAR(13) + 'Nombre: ' + @nombre + CHAR(13) + 'Oficina: ' + cast(@oficina as varchar);

		FETCH NEXT FROM mi_cursor INTO @num, @nombre, @oficina;

		print '--------------------------------------'
	END

print 'El número de empleados es: ' + cast(@@cursor_rows as varchar);

CLOSE mi_cursor;

/*Ej. 1.20*/

GO

DECLARE @num int, @nombre varchar(200), @oficina int;

DECLARE mi_cursor CURSOR for
select NUM_EMPL, NOMBRE, OFICINA_REP FROM REPVENTAS ORDER BY NUM_EMPL DESC; /*por algunha razón non os ordena por orde descendente*/

OPEN mi_cursor;

FETCH NEXT FROM mi_cursor INTO @num, @nombre, @oficina;

print '--------INFORME DE EMPLEADOS--------';

WHILE @@FETCH_STATUS = 0
	BEGIN
		print 'Empleado Nº: ' + cast(@num as varchar) + CHAR(13) + 'Nombre: ' + @nombre + CHAR(13) + 'Oficina: ' + cast(@oficina as varchar);

		FETCH NEXT FROM mi_cursor INTO @num, @nombre, @oficina;

		print '--------------------------------------'
	END

print 'El número de empleados es: ' + cast(@@cursor_rows as varchar);

CLOSE mi_cursor;

/*EJERCICIOS BUCLES*/

/*Ej. 2.1*/

GO

DECLARE @contador int = 1, @total int = 0;

WHILE @contador <= 535
	BEGIN
		SET @total+=@contador;
		SET @contador+=1;
	END

print 'La suma de los números del 1 al 535 es: ' + cast(@total as varchar);

/*Ej. 2.2*/

GO

DECLARE @count int = 0;

WHILE @count <= 9
	BEGIN
		print '5x' + cast(@count as varchar) + ' = ' + cast((@count*5) as varchar) + CHAR(10);
		SET @count+=1;
	END

/*Ej. 2.3*/

GO

DECLARE @indice int = 1;

WHILE @indice <= 100
	BEGIN
		IF @indice%7 = 0
			print @indice;

		SET @indice+=1;
	END

/*Ej. 2.4*/

GO 

DECLARE @index int = 2, @suma int = 0;

WHILE @index < 100
	BEGIN 
		SET @suma += @index;
		set @index+=3;
	END

print 'La suma es: ' + cast(@suma as varchar);

/*Ej. 2.5*/

GO

DECLARE @numeroIncremento int = 1, @multiplicacionTotal int = 1;

WHILE @numeroIncremento <= 10
	BEGIN
		SET @multiplicacionTotal*=@numeroIncremento;
		SET @numeroIncremento+=1;
	END

print 'El resultado de la multiplicación es: ' + cast(@multiplicacionTotal as varchar);

/*EJERCICIOS CURSORES*/

USE LIGA;

/*Ej. 3.1*/

GO

print '------------INFORME DE EQUIPOS------------';

DECLARE cursor_equipos CURSOR STATIC 
FOR SELECT e.identificador, e.nombre, c.nombre FROM EQUIPO e, CAMPO c WHERE e.num_campo=c.numero ORDER BY c.nombre;

DECLARE @num_equipo int, @nombre varchar(100), @num_campo int;

OPEN cursor_equipos;

FETCH NEXT FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

WHILE(@@FETCH_STATUS = 0)
	BEGIN
		print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
		print '---------------------------';

		FETCH NEXT FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;
	END

/*Ej. 3.2*/

GO

print '------------INFORME DE EQUIPOS------------';

DECLARE cursor_equipos CURSOR STATIC 
FOR SELECT e.identificador, e.nombre, c.nombre FROM EQUIPO e, CAMPO c WHERE e.num_campo=c.numero ORDER BY c.nombre;

DECLARE @num_equipo int, @nombre varchar(100), @num_campo int;

OPEN cursor_equipos;

FETCH NEXT FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

WHILE(@@FETCH_STATUS = 0)
	BEGIN
		print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
		print '---------------------------';

		FETCH NEXT FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;
	END

print 'El número de equipos es: ' + cast(@@CURSOR_ROWS as varchar);

/*Ej. 3.3*/

GO

print '------------INFORME DE EQUIPOS------------';

DECLARE cursor_equipos CURSOR SCROLL 
FOR SELECT e.identificador, e.nombre, c.nombre FROM EQUIPO e, CAMPO c WHERE e.num_campo=c.numero ORDER BY c.nombre;

DECLARE @num_equipo int, @nombre varchar(100), @num_campo int;

OPEN cursor_equipos;

FETCH LAST FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

print 'Último equipo de la lista: ';
print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
print '---------------------------';

FETCH PRIOR FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

print 'Penúltimo equipo de la lista: ';
print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
print '---------------------------';

FETCH FIRST FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

print 'Primer equipo de la lista: ';
print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
print '---------------------------';

FETCH RELATIVE 3 FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

print '3 desde el actual equipo de la lista: ';
print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
print '---------------------------';

FETCH ABSOLUTE 5 FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

print 'Quinto equipo de la lista: ';
print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
print '---------------------------';

FETCH RELATIVE -2 FROM cursor_equipos INTO @num_equipo, @nombre, @num_campo;

print '2 antes del actual equipo de la lista: ';
print 'Equipo Nº: ' + cast(@num_equipo as varchar) + CHAR(10) + 'Nombre: ' + @nombre + CHAR(10) + 'Campo: ' + cast(@num_campo as varchar);
print '---------------------------';

/*Ej. 3.4*/

GO

SELECT * INTO CAMPO2 FROM CAMPO;

DECLARE cur_campos CURSOR DYNAMIC FOR SELECT numero, nombre, capacidad FROM CAMPO2 
DECLARE @numero int, @nombre varchar(100), @capacidad int;

OPEN cur_campos;

FETCH NEXT FROM cur_campos INTO @numero, @nombre, @capacidad;

WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @capacidad > 400
		BEGIN
			UPDATE CAMPO2
			SET capacidad*=1.05
			WHERE CURRENT OF cur_campos;
		END
		FETCH NEXT FROM cur_campos INTO @numero, @nombre, @capacidad;
	END

CLOSE cur_campos;

/*Ej. 3.5*/

GO

SELECT * INTO PARTIDO2 FROM PARTIDO;

DECLARE cur_partidos CURSOR DYNAMIC FOR SELECT id_equipo_local, id_equipo_visitante, fechahora, observaciones FROM PARTIDO2 
DECLARE @id_equipo_local int, @id_equipo_visitante int, @fechahora datetime, @observaciones varchar(200);

OPEN cur_partidos;

FETCH NEXT FROM cur_partidos INTO @id_equipo_local, @id_equipo_visitante, @fechahora, @observaciones;

WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @pres > 400
		BEGIN
			UPDATE CAMPO2
			SET capacidad*=1.05
			WHERE CURRENT OF cur_campos;
		END
		FETCH NEXT FROM cur_campos INTO @numero, @nombre, @capacidad;
	END

CLOSE cur_campos;

















