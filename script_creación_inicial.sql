USE GD2C2020
-------------------------------------------------------------------------------------------------
-----------------------------------CREACIÓN DE SCHEMA------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'LAS_IMPOSTORAS')
BEGIN
	EXEC ('CREATE SCHEMA [LAS_IMPOSTORAS]') 
END
GO
/*SELECT * FROM sys.schemas;*/
-----------------------------------CREACIÓN DE TABLAS--------------------------------------------
-----------------------------------CLIENTE-------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[CLIENTE](
	clie_id int IDENTITY(1,1) NOT NULL,
	clie_nombre nvarchar(255),
	clie_apellido nvarchar(255),
	clie_dni decimal(18,0),
	clie_direccion nvarchar(255),
	clie_mail nvarchar(255),
	clie_fecha_nac datetime2(3)
	CONSTRAINT PK_CLIENTE PRIMARY KEY NONCLUSTERED(clie_id) 
) 
GO
-----------------------------------SUCURSAL-----------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[SUCURSAL](
	suc_id int IDENTITY(1,1) NOT NULL,
	suc_ciudad nvarchar(255),
	suc_direccion nvarchar(255),
	suc_mail nvarchar(255),
	suc_telefono decimal(18,0)
	CONSTRAINT PK_SUCURSAL PRIMARY KEY NONCLUSTERED (suc_id), 

)
GO
-----------------------------------FACTURA-------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[FACTURA](
	fac_nro decimal(18,0) NOT NULL,
	fac_fecha datetime2(3),
	fac_total decimal(18,2),
	fac_suc_id int FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[SUCURSAL](suc_id) NOT NULL,
	fac_clie_id int FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[CLIENTE](clie_id),
	CONSTRAINT PK_FACTURA PRIMARY KEY NONCLUSTERED (fac_nro,fac_suc_id), 
)
GO
-----------------------------------TIPO_TRANSMISION------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[TIPO_TRANSMISION](
	ttr_codigo decimal(18,0) NOT NULL,
	ttr_desc nvarchar(255),
	CONSTRAINT PK_TIPO_TRANSMISION PRIMARY KEY NONCLUSTERED (ttr_codigo)
)
GO
-----------------------------------TIPO_CAJA--------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[TIPO_CAJA](
	tca_codigo decimal(18,0) NOT NULL,
	tca_desc nvarchar(255),
	CONSTRAINT PK_TIPO_CAJA PRIMARY KEY NONCLUSTERED (tca_codigo)
)
GO
-----------------------------------TIPO_MOTOR--------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[TIPO_MOTOR](
	tmo_codigo decimal(18,0) NOT NULL,
	CONSTRAINT PK_TIPO_MOTOR PRIMARY KEY NONCLUSTERED (tmo_codigo)
)
GO
-----------------------------------TIPO_AUTO----------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[TIPO_AUTO](
	tau_codigo decimal(18,0) NOT NULL,
	tau_desc nvarchar (255),
	CONSTRAINT PK_TIPO_AUTO PRIMARY KEY NONCLUSTERED (tau_codigo)
)
GO
-----------------------------------MODELO--------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[MODELO](
	mod_codigo decimal(18,0) NOT NULL,
	mod_nombre nvarchar(255),
	mod_potencia decimal(18,0),
	mod_ttr_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[TIPO_TRANSMISION](ttr_codigo),
	mod_tca_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[TIPO_CAJA](tca_codigo),
	mod_tmo_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[TIPO_MOTOR](tmo_codigo),
	mod_tau_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[TIPO_AUTO](tau_codigo), 
	CONSTRAINT PK_TIPO_MODELO PRIMARY KEY NONCLUSTERED (mod_codigo)
)
GO
-----------------------------------PRODUCTO-------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[PRODUCTO](
	prod_mod_codigo decimal(18,0) NOT NULL,
	prod_desc nvarchar(255)NOT NULL, 
	CONSTRAINT FK_PRODUCTO FOREIGN KEY (prod_mod_codigo) REFERENCES [LAS_IMPOSTORAS].[MODELO](mod_codigo),
	CONSTRAINT PK_PRODUCTO PRIMARY KEY NONCLUSTERED (prod_mod_codigo,prod_desc), 
) 
GO

-----------------------------------AUTOMOVIL------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[AUTOMOVIL](
	aut_id decimal(18,0) IDENTITY(1,1) NOT NULL,
	aut_patente nvarchar(50),
	aut_nro_chasis nvarchar(50),
	aut_nro_motor nvarchar(50),
	aut_fecha_alta datetime2(3),
	aut_cant_kms decimal(18,0),
	aut_mod_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[MODELO](mod_codigo),
	aut_prod_mod decimal(18,0),
	aut_prod_desc nvarchar(255),
	CONSTRAINT PK_AUTOMOVIL PRIMARY KEY NONCLUSTERED (aut_id),
	CONSTRAINT FK_AUTOMOVIL FOREIGN KEY (aut_prod_mod,aut_prod_desc) REFERENCES [LAS_IMPOSTORAS].[PRODUCTO](prod_mod_codigo,prod_desc)
)
GO
-----------------------------------FABRICANTE------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[FABRICANTE](
	fab_id decimal(18,0) IDENTITY(1,1) NOT NULL,
	fab_desc nvarchar(255),
	CONSTRAINT PK_FABRICANTE PRIMARY KEY NONCLUSTERED (fab_id)
)
GO
-----------------------------------AUTO_PARTE-------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[AUTO_PARTE](
	aup_codigo decimal(18,0) NOT NULL,
	aup_desc nvarchar(255),
	aup_rubro nvarchar(255),
	aup_fab_id decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[FABRICANTE](fab_id),
	aup_mod_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[MODELO](mod_codigo),
	aup_prod_mod decimal(18,0),
	aup_prod_desc nvarchar (255),
	CONSTRAINT PK_AUTO_PARTE PRIMARY KEY NONCLUSTERED (aup_codigo),
	CONSTRAINT FK_AUTO_PARTE FOREIGN KEY (aup_prod_mod,aup_prod_desc) REFERENCES [LAS_IMPOSTORAS].[PRODUCTO](prod_mod_codigo,prod_desc)
)
GO
-----------------------------------STOCK------------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[STOCK](
	stock_cantidad decimal(18,0),
	stock_prod_desc nvarchar(255)NOT NULL,
	stock_prod_mod decimal(18,0) NOT NULL,
	stock_suc_id int FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[SUCURSAL](suc_id) NOT NULL,
	CONSTRAINT FK_STOCK FOREIGN KEY (stock_prod_mod,stock_prod_desc) REFERENCES [LAS_IMPOSTORAS].[PRODUCTO](prod_mod_codigo,prod_desc),
	CONSTRAINT PK_STOCK PRIMARY KEY NONCLUSTERED (stock_suc_id,stock_prod_mod,stock_prod_desc) 
)
GO
-----------------------------------ITEM_FACTURA------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[ITEM_FACTURA](
	itmf_nro decimal(18,0) IDENTITY(1,1) NOT NULL,
	itmf_precio_facturado decimal(18,2),
	itmf_cantidad_facturada decimal(18,0),
	itmf_fac_nro decimal(18,0) NOT NULL,
	itmf_fac_suc_id int NOT NULL,
	itmf_aut_id decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[AUTOMOVIL](aut_id),
	itmf_aup_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[AUTO_PARTE](aup_codigo),
	CONSTRAINT FK_ITEM_FACTURA FOREIGN KEY (itmf_fac_nro,itmf_fac_suc_id) REFERENCES [LAS_IMPOSTORAS].[FACTURA](fac_nro,fac_suc_id),
	CONSTRAINT PK_ITEM_FACTURA PRIMARY KEY NONCLUSTERED (itmf_nro,itmf_fac_nro,itmf_fac_suc_id)
)
GO
-----------------------------------COMPRA-------------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[COMPRA](
	comp_nro decimal(18,0) NOT NULL,
	comp_total decimal(18,0),
	comp_fecha datetime2(3),
	comp_suc_id int FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[SUCURSAL](suc_id) NOT NULL,
	CONSTRAINT PK_COMPRA PRIMARY KEY NONCLUSTERED(comp_nro,comp_suc_id) 
)
GO
-----------------------------------ITEM_COMPRA---------------------------------------------------------------
CREATE TABLE [LAS_IMPOSTORAS].[ITEM_COMPRA](
	itmc_nro decimal(18,0) IDENTITY(1,1) NOT NULL,
	itmc_precio_comprado decimal(18,2),
	itmc_cantidad_comprada decimal(18,0),
	itmc_comp_nro decimal(18,0) NOT NULL,
	itmc_comp_suc_id int NOT NULL,
	itmc_aut_id decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[AUTOMOVIL](aut_id),
	itmc_aup_codigo decimal(18,0) FOREIGN KEY REFERENCES [LAS_IMPOSTORAS].[AUTO_PARTE](aup_codigo),
	CONSTRAINT FK_ITEM_COMPRA FOREIGN KEY (itmc_comp_nro,itmc_comp_suc_id) REFERENCES [LAS_IMPOSTORAS].[COMPRA](comp_nro,comp_suc_id),
	CONSTRAINT PK_ITEM_COMPRA PRIMARY KEY NONCLUSTERED (itmc_nro,itmc_comp_nro,itmc_comp_suc_id),
)
GO
----------------------------------CREACIÓN DE TRIGGERS---------------------------------------------------
IF OBJECT_ID('[LAS_IMPOSTORAS].TR_EFECTUAR_VENTA') IS NOT NULL DROP TRIGGER [LAS_IMPOSTORAS].TR_EFECTUAR_VENTA; 
GO
CREATE TRIGGER [LAS_IMPOSTORAS].TR_EFECTUAR_VENTA ON LAS_IMPOSTORAS.ITEM_FACTURA AFTER INSERT
AS
BEGIN
	DECLARE @AUTO DECIMAL(18,0)
	DECLARE @AUTO_PARTE DECIMAL(18,0)
	
	SELECT @AUTO= itmf_aut_id FROM inserted
	SELECT @AUTO_PARTE = itmf_aup_codigo FROM inserted

	IF @AUTO IN (SELECT aut_id FROM LAS_IMPOSTORAS.AUTOMOVIL) OR @AUTO_PARTE IN (SELECT aup_codigo FROM LAS_IMPOSTORAS.AUTO_PARTE)
	BEGIN
		
		IF @AUTO_PARTE IS NULL--ES UNA VENTA DE AUTO
		BEGIN 
			UPDATE LAS_IMPOSTORAS.STOCK
		
			SET stock_cantidad = stock_cantidad - I.itmf_cantidad_facturada
			FROM INSERTED I
			INNER JOIN LAS_IMPOSTORAS.AUTOMOVIL ON @AUTO = aut_id
			INNER JOIN LAS_IMPOSTORAS.STOCK ON aut_prod_mod = stock_prod_mod AND (SELECT SUCURSAL FROM AUTO_SUCURSAL_ORIGEN WHERE CODIGO_AUTO = I.itmf_aut_id) = stock_suc_id AND stock_prod_desc = 'AUTO'
		END
		ELSE
		BEGIN
			UPDATE LAS_IMPOSTORAS.STOCK
		
			SET stock_cantidad = stock_cantidad - I.itmf_cantidad_facturada
			FROM INSERTED I
			INNER JOIN LAS_IMPOSTORAS.AUTO_PARTE ON @AUTO_PARTE = aup_codigo
			INNER JOIN LAS_IMPOSTORAS.STOCK ON aup_prod_mod = stock_prod_mod AND I.itmf_fac_suc_id = stock_suc_id AND stock_prod_desc = 'AUTO_PARTE'
		END

		UPDATE [LAS_IMPOSTORAS].[FACTURA]
		SET FAC_TOTAL = ISNULL(FAC_TOTAL,0)+I.ITMF_PRECIO_FACTURADO * I.ITMF_CANTIDAD_FACTURADA 
		FROM inserted I 
		INNER JOIN [LAS_IMPOSTORAS].[FACTURA] ON FAC_NRO = I.ITMF_FAC_NRO AND FAC_SUC_ID = I.ITMF_FAC_SUC_ID
		
	END
	ELSE ROLLBACK TRANSACTION --NO EXISTE EL PRODUCTO

END
GO

CREATE TRIGGER [LAS_IMPOSTORAS].TR_REGISTRAR_COMPRA ON LAS_IMPOSTORAS.ITEM_COMPRA AFTER INSERT
AS
BEGIN
	DECLARE @AUTO DECIMAL(18,0)
	DECLARE @AUTO_PARTE DECIMAL(18,0)
	
	SELECT @AUTO= itmc_aut_id FROM inserted
	SELECT @AUTO_PARTE = itmc_aup_codigo FROM inserted
		
	IF @AUTO_PARTE IS NULL--ES UNA VENTA DE AUTO
	BEGIN 
		UPDATE LAS_IMPOSTORAS.STOCK
		
		SET stock_cantidad = stock_cantidad + I.itmc_cantidad_comprada
		FROM INSERTED I
		INNER JOIN LAS_IMPOSTORAS.AUTOMOVIL ON @AUTO = aut_id
		INNER JOIN LAS_IMPOSTORAS.STOCK ON aut_prod_mod = stock_prod_mod AND itmc_comp_suc_id = stock_suc_id AND stock_prod_desc = 'AUTO'
			
	END
	ELSE
	BEGIN
		UPDATE LAS_IMPOSTORAS.STOCK
		
		SET stock_cantidad = stock_cantidad - I.itmc_cantidad_comprada
		FROM INSERTED I
		INNER JOIN LAS_IMPOSTORAS.AUTO_PARTE ON @AUTO_PARTE = aup_codigo
		INNER JOIN LAS_IMPOSTORAS.STOCK ON aup_prod_mod = stock_prod_mod AND I.itmc_comp_suc_id = stock_suc_id AND stock_prod_desc = 'AUTO_PARTE'
	END

	UPDATE [LAS_IMPOSTORAS].[COMPRA]
	SET comp_total = ISNULL(comp_total,0)+I.itmc_precio_comprado * I.itmc_cantidad_comprada 
	FROM inserted I 
	INNER JOIN [LAS_IMPOSTORAS].[COMPRA] ON COMP_NRO = I.itmc_comp_nro AND comp_suc_id = I.itmc_comp_suc_id

END
GO
----------------------------------CREACIÓN DE VISTAS----------------------------------------------------
CREATE VIEW [LAS_IMPOSTORAS].STOCK_AUTO_SUCURSAL  AS
SELECT suc.suc_id,stock_prod_desc,stock_prod_mod,stck.stock_cantidad
FROM [LAS_IMPOSTORAS].STOCK stck
JOIN [LAS_IMPOSTORAS].[SUCURSAL] suc ON suc.suc_id = stck.stock_suc_id
WHERE stock_prod_desc = 'auto';
GO

CREATE VIEW [LAS_IMPOSTORAS].STOCK_AUTO_PARTE_SUCURSAL AS
SELECT suc.suc_id,stock_prod_desc,stock_prod_mod,stck.stock_cantidad
FROM [LAS_IMPOSTORAS].STOCK stck
JOIN [LAS_IMPOSTORAS].[SUCURSAL] suc ON suc.suc_id = stck.stock_suc_id
WHERE stock_prod_desc = 'auto_parte';
GO
CREATE VIEW [LAS_IMPOSTORAS].AUTO_SUCURSAL_ORIGEN AS
select itmc_comp_suc_id SUCURSAL,itmc_aut_id CODIGO_AUTO
from [LAS_IMPOSTORAS].ITEM_COMPRA
where itmc_aut_id is not null
GO
----------------------------------CREACIÓN DE INDICES----------------------------------------------------
CREATE NONCLUSTERED INDEX IDX_NOMBRE_FABRICANTE
on [LAS_IMPOSTORAS].[FABRICANTE] (fab_desc);

CREATE UNIQUE INDEX IDX_PATENTE ON [LAS_IMPOSTORAS].[AUTOMOVIL] (aut_patente ASC);
GO

-----------------------------------MIGRACIÓN DE DATOS----------------------------------------------------------
----------------------------------- MIGRACIÓN DE CLIENTES------------------------------------------------------

INSERT INTO [LAS_IMPOSTORAS].[CLIENTE](
				clie_apellido,
				clie_direccion,
				clie_dni, 
				clie_fecha_nac,
				clie_mail,
				clie_nombre
)
SELECT DISTINCT	m.[CLIENTE_APELLIDO],
				m.[CLIENTE_DIRECCION],
				m.[CLIENTE_DNI],
				m.[CLIENTE_FECHA_NAC],
				m.[CLIENTE_MAIL],
				m.[CLIENTE_NOMBRE]
FROM GD2C2020.gd_esquema.Maestra m 
where m.[CLIENTE_DNI] is not null	

-----------------------------------MIGRACIÓN DE SUCURSAL----------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[SUCURSAL](
			suc_ciudad,
			suc_direccion,
			suc_mail,
			suc_telefono
)
SELECT DISTINCT	m.[SUCURSAL_CIUDAD],
				m.[SUCURSAL_DIRECCION],
				m.[SUCURSAL_MAIL],
				m.[SUCURSAL_TELEFONO]

FROM GD2C2020.gd_esquema.Maestra m 
where m.[SUCURSAL_CIUDAD] is not null
-----------------------------------MIGRACIÓN TIPO_MOTOR----------------------------------------------- 

INSERT INTO [LAS_IMPOSTORAS].[TIPO_MOTOR](tmo_codigo)
SELECT DISTINCT TIPO_MOTOR_CODIGO 
FROM GD2C2020.gd_esquema.Maestra m
WHERE m.TIPO_MOTOR_CODIGO IS NOT NULL
----------------------------------MIGRACIÓN TIPO_CAJA--------------------------------------------------

INSERT INTO [LAS_IMPOSTORAS].[TIPO_CAJA](tca_codigo,tca_desc)
SELECT DISTINCT TIPO_CAJA_CODIGO, TIPO_CAJA_DESC
FROM GD2C2020.gd_esquema.Maestra m
WHERE m.TIPO_CAJA_CODIGO IS NOT NULL
----------------------------------MIGRACIÓN TIPO_TRANSMISION-------------------------------------------

INSERT INTO [LAS_IMPOSTORAS].[TIPO_TRANSMISION](ttr_codigo, ttr_desc)
SELECT DISTINCT TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC
FROM GD2C2020.gd_esquema.Maestra m
WHERE m.TIPO_TRANSMISION_CODIGO IS NOT NULL
----------------------------------MIGRACIÓN TIPO_AUTO---------------------------------------------------
 
INSERT INTO [LAS_IMPOSTORAS].[TIPO_AUTO](tau_codigo,tau_desc)
SELECT DISTINCT TIPO_AUTO_CODIGO, TIPO_AUTO_DESC
FROM GD2C2020.gd_esquema.Maestra m
WHERE m.TIPO_AUTO_CODIGO IS NOT NULL
---------------------------------- MIGRACIÓN MODELO-----------------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[MODELO](
			mod_codigo,
			mod_nombre,
			mod_potencia,
			mod_ttr_codigo,
			mod_tau_codigo,
			mod_tca_codigo,
			mod_tmo_codigo
)
SELECT DISTINCT m.[MODELO_CODIGO],
				m.[MODELO_NOMBRE],
				m.[MODELO_POTENCIA],
				m.[TIPO_TRANSMISION_CODIGO],
				m.[TIPO_AUTO_CODIGO],
				m.[TIPO_CAJA_CODIGO],
				m.[TIPO_MOTOR_CODIGO]
FROM GD2C2020.gd_esquema.Maestra m
WHERE m.TIPO_TRANSMISION_CODIGO IS NOT NULL and m.[TIPO_AUTO_CODIGO] is not null and m.[TIPO_CAJA_CODIGO] is not null and m.[TIPO_MOTOR_CODIGO] is not null
----------------------------------MIGRACIÓN PRODUCTO AUTO---------------------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[PRODUCTO](
	prod_mod_codigo,
	prod_desc
)
SELECT DISTINCT m.MODELO_CODIGO,
	   'auto'
FROM GD2C2020.gd_esquema.Maestra m
where m.AUTO_PATENTE is not null

----------------------------------MIGRACIÓN DE AUTOMOVILES-----------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[AUTOMOVIL](
			aut_cant_kms,
			aut_fecha_alta,
			aut_nro_chasis,
			aut_nro_motor,
			aut_patente,
			aut_mod_codigo,
			aut_prod_mod,
			aut_prod_desc
)
SELECT DISTINCT m.[AUTO_CANT_KMS],
				m.[AUTO_FECHA_ALTA],
				m.[AUTO_NRO_CHASIS],
				m.[AUTO_NRO_MOTOR],
				m.[AUTO_PATENTE],
				m.[MODELO_CODIGO],
				prod.prod_mod_codigo,
				prod.prod_desc
FROM GD2C2020.gd_esquema.Maestra m 
JOIN [LAS_IMPOSTORAS].[PRODUCTO] prod ON prod_mod_codigo = m.MODELO_CODIGO and prod.prod_desc = 'auto'
WHERE m.AUTO_PATENTE is not null
--------------------------------MIGRACIÓN FABRICANTE--------------------------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[FABRICANTE](
		fab_desc
)
SELECT DISTINCT m.[FABRICANTE_NOMBRE]
FROM GD2C2020.gd_esquema.Maestra m
WHERE m.[FABRICANTE_NOMBRE] IS NOT NULL
----------------------------------MIGRACIÓN PRODUCTO AUTOPARTE----------------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[PRODUCTO](
	prod_mod_codigo,
	prod_desc
)
SELECT DISTINCT m.MODELO_CODIGO,
	   'auto_parte'
FROM GD2C2020.gd_esquema.Maestra m
where m.AUTO_PARTE_CODIGO is not null
---------------------------------- MIGRACIÓN DE AUTOPARTE---------------------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[AUTO_PARTE](
				aup_codigo,
				aup_desc,
				aup_fab_id,
				aup_mod_codigo,
				aup_prod_desc,
				aup_prod_mod
				
)
SELECT DISTINCT m.[AUTO_PARTE_CODIGO],
				m.[AUTO_PARTE_DESCRIPCION],
				fab.fab_id,
				m.[MODELO_CODIGO],
				prod.prod_desc,
				prod.prod_mod_codigo
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[PRODUCTO] prod ON prod_mod_codigo = m.MODELO_CODIGO and prod.prod_desc = 'auto_parte'
JOIN [LAS_IMPOSTORAS].[FABRICANTE] fab ON fab.fab_desc = m.FABRICANTE_NOMBRE 
WHERE m.[AUTO_PARTE_CODIGO] IS NOT NULL
-----------------------------------MIGRACIÓN DE FACTURA---------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[FACTURA](
            fac_fecha,
            fac_nro,
            fac_suc_id
)
SELECT DISTINCT m.[FACTURA_FECHA],
                m.[FACTURA_NRO],
				suc.suc_id
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[SUCURSAL] suc 
on suc.suc_ciudad = m.[FAC_SUCURSAL_CIUDAD] and suc.suc_direccion = m.[FAC_SUCURSAL_DIRECCION]
and suc.suc_mail = m.[FAC_SUCURSAL_MAIL] and suc.suc_telefono = m.[FAC_SUCURSAL_TELEFONO]
WHERE m.[FACTURA_NRO] is not null
---------------------------------MIGRACIÓN DE COMPRA--------------------------------------------
INSERT INTO [LAS_IMPOSTORAS].[COMPRA](
			comp_nro,
			comp_fecha,
			comp_suc_id
)
SELECT DISTINCT m.[COMPRA_NRO],
                m.[COMPRA_FECHA],
				suc.suc_id
FROM GD2C2020.gd_esquema.Maestra m
 JOIN [LAS_IMPOSTORAS].[SUCURSAL] suc 
on suc.suc_ciudad = m.[SUCURSAL_CIUDAD] and suc.suc_direccion = m.[SUCURSAL_DIRECCION]
and suc.suc_mail = m.[SUCURSAL_MAIL] and suc.suc_telefono = m.[SUCURSAL_TELEFONO]
WHERE m.[COMPRA_NRO] is not null

-----------------------------------MIGRACIÓN DE ITEM COMPRA----------------------------------------------
INSERT [LAS_IMPOSTORAS].[ITEM_COMPRA](
		itmc_comp_nro,
		itmc_cantidad_comprada,
		itmc_precio_comprado,
		itmc_comp_suc_id,
		itmc_aup_codigo
)
SELECT  DISTINCT comp_nro,ISNULL(COMPRA_CANT,1),ISNULL(COMPRA_PRECIO,0),suc_id,AUTO_PARTE_CODIGO
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[COMPRA] on comp_nro = COMPRA_NRO and comp_fecha = COMPRA_FECHA
JOIN [LAS_IMPOSTORAS].[SUCURSAL] ON suc_ciudad = SUCURSAL_CIUDAD and
								    suc_direccion = SUCURSAL_DIRECCION AND
									suc_mail = SUCURSAL_MAIL AND
									suc_telefono = SUCURSAL_TELEFONO
WHERE COMPRA_NRO is not null and COMPRA_CANT is not null and AUTO_PARTE_CODIGO is not null

INSERT [LAS_IMPOSTORAS].[ITEM_COMPRA](
		itmc_comp_nro,
		itmc_cantidad_comprada,
		itmc_precio_comprado,
		itmc_comp_suc_id,
		itmc_aut_id
)
SELECT  DISTINCT comp_nro,ISNULL(COMPRA_CANT,1),ISNULL(COMPRA_PRECIO,0),suc_id,aut_id
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[COMPRA] on comp_nro = COMPRA_NRO and comp_fecha = COMPRA_FECHA
JOIN [LAS_IMPOSTORAS].[SUCURSAL] ON suc_ciudad = SUCURSAL_CIUDAD and
								    suc_direccion = SUCURSAL_DIRECCION AND
									suc_mail = SUCURSAL_MAIL AND
									suc_telefono = SUCURSAL_TELEFONO
JOIN [LAS_IMPOSTORAS].[AUTOMOVIL] ON aut_patente = AUTO_PATENTE
WHERE COMPRA_NRO is not null and AUTO_PATENTE is not null

-----------------------------------MIGRACIÓN DE ITEM FACTURA----------------------------------------------
INSERT [LAS_IMPOSTORAS].[ITEM_FACTURA](
		itmf_fac_nro,
		itmf_fac_suc_id,
		itmf_aut_id,
		itmf_cantidad_facturada,
		itmf_precio_facturado
)
SELECT  DISTINCT fac_nro,suc_id,aut_id,ISNULL(CANT_FACTURADA,1),ISNULL(PRECIO_FACTURADO,0)
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[FACTURA] on fac_nro = FACTURA_NRO and fac_fecha = FACTURA_FECHA
JOIN [LAS_IMPOSTORAS].[SUCURSAL] ON suc_ciudad = FAC_SUCURSAL_CIUDAD  and
								    suc_direccion = FAC_SUCURSAL_DIRECCION AND
									suc_mail = FAC_SUCURSAL_MAIL AND
									suc_telefono = FAC_SUCURSAL_TELEFONO
JOIN [LAS_IMPOSTORAS].[AUTOMOVIL] ON aut_patente = AUTO_PATENTE
WHERE FACTURA_NRO is not null and AUTO_PATENTE is not null

INSERT [LAS_IMPOSTORAS].[ITEM_FACTURA](
		itmf_fac_nro,
		itmf_fac_suc_id,
		itmf_aup_codigo,
		itmf_cantidad_facturada,
		itmf_precio_facturado
)
SELECT  DISTINCT fac_nro,suc_id,AUTO_PARTE_CODIGO,ISNULL(CANT_FACTURADA,1),ISNULL(PRECIO_FACTURADO,0)
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[FACTURA] on fac_nro = FACTURA_NRO and fac_fecha = FACTURA_FECHA
JOIN [LAS_IMPOSTORAS].[SUCURSAL] ON suc_ciudad = FAC_SUCURSAL_CIUDAD  and
								    suc_direccion = FAC_SUCURSAL_DIRECCION AND
									suc_mail = FAC_SUCURSAL_MAIL AND
									suc_telefono = FAC_SUCURSAL_TELEFONO
WHERE FACTURA_NRO is not null and AUTO_PARTE_CODIGO is not null

---------------------------------MIGRACIÓN DE STOCK--------------------------------------------
INSERT [LAS_IMPOSTORAS].[STOCK](
		stock_prod_mod,
		stock_prod_desc,
		stock_cantidad,
		stock_suc_id
)

SELECT prod_mod_codigo,prod_desc,COUNT(prod_mod_codigo) as cantidad,suc_id
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[SUCURSAL] on suc_ciudad= m.SUCURSAL_CIUDAD and suc_direccion = m.SUCURSAL_DIRECCION
and suc_mail = m.SUCURSAL_MAIL and suc_telefono = m.SUCURSAL_TELEFONO
JOIN [LAS_IMPOSTORAS].[PRODUCTO] ON prod_mod_codigo = m.MODELO_CODIGO and prod_desc = 'auto'
where m.MODELO_CODIGO is not null and m.SUCURSAL_CIUDAD is not null and m.SUCURSAL_DIRECCION is not null
GROUP BY m.SUCURSAL_CIUDAD,m.SUCURSAL_DIRECCION,m.MODELO_CODIGO,prod_mod_codigo,suc_id,prod_desc

INSERT [LAS_IMPOSTORAS].[STOCK](
		stock_prod_mod,
		stock_prod_desc,
		stock_cantidad,
		stock_suc_id
)

SELECT prod_mod_codigo,prod_desc,COUNT(prod_mod_codigo) as cantidad,suc_id
FROM GD2C2020.gd_esquema.Maestra m
JOIN [LAS_IMPOSTORAS].[SUCURSAL] on suc_ciudad= m.SUCURSAL_CIUDAD and suc_direccion = m.SUCURSAL_DIRECCION
and suc_mail = m.SUCURSAL_MAIL and suc_telefono = m.SUCURSAL_TELEFONO
JOIN [LAS_IMPOSTORAS].[PRODUCTO] ON prod_mod_codigo = m.MODELO_CODIGO and prod_desc = 'auto_parte'
where m.MODELO_CODIGO is not null and m.SUCURSAL_CIUDAD is not null and m.SUCURSAL_DIRECCION is not null
GROUP BY m.SUCURSAL_CIUDAD,m.SUCURSAL_DIRECCION,m.MODELO_CODIGO,prod_mod_codigo,suc_id,prod_desc
GO 

