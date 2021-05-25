USE GD1C2021
--Creación del Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'LOCALHOST1')
	EXEC('CREATE SCHEMA LOCALHOST1 ' )

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Tablas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CREATE TABLE [LOCALHOST1].Cliente(
				cli_codigo int Identity(1,1) NOT NULL,
				cli_nombre nvarchar(255),
				cli_apellido nvarchar(255),
				cli_dni decimal(18,0),
				cli_direccion nvarchar(255),
				cli_fecha_nacimiento datetime2(3),
				cli_mail nvarchar(255),
				cli_telefono int,
				CONSTRAINT PK_CLIENTE PRIMARY KEY(cli_codigo)
)

CREATE TABLE [LOCALHOST1].Fabricante(
				fab_codigo int Identity(1,1) NOT NULL,
				fab_nombre nvarchar(255),
				CONSTRAINT PK_FABRICANTE PRIMARY KEY(fab_codigo)
)

CREATE TABLE [LOCALHOST1].Accesorio(
				acc_codigo decimal(18,0) NOT NULL,
				acc_descripcion nvarchar(255),
				acc_precio decimal(12,2),
				CONSTRAINT PK_ACCESORIO PRIMARY KEY(acc_codigo)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Componentes de PC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CREATE TABLE [LOCALHOST1].Motherboard(
					mother_codigo nvarchar(255) NOT NULL,
					mother_modelo nvarchar(255),
					mother_descripcion nvarchar(255),
					mother_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].Fabricante(fab_codigo),
					CONSTRAINT PK_MOTHERBOARD PRIMARY KEY(mother_codigo)
)

CREATE TABLE [LOCALHOST1].Placa_Video(
					pvideo_codigo int identity(1,1) NOT NULL,
					pvideo_chipset nvarchar(50),
					pvideo_modelo nvarchar(50),
					pvideo_velocidad nvarchar(50),
					pvideo_capacidad nvarchar(255),
					pvideo_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].Fabricante(fab_codigo),
					CONSTRAINT PK_PVIDEO PRIMARY KEY(pvideo_codigo)
)

CREATE TABLE [LOCALHOST1].Microprocesador(
					micro_codigo nvarchar(50) NOT NULL,
					micro_cache nvarchar(50),
					micro_cant_hilos decimal(18,0),
					micro_velocidad nvarchar(50),
					micro_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].Fabricante(fab_codigo),
					CONSTRAINT PK_MICROPROCESADOR PRIMARY KEY(micro_codigo)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de PC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CREATE TABLE [LOCALHOST1].Pc(
					pc_codigo nvarchar(50) NOT NULL,
					pc_alto decimal(18,2),
					pc_ancho decimal(18,2),
					pc_profundidad decimal(18,2),
					pc_motherboard nvarchar(255) FOREIGN KEY REFERENCES [LOCALHOST1].Motherboard(mother_codigo), 
					pc_pvideo int FOREIGN KEY REFERENCES [LOCALHOST1].Placa_Video(pvideo_codigo),
					pc_micro nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Microprocesador(micro_codigo),
					pc_precio decimal(12,2),
					CONSTRAINT PK_PC PRIMARY KEY(pc_codigo)
)

CREATE TABLE [LOCALHOST1].Ram(
					ram_codigo nvarchar(255) NOT NULL,
					ram_tipo nvarchar(255),
					ram_capacidad nvarchar(255),
					ram_velocidad nvarchar(255),
					ram_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].Fabricante(fab_codigo),
					CONSTRAINT PK_RAM PRIMARY KEY(ram_codigo)
)

CREATE TABLE [LOCALHOST1].RAM_X_PC(
					ramxpc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Pc(pc_codigo),
					ramxpc_ram nvarchar(255) FOREIGN KEY REFERENCES [LOCALHOST1].Ram(ram_codigo),
					CONSTRAINT PK_RAM_X_PC PRIMARY KEY(ramxpc_pc,ramxpc_ram)
)


CREATE TABLE [LOCALHOST1].Disco_Almacenamiento(
					disco_codigo nvarchar(255) NOT NULL,
					disco_tipo nvarchar(255),
					disco_capacidad nvarchar(255),
					disco_velocidad nvarchar(255),
					disco_fabricante int FOREIGN KEY REFERENCES [LOCALHOST1].Fabricante(fab_codigo),
					CONSTRAINT PK_DISCO PRIMARY KEY(disco_codigo)
)

CREATE TABLE [LOCALHOST1].Disco_x_Pc(
					discopc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Pc(pc_codigo),
					discopc_disco nvarchar(255) FOREIGN KEY REFERENCES [LOCALHOST1].Disco_Almacenamiento(disco_codigo),
					CONSTRAINT PK_DISCO_X_PX PRIMARY KEY(discopc_pc,discopc_disco)
)


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Ciudad %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CREATE TABLE [LOCALHOST1].Ciudad(
					ciu_codigo int Identity(1,1) NOT NULL,
					ciu_nombre nvarchar(255),
					CONSTRAINT PK_CIUDAD PRIMARY KEY(ciu_codigo)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Sucursal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CREATE TABLE [LOCALHOST1].Sucursal(
					suc_codigo int Identity(1,1) NOT NULL,
					suc_dir nvarchar(255),
					suc_mail nvarchar(255),
					suc_telefono decimal(18,0),
					suc_ciudad int FOREIGN KEY REFERENCES [LOCALHOST1].Ciudad(ciu_codigo),
					CONSTRAINT PK_SUCURSAL PRIMARY KEY(suc_codigo)
)


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Stock %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CREATE TABLE [LOCALHOST1].Stock_Pc(
					stockpc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Pc(pc_codigo),
					stockpc_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].Sucursal(suc_codigo),
					stockpc_cantidad int,
					CONSTRAINT PK_STOCK_PC PRIMARY KEY(stockpc_pc,stockpc_sucursal)
)

CREATE TABLE [LOCALHOST1].Stock_Accesorio(
					stockacc_acc decimal(18,0) FOREIGN KEY REFERENCES [LOCALHOST1].Accesorio(acc_codigo),
					stockacc_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].Sucursal(suc_codigo),
					stockacc_cantidad int,
					CONSTRAINT PK_STOCK_ACC PRIMARY KEY(stockacc_acc,stockacc_sucursal)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Factura Venta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CREATE TABLE [LOCALHOST1].Factura_Venta(
					facven_numero decimal(18,0) NOT NULL,
					facven_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].Sucursal(suc_codigo),
					facven_cliente int FOREIGN KEY REFERENCES [LOCALHOST1].Cliente(cli_codigo),
					facven_fecha datetime2(3),
					facven_total decimal(20,2),
					CONSTRAINT PK_FACVENTA PRIMARY KEY(facven_numero,facven_sucursal)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Items de Venta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CREATE TABLE [LOCALHOST1].Item_Venta_Pc(
					ivenpc_numero decimal(18,0) NOT NULL,
  					ivenpc_sucursal int NOT NULL,
  					ivenpc_renglonpc int IDENTITY(1,1) NOT NULL,
					ivenpc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Pc(pc_codigo),
					ivenpc_cantidad numeric(4),
					ivenpc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_VENTA_PC FOREIGN KEY(ivenpc_numero,ivenpc_sucursal) REFERENCES [LOCALHOST1].Factura_Venta(facven_numero,facven_sucursal),
					CONSTRAINT PK_ITEM_VENTA_PC PRIMARY KEY(ivenpc_numero,ivenpc_pc)
)

CREATE TABLE [LOCALHOST1].Item_Venta_Acc(
					ivenacc_numero decimal(18,0),
  					ivenacc_sucursal int NOT NULL,
  					ivenacc_renglonpc int IDENTITY(1,1) NOT NULL,
					ivenacc_acc decimal(18,0) FOREIGN KEY REFERENCES [LOCALHOST1].Accesorio(acc_codigo),
					ivenacc_cantidad numeric(4),
					ivenacc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_VENTA_ACC FOREIGN KEY(ivenacc_numero,ivenacc_sucursal) REFERENCES [LOCALHOST1].Factura_Venta(facven_numero,facven_sucursal),
					CONSTRAINT PK_ITEM_VENTA_ACC PRIMARY KEY(ivenacc_numero,ivenacc_acc)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Factura Compra %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CREATE TABLE [LOCALHOST1].Factura_Compra(
					faccomp_numero decimal(18,0) NOT NULL,
					faccomp_sucursal int FOREIGN KEY REFERENCES [LOCALHOST1].Sucursal(suc_codigo),
					faccomp_fecha datetime2(3),
					faccomp_total decimal(20,2),
					CONSTRAINT PK_FACCOMPRA PRIMARY KEY(faccomp_numero,faccomp_sucursal)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Creación de Items de Compra %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CREATE TABLE [LOCALHOST1].Item_Compra_Pc(
					icomppc_numero decimal(18,0) NOT NULL,
  				icomppc_sucursal int NOT NULL,
  				icomppc_renglonpc int IDENTITY(1,1) NOT NULL,
					icomppc_pc nvarchar(50) FOREIGN KEY REFERENCES [LOCALHOST1].Pc(pc_codigo),
					icomppc_cantidad numeric(4),
					icomppc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_COMPRA_PC FOREIGN KEY(icomppc_numero,icomppc_sucursal) REFERENCES [LOCALHOST1].Factura_Compra(faccomp_numero,faccomp_sucursal),
					CONSTRAINT PK_ITEM_COMPRA_PC PRIMARY KEY(icomppc_numero,icomppc_pc)
)

CREATE TABLE [LOCALHOST1].Item_Compra_Acc(
					icompacc_numero decimal(18,0),
  				icompacc_sucursal int NOT NULL,
  				icompacc_renglonpc int IDENTITY(1,1) NOT NULL,
  				icompacc_acc decimal(18,0) FOREIGN KEY REFERENCES [LOCALHOST1].Accesorio(acc_codigo),
					icompacc_cantidad numeric(4),
					icompacc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_COMPRA_ACC FOREIGN KEY(icompacc_numero,icompacc_sucursal) REFERENCES [LOCALHOST1].Factura_Compra(faccomp_numero,faccomp_sucursal),
					CONSTRAINT PK_ITEM_COMPRA_ACC PRIMARY KEY(icompacc_numero,icompacc_acc)
)

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VISTAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- CREACION DE VISTA FACTURAS (Compra/Venta)
GO
CREATE VIEW LOCALHOST1.vista_facturas AS
SELECT DISTINCT suc_codigo, maestra.SUCURSAL_DIR, maestra.SUCURSAL_MAIL, maestra.SUCURSAL_TEL, maestra.[COMPRA_NUMERO] ,maestra.[COMPRA_FECHA], maestra.FACTURA_NUMERO,
	maestra.FACTURA_FECHA, maestra.CLIENTE_APELLIDO, maestra.CLIENTE_DNI,maestra.CLIENTE_NOMBRE
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE maestra.SUCURSAL_DIR IS NOT NULL
GO

-- CREACIÓN DE VISTA ITEM COMPRA

CREATE VIEW LOCALHOST1.vista_item_compra AS
SELECT maestra.[COMPRA_NUMERO], suc_codigo, maestra.[COMPRA_CANTIDAD], maestra.[COMPRA_PRECIO], maestra.PC_CODIGO, maestra.ACCESORIO_CODIGO
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].SUCURSAL ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE maestra.SUCURSAL_DIR IS NOT NULL AND COMPRA_NUMERO IS NOT NULL 
GO

-- CRECIÓN DE VISTA ITEM VENTA 

CREATE VIEW LOCALHOST1.vista_item_venta AS
SELECT maestra.[FACTURA_NUMERO], suc_codigo, PC_CODIGO, ACCESORIO_CODIGO
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].SUCURSAL ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE FACTURA_NUMERO is not null
GO

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



-- TRIGGER EFECTUAR VENTA PC

IF OBJECT_ID('[LOCALHOST1].TR_EFECTUAR_VENTA_PC') IS NOT NULL
DROP TRIGGER [LOCALHOST1].TR_EFECTUAR_VENTA_PC;
GO

CREATE TRIGGER [LOCALHOST1].TR_EFECTUAR_VENTA_PC ON [LOCALHOST1].ITEM_VENTA_PC AFTER INSERT
AS
BEGIN
	DECLARE @PC nvarchar(50)
	SELECT @PC = ivenpc_pc FROM inserted

	IF @PC IN (SELECT pc_codigo FROM Pc)
	BEGIN
		/*	UPDATE [LOCALHOST1].Stock_Pc
			SET stockpc_cantidad = stockpc_cantidad - ivenpc_cantidad
			FROM inserted INS
			where INS.ivenpc_pc = Stock_Pc.stockpc_pc AND INS.ivenpc_sucursal = Stock_Pc.stockpc_sucursal;
		*/
			DECLARE @PC_COD nvarchar(50)
			DECLARE @SUC int
			DECLARE @CANT int
			DECLARE @VENTA_NUM decimal(18,0)
			DECLARE @PRECIO decimal(12,2)
			DECLARE CURSOR_TR_VENTA_PC CURSOR
			FOR
			
				SELECT ivenpc_numero, ivenpc_sucursal, ivenpc_pc, ivenpc_cantidad, ivenpc_precio FROM inserted
				OPEN CURSOR_TR_VENTA_PC
				FETCH NEXT FROM CURSOR_TR_VENTA_PC INTO @VENTA_NUM, @SUC, @PC_COD, @CANT, @PRECIO
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
				UPDATE [LOCALHOST1].Stock_Pc
				SET stockpc_cantidad = stockpc_cantidad - @CANT
				FROM  LOCALHOST1.Stock_Pc 
				WHERE stockpc_pc = @PC_COD AND stockpc_sucursal = @SUC
				
				UPDATE [LOCALHOST1].Factura_Venta
				SET facven_total = ISNULL(facven_total,0) + (@PRECIO * @CANT)
				FROM [LOCALHOST1].Factura_Venta
				WHERE facven_numero = @VENTA_NUM AND facven_sucursal = @SUC

				FETCH NEXT FROM CURSOR_TR_VENTA_PC INTO @VENTA_NUM, @SUC, @PC_COD, @CANT, @PRECIO

				END
				CLOSE CURSOR_TR_VENTA_PC
				DEALLOCATE CURSOR_TR_VENTA_PC
	END
	ELSE
	BEGIN
		RAISERROR('No se puede vender una PC que no existe en el stock',16,1);
		ROLLBACK TRANSACTION;
	END
END

-- TRIGGER EFECTUAR VENTA ACCESORIO
GO
IF OBJECT_ID('[LOCALHOST1].TR_EFECTUAR_VENTA_ACCESORIO') IS NOT NULL
DROP TRIGGER [LOCALHOST1].TR_EFECTUAR_VENTA_ACCESORIO;
GO

CREATE TRIGGER [LOCALHOST1].TR_EFECTUAR_VENTA_ACCESORIO ON [LOCALHOST1].ITEM_VENTA_ACC AFTER INSERT
AS
BEGIN
	DECLARE @PC nvarchar(50)
	SELECT @PC = ivenacc_acc FROM inserted

	IF  @PC IN (SELECT stockacc_acc FROM Stock_Accesorio)
	BEGIN
			DECLARE @ACC_COD decimal(18,0)
			DECLARE @SUC int
			DECLARE @CANT int
			DECLARE @COMPRA_NUM decimal(18,0)
			DECLARE @PRECIO decimal(12,2)
			DECLARE CURSOR_TR_VENTA_ACC CURSOR
			FOR
			
				SELECT ivenacc_numero, ivenacc_sucursal, ivenacc_acc, ivenacc_cantidad, ivenacc_precio FROM inserted
				OPEN CURSOR_TR_VENTA_ACC
				FETCH NEXT FROM CURSOR_TR_VENTA_ACC INTO @COMPRA_NUM, @SUC, @ACC_COD, @CANT, @PRECIO
				WHILE @@FETCH_STATUS = 0
				BEGIN

				
				UPDATE [LOCALHOST1].Stock_Accesorio
				SET stockacc_cantidad = stockacc_cantidad - @CANT
				FROM  LOCALHOST1.Stock_Accesorio 
				WHERE stockacc_acc = @ACC_COD AND stockacc_sucursal = @SUC
				
				UPDATE [LOCALHOST1].Factura_Venta
				SET facven_total = ISNULL(facven_total,0) + (@PRECIO * @CANT)
				FROM [LOCALHOST1].Factura_Venta
				WHERE facven_numero = @COMPRA_NUM AND facven_sucursal = @SUC

				FETCH NEXT FROM CURSOR_TR_VENTA_ACC INTO @COMPRA_NUM, @SUC, @ACC_COD, @CANT, @PRECIO

				END
				CLOSE CURSOR_TR_VENTA_ACC
				DEALLOCATE CURSOR_TR_VENTA_ACC
	END
	ELSE
	BEGIN
		RAISERROR('No se puede vender una accesorio que no existe en el stock',16,1);
		ROLLBACK TRANSACTION;
	END
END
GO
-- TRIGGER EFECTUAR COMPRA PC

IF OBJECT_ID('[LOCALHOST1].TR_EFECTUAR_COMPRA_PC') IS NOT NULL
DROP TRIGGER [LOCALHOST1].TR_EFECTUAR_COMPRA_PC;
GO
CREATE TRIGGER [LOCALHOST1].TR_EFECTUAR_COMPRA_PC ON [LOCALHOST1].ITEM_COMPRA_PC AFTER INSERT
AS
BEGIN
	DECLARE @PC nvarchar(50)
  SELECT @PC =	icomppc_pc FROM inserted
  
  IF @PC IN (SELECT stockpc_pc FROM Stock_Pc)
  BEGIN
			DECLARE @PC_COD nvarchar(50)
			DECLARE @SUC int
			DECLARE @CANT int
			DECLARE @COMPRA_NUM decimal(18,0)
			DECLARE @PRECIO decimal(12,2)
			DECLARE CURSOR_TR_COMPRA_PC CURSOR
			FOR
			
				SELECT icomppc_numero, icomppc_sucursal, icomppc_pc, icomppc_cantidad, icomppc_precio FROM inserted
				OPEN CURSOR_TR_COMPRA_PC
				FETCH NEXT FROM CURSOR_TR_COMPRA_PC INTO @COMPRA_NUM, @SUC, @PC_COD, @CANT, @PRECIO
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
				UPDATE [LOCALHOST1].Stock_Pc
				SET stockpc_cantidad = stockpc_cantidad + @CANT
				FROM  LOCALHOST1.Stock_Pc 
				WHERE stockpc_pc = @PC_COD AND stockpc_sucursal = @SUC
				
				UPDATE [LOCALHOST1].Factura_Compra
				SET faccomp_total = ISNULL(faccomp_total,0) + (@PRECIO * @CANT)
				FROM [LOCALHOST1].Factura_Compra
				WHERE faccomp_numero = @COMPRA_NUM AND faccomp_sucursal = @SUC

				FETCH NEXT FROM CURSOR_TR_COMPRA_PC INTO @COMPRA_NUM, @SUC, @PC_COD, @CANT, @PRECIO

				END
				CLOSE CURSOR_TR_COMPRA_PC
				DEALLOCATE CURSOR_TR_COMPRA_PC
  END
  
  /*UPDATE [LOCALHOST1].Factura_Compra
  
  SET faccomp_total = ISNULL(faccomp_total,0) + (icomppc_precio * icomppc_cantidad)
  FROM inserted
  JOIN [LOCALHOST1].Factura_Compra ON icomppc_numero = faccomp_numero AND icomppc_sucursal = faccomp_sucursal*/
END

GO
-- TRIGGER EFECTUAR COMPRA ACCESORIO

IF OBJECT_ID('[LOCALHOST1].TR_EFECTUAR_COMPRA_ACCESORIO') IS NOT NULL
DROP TRIGGER [LOCALHOST1].TR_EFECTUAR_COMPRA_ACCESORIO;
GO
CREATE TRIGGER [LOCALHOST1].TR_EFECTUAR_COMPRA_ACCESORIO ON [LOCALHOST1].ITEM_COMPRA_ACC AFTER INSERT
AS
BEGIN
  DECLARE @ACC decimal(18,0)
  SELECT @ACC =	icompacc_acc FROM inserted
  
  IF @ACC IN (SELECT stockacc_acc FROM Stock_Accesorio)
  BEGIN
  /*	UPDATE [LOCALHOST1].Stock_Accesorio
    SET stockacc_cantidad = stockacc_cantidad + INS.icompacc_cantidad
    FROM inserted INS
    WHERE INS.icompacc_acc = Stock_Accesorio.stockacc_acc AND INS.icompacc_sucursal = Stock_Accesorio.stockacc_sucursal;*/
			DECLARE @ACC_COD decimal(18,0)
			DECLARE @SUC int
			DECLARE @CANT int
			DECLARE @COMPRA_NUM decimal(18,0)
			DECLARE @PRECIO decimal(12,2)
			DECLARE CURSOR_TR_COMPRA_ACC CURSOR
			FOR

				SELECT icompacc_numero, icompacc_sucursal, icompacc_acc, icompacc_cantidad, icompacc_precio FROM inserted
				OPEN CURSOR_TR_COMPRA_ACC
				FETCH NEXT FROM CURSOR_TR_COMPRA_ACC INTO @COMPRA_NUM, @SUC, @ACC_COD, @CANT, @PRECIO
				WHILE @@FETCH_STATUS = 0
				BEGIN

				UPDATE [LOCALHOST1].Stock_Accesorio
				SET stockacc_cantidad = stockacc_cantidad + @CANT
				FROM  LOCALHOST1.Stock_Accesorio 
				where stockacc_acc = @ACC_COD AND stockacc_sucursal = @SUC

				UPDATE [LOCALHOST1].Factura_Compra
  
				SET faccomp_total = ISNULL(faccomp_total,0) + (@PRECIO * @CANT)
				FROM [LOCALHOST1].Factura_Compra 
				where @COMPRA_NUM = faccomp_numero AND @SUC = faccomp_sucursal

				FETCH NEXT FROM CURSOR_TR_COMPRA_ACC INTO @COMPRA_NUM, @SUC, @ACC_COD, @CANT, @PRECIO

				END
				CLOSE CURSOR_TR_COMPRA_ACC
				DEALLOCATE CURSOR_TR_COMPRA_ACC
	
  END

END
GO

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INDICES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CREATE INDEX INDEX_SUCURSAL
ON [LOCALHOST1].[SUCURSAL] (suc_dir,suc_telefono);
GO
CREATE INDEX INDEX_FABRICANTE_NOMBRE 
ON [LOCALHOST1].[FABRICANTE] (fab_nombre);
GO
CREATE INDEX INDEX_CLIENTE 
ON [LOCALHOST1].[CLIENTE] (cli_dni,cli_apellido);

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Tablas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GO
--Migración de Clientes

INSERT INTO [LOCALHOST1].[CLIENTE](
				cli_nombre,
				cli_apellido,
				cli_dni,
				cli_direccion,
				cli_fecha_nacimiento,
				cli_mail,
				cli_telefono
)
SELECT DISTINCT	maestra.[CLIENTE_NOMBRE],
  				maestra.[CLIENTE_APELLIDO],
  				maestra.[CLIENTE_DNI],
  				maestra.[CLIENTE_DIRECCION],
  				maestra.[CLIENTE_FECHA_NACIMIENTO],
  				maestra.[CLIENTE_MAIL],
  				maestra.[CLIENTE_TELEFONO]
  
FROM GD1C2021.gd_esquema.Maestra maestra
WHERE maestra.[CLIENTE_DNI] is not null                 

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Fabricante %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GO
INSERT INTO [LOCALHOST1].[FABRICANTE](
				fab_nombre
)

SELECT DISTINCT ([DISCO_RIGIDO_FABRICANTE]) AS FABRICANTE
FROM GD1C2021.gd_esquema.Maestra maestra
where DISCO_RIGIDO_FABRICANTE is not null
UNION SELECT DISTINCT ([MEMORIA_RAM_FABRICANTE])
FROM GD1C2021.gd_esquema.Maestra maestra
where [MEMORIA_RAM_FABRICANTE] is not null
UNION SELECT DISTINCT ([MICROPROCESADOR_FABRICANTE])
FROM GD1C2021.gd_esquema.Maestra maestra
where [MICROPROCESADOR_FABRICANTE] is not null
UNION SELECT DISTINCT ([PLACA_VIDEO_FABRICANTE])
FROM GD1C2021.gd_esquema.Maestra maestra
where [PLACA_VIDEO_FABRICANTE] is not null
GO
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Accesorios %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INSERT INTO [LOCALHOST1].[ACCESORIO](
  			acc_codigo,
				acc_descripcion,
				acc_precio 
  )

SELECT DISTINCT maestra.[ACCESORIO_CODIGO],
								maestra.[AC_DESCRIPCION],
                maestra.[COMPRA_PRECIO] 
FROM GD1C2021.gd_esquema.Maestra maestra
WHERE [ACCESORIO_CODIGO] is not NULL and [COMPRA_PRECIO] is not NULL
/*
SELECT ACCESORIO_CODIGO, AC_DESCRIPCION, COMPRA_PRECIO
FROM GD1C2021.gd_esquema.Maestra
WHERE ACCESORIO_CODIGO IS NOT NULL AND COMPRA_PRECIO IS NOT NULL
GROUP BY ACCESORIO_CODIGO, AC_DESCRIPCION, COMPRA_PRECIO
*/
GO

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Placa de video %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INSERT INTO [LOCALHOST1].[PLACA_VIDEO](
					pvideo_chipset,
					pvideo_modelo,
					pvideo_velocidad, 
					pvideo_capacidad,
					pvideo_fabricante 
  )
  
SELECT DISTINCT maestra.[PLACA_VIDEO_CHIPSET],
								maestra.[PLACA_VIDEO_MODELO],
                maestra.[PLACA_VIDEO_VELOCIDAD],
                maestra.[PLACA_VIDEO_CAPACIDAD],
                fabricante.[fab_codigo]
                
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[FABRICANTE] fabricante
ON [PLACA_VIDEO_FABRICANTE] = fab_nombre
WHERE [PLACA_VIDEO_CHIPSET] is not NULL
GO


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Microprocesador %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[MICROPROCESADOR](
  				micro_codigo,
					micro_cache,
					micro_cant_hilos, 
					micro_velocidad,
					micro_fabricante
  )

SELECT DISTINCT maestra.[MICROPROCESADOR_CODIGO],
								maestra.[MICROPROCESADOR_CACHE],
                maestra.[MICROPROCESADOR_CANT_HILOS],
                maestra.[MICROPROCESADOR_VELOCIDAD],
                fabricante.[fab_codigo]

FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[FABRICANTE] fabricante
ON [MICROPROCESADOR_FABRICANTE] = fab_nombre
WHERE [MICROPROCESADOR_CODIGO] is not NULL
GO


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de RAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[RAM](
					ram_codigo,
  				ram_tipo ,
					ram_capacidad ,
					ram_velocidad ,
					ram_fabricante 
)

SELECT DISTINCT maestra.[MEMORIA_RAM_CODIGO],
								maestra.[MEMORIA_RAM_TIPO],
               	maestra.[MEMORIA_RAM_CAPACIDAD],
               	maestra.[MEMORIA_RAM_VELOCIDAD],
                fabricante.[fab_codigo]

FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[FABRICANTE] fabricante
ON MEMORIA_RAM_FABRICANTE = fab_nombre
WHERE [MEMORIA_RAM_CODIGO] is not NULL
         
GO        
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Disco Rigido %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[Disco_Almacenamiento](
  				disco_codigo,
					disco_tipo,
					disco_capacidad,
					disco_velocidad,
					disco_fabricante
  )

SELECT DISTINCT maestra.[DISCO_RIGIDO_CODIGO],
								maestra.[DISCO_RIGIDO_TIPO],
                maestra.[DISCO_RIGIDO_CAPACIDAD],
                maestra.[DISCO_RIGIDO_VELOCIDAD],
                fabricante.[fab_codigo]

FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[FABRICANTE] fabricante
ON [DISCO_RIGIDO_FABRICANTE] = fab_nombre
WHERE [DISCO_RIGIDO_CODIGO] is not NULL
          
GO         
                   
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de PC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[PC](
					pc_codigo, 
					pc_alto ,
					pc_ancho ,
					pc_profundidad, 
					pc_motherboard,
					pc_pvideo,
					pc_micro,
					pc_precio 
 )
 
 SELECT DISTINCT 	maestra.[PC_CODIGO],
 									maestra.[PC_ALTO],
                  maestra.[PC_ANCHO],
                  maestra.[PC_PROFUNDIDAD],
                  NULL,
                  placa.[pvideo_codigo],
                  micro.[micro_codigo],
                  maestra.[COMPRA_PRECIO]

FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[PLACA_VIDEO] placa
ON PLACA_VIDEO_CAPACIDAD = pvideo_capacidad AND PLACA_VIDEO_CHIPSET = pvideo_chipset 
AND PLACA_VIDEO_VELOCIDAD = pvideo_velocidad AND PLACA_VIDEO_MODELO = pvideo_modelo
JOIN [LOCALHOST1].[MICROPROCESADOR] micro
ON MICROPROCESADOR_CODIGO = micro_codigo
WHERE PC_CODIGO IS NOT NULL AND COMPRA_PRECIO IS NOT NULL
GO 
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de RAM X PC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[RAM_X_PC](
  				ramxpc_pc,
					ramxpc_ram
)

SELECT DISTINCT maestra.[PC_CODIGO],
								maestra.[MEMORIA_RAM_CODIGO]

FROM GD1C2021.gd_esquema.Maestra maestra
WHERE [PC_CODIGO] IS NOT NULL AND [MEMORIA_RAM_CODIGO] IS NOT NULL
GO
/* select * from LOCALHOST1.Pc
join LOCALHOST1.RAM_X_PC on pc_codigo = ramxpc_pc*/

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Disco Rígido X PC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[DISCO_X_PC](
  				discopc_pc,
					discopc_disco
)

SELECT DISTINCT maestra.[PC_CODIGO],
								maestra.[DISCO_RIGIDO_CODIGO]

FROM GD1C2021.gd_esquema.Maestra maestra
WHERE [PC_CODIGO] IS NOT NULL AND [DISCO_RIGIDO_CODIGO] IS NOT NULL
GO
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Ciudad %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


INSERT INTO [LOCALHOST1].[CIUDAD](
					ciu_nombre 				 
)

SELECT DISTINCT maestra.[CIUDAD]

FROM GD1C2021.gd_esquema.Maestra maestra

GO
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Sucursal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
 INSERT INTO [LOCALHOST1].[SUCURSAL](
 					suc_dir,
					suc_mail,
					suc_telefono,
					suc_ciudad 
 )
 
 SELECT DISTINCT 	maestra.[SUCURSAL_DIR],
  								maestra.[SUCURSAL_MAIL],
                	maestra.[SUCURSAL_TEL],
                  ciudad.[ciu_codigo]
                  
FROM GD1C2021.gd_esquema.Maestra maestra        
JOIN [LOCALHOST1].[CIUDAD] ON ciudad = ciu_nombre
GO
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Stock %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- Migración Stock PC

INSERT INTO [LOCALHOST1].[STOCK_PC](
					stockpc_pc, 
					stockpc_sucursal ,
					stockpc_cantidad 
) 

SELECT DISTINCT maestra.pc_codigo, suc_codigo, 0 AS cantidad
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
JOIN [LOCALHOST1].[PC] ON Pc.pc_codigo = maestra.PC_CODIGO
WHERE maestra.PC_CODIGO IS NOT NULL AND maestra.CIUDAD IS NOT NULL AND  maestra.SUCURSAL_DIR IS NOT NULL
AND maestra.COMPRA_NUMERO IS NOT NULL AND maestra.FACTURA_NUMERO is NULL
GROUP BY suc_codigo, maestra.PC_CODIGO, SUCURSAL_DIR

GO
CREATE VIEW LOCALHOST1.vista_stocks_PC_COMPRA AS
SELECT PC_CODIGO,  suc_codigo, SUM(COMPRA_CANTIDAD) AS CANTIDAD
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE COMPRA_NUMERO IS NOT NULL and PC_CODIGO is not null
group by PC_CODIGO,  suc_codigo
GO
CREATE VIEW LOCALHOST1.vista_stocks_PC_VENTA AS
SELECT PC_CODIGO,  suc_codigo, COUNT(*) AS CANTIDAD
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE FACTURA_NUMERO IS NOT NULL and PC_CODIGO is not null
group by PC_CODIGO,  suc_codigo
GO
CREATE VIEW LOCALHOST1.vista_stocks_ACC_COMPRA AS
SELECT ACCESORIO_CODIGO,  suc_codigo, SUM(COMPRA_CANTIDAD) AS CANTIDAD
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE COMPRA_NUMERO IS NOT NULL and ACCESORIO_CODIGO is not null
group by ACCESORIO_CODIGO,  suc_codigo
GO
CREATE VIEW LOCALHOST1.vista_stocks_ACC_VENTA AS
SELECT ACCESORIO_CODIGO,  suc_codigo, COUNT(*) AS CANTIDAD
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR AND suc_telefono = maestra.SUCURSAL_TEL
WHERE FACTURA_NUMERO IS NOT NULL and ACCESORIO_CODIGO is not null
group by ACCESORIO_CODIGO,  suc_codigo
GO

--Migración de Stock Accesorio
GO
INSERT INTO [LOCALHOST1].[STOCK_ACCESORIO](
					stockacc_acc,
					stockacc_sucursal,
					stockacc_cantidad 
) 

SELECT DISTINCT maestra.ACCESORIO_CODIGO, suc_codigo, 0 AS cantidad
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[SUCURSAL] ON suc_dir = maestra.SUCURSAL_DIR
AND suc_mail = maestra.SUCURSAL_MAIL AND suc_telefono = maestra.SUCURSAL_TEL
JOIN [LOCALHOST1].[ACCESORIO] ON [ACCESORIO].acc_codigo = maestra.ACCESORIO_CODIGO
WHERE maestra.ACCESORIO_CODIGO IS NOT NULL AND maestra.CIUDAD IS NOT NULL AND  maestra.SUCURSAL_DIR IS NOT NULL
AND maestra.COMPRA_NUMERO IS NOT NULL AND maestra.FACTURA_NUMERO IS NULL
GROUP BY suc_codigo, maestra.ACCESORIO_CODIGO, SUCURSAL_DIR

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Facturas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--Migración de Factura Compra
GO
INSERT INTO [LOCALHOST1].[FACTURA_COMPRA](
  				faccomp_numero,
					faccomp_sucursal,
					faccomp_fecha,
					faccomp_total
 )


SELECT DISTINCT maestra.[COMPRA_NUMERO], maestra.suc_codigo, maestra.[COMPRA_FECHA],0 AS cantidad
FROM LOCALHOST1.vista_facturas maestra
WHERE maestra.SUCURSAL_DIR IS NOT NULL AND COMPRA_NUMERO IS NOT NULL

--Migración de Factura Venta
GO
INSERT INTO [LOCALHOST1].[FACTURA_VENTA](
					facven_numero,
					facven_sucursal,
					facven_cliente,
					facven_fecha,
  				facven_total
)

SELECT DISTINCT FACTURA_NUMERO, maestra.suc_codigo, cli_codigo, FACTURA_FECHA, 0
from LOCALHOST1.vista_facturas maestra
join [LOCALHOST1].Cliente on maestra.CLIENTE_APELLIDO = cli_apellido and cli_dni = maestra.CLIENTE_DNI
where FACTURA_NUMERO is not null



-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Migración de Items %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GO
-- Migración de Items COMPRA PC 
INSERT INTO [LOCALHOST1].[ITEM_COMPRA_PC](
       					icomppc_numero,
  						icomppc_sucursal,
						icomppc_pc,
						icomppc_cantidad,
						icomppc_precio
)

SELECT c.[COMPRA_NUMERO], suc_codigo, PC.pc_codigo, SUM(c.[COMPRA_CANTIDAD]),c.[COMPRA_PRECIO]
FROM LOCALHOST1.vista_item_compra c
JOIN [LOCALHOST1].PC ON PC.pc_codigo = c.PC_CODIGO 
WHERE c.suc_codigo IS NOT NULL AND c.COMPRA_NUMERO IS NOT NULL
GROUP BY c.[COMPRA_NUMERO], suc_codigo, PC.pc_codigo, c.[COMPRA_PRECIO]
                               
-- Migración de Items COMPRA ACCESORIO 
GO
INSERT INTO [LOCALHOST1].[ITEM_COMPRA_ACC](
       					icompacc_numero,
  						icompacc_sucursal,
						icompacc_acc,
						icompacc_cantidad,
						icompacc_precio

)

SELECT c.[COMPRA_NUMERO], suc_codigo, ACCESORIO.acc_codigo, SUM(c.[COMPRA_CANTIDAD]),c.[COMPRA_PRECIO]
FROM LOCALHOST1.vista_item_compra c
JOIN [LOCALHOST1].ACCESORIO ON ACCESORIO.acc_codigo = c.ACCESORIO_CODIGO 
WHERE c.ACCESORIO_CODIGO IS NOT NULL AND c.COMPRA_NUMERO IS NOT NULL
GROUP BY c.[COMPRA_NUMERO], suc_codigo, ACCESORIO.acc_codigo, c.[COMPRA_PRECIO]

GO
-- Migración de Items VENTA PC 
		INSERT INTO [LOCALHOST1].[ITEM_VENTA_PC](
							ivenpc_numero,
  							ivenpc_sucursal,
							ivenpc_pc,
							ivenpc_cantidad,
							ivenpc_precio
)

SELECT maestra.[FACTURA_NUMERO], suc_codigo, PC.pc_codigo, COUNT(*), (PC.pc_precio + PC.pc_precio * 0.20)
FROM LOCALHOST1.vista_item_venta maestra
JOIN [LOCALHOST1].PC ON PC.pc_codigo = maestra.PC_CODIGO
WHERE FACTURA_NUMERO is not null 
group by maestra.[FACTURA_NUMERO], suc_codigo, PC.pc_codigo, PC.pc_precio

GO
-- Migración de Items VENTA ACCESORIO
		INSERT INTO [LOCALHOST1].[ITEM_VENTA_ACC](
							ivenacc_numero,
  							ivenacc_sucursal,
							ivenacc_acc,
							ivenacc_cantidad,
							ivenacc_precio
)

SELECT maestra.[FACTURA_NUMERO], suc_codigo, ACC.ACC_CODIGO, COUNT(*), ACC.acc_precio
FROM LOCALHOST1.vista_item_venta maestra
JOIN [LOCALHOST1].Accesorio ACC ON ACC.acc_codigo = maestra.ACCESORIO_CODIGO
WHERE FACTURA_NUMERO is not null
group by maestra.[FACTURA_NUMERO], suc_codigo, ACC.ACC_CODIGO, ACC.acc_precio

