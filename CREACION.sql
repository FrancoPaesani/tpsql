USE GD1C2021
--Creación del Schema
DECLARE @SCHEMA_NAME nvarchar(128)
SET @SCHEMA_NAME = 'LOCALHOST1'
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @SCHEMA_NAME)
	EXEC('CREATE SCHEMA ' + @SCHEMA_NAME)
----------------------------------Creación de Tablas----------------------------------

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

--Creación de componente de la PC.

CREATE TABLE [LOCALHOST1].Motherboard(
					mother_codigo nvarchar(255) NOT NULL,
					mother_modelo nvarchar(255),
					mother_descripcion nvarchar(255),
					mother_fabricante int FOREIGN KEY REFERENCES LOCALHOST1.Fabricante(fab_codigo),
					CONSTRAINT PK_MOTHERBOARD PRIMARY KEY(mother_codigo)
)

CREATE TABLE [LOCALHOST1].Placa_Video(
					pvideo_codigo int identity(1,1) NOT NULL,
					pvideo_chipset nvarchar(50),
					pvideo_modelo nvarchar(50),
					pvideo_velocidad nvarchar(50),
					pvideo_capacidad nvarchar(255),
					pvideo_fabricante int FOREIGN KEY REFERENCES LOCALHOST1.Fabricante(fab_codigo),
					CONSTRAINT PK_PVIDEO PRIMARY KEY(pvideo_codigo)
)

CREATE TABLE [LOCALHOST1].Microprocesador(
					micro_codigo nvarchar(50) NOT NULL,
					micro_cache nvarchar(50),
					micro_cant_hilos decimal(18,0),
					micro_velocidad nvarchar(50),
					micro_fabricante int FOREIGN KEY REFERENCES LOCALHOST1.Fabricante(fab_codigo),
					CONSTRAINT PK_MICROPROCESADOR PRIMARY KEY(micro_codigo)
)

--Creación de PC

CREATE TABLE [LOCALHOST1].Pc(
					pc_codigo nvarchar(50) NOT NULL,
					pc_alto decimal(18,2),
					pc_ancho decimal(18,2),
					pc_profundidad decimal(18,2),
					pc_motherboard nvarchar(255) FOREIGN KEY REFERENCES LOCALHOST1.Motherboard(mother_codigo), 
					pc_pvideo int FOREIGN KEY REFERENCES LOCALHOST1.Placa_Video(pvideo_codigo),
					pc_micro nvarchar(50) FOREIGN KEY REFERENCES LOCALHOST1.Microprocesador(micro_codigo),
					pc_precio decimal(12,2),
					CONSTRAINT PK_PC PRIMARY KEY(pc_codigo)
)

CREATE TABLE [LOCALHOST1].Ram(
					ram_codigo nvarchar(255) NOT NULL,
					ram_tipo nvarchar(255),
					ram_capacidad nvarchar(255),
					ram_velocidad nvarchar(255),
					ram_fabricante int FOREIGN KEY REFERENCES LOCALHOST1.Fabricante(fab_codigo),
					CONSTRAINT PK_RAM PRIMARY KEY(ram_codigo)
)

CREATE TABLE [LOCALHOST1].RAM_X_PC(
					ramxpc_pc nvarchar(50) FOREIGN KEY REFERENCES LOCALHOST1.Pc(pc_codigo),
					ramxpc_ram nvarchar(255) FOREIGN KEY REFERENCES LOCALHOST1.Ram(ram_codigo),
					CONSTRAINT PK_RAM_X_PC PRIMARY KEY(ramxpc_pc,ramxpc_ram)
)


CREATE TABLE [LOCALHOST1].Disco_Almacenamiento(
					disco_codigo nvarchar(255) NOT NULL,
					disco_tipo nvarchar(255),
					disco_capacidad nvarchar(255),
					disco_velocidad nvarchar(255),
					disco_fabricante int FOREIGN KEY REFERENCES LOCALHOST1.Fabricante(fab_codigo),
					CONSTRAINT PK_DISCO PRIMARY KEY(disco_codigo)
)

CREATE TABLE [LOCALHOST1].Disco_x_Pc(
					discopc_pc nvarchar(50) FOREIGN KEY REFERENCES LOCALHOST1.Pc(pc_codigo),
					discopc_disco nvarchar(255) FOREIGN KEY REFERENCES LOCALHOST1.Disco_Almacenamiento(disco_codigo),
					CONSTRAINT PK_DISCO_X_PX PRIMARY KEY(discopc_pc,discopc_disco)
)


--Ciudad

CREATE TABLE [LOCALHOST1].Ciudad(
					ciu_codigo int Identity(1,1) NOT NULL,
					ciu_nombre nvarchar(255),
					CONSTRAINT PK_CIUDAD PRIMARY KEY(ciu_codigo)
)

--Creación de Sucursal

CREATE TABLE [LOCALHOST1].Sucursal(
					suc_codigo int Identity(1,1) NOT NULL,
					suc_dir nvarchar(255),
					suc_mail nvarchar(255),
					suc_telefono decimal(18,0),
					suc_ciudad int FOREIGN KEY REFERENCES LOCALHOST1.Ciudad(ciu_codigo),
					CONSTRAINT PK_SUCURSAL PRIMARY KEY(suc_codigo)
)


--Creación de Stock

CREATE TABLE [LOCALHOST1].Stock_Pc(
					stockpc_pc nvarchar(50) FOREIGN KEY REFERENCES LOCALHOST1.Pc(pc_codigo),
					stockpc_sucursal int FOREIGN KEY REFERENCES LOCALHOST1.Sucursal(suc_codigo),
					stockpc_cantidad int,
					CONSTRAINT PK_STOCK_PC PRIMARY KEY(stockpc_pc,stockpc_sucursal)
)

CREATE TABLE [LOCALHOST1].Stock_Accesorio(
					stockacc_acc decimal(18,0) FOREIGN KEY REFERENCES LOCALHOST1.Accesorio(acc_codigo),
					stockacc_sucursal int FOREIGN KEY REFERENCES LOCALHOST1.Sucursal(suc_codigo),
					stockacc_cantidad int,
					CONSTRAINT PK_STOCK_ACC PRIMARY KEY(stockacc_acc,stockacc_sucursal)
)

--Creación de Factura de Venta
CREATE TABLE [LOCALHOST1].Factura_Venta(
					facven_numero decimal(18,0) NOT NULL,
					facven_sucursal int FOREIGN KEY REFERENCES LOCALHOST1.Sucursal(suc_codigo),
					facven_cliente int FOREIGN KEY REFERENCES LOCALHOST1.Cliente(cli_codigo),
					facven_fecha datetime2(3),
					facven_total decimal(12,2),
					CONSTRAINT PK_FACVENTA PRIMARY KEY(facven_numero,facven_sucursal)
)
--Creación de items de venta
CREATE TABLE [LOCALHOST1].Item_Venta_Pc(
					ivenpc_numero decimal(18,0) NOT NULL,
  				ivenpc_sucursal int NOT NULL,
					ivenpc_pc nvarchar(50) FOREIGN KEY REFERENCES LOCALHOST1.Pc(pc_codigo),
					ivenpc_cantidad numeric(4),
					ivenpc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_VENTA_PC FOREIGN KEY(ivenpc_numero,ivenpc_sucursal) REFERENCES LOCALHOST1.Factura_Venta(facven_numero,facven_sucursal),
					CONSTRAINT PK_ITEM_VENTA_PC PRIMARY KEY(ivenpc_numero,ivenpc_pc)
)

CREATE TABLE [LOCALHOST1].Item_Facven_Acc(
					ivenacc_numero decimal(18,0),
  				ivenacc_sucursal int NOT NULL,
					ivenacc_acc decimal(18,0) FOREIGN KEY REFERENCES LOCALHOST1.Accesorio(acc_codigo),
					ivenacc_cantidad numeric(4),
					ivenacc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_VENTA_ACC FOREIGN KEY(ivenacc_numero,ivenacc_sucursal) REFERENCES LOCALHOST1.Factura_Venta(facven_numero,facven_sucursal),
					CONSTRAINT PK_ITEM_VENTA_ACC PRIMARY KEY(ivenacc_numero,ivenacc_acc)
)

--Creación Factura de Compra

CREATE TABLE [LOCALHOST1].Factura_Compra(
					faccomp_numero decimal(18,0) NOT NULL,
					faccomp_sucursal int FOREIGN KEY REFERENCES LOCALHOST1.Sucursal(suc_codigo),
					faccomp_fecha datetime2(3),
					faccomp_total decimal(12,2),
					CONSTRAINT PK_FACCOMPRA PRIMARY KEY(faccomp_numero,faccomp_sucursal)
)
--Creación de items de Compra
CREATE TABLE [LOCALHOST1].Item_Compra_Pc(
					icomppc_numero decimal(18,0) NOT NULL,
  				icomppc_sucursal int NOT NULL,
					icomppc_pc nvarchar(50) FOREIGN KEY REFERENCES LOCALHOST1.Pc(pc_codigo),
					icomppc_cantidad numeric(4),
					icomppc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_COMPRA_PC FOREIGN KEY(icomppc_numero,icomppc_sucursal) REFERENCES LOCALHOST1.Factura_Compra(faccomp_numero,faccomp_sucursal),
					CONSTRAINT PK_ITEM_COMPRA_PC PRIMARY KEY(icomppc_numero,icomppc_pc)
)

CREATE TABLE [LOCALHOST1].Item_Faccomp_Acc(
					icompacc_numero decimal(18,0),
  					icompacc_sucursal int NOT NULL,
  					icompacc_acc decimal(18,0) FOREIGN KEY REFERENCES LOCALHOST1.Accesorio(acc_codigo),
					icompacc_cantidad numeric(4),
					icompacc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_COMPRA_ACC FOREIGN KEY(icompacc_numero,icompacc_sucursal) REFERENCES LOCALHOST1.Factura_Compra(faccomp_numero,faccomp_sucursal),
					CONSTRAINT PK_ITEM_COMPRA_ACC PRIMARY KEY(icompacc_numero,icompacc_acc)
)

----------------------------------Migración de Tablas----------------------------------

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

--Migración de Fabricante

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

--MIGRACIÓN ACCESORIO

INSERT INTO [LOCALHOST1].[Accesorio](
				acc_codigo,
				acc_descripcion,
				acc_precio
)
/*
SELECT ACCESORIO_CODIGO, AC_DESCRIPCION, COMPRA_PRECIO
FROM GD1C2021.gd_esquema.Maestra
WHERE ACCESORIO_CODIGO IS NOT NULL AND COMPRA_PRECIO IS NOT NULL
GROUP BY ACCESORIO_CODIGO, AC_DESCRIPCION, COMPRA_PRECIO
*/
SELECT DISTINCT maestra.[ACCESORIO_CODIGO],
								maestra.[AC_DESCRIPCION]
								, maestra.[COMPRA_PRECIO]
                 
FROM GD1C2021.gd_esquema.Maestra maestra
WHERE [ACCESORIO_CODIGO] is not NULL and [COMPRA_PRECIO] is not null

GO

--Migración de PlavaDeVideo

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

--Migración de Microprocesador

SELECT DISTINCT MICROPROCESADOR_CACHE,
								maestra.[PLACA_VIDEO_MODELO],
                maestra.[PLACA_VIDEO_VELOCIDAD],
                maestra.[PLACA_VIDEO_CAPACIDAD],
                fabricante.[fab_codigo]
                
FROM GD1C2021.gd_esquema.Maestra maestra
JOIN [LOCALHOST1].[FABRICANTE] fabricante
ON [PLACA_VIDEO_FABRICANTE] = fab_nombre
WHERE [PLACA_VIDEO_CHIPSET] is not NULL

select MICROPROCESADOR_CODIGO, MICROPROCESADOR_CACHE, MICROPROCESADOR_CANT_HILOS, MICROPROCESADOR_FABRICANTE, MICROPROCESADOR_VELOCIDAD from gd_esquema.Maestra
group by  MICROPROCESADOR_CODIGO, MICROPROCESADOR_CACHE, MICROPROCESADOR_CANT_HILOS, MICROPROCESADOR_FABRICANTE, MICROPROCESADOR_VELOCIDAD 

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

--Mig de RAM

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

--Mig de Disco

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

--Migracion de PC

select * from gd_esquema.Maestra

select PC_CODIGO, PC_ALTO, PC_ANCHO, PC_PROFUNDIDAD, DISCO_RIGIDO_CODIGO, MEMORIA_RAM_CODIGO, MICROPROCESADOR_CODIGO, COMPRA_PRECIO from gd_esquema.Maestra
join LOCALHOST1.Placa_Video on PLACA_VIDEO_CAPACIDAD = pvideo_capacidad AND
PLACA_VIDEO_CHIPSET = pvideo_chipset AND PLACA_VIDEO_VELOCIDAD = pvideo_velocidad AND PLACA_VIDEO_FABRICANTE = PLACA_VIDEO_FABRICANTE AND
PLACA_VIDEO_MODELO = pvideo_modelo
where PC_CODIGO is not null and COMPRA_PRECIO is not null
group by PC_CODIGO, PC_ALTO, PC_ANCHO, PC_PROFUNDIDAD, DISCO_RIGIDO_CODIGO, MEMORIA_RAM_CODIGO, MICROPROCESADOR_CODIGO, COMPRA_PRECIO


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
where PC_CODIGO is not null and COMPRA_PRECIO is not null

--Migración de RAMxPC

INSERT INTO [LOCALHOST1].[RAM_X_PC](
  				ramxpc_pc,
					ramxpc_ram
)


SELECT DISTINCT maestra.[PC_CODIGO],
								maestra.[MEMORIA_RAM_CODIGO]

FROM GD1C2021.gd_esquema.Maestra maestra
where [PC_CODIGO] is not null AND [MEMORIA_RAM_CODIGO] is not null

-- DISCO_X_PC

INSERT INTO [LOCALHOST1].[DISCO_X_PC](
				discopc_pc,
  				discopc_disco
)

SELECT DISTINCT maestra.[PC_CODIGO],
								maestra.[DISCO_RIGIDO_CODIGO]

FROM GD1C2021.gd_esquema.Maestra maestra
WHERE [PC_CODIGO] IS NOT NULL AND [DISCO_RIGIDO_CODIGO] IS NOT NULL

--CIUDAD

INSERT INTO [LOCALHOST1].[CIUDAD](
					ciu_nombre 				 
)

SELECT DISTINCT maestra.[CIUDAD]
FROM GD1C2021.gd_esquema.Maestra maestra

--SUCURSAL

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
JOIN [LOCALHOST1].[CIUDAD] on ciudad = ciu_nombre
