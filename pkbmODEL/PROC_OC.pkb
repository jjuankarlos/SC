CREATE OR REPLACE PACKAGE BODY COMP.PROC_OC IS
-- Número de versión del package
vVerPkg VARCHAR2(10) := '6.6.1';
--
/* INI:KNTDocVer *********************************************************************
 REVISIONES (en orden inverso):
 Vers        Fecha       Autor        Lista de reportes de falla (ej: 123, 4678, 45.3)
 ----------  ----------  -----------  ------------------------------------------------
 6.6.1       20/12/2007  CPRINS       010781
 Se modificó el proceso CREA_HEADER_OC  para colocar el simbolo de la moneda en vez del
 nombre de la moneda en el campo MONEDA de la OC.
 IF - 25/01/2008
 Se ajusto el PROCEDURE ANULA_OC para no considerar cambios con Sts "ACP" (Aceptados)
 JR - 04/01/2008
 Se Ajustó en los procedimientos y funciones que aparece PROC_INSTALACION.CODMONEDAINST 
 el trunc(sysdate).
 VN - 11/01/2008 Ajustes de tamaño en la variable de decripcion de OC en procedimiento 
 ELIMINAR_OC. ANULA_CO
 -------------------------------------------------------------------------------------
 6.6.0       12/12/2007  IFLORES      101139
 JRONDON: Se agregó en los procedimientos CREA_HEADER_OC, ANULA_OC en el insert into de
 ORDEN_COMPRA y DOCUMENTOS_ORIGEN el campo de CodMoneda.
 - Se creó el cursor  C_ORDCOMP. (CPRINS).
 -------------------------------------------------------------------------------------
 6.5.0       30/07/2007  IFLORES      101098
 Creación de la rutina VERIF_DETSRENGOC.
 Ajuste de la rutina "APRUEBA_OC"  para llamar a la rutina que realiza verificaciónes
 a los detalles de los renglones de la O/C. CPRINS.
 Ajuste de rutina CREA_RENGOC para registrar indicador de detalle de renglon e 
 informacion de impuesto.
 Ajuste de rutina CALCULO_MTO_OC para no calcular el monto de impuesto si no tomarlo
 directamente de la TABLA.
 -------------------------------------------------------------------------------------
 6.4.0       30/07/2007  IFLORES      101098
 Ajuste de la rutina "CREA_RENGOC"  para que inserte también los detalles del renglón
 a la O/C.
 -------------------------------------------------------------------------------------
 6.3.4       03/01/2007  IFLORES      008642
 Ajuste de la rutina "CALCULO_MTO_OC" por problema de redondeo, ahora se suman
 los ROUND.
 -------------------------------------------------------------------------------------
 6.3.3      16/05/2006  IFLORES      007688
 Se ajusto el proceso ANULA_OC  para al generar el documento se verifica si el documento
 administrativo que inicio el proceso fue transferido a otro ejercicio presupuestario
 se debe tomar como IdDoc de referencia la transferencia.
 -------------------------------------------------------------------------------------
 6.3.2       27/03/2006  IFLORES      007450
 Se ajustaron los procesos LIMINA_OC y ANULA_OC para actualizar el estatus de la orden.
 ---------------------------------------------------------------------------------------
 6.3.1       04/10/2005  ASOARES      006318
 Se modificó procedimientos ELIMINA_OC y ANULA_OC para actualizar fecha de anulación con
 fecha suministrada y no la del sistema.
 ---------------------------------------------------------------------------------------
 6.3.0       30/08/2005  IFLORES      005844
 Ajuste de procedimientos ELIMINA_OC y ANULA_OC para actualizar fecha y usuario que anula
 la orden.
 ---------------------------------------------------------------------------------------
 6.2.0       10/04/2005  RARRIETA      100584
 Se modificó el procedimiento ASIGNAR_OC para manejar la numeración automática o manual
 de las ordenes de compra y servicio.
 ---------------------------------------------------------------------------------------
 6.1.6       29/12/2004  VNEGRIN      100516
 Se modifico la declaración de la variable vNumBenef GOBSTD.NumBenef utilizada en el procedimiento
 ELIMINAR_OC, por BENEFICIARIOS.NumBenef%TYPE
 Se modifico la variable vNumBenef GOBSTD.NumBenef en el procedimiento ANULA_OC por
 DOCUMENTOS_ORIGEN.NumBenef%TYPE
 ---------------------------------------------------------------------------------------
 6.1.5       02/12/2004  M.Veloso     100509
 Se quitó la recerencia a COMP. en CALCULO_MTO_OC para poder trabajar multi-instalación.
 -------------------------------------------------------------------------------------
 6.1.4       27/10/2004  IFLORES      005204
 Se ajustó el procedure ACTUALIZA_DOCORIG para actualizar tambien el tipo de documento,
 para contemplar posibles cambios de tipos de compras a ordenes rechazadas.
 -------------------------------------------------------------------------------------
 6.1.3       25/06/2004  IFLORES      004866
 Se modificó PROCEDURE CALCULO_MTO_OC para utilizar nuevo manejo para el calculo del
 impuesto y el monto total de la orden.
 -------------------------------------------------------------------------------------
 6.1.2       28/04/2004  IFLORES      004575
 Se ajustó el procedimiento CALCULO_MTO_OC y ANULA_OC para redondear (ROUND) los calculos
 a dos deciamles por problema de redondeo.
 -------------------------------------------------------------------------------------
 6.1.1       25/02/2004  IF
 Se ajusto la function APRUEBA_OC para validar si la orden contiene renglones registrados
 -------------------------------------------------------------------------------------
 6.1.0       18/02/2004  M.Veloso     100335
 Ajuste por cambio del nombre de PROC_BENEF a PROC_BENEF_COMP
 -------------------------------------------------------------------------------------
 6.0.2       28/10/2003  IF           100241
 Se adapto la FUNCTION APRUEBA_OC para enviar nuevamente la orden para aprobación
 siempre y cuando no tenga documento emitido o tenga documento emitido y la orden este
 rechazada "RCH".
 -------------------------------------------------------------------------------------
 6.0.1       15/09/2003  RRR
 Se añadió la verificación de vigencia del beneficiario asociado a un proveedor en el
 procedimiento CREA_HEADER_OC.
 -------------------------------------------------------------------------------------
 6.0.0       01/07/2003  IF
 Se creo el procedure REVERSA_RECEP_OC con la finalidad de manejar el reverso de una
 recepción de una determinada orden de compra en el modulo de almacén.
 -------------------------------------------------------------------------------------
 5.0.4       12/02/2003  IF
 Se mejoro el calculo la obteneter la cantidad pendiente de la OC para considerar en el
 renglon cantidad recibida en el procedimiento ACT_CANT_RENGOC.
 -----------------------------------------------------------------------------------
 5.0.3       05/12/2002  MR
 Se modifica la declaración de la variable vCantPendOC en el procedimiento
 ACT_CANT_RENGOC.
 -----------------------------------------------------------------------------------
 5.0.2       30/01/2002  IF
 Incorporó a los mensajes de EXCEPTION la instrucción SQLERRM para detallar el error
 que se presente en el procedimiento CREA_HEADER_OC.
 -----------------------------------------------------------------------------------
 5.0.1       16/10/2001  IF
 Modificaciones del procedimiento ANULA_OC para retornar la IdDoc Generado.
 -----------------------------------------------------------------------------------
 5.0.0       13/03/2001  BM
 Modificaciones para manejar excepciones al actualizar los renglones de OC cuando son
 anulados.
 -----------------------------------------------------------------------------------
 4.0.0       06/03/2001  BM
 Modificaciones para incluir el impuesto en el calculo del monto del doc de anulación
 de OC.
 -----------------------------------------------------------------------------------
 3.0.0       22/02/2001  BM
 Modificaciones en cálculo de cantidades pendientes cuando se elimina un renglón de la
 OC.
 -----------------------------------------------------------------------------------
 2.0.0       14/02/2001  BM
 Modificaciones en el proceso de Anulación de OC.
 -----------------------------------------------------------------------------------
 1.0.0       14/02/2001  M.Veloso
 Inicio de la numeración de versiones de packages
 -----------------------------------------------------------------------------------
** FIN:KNTDocVer *********************************************************************/
--
-- RUTINAS DEL PACKAGE
-- *******************

 /************************************************************************/
/* C_ORDCOMP: Cursor que devuelve la información de una Orden de Compra. */
/*************************************************************************/
 CURSOR C_ORDCOMP(cIdOrdCmp ORDEN_COMPRA.IDORDCMP%TYPE) IS
 SELECT * 
 FROM ORDEN_COMPRA 
 WHERE IdOrdCmp = cIdOrdCmp
 ;
 
/*********************************************************/
/* VERPKG: Retorna el numero de versión de este package. */
/*********************************************************/
FUNCTION VERPKG RETURN VARCHAR2
IS
BEGIN
  RETURN vVerPkg;
END VERPKG;
/*********************************************************************/
/*     Se crea el header de la Orden de Compra                       */
/*********************************************************************/
PROCEDURE CREA_HEADER_OC(pNroSC    SOL_COMPRAS.NroSC%TYPE,
                         pNumBenef ORDEN_COMPRA.NumBenef%TYPE,
                            pIdOrdCmp ORDEN_COMPRA.IdOrdCmp%TYPE,
                         pNumCot   COTIZACIONES.NumCot%TYPE) IS
  vDescSC      SOL_COMPRAS.DESCSC%TYPE;
  vCCosto      GOBSTD.CCOSTO;
  vCodAccInt   GOBSTD.CODACCINT;
  vLetraId     GOBSTD.LETRAID;
  vNumId       GOBSTD.NumId;
  vIdSolSum    KNTSTD.Identificador;
  vIdDoc       KNTSTD.Identificador;
  vBenef       BENEFICIARIOS.NumBenef%TYPE;
BEGIN
  /* Se selecciona los campos necesarios en la solicitud de compra para  */
  /* la construccion de la orden de compra                               */
  BEGIN
    SELECT DescSC,CCosto,CodAccInt,IdSolSum,IdDoc
    INTO vDescSC,vCCosto,vCodAccInt,vIdSolSum,vIdDoc
    FROM SOL_COMPRAS
    WHERE NroSC = pNroSC;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001,'No existe la solicitud de Compra para procesar la O/C. '||SQLERRM);
  END;

/*
  -- 15/09/2003 - RRR - Comentado para añadir verificación antes de intentar generar la oc en generar_oc

  -- Se localiza el numero del beneficiario por proveedor
  BEGIN
    SELECT NumBenef,LetraId,NumId
    INTO vBenef,vLetraId,vNumId
    FROM FAB_PRO
    WHERE NumProv = pNumProv;
    IF vBenef IS NULL THEN
      vBenef := PROC_PPTO.BUSCA_BENEF(vLetraId,vNumId);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- El codigo del proveedor no existe
      RAISE_APPLICATION_ERROR(-20099,'El Proveedor no Existe como Beneficiario. '||SQLERRM);
  END;
*/

  BEGIN
  --JR 30/11/2007 Se Agregó el Campo de CodMoneda 
  INSERT INTO ORDEN_COMPRA
     (IdOrdCmp,DescOC,CCosto,CodAccInt,
      FecOc,Via,FecEntrega,LugarEntrega,
      FormaPago,MtoOCBs,Moneda,Tcambio,
      MtoOCOrig,StsOC,FecSts, IdSolSUm,
      Numbenef, NumCot, MtoOcTotal,CodMoneda)
  VALUES
     (pIdOrdCmp,vDescSC,vCCosto,vCodAccInt,
      SYSDATE,'TERRESTRE',SYSDATE,'ALMACEN GENERAL',
      'ORDEN DE PAGO DIRECTA',1,PROC_MONEDA.SIMBOLO(PROC_INSTALACION.CODMONEDAINST(trunc(SYSDATE))),1,
      1,'PEN',SYSDATE,vIdSolSum,
      pNumBenef,pNumCot, 1, PROC_INSTALACION.CODMONEDAINST(trunc(SYSDATE)));
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20100,'Problemas al generar la Orden de Compra. '||SQLERRM);
  END;
END;
/*********************************************************************/
/*     Se crea los renglones de la Orden de Compra                   */
/*********************************************************************/
PROCEDURE CREA_RENGOC(pIdOrdCmp      ORDEN_COMPRA.IdOrdCmp%TYPE,
                      pNumCot        COTIZACIONES.NumCot%TYPE,
                      pNroRengCot    RENG_COTIZACION.NRORENGCOT%TYPE,
                      pCantPorPedir  RENG_SOL_COMPRA.CANTPEND%TYPE) IS
                      
                     
vNroSC        GOBSTD.NroSc;
vTipoReng     GOBSTD.TipoReng;
vCodItem      GOBSTD.CodItem;
vCantAprob    RENG_COTIZACION.CantAprob%TYPE;
vCantConv     GOBSTD.CantConv;
vDescReng     RENG_SOL_COMPRA.DescReng%TYPE;
vDescAdiItem  RENG_SOL_COMPRA.DescAdiItem%TYPE;
vUndSol       GOBSTD.Unidad;
vUndCmp       GOBSTD.Unidad;
vPrecioUnit   KNTSTD.Monto   := 0;
vNroRengSC    GOBSTD.NroReng := 0;
vNreg         GOBSTD.NroReng := 0;
vIndDetReng   RENG_COTIZACION.IndDetReng%TYPE;
--BM 08/10/99  Modificaciones por IVA.
vCodCatg      RENG_OC.CodCatg%TYPE;
vPorcCat      RENG_OC.PORCCAT%TYPE := 0;
vMtoImpto     RENG_OC.MtoImpto%TYPE := 0;
vIndImptoMan  RENG_OC.IndImptoMan%TYPE;
vCodMonedaActual  COTIZACIONES.CODMONEDA%TYPE := PROC_INSTALACION.CODMONEDAINST(trunc(SYSDATE));

  -- Cursor que devuelve todos los renglones de detalle de un renglón de cotización
  CURSOR C_DETSRENGCOT(
                       cNumCot DETS_RENG_COTIZACION.NUMCOT%TYPE,
                       cNumRengCot DETS_RENG_COTIZACION.NUMRENGCOT%TYPE
                      )
  IS
    SELECT *
    FROM   DETS_RENG_COTIZACION
    WHERE  NUMCOT = cNUMCOT
    AND    NUMRENGCOT = cNumRengCot
    ;


BEGIN
  --
  -- IF 27/10/07: Se obtiene indicador de detalle de renglon e informacion de impuesto
  BEGIN
    -- Datos de la cotizacion para crear el renglon en O/C
    SELECT TipoReng,CantAprob,CodItem,DescRenglon,UndSol,
           UndCmp,PrecioUnit,CantConv,NroSC,DescAdiItem,NroRengSC,
           CodCatg, PorcCat, IndDetReng, MtoImpto, IndImptoMan
    INTO   vTipoReng,vCantAprob,vCodItem,vDescReng,vUndSol,
           vUndCmp,vPrecioUnit,vCantConv,vNroSC,vDescAdiItem,vNroRengSC,
           vCodCatg, vPorcCat, vIndDetReng, vMtoImpto, vIndImptoMan
    FROM RENG_COTIZACION
    WHERE NumCot     = pNumCot AND
          NroRengCot = pNroRengCot;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20002,'No existe el renglon de la cotizacion.');
  END;
  -- Para localizar el nro. del renglon que se va ha insertar
  SELECT NVL(MAX(NroReng),0) + 1
  INTO vNreg
  FROM RENG_OC
  WHERE IdOrdCmp = pIdOrdCmp;
  BEGIN
  IF vPorcCat IS NULL THEN
    vPorcCat := 0;
  END IF;
  
  -- CP 12/12/2007 Uso función que verifica si debe o no reconvertir los montos según las monedas.
  
    vPrecioUnit :=  PROC_RECONV_KNT.MONTO_REEXPRESADO(vPrecioUnit,PROC_COTIZACION.CODMONEDA(pNumCot), vCodMonedaActual ); 
    vMtoImpto   :=  PROC_RECONV_KNT.MONTO_REEXPRESADO(vMtoImpto,PROC_COTIZACION.CODMONEDA(pNumCot), vCodMonedaActual );
        
   --
  -- IF 27/10/07: Se guarda indicador de detalle denglon e informacion de impuesto
  INSERT INTO RENG_OC
     (IdOrdCmp,NRORENG,NROSC,NUMRENGSC,
      TIPORENG,CODITEM,DESCRENG,UNDSOL,
      CANTORIGOC,CANTACTOC,CANTPENOC,STSRENGOC,FECSTS,
      UNDCMP,CANTCONV,PRECIOUNIT,DescAdiItem,
      CodCatg, PorcCat, IndDetReng, MtoImpto, IndImptoMan)
  VALUES
     (pIdOrdCmp,vNreg,vNroSC,vNroRengSC,
      vTipoReng,vCodItem,vDescReng,vUndSol,
      vCantAprob,vCantAprob,vCantAprob,'PEN',SYSDATE,
      vUndCmp,vCantConv,vPrecioUnit,vDescAdiItem,
      vCodCatg, vPorcCat, vIndDetReng, vMtoImpto, vIndImptoMan);     
         
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20003,'Problemas al generar los renglones de ' ||
                               'Orden de Compra.'||SQLERRM);
                               
  END;
  BEGIN
    IF vIndDetReng =  'S' THEN 
      -- Si existen detalles en el renglón se colocan tambien en la O/C.
      FOR R_DETSRENGCOT IN C_DETSRENGCOT(pNumCot,
                                         pNroRengCot) LOOP
										 
	-- CP 12/12/2007 Uso función que verifica si debe o no reconvertir los montos según las monedas.
									 
          R_DETSRENGCOT.PrecioUnit    := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_DETSRENGCOT.PrecioUnit,PROC_COTIZACION.CODMONEDA(pNumCot), vCodMonedaActual ); 
		  R_DETSRENGCOT.MtoImpto      := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_DETSRENGCOT.MtoImpto,PROC_COTIZACION.CODMONEDA(pNumCot), vCodMonedaActual );  		
		  R_DETSRENGCOT.TotalDetalle  := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_DETSRENGCOT.TotalDetalle ,PROC_COTIZACION.CODMONEDA(pNumCot), vCodMonedaActual ); 							 
                        
       INSERT INTO DETS_RENG_OC
         (IDORDCMP, NUMRENGOC, NUMDETRENGOC,
          DESCDETRENGOC, PRECIOUNIT, CANTIDAD,
          CODCATG, PORCAT, MTOIMPTO,
          CODCTA, TOTALDETALLE)
       VALUES
         (pIdOrdCmp, vNreg, R_DETSRENGCOT.NumDetRengCot,
          R_DETSRENGCOT.DescDetRengCot, R_DETSRENGCOT.PrecioUnit, R_DETSRENGCOT.Cantidad,
          R_DETSRENGCOT.CodCatg, R_DETSRENGCOT.PorCat, R_DETSRENGCOT.MtoImpto,
          R_DETSRENGCOT.CodCta, R_DETSRENGCOT.TotalDetalle);
      END LOOP;                  
    END IF;
    
    
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20512,'Problemas al generar los renglones de detalles de ' ||
                               'Orden de Compra.'||SQLERRM);
  END;
 
END;
/*********************************************************************/
/*     Actualiza el monto a la Orden de Compra                       */
/*********************************************************************/
PROCEDURE ACT_MTO_OC(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE,
                     nTotBS     ORDEN_COMPRA.MTOOCORIG%TYPE,
                     pTotOCImp  ORDEN_COMPRA.MTOOCTOTAL%TYPE) IS
BEGIN
  UPDATE ORDEN_COMPRA
  SET MTOOCBS = nTOTBS,
      MTOOCORIG = nTOTBS,
      MtoOcTotal =  pTotOCImp
  WHERE IdOrdCmp = pIdOrdCmp;
END;
/*********************************************************************/
/*     Actualiza estatus a los renglones de la Orden de Compra       */
/*********************************************************************/
PROCEDURE ACT_STS_TODOS_RENGOC(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE,
                               pStsOC     ORDEN_COMPRA.StsOC%TYPE) IS
BEGIN
  UPDATE RENG_OC
  SET StsRengOC  = pStsOC
  WHERE IdOrdCmp = pIdOrdCmp;
  ACT_STS_OC(pIdOrdCmp);
END;
/*********************************************************************/
/*     Actualiza estatus a un renglon de la Orden de Compra          */
/*********************************************************************/
PROCEDURE ACT_STS_RENGOC(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE,
                         pRengOC    RENG_OC.NRORENG%TYPE,
                         pStsOC     ORDEN_COMPRA.StsOC%TYPE) IS
BEGIN
  UPDATE RENG_OC
  SET StsRengOC  = pStsOC
  WHERE IdOrdCmp = pIdOrdCmp AND
        NroReng  = pRengOC;
  ACT_STS_OC(pIdOrdCmp);
END;
/*********************************************************************/
/*     Actualiza la Cantidad Recibida y Pendiente del renglon de OC  */
/*********************************************************************/
PROCEDURE ACT_CANT_RENGOC(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE,
                          pRengOC    RENG_OC.NRORENG%TYPE,
                          pCantidad  RENG_OC.CANTORIGOC%TYPE) IS
  vSts        KNTSTD.Estatus;
  vCantPenOC  RENG_OC.CantPenOC%TYPE;
BEGIN
  BEGIN
    SELECT CantPenOC
    INTO vCantPenOC
    FROM RENG_OC
    WHERE IdOrdCmp = pIdOrdCmp  AND
          NroReng  = pRengOC;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20510,'Error: el renglon de la O/C invalido.');
  END;
  IF pCantidad <= vCantPenOC THEN
    IF pCantidad < vCantPenOC THEN
       vSts := 'PAR';
    ELSE
       vSts := 'CMP';
    END IF;
    UPDATE RENG_OC
    SET StsRengOC  =  vSts,
        CantPenOC  = (NVL(CantActOC,0) - NVL(CantRecOC,0)) - pCantidad,
        CantRecOC  = NVL(CantRecOC,0) + pCantidad
    WHERE IdOrdCmp = pIdOrdCmp AND
          NroReng  = pRengOC;
    ACT_STS_OC(pIdOrdCmp);
  ELSE
    RAISE_APPLICATION_ERROR(-20511,
      'Error: la cantidad recibida: ' ||  pCantidad || ' no puede ser mayor a la ' ||
      'cantidad pendiente: ' || vCantPenOC || '.');
  END IF;
END;
/****************************************************/
/*     Actualiza estatus de la Orden de Compra      */
/****************************************************/
PROCEDURE ACT_STS_OC(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE) IS
  nReg  NUMBER(10) := 0;
  nRch  NUMBER(10) := 0;
  nAcp  NUMBER(10) := 0;
  nPro  NUMBER(10) := 0;
  nRev  NUMBER(10) := 0;
  nAnu  NUMBER(10) := 0;
  nPen  NUMBER(10) := 0;
  nPar  NUMBER(10) := 0;
  nCmp  NUMBER(10) := 0;
  nEli  NUMBER(10) := 0;
  vSts  KNTSTD.Estatus;
  CURSOR RENGOC IS
    SELECT StsRengOC,COUNT(*) nCant
    FROM RENG_OC
    WHERE IdOrdCmp = pIdOrdCmp
    GROUP BY StsRengOC;
BEGIN
  SELECT COUNT(*)INTO nReg
  FROM RENG_OC
  WHERE IdOrdCmp = pIdOrdCmp;
  FOR R_OC IN RENGOC LOOP
    IF R_OC.StsRengOC = 'PEN' THEN
      vSts := 'PEN';
      EXIT;
    ELSIF R_OC.StsRengOC = 'REV' THEN
      nRev := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'RCH' THEN
      nRch := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'ACP' THEN
      nAcp := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'PRO' THEN
      nPro := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'ANU' THEN
      nAnu := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'PAR' THEN
      nPar := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'ELI' THEN
      nEli := R_OC.nCant;
    ELSIF R_OC.StsRengOC = 'CMP' THEN
      nCmp := R_OC.nCant;
    END IF;
  END LOOP;
  IF vSts IS NULL THEN
    IF nRev > 0 THEN
      vSts := 'REV';
    ELSIF nRch > 0 THEN
      vSts := 'RCH';
    ELSIF nAcp > 0 THEN
      vSts := 'ACP';
    ELSIF nPro > 0 THEN
      vSts := 'PRO';
    ELSIF nAnu > 0 THEN
      vSts := 'ANU';
    ELSIF nPar > 0 THEN
      vSts := 'PAR';
    ELSIF nEli > 0 OR nReg = 0 THEN
      vSts := 'ELI';
    ELSIF nCmp > 0 THEN
      vSts := 'CMP';
    END IF;
  END IF;
  UPDATE ORDEN_COMPRA
  SET StsOC = vSts
  WHERE IdOrdCmp = pIdOrdCmp;
END;
/**********************************************************/
/*     Actualiza IndDocEmitido de la Orden de Compra      */
/**********************************************************/
PROCEDURE ACT_INDDOCEMI(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE,
                        pInd       ORDEN_COMPRA.IndDocEmitido%TYPE) IS
 BEGIN
   UPDATE ORDEN_COMPRA
   SET IndDocEmitido = pInd
   WHERE IdOrdCmp = pIdOrdCmp;
 END;
/***********************************************************/
/*     Eliminar Orden de Compra                            */
/***********************************************************/
PROCEDURE ELIMINAR_OC(pIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE,
                      pFecAnu  ORDEN_COMPRA.FecAnu%TYPE) IS
vNumCot             COTIZACIONES.NumCot%TYPE;
nMtoCamb            KNTSTD.MONTO :=0;
nAnular             KNTSTD.MONTO :=0;
nMtoOrig            KNTSTD.MONTO :=0;
nTipoDoc            NUMBER(3);
vIdDoc              KNTSTD.IDENTIFICADOR;
vIdDocOC            KNTSTD.IDENTIFICADOR;
vIdEvento           KNTSTD.IDENTIFICADOR;
vDescrip            ORDEN_COMPRA.DESCOC%type;
vNumBenef           BENEFICIARIOS.NumBenef%TYPE;
vNumOC                GOBSTD.NUMOC;
vProxSis            GOBSTD.CodSis;
  CURSOR C_ROC IS
    SELECT NroReng,NroSC,NumRengSC,CantPenOC CantUndCmp,
           (CantPenOC  * CantConv) CantUndSol,
           (CantOrigOC * PrecioUnit) MtoOrig,
           (CantPenOC  * PrecioUnit) MtoPend
    FROM RENG_OC
    WHERE IdOrdCmp = pIdOrdCmp;
BEGIN
  -- Localizo dato necesarios de la O/C para la anulación
  SELECT SUBSTR(DescOC,1,59),NumBenef,IdDoc,
         NumOC, NumCot
  INTO   vDescrip,vNumBenef,vIdDocOC,
         vNumOC, vNumCot
  FROM   ORDEN_COMPRA
  WHERE  IdOrdCmp = pIdOrdCmp;
  -- Recorro los renglones de la OC
  FOR R_ROC IN C_ROC LOOP
    -- Verificar monto original de los renglones
    nMtoOrig := NVL(nMtoOrig,0) + NVL(R_ROC.MtoOrig,0);
    -- Calculo el monto pendiente de los renglones que se anulara
    nMtoCamb := NVL(nMtoCamb,0) + NVL(R_ROC.MtoPend,0);
    -- Actualiza campos de la solicitud de compra
    PROC_SOLCOMPRA.VER_RENGSC_ANULACIONOC(R_ROC.NroSC,R_ROC.NumRengSC,
                                          R_ROC.CantUndSol);
    -- Actualizo en cero la cantidad pendiente de O/C
    UPDATE RENG_OC
    SET CantPenOC = 0
    WHERE IdOrdCmp = pIdOrdCmp AND
          NroReng = R_ROC.NroReng;
    -- Actualiza Estatus del renglon de la O/C
    ACT_STS_RENGOC(pIdOrdCmp,R_ROC.NroReng,'ELI');
    -- Reversamos el status de los renglones en Perdida afectados
    PROC_COTIZACION.REV_RENGCOT_STSPER(R_ROC.NroSC,R_ROC.NumRengSC,vNumCot);
  END LOOP;
  -- Actualizo el status de la Cotizacion y sus renglones
    PROC_COTIZACION.VER_RENGCOT_ANULAOC(vNumCot);

  --
  -- IF 30/08/05: Actualiza columnas de anulacion de la orden
  -- AS 04/10/05: Se utiliza una fecha de anulacion suministrada
    UPDATE ORDEN_COMPRA
    SET UsuAnu = SUBSTR(USER,1,15),
         FecAnu = pFecAnu
    WHERE IdOrdCmp = pIdOrdCmp;
--
-- IF 27/03/06: Actualizamos el estatus de la orden
   ACT_STS_OC(pIdOrdCmp);
--

--  vCantsol     GOBSTD.CANTIDAD;
--   vCantPend    GOBSTD.CANTIDAD;
--   vNuevoSts    KNTSTD.ESTATUS;
--   vNroSC       GOBSTD.NROSC;
--
--   CURSOR RENGOC IS
--     SELECT NroSC,NumRengSC,CantOrigOC
--     FROM RENG_OC
--     WHERE IdOrdCmp = pIdOrdCmp;
-- BEGIN
--   FOR R_ROC IN RENGOC LOOP
--     vCantSol   := 0;
--     vCantPend  := 0;
--     vNroSC     := R_ROC.NroSC;
--     BEGIN
--       SELECT NVL(CantSol,0),NVL(CantPend,0)
--       INTO vCantSol,vCantPend
--       FROM RENG_SOL_COMPRA
--       WHERE NroSC     = R_ROC.NroSC AND
--             NroRengSC = R_ROC.NumRengSC;
--     EXCEPTION
--       WHEN NO_DATA_FOUND THEN
--         RAISE_APPLICATION_ERROR(-20003,'No existe el renglon en la solicitud.');
--     END;
--     vCantPend := vCantPend + R_ROC.CantOrigOC;
    /* Se cambia la cantidad pendiente y el estatus del reng de la SC  */
--     IF vCantSol = vCantPend THEN
--       vNuevoSts := 'REC';
--     ELSE
--       vNuevoSts := 'OCP';
--     END IF;
--     Proc_Solcompra.REBAJA_PENDIENTE(R_ROC.NroSC,R_ROC.NumRengSC,
--                                     vCantPend*-1,vNuevoSts);
--  END LOOP;
  /* Actualizo con ELI todos los renglones OC          */
  /* para diferenciar entre una OC emitida y otra no.  */
--  ACT_STS_TODOS_RENGOC(pIdOrdCmp,'ELI');
  /* Elimino todas las cotizaciones asociadas a la OC */
--   DELETE FROM RENG_COTIZACION
--   WHERE NroSC = vNroSC;
--   DELETE FROM COTIZACIONES
--   WHERE NroSC = vNroSC;
--  COMMIT;
END;



/***************************************************************************/
/* GENERAR_OC: Genera la orden de compra partiendo de la cotizacion        */
/***************************************************************************/
  FUNCTION GENERAR_OC(pNumCot COTIZACIONES.NumCot%TYPE) RETURN NUMBER IS

    vCantPend       RENG_COTIZACION.CantSol%TYPE  := 0;
    vCantPorPedir   RENG_COTIZACION.CantSol%TYPE  := 0;
    vNroReg         GOBSTD.NroReng         := 0;
    vNumProv        GOBSTD.NumProv;
    vNumBenef       BENEFICIARIOS.NumBenef%TYPE;
    vSts            KNTSTD.Estatus;
    vTotOC          KNTSTD.Monto           := 0;
    vTotOCImp       KNTSTD.Monto           := 0;
    vTotReng        KNTSTD.MONTO           := 0;
    cIdSolSum       KNTSTD.Identificador;
    cIdDoc          KNTSTD.Identificador;
    cNuevoSts       KNTSTD.Estatus;
    bCreado         BOOLEAN                := FALSE;
    vNumOc          GOBSTD.NumOc;
    vIdOrdCmp       KNTSTD.Identificador;
    vDummyBln       BOOLEAN;

    -- Cursor con los renglones de la Cotizacion a Generar en OC
    CURSOR C_RCO IS
      SELECT NroRengCot, NroSC, NroRengSC,
             StsReng, PrecioUnit, CantSol,
             CantAprob, FecEntrega, CantCotiz,
             CantConv, UndCmp, CodCatg, PorcCat, MtoImpto, IndImptoMan
      FROM RENG_COTIZACION
      WHERE NumCot = pNumCot
      AND StsReng <> 'ANU';

    -- 15/09/2003 - RRR - Cursor para obtener el número de proveedor de la cotización.
    CURSOR C_PROV(cNumCot COTIZACIONES.NumCot%TYPE) IS
      SELECT NumProv
      FROM COTIZACIONES
      WHERE NumCot = cNumCot;

BEGIN

  

  -- 15/09/2003 - RRR - Añadir localización de beneficiario asociado al proveedor.
  OPEN C_PROV(pNumCot);
  FETCH C_PROV INTO vNumProv;
  IF (C_PROV%NOTFOUND) OR (vNumProv IS NULL) THEN
    CLOSE C_PROV;
    RAISE_APPLICATION_ERROR(-20101,'ERROR DE DATOS: ' ||
      'La cotización no tiene proveedor asociado. ' || SQLERRM);
  END IF;
  CLOSE C_PROV;

  -- 15/09/2003 - RRR - Añadir localización de beneficiario asociado al proveedor.
  vNumBenef := PROC_FAB_PRO.LOCALIZAR_BENEF(vNumProv);

  -- 15/09/2003 - RRR - Añadir verificación de vigencia de beneficiario, se ignora
  -- el resultado para verificación interactiva.
  vDummyBln := PROC_BENEF_COMP.VERIF_FECVIGENCIA_BENEF(vNumBenef, 'GEN_OC');

  -- Verifico si hay algun renglon marcado para construir la O/C
  FOR R_RCO IN C_RCO LOOP
    IF R_RCO.CantAprob > 0 THEN
      bCreado := TRUE;
      EXIT;
    END IF;
  END LOOP;

  IF bCreado = TRUE THEN
    vNumOC := 0;
    FOR R_RCO IN C_RCO LOOP
      IF R_RCO.CantAprob > 0 THEN
        vNroReg := vNroReg + 1;
        IF vNroReg = 1 THEN
          -- Selecciona el secuencial para la nueva OC
          SELECT SQ_IdOrdCmp.NEXTVAL
          INTO vIdOrdCmp
          FROM DUAL;
          --BM: 03/07/00 Comentado por el manejo de las ordenes de servicio
          -- Selecciono  el numero que le correspondera a la OC para el año en curso
--          BEGIN
--            SELECT NVL(NumOc,0)+ 1
--            INTO vNumOC
--            FROM CONTROL_OC
--            WHERE ANO = TO_NUMBER(TO_CHAR(SYSDATE,'YYYY'));
--          EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--              RAISE_APPLICATION_ERROR(-20999,'Problemas al seleccionar el ' ||
--                'número de orden de compra.');
--          END;
            -- Actualizo el numero de la orden de compra para elño correspondiente */
--          UPDATE CONTROL_OC
--          SET NumOC = vNumOC
--          WHERE  ANO = TO_NUMBER(TO_CHAR(SYSDATE,'YYYY'));


/*
            -- 15/09/2003 - RRR - Añadir localización de beneficiario asociado al proveedor.
            -- Esta búsqueda se mueve al principio del procedimiento.
            -- Localizo el codigo del proveedor
            SELECT NumProv
            INTO vNumProv
            FROM COTIZACIONES
            WHERE NumCot = pNumCot;
*/

            DBMS_OUTPUT.PUT_LINE('-- Crear header de la OC');
            --BM: 03/07/00 Comentado por el manejo de las ordenes de servicio
            --se manda a crear la oc u os sin el número porque en este momento
            --no se ha identificado si está creando una Orden de Compras o una
            --Orden de Servicios.
            --CREA_HEADER_OC(R_RCO.NroSC,vNumProv,vNumOC,vIdOrdCmp,pNumCot);
            CREA_HEADER_OC(R_RCO.NroSC,vNumBenef,vIdOrdCmp,pNumCot);
          END IF;

          -- Busca la cantidad pendiente del renglon en la SC
          SELECT CantPend
          INTO vCantPend
          FROM RENG_SOL_COMPRA
          WHERE NroSC = R_RCO.NroSC
          AND   NroRengSC = R_RCO.NroRengSC;

          vCantPorPedir := R_RCO.CantAprob * R_RCO.CantConv ;

          IF (vCantPend - vCantPorPedir) = 0 THEN
            vSts := 'OCC'; -- Orden de Compra COMPLETA
            --Pone en PERDIDO los otros renglones que Competian');
            PROC_COTIZACION.RENGCOT_STSPER(R_RCO.NroSC,R_RCO.NroRengSC,pNumCot);
          ELSE
            vSts := 'OCP'; -- Orden de Compra PARCIAL
          END IF;

          -- Actualizo la cantidad y el status en la solicitud de compra'|| vsts);
          PROC_SOLCOMPRA.REBAJA_PENDIENTE(R_RCO.NroSC,R_RCO.NroRengSC,vCantPorPedir,vSTS);
          vTotReng :=  ROUND(R_RCO.CantAprob * R_RCO.PrecioUnit,2);
          vTotOC   := vTotOC + vTotReng;
          --BM 11/11/99 Cálcula el Monto de la OC con Impuesto
          --vTotOCImp:=  NVL(vTotOc,0) + ROUND(( NVL(vTotOc,0) * NVL(R_RCO.PorcCat,0))/100,2);
          --
          -- IF 27/10/07: Ahora se toma el campo de impuesto y no se calcula
          vTotOCImp:=  NVL(vTotOc,0) + nvl(R_RCO.MtoImpto,0);
          PROC_OC.CREA_RENGOC(vIdOrdCmp,pNumCot,R_RCO.NroRengCot,R_RCO.CantAprob);
          cNuevoSts := 'PRO';
          /* Actualiza el estatus del renglon de la cotizacion    */
          /* si este fue asignado  o no   en una OC               */
          PROC_COTIZACION.ACT_STS_RENGCOT(pNumCot,R_RCO.NroRengCot,cNuevoSts);

        ELSE

          PROC_COTIZACION.ACT_STS_RENGCOT(pNumCot,R_RCO.NroRengCot,'PER');

        END IF;

      END LOOP;

      --    Actualizo el mto original de O/C
      --Proc_Oc.ACT_MTO_OC(vIdOrdCmp, vTotOC,  vTotOCImp);
      CALCULO_MTO_OC(vIdOrdCmp);

    ELSE

      FOR R_RCO IN C_RCO LOOP
        PROC_COTIZACION.ACT_STS_RENGCOT(pNumCot,R_RCO.NroRengCot,'PER');
      END LOOP;

    END IF;

    RETURN(vIdOrdCmp);

  END;

--------------------------------------------------------------------------------

/**************************************************************************************/
/* VERIF_DETSRENGOC: Verifica ciertas condiciones que se deben cumplir al generar     */ 
/*  renglones de detalles de un reglón de cotización.                                 */
/**************************************************************************************/

PROCEDURE VERIF_DETSRENGOC(pIdOrdCmp ORDEN_COMPRA.IdOrdCmp%TYPE) IS
       
  CURSOR C_OC IS
    
  SELECT IndDetReng,
         NroReng,
         nvl(IndImptoMan,'N') IndImptoMan
  FROM   RENG_OC
  WHERE  IdOrdCmp = pIdOrdCmp;
  
  vNroRengDetOC     NUMBER(3) := 0;
  vMontoTotRengsDet NUMBER(14,2) := 0;
  vMontoTotRengOC   NUMBER(14,2) := 0;
  
BEGIN
  FOR R_OC IN C_OC LOOP
    IF R_OC.IndDetReng = 'S' THEN
    
     IF PROC_DETS_RENG_OC.VERIF_EXIST_DETRENG(pIdOrdCmp,
                                              R_OC.NroReng) = FALSE THEN
        RAISE_APPLICATION_ERROR
	    (-20315,'El renglón Nro ' || R_OC.NroReng || ' tiene marcado el indicador para detalles pero no posee por lo menos uno');   
     END IF;
      
      vNroRengDetOc := PROC_DETS_RENG_OC.VERIF_IMPDETSRENG(pIdOrdCmp,
                                                           R_OC.NroReng);
      
      IF vNroRengDetOC <> 0 THEN
        RAISE_APPLICATION_ERROR
	    (-20316,'El valor del impuesto del renglón de detalle Nro ' || vNroRengDetOC || 
                ' no es igual al valor del impuesto del renglón Nro ' ||R_OC.NroReng|| 
                ' al cual pertenece');   
      END IF;
      
      IF R_OC.IndImptoMan = 'N' THEN 
        IF  PROC_DETS_RENG_OC.VERIF_TOTALRENG(pIdOrdCmp,
                                            R_OC.NroReng,
											vMontoTotRengsDet,
											vMontoTotRengOC  ) = FALSE THEN
        RAISE_APPLICATION_ERROR
	    (-20317,'El monto total de los detalles del renglón Nro ' || R_OC.NroReng || 
		        ' ( ' || vMontoTotRengsDet || ' ) ' ||   
                ' no concuerda con el monto total del renglón' || ' ( ' || vMontoTotRengOC || ' ) ' );
        END IF;
      END IF;  
      
      PROC_DETS_RENG_OC.VERIF_CODCTA_DETRENG(pIdOrdCmp,
                                             R_OC.NroReng);
       
    END IF; 
  END LOOP;
END;

----------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************/
/*   Aprobacion de la OC                                                 */
/*******************************************************************/
FUNCTION APRUEBA_OC(pIdOrdCmp      ORDEN_COMPRA.IDORDCMP%TYPE,
                    pIdDoc  IN OUT ORDEN_COMPRA.IdDoc%TYPE) RETURN VARCHAR2 IS
--
-- IF 25/02/04: Inf. de renglones
CURSOR C_RENG(cIdOrdCmp   ORDEN_COMPRA.IdOrdCmp%TYPE) IS
  SELECT *
  FROM RENG_OC
  WHERE IdOrdCmp = cIdOrdCmp;
---
vStsOC          KNTSTD.Estatus;
vIndDocEmitido  KNTSTD.Indicador;
vTipoCompra     GOBSTD.TipoDoc;
vCodProxSis     GOBSTD.CodSis       := NULL;
vIdDoc          KNTSTD.Identificador;
R_RENG          C_RENG%ROWTYPE;
BEGIN
  BEGIN
    SELECT StsOC,NVL(IndDocEmitido,'N'),TipoCompra,IdDoc
    INTO vStsOC,vIndDocEmitido,vTipoCompra,vIdDoc
    FROM ORDEN_COMPRA
    WHERE IdOrdCmp = pIdOrdCmp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20700,'La Orden de Compra a Aprobar no existe.');
  END;
  --
  -- IF 25/02/04: Se verifica si la orden contiene renglones
  OPEN C_RENG(pIdOrdCmp);
  FETCH C_RENG INTO R_RENG;
  IF C_RENG%NOTFOUND THEN
    CLOSE C_RENG;
    RAISE_APPLICATION_ERROR(-20701,'ERROR DE DATOS: '||
    'La orden de compra a aprobar con identificador '||pIdOrdCmp||'" no contiene renglones,'
    ||' debe anularla');
  END IF;
  CLOSE C_RENG;
  
  -- CP: 25/9/2007 : Verificación para los detalles de los renglones de la OC
    VERIF_DETSRENGOC(pIdOrdCmp);
  
  -- IF (28/10/03): Debe considerar ordenes con documento emitido pero con estatus
  --                rechazado para realizar de nuevo el envio para aprobacion
  --
  -- Se pregunta si es una Compra nueva (DocEmitido = 'N') o es ya uno que
  -- salió de Compras
  IF vIndDocEmitido = 'N'
     OR (vIndDocEmitido = 'S' AND vStsOC = 'RCH') THEN
    -- Envio datos al mensajero referidos a la OC
    vCodProxSis := PROC_COMP.ENVIO_DATOS(pIdOrdCmp,NULL,pIdDoc);
    -- Actualizo inddocemtido para saber que los datos pasaron
    ACT_INDDOCEMI(pIdOrdCmp,'S');
    ACT_STS_TODOS_RENGOC(pIdOrdCmp,'REV');
  ELSE
    IF vStsOC = 'ACP' THEN -- Fue aceptada por la ruta del Mensajero
      -- Actualizo la OC y sus Renglones
      ACT_STS_TODOS_RENGOC(pIdOrdCmp,'PRO');
      vCodProxSis := PROC_MENSAJERO.APRUEBA_DOC(vIdDoc,'COMP');
    END IF;
  END IF;
  COMMIT;
  RETURN vCodProxSis;
END;
/*
BEGIN
  BEGIN
    SELECT StsOC,NVL(IndDocEmitido,'N'),TipoCompra,IdDoc
    INTO vStsOC,vIndDocEmitido,vTipoCompra,vIdDoc
    FROM ORDEN_COMPRA
    WHERE IdOrdCmp = pIdOrdCmp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20700,'La Orden de Compra a Aprobar no existe.');
  END;
  -- Se pregunta si es una Compra nueva (DocEmitido = 'N') o es ya uno que
  -- salió de Compras
  IF vIndDocEmitido = 'N' THEN
    -- Envio datos al mensajero referidos a la OC
    vCodProxSis := Proc_Comp.ENVIO_DATOS(pIdOrdCmp,NULL);
    -- Actualizo inddocemtido para saber que los datos pasaron
    ACT_INDDOCEMI(pIdOrdCmp,'S');
    ACT_STS_TODOS_RENGOC(pIdOrdCmp,'REV');
  ELSE
    IF vStsOC = 'ACP' THEN -- Fue aceptada por la ruta del Mensajero
      -- Actualizo la OC y sus Renglones
      ACT_STS_TODOS_RENGOC(pIdOrdCmp,'PRO');
      vCodProxSis := PROC_MENSAJERO.APRUEBA_DOC(vIdDoc,'COMP');
    END IF;
  END IF;
  COMMIT;
  RETURN vCodProxSis;
END;
*/
/*******************************************************************/
/*   Anula Orden de Compra                                         */
/*******************************************************************/
PROCEDURE ANULA_OC(pIdOrdCmp  ORDEN_COMPRA.IDORDCMP%TYPE,
                   pIdDoc      OUT ORDEN_COMPRA.IdDoc%TYPE,
                   pCodProxSis OUT SISTEMAS.CodSis%TYPE,
                   pFecAnu  ORDEN_COMPRA.FecAnu%TYPE) IS
                   
--
--  IF 27/10/07: Inf. de renglones 
  CURSOR C_ROC (cIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE) IS
  SELECT NroReng,NroSC,NumRengSC,CantPenOC CantUndCmp,
        ROUND((CantPenOC  * CantConv),2) CantUndSol
  FROM RENG_OC	
  WHERE IdOrdCmp = cIdOrdCmp;         
--
-- IF 27/10/07: Neto de cantidad pendiente
 CURSOR C_NETO (cIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE) IS        
  SELECT       ROUND(SUM(NVL((NVL(CantPenOC,0) * PrecioUnit),0)),2) MtoNetoPend
  FROM  RENG_OC
  WHERE IdOrdCmp = cIdOrdCmp;   
--
-- IF 27/10/07:Inf. de renglones impuesto
  CURSOR C_IMP(cIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE) IS
  SELECT ROUND((SUM(NVL(Preciounit*CantPenOC,0)) * NVL(PorcCat,0))/100,2) MtoPendImp  
  FROM RENG_OC
  WHERE    IdOrdCmp = cIdOrdCmp
  GROUP BY PorcCat;                       
                    
--
-- IF 28/04/04: Se incorporó la sentencia ROUND a dos decimales en los calculos
--  CURSOR C_ROC IS
--    SELECT NroReng,NroSC,NumRengSC,CantPenOC CantUndCmp, IndImptoMan, 
--           ROUND((CantPenOC  * CantConv),2) CantUndSol,
--           ROUND((CantOrigOC * PrecioUnit),2) MtoOrig,
--           ROUND((CantOrigOC * PrecioUnit * PorcCat)/100,2) MtoOrigImp,
--           ROUND((CantPenOC  * PrecioUnit),2) MtoPend,
--           ROUND((CantPenOC  * PrecioUnit * PorcCat)/100,2) MtoPendImp
--    FROM RENG_OC
--    WHERE IdOrdCmp = pIdOrdCmp;

--
-- IF  16/05/06: Inf. del documento administrativo
   CURSOR C_DOC (cIdDoc  DOCUMENTOS_ORIGEN.IdDoc%TYPE) IS
    SELECT IdDocTransf
    FROM DOCUMENTOS_ORIGEN
     WHERE  IdDoc = cIdDoc;
--
-- Variables de trabajo
  vCantCambios        NUMBER(10);
  vTipoCompra         ORDEN_COMPRA.TIPOCOMPRA%TYPE;
  vNumCot             COTIZACIONES.NumCot%TYPE;
  vTipoDoc            GOBSTD.TIPODOC;
  vMtoOC              KNTSTD.MONTO :=0;
  nAnular             KNTSTD.MONTO :=0;
  nMtoOrig            KNTSTD.MONTO :=0;
  nTipoDoc            NUMBER(3);
  vIdDoc              KNTSTD.IDENTIFICADOR;
  vIdDocOC            KNTSTD.IDENTIFICADOR;
  vIdEvento           KNTSTD.IDENTIFICADOR;
  vDescrip            ORDEN_COMPRA.DESCOC%TYPE;
  vDescripExt         ORDEN_COMPRA.DESCOC%TYPE;
  vNumBenef           DOCUMENTOS_ORIGEN.NUMBENEF%TYPE;
  vNumOC              GOBSTD.NUMOC;
  vProxSis            GOBSTD.CodSis;
  R_DOC               C_DOC%ROWTYPE;
  nMtoDoc             KNTSTD.MONTO :=0;
  R_IMP               C_IMP%ROWTYPE;
  R_ACUMIMP           C_IMP%ROWTYPE;
  R_NETO              C_NETO%ROWTYPE;
BEGIN
  --
  -- Localizo dato necesarios de la O/C para la anulación
  SELECT TipoCompra,MtoOCOrig,SUBSTR(DescOC,1,59),NumBenef,IdDoc,
         NumOC, NumCot, DescOC
  INTO   vTipoCompra,vMtoOC,vDescrip,vNumBenef,vIdDocOC,
         vNumOC, vNumCot, vDescripExt
  FROM   ORDEN_COMPRA
  WHERE  IdOrdCmp = pIdOrdCmp;
  --
  -- Verifico si tiene cambios pendientes
  SELECT COUNT(*)
  INTO vCantCambios
  FROM CAMBIO_OC
  WHERE IdOrdCmp = pIdOrdCmp AND
        StsCamb IN ('REV');
  --
  --       
  IF vCantCambios = 0 THEN
    PROC_CAMBIOOC.ACT_STS_CAMBIOOC(pIdOrdCmp,NULL,'ANU');
  ELSE
    RAISE_APPLICATION_ERROR(-20180,'No puede eliminar la O/C que posee Cambios en REVISION.');
  END IF;  
  --
  --
  -- IF 28/04/04: Calculamos el monto neto de la orden segun cantidades pendientes
    OPEN C_NETO(pIdOrdCmp);
    FETCH C_NETO INTO R_NETO;
    CLOSE C_NETO;    
  --
  -- IF 28/04/04:Monto impuesto pendiente Impuesto
    FOR R_IMP IN C_IMP(pIdOrdCmp) LOOP
      --
      -- Se acumula
     R_ACUMIMP.MtoPendImp   := nvl(R_ACUMIMP.MtoPendImp,0) + R_IMP.MtoPendImp  ;
    END LOOP;    
  --
  -- Se calcula del documento de anulacion de la orden
  nMtoDoc := R_ACUMIMP.MtoPendImp  + R_NETO.MtoNetoPend;     
  -- 
  -- Recorro los renglones de la OC
  FOR R_ROC IN C_ROC(pIdOrdCmp) LOOP 
  --  
  -- Actualiza campos de la solicitud de compra
    PROC_SOLCOMPRA.VER_RENGSC_ANULACIONOC(R_ROC.NroSC,R_ROC.NumRengSC,R_ROC.CantUndSol);
  --
  -- Actualizo en cero la cantidad pendiente de O/C
    BEGIN
      UPDATE RENG_OC
      SET CantPenOC = 0
      WHERE IdOrdCmp = pIdOrdCmp 
      AND   NroReng = R_ROC.NroReng;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR
          (-20550,'Problemas al actualizar la tabla RENG_OC.'||SQLERRM);
    END;
    IF SQL%NOTFOUND THEN
      RAISE_APPLICATION_ERROR
          (-20555,'No se encontraron renglones para la OC: '|| pIdOrdCmp||'.'||SQLERRM);
    END IF;
    --
    -- Actualiza Estatus del renglon de la O/C
    ACT_STS_RENGOC(pIdOrdCmp,R_ROC.NroReng,'ANU');
    --
    -- Reversamos el status de los renglones en Perdida afectados
    PROC_COTIZACION.REV_RENGCOT_STSPER(R_ROC.NroSC,R_ROC.NumRengSC,vNumCot);
  END LOOP;
--
-- Actualizo el status de la Cotizacion y sus renglones
  PROC_COTIZACION.VER_RENGCOT_ANULAOC(vNumCot);
--  
-- Notifico al Mensajero sobre la anulacion de la O/C
  SELECT TipoDoc
  INTO   vTipoDoc
  FROM   TIPO_DOC_COM
  WHERE  TipoCompra = vTipoCompra;
--
-- IF  16/05/2006: Se obtiene informacion del documento
  OPEN C_DOC(vIdDocOC);
  FETCH C_DOC INTO R_DOC;
  IF C_DOC%NOTFOUND THEN
    CLOSE C_DOC;
    RAISE_APPLICATION_ERROR(-20100,'ERROR DE DATOS: '||
    'No se encontró el documento administrativo "'||vIdDocOC||'"');
  END IF;
  CLOSE C_DOC;
--
--   IF  16/05/2006: Verificamos si fue transferido el compromiso
--                  en caso contrario se mantiene el documento que inicio el proceso
 IF R_DOC.IdDocTransf IS NOT NULL THEN
    --
    -- Se cambia la variable IdDocOC
    vIdDocOC :=  R_DOC.IdDocTransf;
 END IF;
-- 
-- Selecciono el sequence de IdDoc para el  documento
  BEGIN
    SELECT SQ_IDDOC.NEXTVAL
    INTO vIdDoc
    FROM DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20102,'Error seleccionando el secuencial del documento ');
  END;
  --
  -- Inserto el registro en la tabla Dcumento_Origen
  BEGIN
  --JR 30/11/2007 Se Agregaron los Campos de Moneda 
    INSERT INTO DOCUMENTOS_ORIGEN
        (IdDoc,DescDoc,Origen,NumBenef,RefDoc,MtoDoc,
         StsDoc,FecDoc,TipoDoc,Ano,IndReverso,IdDocRef, 
		 CodSitio,CodMoneda,Tasa,CodMonedaMtoDoc,MontoOrig, DescDocExt)
    VALUES
        (vIdDoc,vDescrip,'COMP',vNumBenef,'ANU O/C '||vNumOC,nMtoDoc,
         'INS',pFecAnu,vTipoDoc,TO_CHAR(pFecAnu,'YYYY'),'S',vIdDocOC,
		  PROC_INSTALACION.SITIOINST,PROC_INSTALACION.CODMONEDAINST(pFecAnu),
 		  1,PROC_INSTALACION.CODMONEDAINST(pFecAnu),nMtoDoc, vDescripExt);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20103,'Error: insertando registro en la tabla Documentos Origen..:'|| TO_CHAR(SQLCODE));
  END;
--
-- Informa al mensajero
  vProxSis := PROC_MENSAJERO.GENAPRUEBA_DOC(vIdDoc,'COMP');
--
-- IF 30/08/05: Actualiza columnas de anulacion de la orden
-- AS 04/10/05: Se utiliza una fecha de anulacion suministrada
    UPDATE ORDEN_COMPRA
    SET UsuAnu = SUBSTR(USER,1,15),
        FecAnu = pFecAnu
    WHERE IdOrdCmp = pIdOrdCmp;
--
--
-- IF 27/03/06: Actualizamos el estatus de la orden
   ACT_STS_OC(pIdOrdCmp);
--
  pIdDoc   := vIdDoc;
  pCodProxSis := vProxSis;
--  
END;
/*******************************************************************/
/*   Calculo Monto de la Orden de Compra                           */
/*******************************************************************/
PROCEDURE CALCULO_MTO_OC(pIdOrdCmp  ORDEN_COMPRA.IDORDCMP%TYPE) IS

--
-- IF 25/04/04: Inf. de renglones neto
  CURSOR C_NETO (cIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE) IS
  SELECT SUM(round(NVL((NVL(CantActOC,0) * PrecioUnit),0),2)) MtoNetoOC
  FROM  RENG_OC
  WHERE IdOrdCmp = cIdOrdCmp;
--
-- IF 25/04/04: Inf. de renglones impuesto
  CURSOR C_IMP(cIdOrdCmp  ORDEN_COMPRA.IdOrdCmp%TYPE) IS
  SELECT 
--ROUND(
--SUM(round((round(NVL(Preciounit*CantOrigOC,0),2)* PorcCat)/100,2)),2)  MtoImp 
-- CP 2/10/2007 Se cambio el calculo de impto por campo de la tabla
  SUM(NVL(MtoImpto,0)) MtoImp
  FROM RENG_OC
  WHERE    IdOrdCmp = cIdOrdCmp;
 -- GROUP BY PorcCat;

--
-- Variables de trabajo
R_NETO         C_NETO%ROWTYPE;
R_IMP          C_IMP%ROWTYPE;
R_ACUMIMP      C_IMP%ROWTYPE;
vMtoOC   KNTSTD.MONTO := 0;
BEGIN
  OPEN C_NETO(pIdOrdCmp);
  FETCH C_NETO INTO R_NETO;
  CLOSE C_NETO;
  --
  -- Impuesto
    R_ACUMIMP.MtoImp := 0;
  FOR R_IMP IN C_IMP(pIdOrdCmp) LOOP
    --
    -- Se acumula
   R_ACUMIMP.MtoImp := R_ACUMIMP.MtoImp + R_IMP.MtoImp;
  END LOOP;
--
-- Se calcula total de la orden
  vMtoOC := R_ACUMIMP.MtoImp + R_NETO.MtoNetoOC;
--
-- Se asigna monto
  UPDATE ORDEN_COMPRA
  SET MtoOCBs    = NVL(R_NETO.MtoNetoOC * TCambio,0),
      MtoOCOrig  = NVL(R_NETO.MtoNetoOC,0),
      MtoOcTotal = NVL(vMtoOC * TCambio,0)
  WHERE IdOrdCmp = pIdOrdCmp;
  COMMIT;
END;
/***********************************************************/
/*     Eliminar renglon a la Orden de Compra               */
/***********************************************************/
PROCEDURE ELIMINAR_RENG_OC(pIdOrdCmp   ORDEN_COMPRA.IDORDCMP%TYPE,
                           pNroReng    RENG_OC.NRORENG%TYPE) IS
  nCantPenSol  GOBSTD.CANTIDAD := 0;
  nCantSol     GOBSTD.CANTIDAD := 0;
  nCantOrig    GOBSTD.CANTIDAD := 0;
  nCantPenOC   GOBSTD.CANTIDAD := 0;
  cNuevoSts    KNTSTD.ESTATUS;
  nNroSC       GOBSTD.NROSC;
  nNumRengSC   GOBSTD.NRORENG;
  nCantReng    NUMBER(5)   := 0;
BEGIN
  SELECT COUNT(*)
  INTO nCantReng
  FROM RENG_OC
  WHERE IdOrdCmp = pIdOrdCmp;
  IF nCantReng = 0 THEN
    RAISE_APPLICATION_ERROR(-20014,'No existe la OC.');
  ELSE
    -- Localiza datos del renglon para su eliminación y colocar
    -- las cantidades activas en la solicitud de compra
    SELECT NroSC,NumRengSC,CantPenOC * CantConv
    INTO nNroSC,nNumRengSC,nCantPenOC
    FROM RENG_OC
    WHERE IdOrdCmp = pIdOrdCmp AND
          NroReng = pNroReng;
    BEGIN
      SELECT NVL(CantSol,0),NVL(CantPend,0)
      INTO nCantSol,nCantPenSol
      FROM RENG_SOL_COMPRA
      WHERE NroSC     = nNroSC AND
            NroRengSC = nNumRengSC;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003,'No existe el renglon en la solicitud.');
    END;
    --nCantPenSol := nCantPenSol + nCantPenOC;
    nCantPenSol := nCantPenOC;
    -- Se cambia la cantidad pendiente y el estatus del reng de la SC
    IF nCantSol = nCantPenOC THEN
      cNuevoSts := 'REC'; -- "Recibido", totalmente pendiente
    ELSE
      cNuevoSts := 'OCP'; -- "Orden Parcial"
    END IF;
    nCantPenSol := nCantPenSol * -1;
    PROC_SOLCOMPRA.REBAJA_PENDIENTE(nNroSC,nNumRengSC,nCantPenSol,cNuevoSts);
    -- Elimino el renglon a la OC
    DELETE RENG_OC
    WHERE IdOrdCmp = pIdOrdCmp AND
          NroReng = pNroReng;
  END IF;
  --COMMIT;
END;
/***************************************************************************/
/* Procedimiento para actualizar los valores de un documento verificado en */
/*               la tabla DOCUMENTOS_ORIGEN                             */
/***************************************************************************/
PROCEDURE ACTUALIZA_DOCORIGEN (pIdOrdCmp ORDEN_COMPRA.IdOrdCmp%TYPE) IS
--
-- IF 27/10/04: Ahora se obtiene el tipo de compra
--
-- Inf. de la orden
CURSOR C_ORD IS
  SELECT  IdDoc, DescOc, MtoOcTotal,FecOc, TipoCompra
  FROM ORDEN_COMPRA
  WHERE IdOrdCmp = pIdOrdCmp;
--
-- Inf. del tipo de compra
  CURSOR C_TDOC (cTipoCompra TIPO_DOC_COM.TipoCompra%TYPE) IS
   SELECT TipoDoc
   FROM TIPO_DOC_COM
   WHERE TipoCompra  = cTipoCompra;
--
-- Variables de trabajo
vOrigen    GOBSTD.CodSis;
vDocOrigen GOBSTD.CodSis;
R_TDOC     C_TDOC%ROWTYPE;
BEGIN
  --vOrigen := APLICACION.OBTIENE_APLIC;
  --BM 14/06/00: Colocado a mano por problemas en el usu del Obtiene aplic
  vOrigen := 'COMP';
  FOR R_ORD IN C_ORD LOOP
  --
  -- IF 27/07/04: Se ubica el tipo de documento segun tipo de compra
    OPEN C_TDOC(R_ORD.TipoCompra);
    FETCH C_TDOC INTO R_TDOC;
    IF C_TDOC%NOTFOUND THEN
      CLOSE C_TDOC;
      RAISE_APPLICATION_ERROR(-20208,'ERROR DE DATOS: '||
          'No existe el tipo de compra "'|| R_ORD.TipoCompra ||'" asociado '||
          ' a la orden con identificador "'|| pIdOrdCmp ||'"');
    END IF;
    CLOSE C_TDOC;


    -- Busca origen del documento en DOCUMENTOS_ORIGEN
    BEGIN
      SELECT Origen
      INTO   vDocOrigen
      FROM   DOCUMENTOS_ORIGEN
      WHERE  IdDoc = R_ORD.IdDoc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20203,
          'No existe Documento en DOCUMENTOS_ORIGEN' || R_ORD.IdDoc);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20204,
          'Problemas al buscar en DOCUMENTOS_ORIGEN IdDoc: ' || R_ORD.IdDoc ||
          '. ' || SQLERRM);
    END;
    IF vOrigen = vDocOrigen THEN
      --
      -- IF 27/10/04: Ahora se actualiza tambien el tipo de documento
      UPDATE DOCUMENTOS_ORIGEN
      SET DescDoc   = SUBSTR(R_ORD.DescOc,1,60),
          MtoDoc    = R_ORD.MtoOCTotal,
          FecDoc    = R_ORD.FecOc,
          TipoDoc   = R_TDOC.TipoDoc,
          MontoOrig = R_ORD.MtoOCTotal 
      WHERE IdDoc = R_ORD.IdDoc;
      IF SQL%NOTFOUND THEN
         RAISE_APPLICATION_ERROR
           (-20202,'Problemas al actualizar DOCUMENTOS_ORIGEN con el documento No. '||R_ORD.IdDoc
          || SQLERRM);
      END IF;
    END IF;
  END LOOP;
END;

---------------------------------------------------------------------------------------
--NUMERO_OC: Retorna el siguiente número automático correspondiente al tipo de OC
--
FUNCTION NUMERO_OC(pAno    CONTROL_OC.Ano%TYPE,
                   pTipoOC CONTROL_OC.TipoOc%TYPE) RETURN  NUMBER
IS

  vNumOC CONTROL_OC.NumOC%TYPE := 0;

BEGIN
  BEGIN
    SELECT NumOC
     INTO vNumOC
     FROM CONTROL_OC
     WHERE  Ano    = pAno
     AND    TipoOc = pTipoOc;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       BEGIN
         INSERT INTO CONTROL_OC
                (Ano, TipoOc, NumOc)
                 VALUES
                (pAno, pTipoOc,vNumOc);
       EXCEPTION
         WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20210,
              'Problemas al insertar registro en la tabla CONTROL_OC.'
              ||SQLERRM||'Año: '|| pAno
              ||' Tipo Oc: '|| pTipoOc);
         END;
    END;
  RETURN(vNumOc + 1);
END;

---------------------------------------------------------------------------------------
--VALIDA_NUM_OC: Retorna si el numero existe para el año en curso
--
FUNCTION VALIDA_NUM_OC(pFecOc  ORDEN_COMPRA.FecOc%TYPE,
                       pTipoOc CONTROL_OC.TipoOc%TYPE,
                       pNumOc  ORDEN_COMPRA.NumOc%TYPE) RETURN BOOLEAN
IS

  CURSOR C_ORDCOMP(cFecOc  ORDEN_COMPRA.FecOc%TYPE,
                   cTipoOc CONTROL_OC.TipoOc%TYPE,
                   cNumOc  ORDEN_COMPRA.NumOc%TYPE)
  IS
    SELECT 1
    FROM   ORDEN_COMPRA
    WHERE  TO_CHAR(FecOc,'YYYY') = TO_CHAR(pFecOc,'YYYY')
    AND    TipoOc = pTipoOc
    AND    NumOc  = pNumOc;

    R_ORDCOMP C_ORDCOMP%ROWTYPE;

BEGIN
  OPEN C_ORDCOMP(pFecOc,
                 pTipoOc,
                 pNumOc);

  FETCH C_ORDCOMP INTO R_ORDCOMP;
  IF C_ORDCOMP%FOUND THEN
     CLOSE C_ORDCOMP;
     RETURN(TRUE);
  ELSE
     CLOSE C_ORDCOMP;
     RETURN(FALSE);
  END IF;
END;

/*********************************************************************/
/* Se toma el No. de OC u OS siguiente de la tabla control_oc y se   */
/* actualiza la orden de compra o servicio con el No. obtenido       */
/*********************************************************************/
FUNCTION ASIGNAR_OC(pIdOrdCmp ORDEN_COMPRA.IdOrdCmp%TYPE,
                    pTipoOC   CONTROL_OC.TipoOc%TYPE,
                    pNumOC    ORDEN_COMPRA.NumOC%TYPE) RETURN  NUMBER
IS
  vIndAutOC TIPOS_OC.IndAutOC%TYPE;
  vNumOC    CONTROL_OC.NumOC%TYPE;
  vFecOC    DATE;
  pExiste   BOOLEAN := FALSE;

BEGIN

  SELECT FecOc
  INTO vFecOc
  FROM ORDEN_COMPRA
  WHERE IdOrdCmp = pIdOrdCmp;

  vIndAutOC := PROC_TIPOOC.IndAutOC(pTipoOC,' ',TRUE);

  IF vIndAutOC = 'S' THEN
     vNumOC := NUMERO_OC(TO_NUMBER(TO_CHAR(vFecOC,'YYYY')),pTipoOC);

     WHILE(VALIDA_NUM_OC(vFecOC, pTipoOC, vNumOC))LOOP
           vNumOC := vNumOC + 1;
     END LOOP;

     UPDATE CONTROL_OC
     SET    NumOC  = vNumOC
     WHERE  Ano    = TO_CHAR(vFecOC,'YYYY')
     AND    TipoOc = pTipoOc;

   ELSE
     IF VALIDA_NUM_OC(vFecOC, pTipoOC, pNumOC) THEN
        RAISE_APPLICATION_ERROR
        (-20210,'La Orden de compra Nro. ['|| pNumOC ||
        '] ya a sido asignado para el año '|| TO_CHAR(vFecOC,'YYYY') ||
        ' y tipo de orden [' || pTipoOC ||'] verifique la configuración del modulo');
     ELSE
        vNumOC := pNumOC;
     END IF;
   END IF;

   BEGIN
     UPDATE ORDEN_COMPRA
     SET    NumOC    = vNumOC
     WHERE  IdOrdCmp = pIdOrdCmp;
     IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR
        (-20202,'Problemas al actualizar la tabla ORDEN_COMPRA.'|| SQLERRM);
     END IF;
  END;
  RETURN vNumOC;
END;



---------------------------------------------------------------------------------
-- REVERSA_RECEP_OC manejar el reverso de una recepción de una determinada orden
-- de compra en el modulo de almacén.
PROCEDURE REVERSA_RECEP_OC(pIdOrdCmp   NUMBER,
                           pRengOC     NUMBER,
                           pCantidad   NUMBER,
                           pFactorConv NUMBER) IS

-- Cursor de renglones
 CURSOR C_RNG(cIdOrdCmp NUMBER, cRengOC NUMBER) IS
  SELECT CantPenOC,CantActOC
  FROM RENG_OC
  WHERE IdOrdCmp = cIdOrdCmp
   AND  NroReng  = cRengOC;
--
-- Variables de trabajo
  R_RNG    C_RNG%ROWTYPE;
  vStsReng RENG_OC.StsRengOC%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('actualiza');
  DBMS_OUTPUT.PUT_LINE('pCantidad '|| pCantidad);
  DBMS_OUTPUT.PUT_LINE('pFactorConv '||pFactorConv);
  DBMS_OUTPUT.PUT_LINE('pIdOrdCmp '||pIdOrdCmp);
    DBMS_OUTPUT.PUT_LINE('pRengOC '||pRengOC);

  UPDATE RENG_OC
  SET   CantPenOC  = NVL(CantPenOC,0) + (NVL(pCantidad,0)/pFactorConv),
        CantRecOC  = NVL(CantRecOC,0) - (NVL(pCantidad,0)/pFactorConv),
        CantRecAlm = NULL
  WHERE IdOrdCmp = pIdOrdCmp AND
        NroReng  = pRengOC;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20203,'ERROR INTERNO: '||
     'No se encontró el renglón: '||pRengOC||' para la la orden de compra Id: '||pIdOrdCmp||
     ' para actualizar cantidad pendiente y recibida.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('se busca lo actualizado');
  --
  -- Se obtiene la informacion den renglon actualizado
  OPEN C_RNG(pIdOrdCmp,pRengOC);
  FETCH C_RNG INTO R_RNG;
  IF C_RNG%NOTFOUND THEN
    CLOSE C_RNG;
    RAISE_APPLICATION_ERROR(-20204,'ERROR DE DATOS: '||
     'No se encontró el renglón: '||pRengOC||' para la la orden de compra Id: '||pIdOrdCmp);
  END IF;
  CLOSE C_RNG;
  DBMS_OUTPUT.PUT_LINE('se verifica cantidades');
  DBMS_OUTPUT.PUT_LINE('R_RNG.CantPenOC '||R_RNG.CantPenOC);
  DBMS_OUTPUT.PUT_LINE('R_RNG.CantActOC '||R_RNG.CantActOC);
  --
  -- Se determina el estatus que debe quedar el renglón
  IF R_RNG.CantPenOC = R_RNG.CantActOC THEN
    vStsReng := 'PRO';
  ELSIF R_RNG.CantPenOC < R_RNG.CantActOC THEN
    vStsReng := 'PAR';
  ELSE
    RAISE_APPLICATION_ERROR(-20205,'ERROR INTERNO: '||
     'Al determinar el estatus a asociar al renglón: '||pRengOC||
     ' para la la orden de compra Id: '||pIdOrdCmp||', cantidad actual: '||R_RNG.CantActOC||
     ', cantidad pendiente: '||R_RNG.CantPenOC );
  END IF;
   DBMS_OUTPUT.PUT_LINE('se actualiza estatus');
  --
  -- Se actualiza el estatus del renglòn
  BEGIN
    UPDATE RENG_OC
    SET StsRengOC  = vStsReng
    WHERE IdOrdCmp = pIdOrdCmp AND
          NroReng  = pRengOC;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20206,'ERROR INTERNO: '||
       'Al actualizar el estatus de el renglón: '||pRengOC||
       ' para la la orden de compra Id: '||pIdOrdCmp||','||SQLERRM);
  END;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20207,'ERROR INTERNO: '||
       'No se encontró el renglón: '||pRengOC||' para la la orden de compra Id: '||pIdOrdCmp||
       ' para actualizar su estatus.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('se actulizo el estatus');
END;

------------------------------------------------------------------------------------- 
--  CODMONEDAOC: Retorna Retorna la moneda de una Oden de Compra o un valor por omisión
--  en caso que no exista.  
                     
  FUNCTION CODMONEDAOC(pIdOrdComp ORDEN_COMPRA.IDORDCMP%TYPE) RETURN VARCHAR2 IS
	
  R_ORDCOMP C_ORDCOMP%ROWTYPE;	
							   
BEGIN
   
 BEGIN 
   OPEN  C_ORDCOMP(pIdOrdComp);
   FETCH C_ORDCOMP INTO R_ORDCOMP;
   IF C_ORDCOMP%FOUND THEN     
     CLOSE C_ORDCOMP;
     RETURN(R_ORDCOMP.CodMoneda);   
   ELSE    
     CLOSE C_ORDCOMP;
     RETURN(NULL); 
   END IF;
   EXCEPTION
      
	  WHEN NO_DATA_FOUND THEN
	     CLOSE C_ORDCOMP;
	     RAISE_APPLICATION_ERROR(-20123,'ERROR DE DATOS: '||
          ' No existe la Orden de Compra con el id. '|| pIdOrdComp  || SQLERRM);
		  
	  WHEN OTHERS THEN	
	      CLOSE C_ORDCOMP;   
	     RAISE_APPLICATION_ERROR(-20124,'ERROR INTERNO: '||
          ' Problema al consultar registro en la tabla ORDEN_COMPRA con el id. '|| pIdOrdComp  || SQLERRM);  
		  
   END;  
   
END;	


/**************  Fin Package  ************/
END;
/
