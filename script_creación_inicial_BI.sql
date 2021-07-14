USE GD1C2021


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INDICES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*
GO
CREATE NONCLUSTERED INDEX INDEX_ITEM_VENTA_PC_SUC 
ON [LOCALHOST1].[ITEM_VENTA_PC] (ivenpc_sucursal,ivenpc_pc) INCLUDE (ivenpc_numero, ivenpc_precio)
GO

GO
CREATE NONCLUSTERED INDEX INDEX_ITEM_COMPRA_PC
ON [LOCALHOST1].[Item_Compra_Pc] ([icomppc_pc])
INCLUDE ([icomppc_numero],[icomppc_sucursal])
GO

GO
CREATE NONCLUSTERED INDEX INDEX_ITEM_COMPRA_PC_SUCURSAL
ON [LOCALHOST1].[Item_Compra_Pc] ([icomppc_sucursal],[icomppc_pc])
INCLUDE ([icomppc_numero],[icomppc_cantidad])
GO

GO
CREATE NONCLUSTERED INDEX INDEX_FACTURA_VENTA 
ON [LOCALHOST1].[FACTURA_VENTA] (facven_sucursal,facven_cliente)
GO

GO
CREATE NONCLUSTERED INDEX INDEX_COMPRAS_PC
ON [LOCALHOST1].[Item_Venta_Pc] ([ivenpc_pc])
INCLUDE ([ivenpc_numero],[ivenpc_sucursal])
GO
*/

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Funciones %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GO
CREATE FUNCTION [CLIENTE_A_BI](@cli int)
RETURNS int
AS
BEGIN
    RETURN
		(
		SELECT TOP 1 clie_codigo FROM [LOCALHOST1].Cliente
		JOIN [LOCALHOST1].BI_CLIENTE ON CLIE_EDAD_INICIAL <= DATEDIFF(day,cli_fecha_nacimiento,getdate())/365 AND
		CLIE_EDAD_FINAL >= DATEDIFF(day,cli_fecha_nacimiento,getdate())/365
		WHERE cli_codigo=@cli
		)
END
GO

GO
CREATE FUNCTION CANT_PC_VENDIDAS(@pc nvarchar(50), @suc_id int, @cliente int , @año char(4), @mes char(2))
RETURNS int
AS
BEGIN
	RETURN	(
				SELECT SUM(isnull(ivenpc_cantidad,0)) FROM [LOCALHOST1].[Item_Venta_Pc] 
				JOIN [LOCALHOST1].[Factura_Venta] ON facven_sucursal = ivenpc_sucursal AND facven_numero = ivenpc_numero
				WHERE ivenpc_pc=@pc AND facven_sucursal=@suc_id AND @cliente = facven_cliente AND
				YEAR(facven_fecha)=@año AND MONTH(facven_fecha)=@mes
				GROUP BY ivenpc_pc, facven_sucursal, facven_cliente, YEAR(facven_fecha), MONTH(facven_fecha)
			)
END
GO      

GO
CREATE FUNCTION PRECIO_PROMEDIO_VENTA_PC(@pc nvarchar(50), @suc_id int, @cliente int , @año char(4), @mes char(2))
RETURNS decimal(12,2)
AS
BEGIN
	RETURN	(
				SELECT AVG(ivenpc_precio) FROM [LOCALHOST1].[Item_Venta_Pc] 
				JOIN [LOCALHOST1].[Factura_Venta] ON facven_sucursal = ivenpc_sucursal AND facven_numero = ivenpc_numero
				WHERE ivenpc_pc=@pc AND facven_sucursal=@suc_id AND facven_cliente=@cliente
				AND YEAR(facven_fecha)=@año AND MONTH(facven_fecha)=@mes
				GROUP BY ivenpc_pc, facven_sucursal, facven_cliente, YEAR(facven_fecha), MONTH(facven_fecha)
			)
END
GO

-- Función Ganancia de PC

GO
CREATE FUNCTION [GANANCIA_PC](@pc nvarchar(50), @suc_id int, @cliente int , @año char(4), @mes char(2))
RETURNS decimal(12,2)
AS
BEGIN
			RETURN(
					SELECT SUM((ivenpc_precio-pc_precio)*ivenpc_cantidad)
					FROM [LOCALHOST1].[ITEM_VENTA_PC]
					JOIN [LOCALHOST1].[Factura_Venta] ON facven_sucursal = ivenpc_sucursal AND facven_numero = ivenpc_numero
					JOIN [LOCALHOST1].[PC] ON ivenpc_pc=pc_codigo
					WHERE ivenpc_pc=@pc AND facven_sucursal=@suc_id AND facven_cliente=@cliente AND YEAR(facven_fecha)=@año AND month(facven_fecha)=@mes
					GROUP BY ivenpc_pc,facven_sucursal,facven_cliente,year(facven_fecha),month(facven_fecha)
      			)
END    
GO  

-- Función Cantidad de accesorios vendidos


GO
CREATE FUNCTION CANT_ACC_VENDIDOS(@acc decimal(18,0), @suc_id int, @cliente int , @año char(4), @mes char(2))
RETURNS int
AS
BEGIN
	RETURN	(
				SELECT SUM(isnull(ivenacc_cantidad,0)) FROM [LOCALHOST1].[Item_Venta_Acc] 
				JOIN [LOCALHOST1].[Factura_Venta] ON facven_sucursal = ivenacc_sucursal AND facven_numero = ivenacc_numero
				JOIN [LOCALHOST1].[BI_CLIENTE] ON clie_codigo=@cliente AND dbo.[CLIENTE_A_BI](facven_cliente) = clie_codigo
				WHERE ivenacc_acc=@acc AND facven_sucursal=@suc_id
				AND YEAR(facven_fecha)=@año AND MONTH(facven_fecha)=@mes
				GROUP BY ivenacc_acc, facven_sucursal, clie_codigo, YEAR(facven_fecha), MONTH(facven_fecha)
			)
END
GO     

-- Función Precio promedio de venta de accesorios

GO
CREATE FUNCTION PRECIO_PROMEDIO_VENTA_ACC(@acc decimal(18,0), @suc_id int, @cliente int , @año char(4), @mes char(2))
RETURNS decimal(12,2)
AS
BEGIN
	RETURN	(
				SELECT AVG(ivenacc_precio*1.20) FROM [LOCALHOST1].[Item_Venta_Acc] 
				JOIN [LOCALHOST1].[Factura_Venta] ON facven_sucursal = ivenacc_sucursal AND facven_numero = ivenacc_numero
				JOIN [LOCALHOST1].[BI_CLIENTE] ON clie_codigo=@cliente AND dbo.[CLIENTE_A_BI](facven_cliente) = clie_codigo
				WHERE ivenacc_acc=@acc AND facven_sucursal=@suc_id
				AND YEAR(facven_fecha)=@año AND MONTH(facven_fecha)=@mes
				GROUP BY ivenacc_acc, facven_sucursal, clie_codigo, YEAR(facven_fecha), MONTH(facven_fecha)
			)
END
GO
-- Función Ganancia de accesorios

GO
CREATE FUNCTION GANANCIA_ACC(@acc decimal(18,0), @suc_id int, @cliente int , @año char(4), @mes char(2))
RETURNS decimal(12,2)
AS
BEGIN
			RETURN(
        			SELECT SUM((ivenacc_precio*1.20-acc_precio)*ivenacc_cantidad) FROM [LOCALHOST1].[Item_Venta_Acc]
        			JOIN [LOCALHOST1].[Factura_Venta] ON facven_sucursal = ivenacc_sucursal AND facven_numero = ivenacc_numero
					JOIN [LOCALHOST1].[BI_CLIENTE] ON clie_codigo=@cliente AND dbo.[CLIENTE_A_BI](facven_cliente) = clie_codigo
        			JOIN [LOCALHOST1].Accesorio ON ivenacc_acc=acc_codigo
        			WHERE ivenacc_acc=@acc AND facven_sucursal=@suc_id
					AND YEAR(facven_fecha)=@año AND MONTH(facven_fecha)=@mes
					GROUP BY ivenacc_acc, facven_sucursal, clie_codigo, YEAR(facven_fecha), MONTH(facven_fecha)
      			)
END    
GO  

-- Función Precio promedio de compra de accesorios

GO
CREATE FUNCTION PRECIO_PROMEDIO_COMPRA_ACC(@acc decimal(18,0), @suc_id int, @año char(4), @mes char(2))
RETURNS decimal(12,2)
AS
BEGIN
	RETURN	(
				SELECT AVG(icompacc_precio) FROM [LOCALHOST1].[Item_Compra_Acc] 
				JOIN [LOCALHOST1].[Factura_Compra] ON faccomp_sucursal = icompacc_sucursal AND faccomp_numero = icompacc_numero
				WHERE icompacc_acc=@acc AND faccomp_sucursal=@suc_id
				AND YEAR(faccomp_fecha)=@año AND MONTH(faccomp_fecha)=@mes
				GROUP BY icompacc_acc, faccomp_sucursal, YEAR(faccomp_fecha), MONTH(faccomp_fecha)
			)
END
GO

-- Funcion Precio promedio de compra de pc
GO
CREATE FUNCTION PRECIO_PROMEDIO_COMPRA_PC(@pc nvarchar(50), @suc_id int, @año char(4), @mes char(2))
RETURNS decimal(12,2)
AS
BEGIN
	RETURN	(
				SELECT AVG(icomppc_precio) FROM [LOCALHOST1].[Item_Compra_Pc] 
				JOIN [LOCALHOST1].[Factura_Compra] ON faccomp_sucursal = icomppc_sucursal AND faccomp_numero = icomppc_numero
				WHERE icomppc_pc=@pc AND faccomp_sucursal=@suc_id
				AND YEAR(faccomp_fecha)=@año AND MONTH(faccomp_fecha)=@mes
				GROUP BY icomppc_pc, faccomp_sucursal, YEAR(faccomp_fecha), MONTH(faccomp_fecha)
			)
END
GO
-- Funcion Cantidad de PCs compradas
GO
CREATE FUNCTION CANT_PC_COMPRADAS(@pc nvarchar(50), @suc_id int, @año char(4), @mes char(2))
RETURNS int
AS
BEGIN
	RETURN	(
				SELECT SUM(isnull(icomppc_cantidad,0)) FROM [LOCALHOST1].[Item_Compra_Pc]
				JOIN [LOCALHOST1].[Factura_Compra] ON faccomp_sucursal = icomppc_sucursal AND faccomp_numero = icomppc_numero
				WHERE icomppc_pc=@pc AND faccomp_sucursal=@suc_id AND YEAR(faccomp_fecha)=@año AND MONTH(faccomp_fecha)=@mes
				GROUP BY icomppc_pc, icomppc_sucursal, year(faccomp_fecha), month(faccomp_fecha)
			)
END
GO
-- Funcion Cantidad de accesorios compradas

GO
CREATE FUNCTION CANT_ACC_COMPRADOS(@acc decimal(18,0), @suc_id int, @año char(4), @mes char(2))
RETURNS	int
AS
BEGIN 
	RETURN (
    			SELECT SUM(isnull(icompacc_cantidad,0)) FROM [LOCALHOST1].[Item_compra_acc]
    			JOIN [LOCALHOST1].[Factura_Compra] ON faccomp_sucursal = icompacc_sucursal AND faccomp_numero = icompacc_numero 
    			WHERE icompacc_acc = @acc AND faccomp_sucursal = @suc_id AND YEAR(faccomp_fecha) = @año AND month(faccomp_fecha) = @mes
				GROUP BY icompacc_acc, icompacc_sucursal, year(faccomp_fecha), month(faccomp_fecha)
				) 
END
GO

CREATE FUNCTION PROM_PC_STOCK(@pc nvarchar(50))
RETURNS int
BEGIN
RETURN(
	SELECT AVG(CONVERT(BIGINT,DATEDIFF(DAY,faccomp_fecha,(facven_fecha)))) FROM LOCALHOST1.Item_Compra_pc join LOCALHOST1.Item_Venta_Pc on icomppc_pc=ivenpc_pc
	join LOCALHOST1.Factura_Venta on facven_sucursal=ivenpc_sucursal and facven_numero=ivenpc_numero
	join LOCALHOST1.Factura_Compra on faccomp_sucursal=icomppc_sucursal and faccomp_numero=icomppc_numero
	WHERE icomppc_pc = @pc
	GROUP BY ivenpc_pc
	)
END

GO
CREATE FUNCTION PROM_ACC_STOCK(@acc decimal(18,0))
RETURNS int
BEGIN
RETURN(
	SELECT AVG(CONVERT(BIGINT,DATEDIFF(DAY,faccomp_fecha,(facven_fecha)))) FROM LOCALHOST1.Item_Compra_Acc join LOCALHOST1.Item_Venta_Acc on icompacc_acc=ivenacc_acc
	join LOCALHOST1.Factura_Venta on facven_sucursal=ivenacc_sucursal and facven_numero=ivenacc_numero
	join LOCALHOST1.Factura_Compra on faccomp_sucursal=icompacc_sucursal and faccomp_numero=icompacc_numero
	WHERE icompacc_acc = @acc
	GROUP BY ivenacc_acc
	)
END
GO

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Tablas de dimensiones %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- Dimensión Tiempo
CREATE TABLE [LOCALHOST1].[BI_TIEMPO](
	tiempo_codigo int IDENTITY(1,1) not null,
	tiempo_anio char(4),
	tiempo_mes char(2),
	CONSTRAINT PK_BI_TIEMPO PRIMARY KEY (tiempo_codigo)
)

INSERT INTO [LOCALHOST1].[BI_TIEMPO] 
SELECT año,mes
FROM 
		(
		SELECT YEAR(faccomp_fecha) as año, MONTH(faccomp_fecha) as mes FROM [LOCALHOST1].[Factura_Compra]
		UNION
		SELECT YEAR(facven_fecha) as año, MONTH(facven_fecha) as mes FROM [LOCALHOST1].[Factura_Venta]
		) años
GROUP BY año, mes
ORDER BY año, mes

-- Dimensión Cliente
CREATE TABLE [LOCALHOST1].[BI_CLIENTE](
	clie_codigo int IDENTITY(1,1) not null,
	clie_sexo nvarchar(1),
	clie_edad_inicial int,
	clie_edad_final int,
	clie_rango_edad nvarchar(8),
	CONSTRAINT PK_BI_CLIENTE PRIMARY KEY(clie_codigo),
	CHECK (clie_sexo='M' OR clie_sexo='F' )
)
INSERT INTO [LOCALHOST1].[BI_CLIENTE]
VALUES ('M',18,30,'18-30') , ('M',31,50,'31-50'), ('M',51,200,'>50'), ('F',18,30,'18-30') , ('F',31,50,'31-50'), ('F',51,200,'>50')

-- Dimensión Ciudad
CREATE TABLE [LOCALHOST1].[BI_CIUDAD](
	ciu_codigo int not null,
	ciu_nombre char(255),
	CONSTRAINT PK_BI_CIUDAD PRIMARY KEY(ciu_codigo)
)
INSERT INTO [LOCALHOST1].[BI_CIUDAD] 
SELECT * FROM [LOCALHOST1].[Ciudad]

-- Dimensión Sucursal
CREATE TABLE [LOCALHOST1].[BI_SUCURSAL](
  suc_codigo int not null,
  suc_ciudad int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_CIUDAD](ciu_codigo),
  suc_direccion nvarchar(255),
  CONSTRAINT PK_BI_SUCURSAL PRIMARY KEY(suc_codigo)
)
INSERT INTO [LOCALHOST1].[BI_SUCURSAL] 
SELECT suc_codigo,suc_ciudad,suc_dir FROM [LOCALHOST1].[Sucursal]

-- Dimensión Fabricante  
CREATE TABLE [LOCALHOST1].[BI_FABRICANTE](
  fab_codigo int not null,
  CONSTRAINT PK_BI_FABRICANTE PRIMARY KEY (fab_codigo)
)
INSERT INTO [LOCALHOST1].[BI_FABRICANTE]
	SELECT fab_codigo FROM [LOCALHOST1].[Fabricante]


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 -- Dimensión Código de PC
GO
CREATE TABLE [LOCALHOST1].[BI_CODIGO_PC](
	pc_codigo nvarchar(50) not null,
	pc_prom_stock int,
	CONSTRAINT PK_BI_CODIGO_PC PRIMARY KEY(pc_codigo)
)

INSERT INTO [LOCALHOST1].[BI_CODIGO_PC]
  --SELECT pc_codigo, 1 FROM [LOCALHOST1].[PC]
  SELECT pc_codigo, dbo.PROM_PC_STOCK(pc_codigo) FROM [LOCALHOST1].[PC]

 
-- Dimensión Motherboard
CREATE TABLE [LOCALHOST1].[BI_MOTHERBOARD](
  mother_codigo nvarchar(50) not null,
  mother_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_FABRICANTE](fab_codigo),
  CONSTRAINT PK_BI_MOTHERBOARD PRIMARY KEY(mother_codigo)
)

INSERT INTO [LOCALHOST1].[BI_MOTHERBOARD]
  SELECT mother_codigo,mother_fabricante FROM [LOCALHOST1].[MOTHERBOARD]

INSERT INTO [LOCALHOST1].[BI_MOTHERBOARD] VALUES('Sincodigo',1)

-- Dimensión Placa de video

CREATE TABLE [LOCALHOST1].[BI_PLACA_VIDEO](
  pvideo_codigo int not null,
  pvideo_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_FABRICANTE](fab_codigo),
  CONSTRAINT PK_BI_PLACA_VIDEO PRIMARY KEY(pvideo_codigo)
) 

INSERT INTO [LOCALHOST1].[BI_PLACA_VIDEO]
  SELECT pvideo_codigo, pvideo_fabricante FROM [LOCALHOST1].[Placa_Video]
  
-- Dimensión Microprocesador
 CREATE TABLE [LOCALHOST1].[BI_MICROPROCESADOR](
  micro_codigo nvarchar(50) not null,
  micro_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_FABRICANTE](fab_codigo),
  CONSTRAINT PK_BI_MICROPROCESADOR PRIMARY KEY(micro_codigo)
)
INSERT INTO  [LOCALHOST1].[BI_MICROPROCESADOR]
  SELECT micro_codigo, micro_fabricante FROM [LOCALHOST1].[Microprocesador]

-- Dimensión RAM
  CREATE TABLE [LOCALHOST1].[BI_RAM](
  ram_codigo nvarchar(50) not null,
  ram_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_FABRICANTE](fab_codigo),
  CONSTRAINT PK_BI_RAM PRIMARY KEY(ram_codigo)
)

INSERT INTO [LOCALHOST1].[BI_RAM]
  SELECT ram_codigo,ram_fabricante FROM [LOCALHOST1].[Ram]
  
-- Dimensión RAM X PC
 CREATE TABLE [LOCALHOST1].[BI_RAM_X_PC](
  ramxpc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_CODIGO_PC](pc_codigo) not null,
  ramxpc_ram nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_RAM](ram_codigo) not null,
  CONSTRAINT PK_BI_RAM_X_PC PRIMARY KEY(ramxpc_pc,ramxpc_ram)
)

INSERT INTO [LOCALHOST1].[BI_RAM_X_PC]
  SELECT ramxpc_pc,ramxpc_ram FROM [LOCALHOST1].[Ram_x_pc]
  
-- Dimensión Disco de almacenamiento
CREATE TABLE [LOCALHOST1].[BI_DISCO_ALMACENAMIENTO](
  disco_codigo nvarchar(50) not null,
  disco_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_FABRICANTE](fab_codigo),
  CONSTRAINT PK_BI_DISCO_ALMACENAMIENTO PRIMARY KEY(disco_codigo)
)

INSERT INTO [LOCALHOST1].[BI_DISCO_ALMACENAMIENTO]
	SELECT disco_codigo, disco_fabricante FROM [LOCALHOST1].[DISCO_ALMACENAMIENTO]


-- Dimensión DISCO X PC 
CREATE TABLE [LOCALHOST1].[BI_DISCO_X_PC](
			discopc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Pc(pc_codigo),
			discopc_disco nvarchar(255) FOREIGN KEY REFERENCES [LOCALHOST1].Disco_Almacenamiento(disco_codigo),
			CONSTRAINT PK_DISCO_X_PC PRIMARY KEY(discopc_pc,discopc_disco)
)
INSERT INTO [LOCALHOST1].[BI_DISCO_X_PC]
SELECT discopc_pc, discopc_disco FROM [LOCALHOST1].[Disco_x_Pc]



-- Dimensión Accesorio
CREATE TABLE [LOCALHOST1].[BI_ACCESORIO](
	acc_codigo decimal(18,0) not null,
	acc_prom_stock int,
	acc_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_FABRICANTE](fab_codigo),
	CONSTRAINT PK_BI_ACCESORIO PRIMARY KEY (acc_codigo)
)

INSERT INTO [LOCALHOST1].[BI_ACCESORIO]
 SELECT acc_codigo, dbo.PROM_ACC_STOCK(acc_codigo), acc_fabricante FROM [LOCALHOST1].[Accesorio]
 

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Tablas de hecho %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- Tabla de hecho de Ventas PC
CREATE TABLE [LOCALHOST1].[BI_VENTAS_PC](
  venpc_cliente int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_CLIENTE](clie_codigo) not null,
  venpc_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_SUCURSAL](suc_codigo) not null,
  venpc_tiempo int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_TIEMPO](tiempo_codigo) not null,
  venpc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_CODIGO_PC](pc_codigo) not null,
  venpc_motherboard nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_MOTHERBOARD](mother_codigo) not null,
  venpc_microprocesador nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_MICROPROCESADOR](micro_codigo) not null,
  venpc_pvideo int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_PLACA_VIDEO](pvideo_codigo) not null,
  venpc_precio_promedio decimal(12,2),
  venpc_cantidad int,
  venpc_ganancia decimal(12,2)
  CONSTRAINT PK_BI_VENTAS_PC PRIMARY KEY (venpc_cliente,venpc_sucursal,venpc_tiempo,venpc_pc,venpc_motherboard,venpc_microprocesador,
  																				venpc_pvideo)
) 

INSERT INTO [LOCALHOST1].[BI_VENTAS_PC](
	venpc_cliente,
	venpc_sucursal,
	venpc_tiempo,
	venpc_pc,
	venpc_motherboard,
	venpc_microprocesador,
	venpc_pvideo,
	venpc_precio_promedio,
	venpc_cantidad,
	venpc_ganancia
)

SELECT
  clie_codigo,
  ivenpc_sucursal,
  tiempo_codigo,
  ivenpc_pc,
  'Sincodigo',
  pc_micro,
  pc_pvideo,
  CONVERT(decimal(12,2),AVG(dbo.PRECIO_PROMEDIO_VENTA_PC(pc_codigo,ivenpc_sucursal,facven_cliente,tiempo_anio,tiempo_mes))),
  CONVERT(int,SUM(dbo.CANT_PC_VENDIDAS(pc_codigo,ivenpc_sucursal,facven_cliente,tiempo_anio,tiempo_mes))),
  SUM(dbo.[GANANCIA_PC](pc_codigo,ivenpc_sucursal,facven_cliente,tiempo_anio,tiempo_mes))
  
FROM [LOCALHOST1].[BI_CLIENTE]
JOIN  [LOCALHOST1].[FACTURA_VENTA] ON clie_codigo = dbo.[CLIENTE_A_BI](facven_cliente)
JOIN [LOCALHOST1].[ITEM_VENTA_PC] ON facven_numero = ivenpc_numero AND facven_sucursal = ivenpc_sucursal
JOIN [LOCALHOST1].[BI_TIEMPO] ON year(facven_fecha) = tiempo_anio AND month(facven_fecha) = tiempo_mes 	
JOIN [LOCALHOST1].[PC] ON ivenpc_pc = pc_codigo
GROUP BY clie_codigo,ivenpc_sucursal,tiempo_codigo,ivenpc_pc,pc_motherboard,pc_micro,pc_pvideo,pc_codigo, tiempo_anio, tiempo_mes

 
-- Tabla de hecho de Ventas Accesorios
CREATE TABLE [LOCALHOST1].[BI_VENTAS_ACCESORIOS](
	venacc_acc decimal(18,0) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_ACCESORIO](acc_codigo) not null,
	venacc_cliente int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_CLIENTE](clie_codigo) not null,
	venacc_tiempo int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_TIEMPO](tiempo_codigo) not null,
	venacc_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_SUCURSAL](suc_codigo) not null,
	venacc_precio_promedio decimal(12,2),
	venacc_cantidad int,
	venacc_ganancia decimal(12,2),
	CONSTRAINT PK_BI_VENTAS_ACC PRIMARY KEY (venacc_acc, venacc_cliente, venacc_tiempo, venacc_sucursal)
)

INSERT INTO [LOCALHOST1].[BI_VENTAS_ACCESORIOS](
	venacc_acc,
	venacc_cliente,
	venacc_tiempo,
	venacc_sucursal,
	venacc_precio_promedio,
	venacc_cantidad,
	venacc_ganancia
)

SELECT 
	ivenacc_acc,
	clie_codigo,
	tiempo_codigo,
	facven_sucursal,
	dbo.PRECIO_PROMEDIO_VENTA_ACC(ivenacc_acc,facven_sucursal,clie_codigo,tiempo_anio,tiempo_mes),
	dbo.CANT_ACC_VENDIDOS(ivenacc_acc,facven_sucursal,clie_codigo,tiempo_anio,tiempo_mes),
	dbo.GANANCIA_ACC(ivenacc_acc,facven_sucursal,clie_codigo,tiempo_anio,tiempo_mes)

FROM [LOCALHOST1].[FACTURA_VENTA]
JOIN [LOCALHOST1].BI_CLIENTE ON clie_codigo = dbo.[CLIENTE_A_BI](facven_cliente)
JOIN [LOCALHOST1].[ITEM_VENTA_ACC] ON facven_numero = ivenacc_numero AND facven_sucursal = ivenacc_sucursal
JOIN [LOCALHOST1].[BI_TIEMPO] ON year(facven_fecha) = tiempo_anio AND month(facven_fecha) = tiempo_mes
GROUP BY ivenacc_acc, clie_codigo, tiempo_codigo, facven_sucursaL, tiempo_anio, tiempo_mes
            
-- Tabla de hecho de Compras PC
CREATE TABLE [LOCALHOST1].[BI_COMPRAS_PC](
	comppc_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_SUCURSAL](suc_codigo) not null,
	comppc_tiempo int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_TIEMPO](tiempo_codigo) not null,
	comppc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_CODIGO_PC](pc_codigo) not null,
	comppc_motherboard nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_MOTHERBOARD](mother_codigo) not null,
	comppc_microprocesador nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_MICROPROCESADOR](micro_codigo) not null,
	comppc_pvideo int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_PLACA_VIDEO](pvideo_codigo) not null,
	comppc_precio_promedio decimal(12,2),
	comppc_cantidad int
	CONSTRAINT PK_BI_COMPRAS_PC PRIMARY KEY (comppc_sucursal,comppc_tiempo,comppc_pc,comppc_motherboard,
	comppc_microprocesador,comppc_pvideo)
)

INSERT INTO [LOCALHOST1].[BI_COMPRAS_PC](
	comppc_sucursal,
	comppc_tiempo,
	comppc_pc,
	comppc_motherboard,
	comppc_microprocesador,
	comppc_pvideo,
	comppc_precio_promedio,
	comppc_cantidad
)

SELECT 
	faccomp_sucursal,
	tiempo_codigo,  
	icomppc_pc, 
	'Sincodigo',
	pc_micro, 
	pc_pvideo,
	dbo.PRECIO_PROMEDIO_COMPRA_PC(icomppc_pc,faccomp_sucursal,tiempo_anio,tiempo_mes),
	dbo.CANT_PC_COMPRADAS(icomppc_pc,faccomp_sucursal,tiempo_anio,tiempo_mes)
FROM [LOCALHOST1].[FACTURA_COMPRA]
JOIN [LOCALHOST1].[ITEM_COMPRA_PC] ON faccomp_numero = icomppc_numero AND faccomp_sucursal = icomppc_sucursal
JOIN [LOCALHOST1].[BI_TIEMPO] ON year(faccomp_fecha) = tiempo_anio AND month(faccomp_fecha) = tiempo_mes 	
JOIN [LOCALHOST1].[PC] ON icomppc_pc = pc_codigo
GROUP BY icomppc_pc,tiempo_codigo, faccomp_sucursal, pc_micro, pc_pvideo, tiempo_anio, tiempo_mes, pc_motherboard

   
-- Tabla de hecho de Compras Accesorios
CREATE TABLE [LOCALHOST1].[BI_COMPRAS_ACCESORIOS](
	compacc_acc decimal(18,0) FOREIGN KEY REFERENCES [LOCALHOST1].[BI_ACCESORIO](acc_codigo) not null,
	compacc_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_SUCURSAL](suc_codigo) not null,
	compacc_tiempo int FOREIGN KEY REFERENCES [LOCALHOST1].[BI_TIEMPO](tiempo_codigo) not null,
	compacc_precio_promedio decimal(12,2) not null, 
	compacc_cantidad int,
  CONSTRAINT PK_BI_COMPRAS_ACC PRIMARY KEY (compacc_acc, compacc_sucursal, compacc_tiempo)
)

INSERT INTO [LOCALHOST1].[BI_COMPRAS_ACCESORIOS](
	compacc_acc,
	compacc_sucursal,
	compacc_tiempo,
	compacc_precio_promedio,
	compacc_cantidad
)

SELECT DISTINCT
  icompacc_acc,
  faccomp_sucursal,
  tiempo_codigo,
  dbo.PRECIO_PROMEDIO_COMPRA_ACC(icompacc_acc,faccomp_sucursal,tiempo_anio,tiempo_mes),
  dbo.CANT_ACC_COMPRADOS(icompacc_acc,faccomp_sucursal,tiempo_anio,tiempo_mes)

FROM [LOCALHOST1].[FACTURA_COMPRA]
JOIN [LOCALHOST1].[ITEM_COMPRA_ACC] ON faccomp_numero = icompacc_numero AND  faccomp_sucursal =  icompacc_sucursal
JOIN [LOCALHOST1].[BI_TIEMPO] ON year(faccomp_fecha) = tiempo_anio AND month(faccomp_fecha) = tiempo_mes

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Vistas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- Precio promedio de PCs, vendidos y comprados
GO
CREATE VIEW [LOCALHOST1].VW_PRECIO_PROMEDIO_VENTA_PC
AS
SELECT comppc_pc, comppc_precio_promedio, venpc_precio_promedio
FROM [LOCALHOST1].[BI_COMPRAS_PC]
JOIN [LOCALHOST1].[BI_VENTAS_PC] ON comppc_pc = venpc_pc

-- Cantidad de PCs, vendidos y comprados x sucursal y mes
GO
CREATE VIEW [LOCALHOST1].VW_CANT_PC_X_SUCURSAL_Y_MES
AS
SELECT comppc_pc, comppc_sucursal,tiempo_anio, tiempo_mes, SUM(comppc_cantidad) AS cantidad_comprada, SUM(venpc_cantidad) AS cantidad_vendidas
FROM [LOCALHOST1].[BI_COMPRAS_PC]
JOIN [LOCALHOST1].[BI_VENTAS_PC] ON comppc_pc = venpc_pc AND comppc_sucursal = venpc_sucursal
JOIN [LOCALHOST1].[BI_TIEMPO] ON comppc_tiempo = tiempo_codigo
GROUP BY comppc_pc, comppc_sucursal, tiempo_anio, tiempo_mes 

-- Ganancias (precio de venta – precio de compra) x Sucursal x mes
GO
CREATE VIEW [LOCALHOST1].VW_GANANCIAS_PC_X_SUCURSAL_Y_MES
AS
SELECT venpc_pc, venpc_sucursal,tiempo_anio, tiempo_mes, SUM(venpc_ganancia) AS ganancia
FROM [LOCALHOST1].[BI_VENTAS_PC]
JOIN [LOCALHOST1].[BI_TIEMPO] ON venpc_tiempo = tiempo_codigo
GROUP BY venpc_pc, venpc_sucursal, tiempo_anio, tiempo_mes 


-- ACCESORIOS
-- Precio promedio de cada accesorio, vendido y comprado
GO
CREATE VIEW [LOCALHOST1].VW_PRECIO_PROMEDIO_COMPRAS_ACC
AS
SELECT compacc_acc, compacc_precio_promedio, venacc_precio_promedio
FROM [LOCALHOST1].[BI_COMPRAS_ACCESORIOS]
JOIN [LOCALHOST1].[BI_VENTAS_ACCESORIOS] ON compacc_acc = venacc_acc


-- Ganancias (precio de venta – precio de compra) x Sucursal x mes
GO
CREATE VIEW [LOCALHOST1].VW_GANANCIAS_ACC_X_SUCURSAL_Y_MES
AS
SELECT venacc_acc, venacc_sucursal, tiempo_anio, tiempo_mes, SUM(venacc_ganancia) AS ganancia
FROM [LOCALHOST1].[BI_VENTAS_ACCESORIOS]
JOIN [LOCALHOST1].[BI_TIEMPO] ON venacc_tiempo = tiempo_codigo 
GROUP BY venacc_acc, venacc_sucursal, tiempo_anio, tiempo_mes


-- Máxima cantidad de stock por cada sucursal (anual)
GO
CREATE VIEW [LOCALHOST1].VW_MAX_CANT_STOCK_ANUAL
AS
SELECT compacc_sucursal, tiempo_anio, MAX(cant) cantidad FROM (
             	 		SELECT (
                				select SUM(compacc_cantidad) cant from [LOCALHOST1].[BI_COMPRAS_ACCESORIOS] 
                       			JOIN [LOCALHOST1].[BI_TIEMPO] ON compacc_tiempo = tiempo_codigo
		                        WHERE tiempo_anio <= t.tiempo_anio and tiempo_mes=t.tiempo_mes and compacc_sucursal=c.compacc_sucursal
    		                  	) 
        		       			-
            		   			(
                		        select SUM(venacc_cantidad) from [LOCALHOST1].[BI_VENTAS_ACCESORIOS] 
                    		   	JOIN [LOCALHOST1].[BI_TIEMPO] ON venacc_tiempo = tiempo_codigo
		                        WHERE tiempo_anio <= t.tiempo_anio and tiempo_mes=t.tiempo_mes and venacc_sucursal=c.compacc_sucursal
    		                    ) cant, compacc_sucursal, tiempo_anio, tiempo_mes
        		      	FROM [LOCALHOST1].[BI_COMPRAS_ACCESORIOS] c
						JOIN [LOCALHOST1].[BI_TIEMPO] t ON compacc_tiempo = tiempo_codigo
						GROUP BY compacc_sucursal, tiempo_anio, tiempo_mes
            					) cantidades
GROUP BY compacc_sucursal, tiempo_anio;

-- Promedio de tiempo en stock de cada modelo de Pc
GO
CREATE VIEW [LOCALHOST1].VW_PROM_TIEMPO_STOCK_PC
AS
SELECT pc_codigo, pc_prom_stock FROM [LOCALHOST1].BI_CODIGO_PC

-- Promedio de tiempo en stock de cada modelo de accesorio

GO
CREATE VIEW [LOCALHOST1].VW_PROM_TIEMPO_STOCK_ACC
AS
SELECT acc_codigo, acc_prom_stock FROM [LOCALHOST1].BI_ACCESORIO


/*

DROP TABLE LOCALHOST1.BI_VENTAS_PC
DROP TABLE LOCALHOST1.BI_COMPRAS_PC
DROP TABLE LOCALHOST1.BI_VENTAS_ACCESORIOS
DROP TABLE LOCALHOST1.BI_COMPRAS_ACCESORIOS
DROP TABLE LOCALHOST1.BI_RAM_X_PC
DROP TABLE LOCALHOST1.BI_DISCO_X_PC
DROP TABLE LOCALHOST1.BI_CODIGO_PC
DROP TABLE LOCALHOST1.BI_ACCESORIO
DROP TABLE LOCALHOST1.BI_PLACA_VIDEO
DROP TABLE LOCALHOST1.BI_RAM
DROP TABLE LOCALHOST1.BI_MOTHERBOARD
DROP TABLE LOCALHOST1.BI_MICROPROCESADOR
DROP TABLE LOCALHOST1.BI_DISCO_ALMACENAMIENTO
DROP TABLE LOCALHOST1.BI_FABRICANTE
DROP TABLE LOCALHOST1.BI_CLIENTE
DROP TABLE LOCALHOST1.BI_FRANJA_EDAD
DROP TABLE LOCALHOST1.BI_TIEMPO
DROP TABLE LOCALHOST1.BI_SUCURSAL
DROP TABLE LOCALHOST1.BI_CIUDAD
DROP TABLE [LOCALHOST1].[AUX_PROM_PC]
      
DROP FUNCTION dbo.[CLIENTE_A_BI]
DROP FUNCTION dbo.[CANT_PC_VENDIDAS]
DROP FUNCTION dbo.[PRECIO_PROMEDIO_VENTA_PC]
DROP FUNCTION dbo.[GANANCIA_PC]
DROP FUNCTION dbo.[PRECIO_PROMEDIO_COMPRA_ACC]
DROP FUNCTION dbo.[CANT_ACC_VENDIDOS]
DROP FUNCTION dbo.[PRECIO_PROMEDIO_VENTA_ACC]
DROP FUNCTION dbo.[GANANCIA_ACC]
DROP FUNCTION dbo.[PRECIO_PROMEDIO_COMPRA_ACC]
DROP FUNCTION dbo.[PRECIO_PROMEDIO_COMPRA_PC]
DROP FUNCTION dbo.[CANT_PC_COMPRADAS]
DROP FUNCTION dbo.[CANT_ACC_COMPRADoS]
DROP FUNCTION dbo.[PROM_ACC_STOCK]
DROP FUNCTION dbo.[PROM_PC_STOCK]
DROP VIEW LOCALHOST1.VW_PRECIO_PROMEDIO_VENTA_PC
DROP VIEW LOCALHOST1.VW_CANT_PC_X_SUCURSAL_Y_MES
DROP VIEW LOCALHOST1.VW_GANANCIAS_PC_X_SUCURSAL_Y_MES
DROP VIEW LOCALHOST1.VW_PRECIO_PROMEDIO_COMPRAS_ACC
DROP VIEW LOCALHOST1.VW_GANANCIAS_ACC_X_SUCURSAL_Y_MES
DROP VIEW LOCALHOST1.VW_MAX_CANT_STOCK_ANUAL
DROP VIEW LOCALHOST1.VW_PROM_TIEMPO_STOCK_PC
DROP VIEW LOCALHOST1.VW_PROM_TIEMPO_STOCK_ACC

*/
