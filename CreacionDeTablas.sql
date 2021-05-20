USE GD1C2021
--Creación del Schema
DECLARE @SCHEMA_NAME nvarchar(128)
SET @SCHEMA_NAME = 'prueba'
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @SCHEMA_NAME)
	EXEC('CREATE SCHEMA ' + @SCHEMA_NAME)
--Creación de Tablas

CREATE TABLE /*NOMBRE SCHEMA*/Cliente(
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

CREATE TABLE Fabricante(
				fab_codigo int Identity(1,1) NOT NULL,
				fab_nombre nvarchar(255),
				CONSTRAINT PK_FABRICANTE PRIMARY KEY(fab_codigo)
)

CREATE TABLE Accesorio(
				acc_codigo decimal(18,0) NOT NULL,
				acc_descripcion nvarchar(255),
				acc_precio decimal(12,2),
				CONSTRAINT PK_FABRICANTE PRIMARY KEY(acc_codigo)
)

--Creación de componente de la PC.

CREATE TABLE Motherboard(
					mother_codigo nvarchar(255) NOT NULL,
					mother_modelo nvarchar(255),
					mother_cantidad_sockets_ram int,	--agregamos?
					mother_cantidad_memoria_maxima char(10),  --agregamos?
					mother_descripcion nvarchar(255),
					mother_fabricante int FOREIGN KEY REFERENCES Fabricante(fab_codigo),
					CONSTRAINT PK_MOTHERBOARD PRIMARY KEY(mother_codigo)
)

CREATE TABLE Placa_Video(
					pvideo_codigo int identity(1,1) NOT NULL,
					pvideo_chipset nvarchar(50),
					pvideo_modelo nvarchar(50),
					pvideo_velocidad nvarchar(50),
					pvideo_capacidad nvarchar(255),
					pvideo_fabricante int FOREIGN KEY REFERENCES Fabricante(fab_codigo),
					CONSTRAINT PK_PVIDEO PRIMARY KEY(pvideo_codigo)
)

CREATE TABLE Microprocesador(
					micro_codigo nvarchar(50) NOT NULL,
					micro_cache nvarchar(50),
					micro_cant_hilos decimal(18,0),
					micro_velocidad nvarchar(50),
					micro_fabricante int FOREIGN KEY REFERENCES Fabricante(fab_codigo),
					CONSTRAINT PK_MICROPROCESADOR PRIMARY KEY(micro_codigo)
)

--Creación de PC

CREATE TABLE Pc(
					pc_codigo nvarchar(50) NOT NULL,
					pc_alto decimal(18,2),
					pc_ancho decimal(18,2),
					pc_profundidad decimal(18,2),
					pc_motherboard nvarchar(255) FOREIGN KEY REFERENCES Motherboard(mother_codigo), 
					pc_pvideo int FOREIGN KEY REFERENCES Placa_Video(pvideo_codigo),
					pc_micro nvarchar(50) FOREIGN KEY REFERENCES Microprocesador(micro_codigo),
					pc_precio decimal(12,2),
					CONSTRAINT PK_PC PRIMARY KEY(pc_codigo)
)

CREATE TABLE Ram(
					ram_codigo int Identity(1,1) NOT NULL,
					ram_tipo nvarchar(255),
					ram_capacidad nvarchar(255),
					ram_velocidad nvarchar(255),
					ram_fabricante int FOREIGN KEY REFERENCES Fabricante(fab_codigo),
					CONSTRAINT PK_RAM PRIMARY KEY(ram_codigo)
)

CREATE TABLE RAM_X_PC(
					ramxpc_pc nvarchar(50) FOREIGN KEY REFERENCES Pc(pc_codigo),
					ramxpc_ram int FOREIGN KEY REFERENCES Ram(ram_codigo),
					CONSTRAINT PK_RAM_X_PC PRIMARY KEY(ramxpc_pc,ramxpc_ram)
)


CREATE TABLE Disco_Almacenamiento(
					disco_codigo nvarchar(255) NOT NULL,
					disco_tipo nvarchar(255),
					disco_capacidad nvarchar(255),
					disco_velocidad nvarchar(255),
					disco_fabricante int FOREIGN KEY REFERENCES Fabricante(fab_codigo),
					CONSTRAINT PK_DISCO PRIMARY KEY(disco_codigo)
)

CREATE TABLE Disco_x_Pc(
					discopc_pc nvarchar(50) FOREIGN KEY REFERENCES Pc(pc_codigo),
					discopc_disco nvarchar(255) FOREIGN KEY REFERENCES Disco_Almacenamiento(disco_codigo),
					CONSTRAINT PK_DISCO_X_PX PRIMARY KEY(discopc_pc,discopc_disco)
)


--Ciudad

CREATE TABLE Ciudad(
					ciu_codigo int Identity(1,1) NOT NULL,
					ciu_nombre nvarchar(255),
					CONSTRAINT PK_CIUDAD PRIMARY KEY(ciu_codigo)
)

--Creación de Sucursal

CREATE TABLE Sucursal(
					suc_codigo int Identity(1,1) NOT NULL,
					suc_dir nvarchar(255),
					suc_mail nvarchar(255),
					suc_telefono decimal(18,0),
					suc_ciudad int FOREIGN KEY REFERENCES Ciudad(ciu_codigo),
					CONSTRAINT PK_SUCURSAL PRIMARY KEY(suc_codigo)
)


--Creación de Stock

CREATE TABLE Stock_Pc(
					stockpc_pc nvarchar(50) FOREIGN KEY REFERENCES Pc(pc_codigo),
					stockpc_sucursal int FOREIGN KEY REFERENCES Sucursal(suc_codigo),
					stockpc_cantidad int,
					CONSTRAINT PK_STOCK_PC PRIMARY KEY(stockpc_pc,stockpc_sucursal)
)

CREATE TABLE Stock_Accesorio(
					stockacc_acc decimal(18,0) FOREIGN KEY REFERENCES Accesorio(acc_codigo),
					stockacc_sucursal int FOREIGN KEY REFERENCES Sucursal(suc_codigo),
					stockacc_cantidad int,
					CONSTRAINT PK_STOCK_ACC PRIMARY KEY(stockacc_acc,stockacc_sucursal)
)

--Creación de Factura de Venta
CREATE TABLE Factura_Venta(
					facven_numero decimal(18,0) NOT NULL,
					facven_sucursal int FOREIGN KEY REFERENCES Sucursal(suc_codigo),
					facven_cliente int FOREIGN KEY REFERENCES Cliente(cli_codigo),
					facven_fecha datetime2(3),
					facven_total decimal(12,2),
					CONSTRAINT PK_FACVENTA PRIMARY KEY(facven_numero,facven_sucursal)
)
-- Creación de items de venta
CREATE TABLE Item_Venta_Pc(
					ivenpc_numero decimal(18,0) NOT NULL,
					ivenpc_sucursal int NOT NULL,
					ivenpc_pc nvarchar(50) FOREIGN KEY REFERENCES Pc(pc_codigo),
					ivenpc_cantidad numeric(4),
					ivenpc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_VENTA_PC FOREIGN KEY(ivenpc_numero,ivenpc_sucursal) REFERENCES Factura_Venta(facven_numero,facven_sucursal),
					CONSTRAINT PK_ITEM_VENTA_PC PRIMARY KEY(ivenpc_numero,ivenpc_pc)
)

CREATE TABLE Item_Facven_Acc(
					ivenacc_numero decimal(18,0),
					ivenacc_sucursal int NOT NULL,
					ivenacc_acc decimal(18,0) FOREIGN KEY REFERENCES Accesorio(acc_codigo),
					ivenacc_cantidad numeric(4),
					ivenacc_precio decimal(12,2),
					CONSTRAINT FK_ITEM_VENTA_ACC FOREIGN KEY(ivenacc_numero,ivenacc_sucursal) REFERENCES Factura_Venta(facven_numero,facven_sucursal),
					CONSTRAINT PK_ITEM_VENTA_ACC PRIMARY KEY(ivenacc_numero,ivenacc_acc)
)