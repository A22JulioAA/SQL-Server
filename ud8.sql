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

GO

CREATE PROCEDURE dbo.spu_agregar_oficina
	@ciudad varchar(100), @region varchar(10), @director smallint, @objetivo int, @ventas int

AS
	IF @ciudad IS NULL or @region IS NULL or @director IS NULL or @ventas IS NULL
		BEGIN
			print 'Los datos introducidos no son válidos';
			return
		END

	IF NOT EXISTS(SELECT 1 FROM REPVENTAS WHERE DIRECTOR=@director)
		BEGIN
			raiseerror('Ese número de director no es válido')
		END
		

	DECLARE @numeroOficina int
	SELECT TOP 1 @numeroOficina = OFICINA
	FROM OFICINA
	ORDER BY OFICINA DESC;
	SET @numeroOficina = @numeroOficina + 1



	

GO

EXEC dbo.spu_agregar_oficina 'Galicia', 'caca', 44, 8888, null
	