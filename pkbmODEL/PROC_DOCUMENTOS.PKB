CREATE OR REPLACE PACKAGE BODY PROC_DOCUMENTOS IS
-- Número de versión del package
vVerPkg VARCHAR2(8) := '8.3.7';
--
/* INI:KNTDocVer ***************************************************************
 REVISIONES (en orden inverso):
 Vers    Fecha       Autor        Lista de reportes de falla (ej: 123, 4678, 45.3)
 -----  ----------  -----------  ------------------------------------------------
 8.3.7  14/07/2008 JRONDON      013667 
 Se crea nuevo procedimiento de validación de indicador de reverso VALIDA_INDREVERSO.
 Ahora se valida en el mismo, si un documento posee un hijo y si además el hijo está 
 verificado y tiene indicador de reverso en S, para no permitir su devolución.
 ---------------------------------------------------------------------------------- 
 8.3.6  09/05/2008 IFLORES      012214, 012653, 012690 
 IF: Se efectúan cambios sobre el procedimiento de procesa_automaticos con el fin de 
 que se maneje la regeneración de los montos de los documentos antes de verificar. se
 agregó while   y la llamada al package PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF durante
 el transcurso del proceso de aprobación del documento JR: 09/05/2008 

 8.3.5  16/04/2008  IFLORES      012214, 012653, 012690 
 JR: Se ajusta el query de de selección de proceso automático se excluye la búsqueda 
 en el cursor de Documento Con cuentas y se utiliza DISTINC a raíz de que se encuentra
 con más de dos registros de definición que hacían que que tomara dos veces el miemo 
 documento a verificar colocandolo en RCH en vez de VER. JR: 06/05/2008 

 8.3.4  16/04/2008  IFLORES      012214, 012653 
 JR: Se ajusta el query de de selección de proceso automático se incluye la búsqueda 
 en el cursor de Documento Con cuentas. JR: 16/04/2008 

 8.3.3  27/03/2008  IFLORES      012214
 Ajuste de la rutina VERIFICA_DOC para no verificar los hermanos si el documento 
 aumenta el CAUSADO para manejar temporarmente los documentos asociados a NOMINAS 
 que puedes presentar problema en la secuencia (orden) al procesarlos. 
 ---------------------------------------------------------------------------------- 
 8.3.2  04/01/2008  JRONDON      010781
 IF: Se creo la rutina ACT_INF_TIPNIVCOMPROM para actualizar nivel y tipo de compriso
 en las rutinas VERDOC y REGDOC, para solventar el problema que se presenta
 en PROCESO_AUTOMATICO. 

 8.3.1  04/01/2008  JRONDON      010781
 IF: Se desactivo la validación de documentos asociados con estatus verificados, 
 en la devolución de documentos en DEVOLVER_DOC y VALDOC por la dependencia en el
 proceso de anulacion de ordenes de pago, para resolver llamada 10409 de LARA.  
 
 Se modificó en el procedimiento GENERA_REVERSO y ajustó PROC_INSTALACION.CODMONEDAINST
 para que pasara por parámetro trunc(sysdate).
 
 ---------------------------------------------------------------------------------- 
 8.3.0  22/08/2007  ABOTANA      101139
 Ajustes al proceso para el manejo de la reconversion monetaria.
 MV: Se volvió a activar la llamada a PROC_DOCS_TESO.REVERSA_TRANSFDOC en 
 REVERSA_TRANSFDOC, para resolver llamada 9395 del INE.  
 IF; Ahora la rutina VALDOC en los casos que el documento tenga IdDocRef valida
 la consistencia del beneficiario sin verificar si estable compromiso el documento.
 CP : Se modificó el proceso GEN_MOV_CONT para reconvertir el monto del documento 
 tomando en cuenta la moneda del documento origen.
 MV: Se modificó el procesa automáticos para regenerar la imputación presupuestaria
 de los documentos que pagan si no se logran verificar, para aprovechar la nueva 
 rutina PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF que hace la asignación a las 
 cuentas en función de los saldos. 
 JRONDON03/12/2007: Se modificó en el procedimiento GENERA_REVERSO en base al insert
 into de DOCUMENTOS_ORIGEN la información monetaria con respecto a la fecha de la 
 reconversión.    
 ---------------------------------------------------------------------------------- 
 8.2.1  09/07/2007  IFLORES      009397
 Se ajusto proceso CARGA_TRANSFDOC para la busqueda del documento a procesar sea
 igual al criterio que utiliza la pantalla, para manejar o considerar a documentos
 que establezcan reserva.
 ----------------------------------------------------------------------------------
 8.1.1   26/02/2006  ACHACON      008789
 Se modifico cursor de la función corfirma_trasfdoc para que la validación que no valide
 el documento para el periodo sino solo para el año. 
  
 02/03/2007 - ACHACON 008879 
 Se agrego validación de documentos asociados con estatus verificados, en la devolución
 de documentos 
 
 27/04/2007 ACHACON - Se cambio la devolución de documentos desde presupuesto, para que
 no se permita devolver si tines hijos con estarus  PEN, COD, VER RCH O DEV  
 ----------------------------------------------------------------------------------
 8.1.0   14/07/2006  VNEGRIN     007976
 Se agregó la función de reeviar documentos en la pantalla de verificacion. Esta función
 permite devolver el docuemnto al modulo que lo envio.
 ----------------------------------------------------------------------------------
 8.0.1   04/01/2006  IFLORES      007050
 Se agrego función de cambio de contexto a las rutinas "GEN_MOV_CONT".
 ---------------------------------------------------------------------------------
 8.0.0   13/01/2006  APIMENTEL    007050
 Se afrego el campo del código de estructura a los insert de la tabla CTAS_DOC
 ---------------------------------------------------------------------------------
 7.2.8   19/10/2005  IFLORES       006706
 Se ajustó la FUNCTION VALDOS para que permita seguir el documento si no realiza
 ningun efecto en el presupuesto.
 -----------------------------------------------------------------------------------
 7.2.7   14/09/2005  VNEGRIN      006541
 Se agregó la condición vStsDoc <> 'DEV' en la función VALDOC, en la sentencia donde
 se valida que el documentos padre este verificado, ahora valida que este verificado o devuelto
 Se volvió activar la llamada al proceso PROC_DOCS_TESO.
 -----------------------------------------------------------------------------------
 7.2.6   23/05/2005  IFLORES      100586
 Se adapto el FUNCTION ACEPTAR_DEV para permitir pasar documentos con periodo ya cerrado con
 respecto al año prespuestario en ejecucion y ademas se creó la rutina ACT_DOC_DEV para
 actualizar la información del documento que se esta recibiendo.
 -----------------------------------------------------------------------------------
 7.1.6   18/02/2005  VRIVERO      005626
 Se agrego que solo enviara el mensaje de 'El periodo del Documento debe ser menor
 o igual a los períodos definidos para el ejercicio' solo cuando verifique y no
 cuando registre
 -----------------------------------------------------------------------------------
 7.1.5   03/02/2005  R.Arrieta    100549
 Se creó procedimiento CTA_ADIC para insertar las cuentas adicionales en los documentos
 padres en los casos de aumento de compromiso si son seleccionadas cuentas diferentes.
 -----------------------------------------------------------------------------------
 7.1.4   03/01/2005  V.NEGRIN     100516
 Se modifico la declaracion de la variable vNumBenef  de la función
 VALDOC. Se le agrego 3 digítos a las validaciones de NumBenef en la misma función
 -----------------------------------------------------------------------------------
 7.1.3   02/12/2004  RARRIETA     005074
 Se modificó devolver documentos para actualizar los documentos a REV y no
 eliminarlos de la tabla.
 -----------------------------------------------------------------------------------
 7.1.2   24/11/2004  RARRIETA     005480
 Se corrigió SELECT, se incluyó en el group by el indicador INDDISTRIBMTO.
 -----------------------------------------------------------------------------------
 7.1.1   10/11/2004  RARRIETA     005410
 Se ajustó procedimiento GEN_MOV_CONT con el uso del indicador INDDISTRIBMTO.
 -----------------------------------------------------------------------------------
 7.1.0   08/11/2004  RARRIETA     005410
 Se incluyó indicador INDDISTRIBMTO para generación de registro contable.
 -----------------------------------------------------------------------------------
 7.0.8   07/10/2004  RARRIETA     100457
 Se modificó en procedimiento GEN_MOV_CONT  para insertar CodAuxiliar en MOV_CONT_ADIC
 -----------------------------------------------------------------------------------
 7.0.7   17/06/2004  M.Veloso     004855
 Se incluyó nuevamente la validación del período presupuestario cerrado, la cual
 se comentó por error en la actividad anterior (DEF#155)
 -----------------------------------------------------------------------------------
 7.0.6   27/05/2004  M.Veloso     100391
 Se comentó la llamada a PROC_DOCS_TESO hasta que se ajuste para trabajar sin
 crear la dependencia de PPTO a TESO
 -----------------------------------------------------------------------------------
 7.0.5   14/05/2004  A.Botana     100391
 Se agregó la eliminación de los movimientos contables de transferencia antes
 de generar unos nuevos registros.
 -----------------------------------------------------------------------------------
 7.0.4   07/05/2004  M.Veloso     100391
 Se corrigió la validación del estatus del ejercicio, ya que en ocasiones permitía
 procesar documentos estando en formulación.
 -----------------------------------------------------------------------------------
 7.0.3   28/04/2004  Abotana      100383
 Se cambio el proceso GEN_MOV_CONT de generación de la informacion para el
 movimiento contable si el ejercicio presupuestario del documento así lo indica.
 Se genera información con el codigo de la cuenta presupuestaria o con la cuenta
 de conversion contable según lo indicado en el Ejercicio EJS_PRESUP
 -----------------------------------------------------------------------------------
 7.0.2   26/04/2004  E.Rodriguez  004583
 Se agrego condición que valide si hay algun efecto de reserva o compromiso a la hora
 de llamar a los procedimientos de cuentas de control(ACTCTASDOC).
 -----------------------------------------------------------------------------------
 7.0.1   10/03/2004  M.Rosito     4422
 Se modifica VALDOC para tomar en cuenta los reversos en la validaciòn del indicador
 de referencia.
 ---------------------------------------------------------------------------------
 7.0.0   16/09/2004  E.Rodriguez  100293
 Se modifico el PROCEDURE ACTCTASDOC  para que llame a las funciones de actualización
 de cuentas de control si la configuración indica que la disponibilidad es de Nivel
 Configurable.
 ---------------------------------------------------------------------------------
 6.0.2   26/09/03    M.Rosito
 Se modifica VALDOC para validar (solo en documentos que no sean devoluciones)
 consistencia entre el indicador de referencia y el IdDocRef del documento.
 ---------------------------------------------------------------------------------
 6.0.1   02/09/2003  E.Rodriguez   100217
 Se agrego rutina VERIFICA_HERMANOS. Esta toma los documentos que posean el mismo
 IdDocRef y verifica su orden de de proceso según su fecha y si las fechas son iguales
 según su IdDoc. obliga a que los documentos hermanos deban ser verificados en orden.
 ---------------------------------------------------------------------------------
 6.0.0   18/08/2003  I.Flores      100191
 Se creó el PROCEDURE CARGA_TRANSFDOC para cargar los documentos presupuestario
 o solcititudes de pago elegibles para transferencia
 Se creó la FUNCTION CONFIRMA_TRANSFDOC para confirma la tranferencia del documento
 presupuestario recibido.
 Se creó la FUNCTION REVERSA_CARGA_TRANSFDOC para reversa carga del documento
 presupuestario o solcititudes de pago
 Se adapto el procedimiento ANULA_DOC para considerar la anulación de un documento
 de trasferencia.
 ---------------------------------------------------------------------------------
 5.5.2  03/08/2003   M.Rosito
 Se agrega la validación de disponibilidad de cuotas de compromiso (si el documento
 afecta cuotas) en la función CODIFICA_DOC. Esto se hace ejecutando la cuota y
 haciendo ROLLBACK si todo está bien, ya que la ejecución se hace en la verificación.
 ---------------------------------------------------------------------------------
 5.5.1  07/07/2003   E.Rodriguez    100144
 Se agregó llamado en VERIFICA_DOC y ACEPTAR_DEV al proceso de CARGA_EJECUTADO de
 cuotas de compromiso si el documento tiene el indicador de establece compromiso
 activado.
 Ahora al verificar si ocurre un error se crea el mensaje con el error para
 ser mostrado en la pantalla de verificacion o codificación.
 ---------------------------------------------------------------------------------
 5.5.0  26/06/2003   A.Botana
 Generacion de la informacion en MOV_CONT_ADIC (CONTABILIDAD) para que genere
 automaticamente los movimientos contables con las cuentas de PPTO al momento
 de Verificar (VERDOC).
 Depende que este presente la version 2.2.0 o superior del package PROC_MOVIMIENTOS
 de CONT.
 ---------------------------------------------------------------------------------
 5.4.4   27/05/2003  R.Romero
 Cambio en la lógica de decisión de REGDOC para evitar IF ISOPEN THEN CLOSE.
 ---------------------------------------------------------------------------------
 5.4.3   14/03/2003  M.Veloso
 Se quitó la restricción que impedía tener más de un año de períodos
 presupuestarios sin cerrar.
 ---------------------------------------------------------------------------------
 5.4.2   21/02/2003  M.Veloso
 No se actualizaban correctamente los detalles del fondo durante el reverso del
 registro de los documentos, cuando se aceptaba una devolución.
 ---------------------------------------------------------------------------------
 5.4.1   20/01/2003  M.Veloso
 Se puso el cursor C_CTACCF en el spec para reutilizarlo, esto no afecta el spec
 para efectos del signature y por eso se considera una revisión menor
 ---------------------------------------------------------------------------------
 5.4.0   06/08/2002  M.Rosito
 Se incluyó una rutina para devolver documentos presupuestarios
 ---------------------------------------------------------------------------------
 5.3.1   21/05/2002  M.Veloso
 Se incluyó validación para la clase de cuentas en la imputación, según la indicada
 en la configuración del tipo de documento en PPTO.
 ---------------------------------------------------------------------------------
 5.3.0   03/05/2002  M.Veloso
 Se incluyó una rutina para anular documentos y se eliminó del spec CHK_ANULA_DOC
 y ahora se llama desde ANULA_DOC.
 Se quitó VERDOC y REGDOC del spec, sólo debe usarse VERIFICA_DOC.
 ---------------------------------------------------------------------------------
 5.2.0   29/04/2002  M.Veloso
 Se incluyó una función para manejar la codificación de documentos.
 Se incluyó rutina para validar estatus de los documentos
 Otros ajustes menores para el manejo de fondos en avance
 ---------------------------------------------------------------------------------
 5.1.4   04/04/2002  M.Veloso
 Se incluyó validación para asegurar:
   1) Que el padre este verificado
   2) Que el período del documento no exceda los definidos para el ejercicio
   3) Que no se pueda verificar el reverso de un reverso
 ---------------------------------------------------------------------------------
 5.1.3   28/11/2001   BM
 Se incluyó función para verificar que todos los hijos de un documento estan
 anulados cuando se desea anular el padre
 ---------------------------------------------------------------------------------
 5.0.2   14/11/2001  M.Veloso     1719
 Se incluyó una validación adicional para verificar que si un documento tiene
 efecto de disminución no exista ningún otro hijo (o nietos) del documento padre
 pendientes por verificar
 ---------------------------------------------------------------------------------
 5.0.1   28/08/2001  BM
 Modificaciones de la función VERPKG
 ---------------------------------------------------------------------------------
 5.0.0   18/06/2001  BM
 Se eliminó el uso de la función obtiene_aplic por problemas en algunas instalaciones
 ---------------------------------------------------------------------------------
 4       03/05/2001  BM
 Modificaciones para no permitir la verificación de doc. en ejercicios cerrados y
 para registrar documentos a traves del proceso automático.
 ---------------------------------------------------------------------------------
 3       23/02/2001  BM
 Modificaciones para registrar (no verificar) doc. en un ejercicio presupuestario
 cerrado, si el documento tiene efecto de Pago.
 ---------------------------------------------------------------------------------
 2       22/01/2001  MV
 Inclusión de COMMIT en PROCESA_AUTOMATICOS, para disminuir las transacciones
 detenidas de otros usuarios, esperando por liberación de bloqueos.
 ---------------------------------------------------------------------------------
 1       15/01/2001  BM
 Numeración inicial.
** FIN:KNTDocVer **************************************************************/
-- Cursor para buscar manejo de cuotas
CURSOR C_CUOTA(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT EJS.Ano,
           DPR.IndEstComprom,
           EJS.IndCtrlCuota
    FROM   DOCS_PRESUP DPR,
           EJS_PRESUP  EJS
    WHERE DPR.Ano = EJS.Ano
    AND   DPR.IdDoc = cIdDoc;
--------------------------------------------------------------------------------
--AP(16/01/2006) Cursor para traer el código de estructura del ejercicio presupuestario
CURSOR C_EJS (pAno NUMBER) IS
	SELECT EJS.CodEstruct
	FROM   EJS_PRESUP EJS
	WHERE  EJS.Ano = pAno;
--------------------------------------------------------------------------------
-- VALIDA_STS_DOC: Asegura que el estatus del documento sea el solicitado
-- MV 01/05/2002
PROCEDURE VALIDA_STS(pIdDoc NUMBER, pStsDoc VARCHAR2) IS

  vStsdoc DOCS_PRESUP.StsDoc%TYPE;
BEGIN

  BEGIN

    SELECT StsDoc
    INTO   vStsDoc
    FROM   DOCS_PRESUP
    WHERE  IdDoc = pIdDoc;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20502, 'ERROR INTERNO:' ||
        ' Buscando el documento "' || pIdDoc || '". ' || SQLERRM);
  END;

  IF INSTR(pStsDoc, vStsDoc) = 0 THEN
    RAISE_APPLICATION_ERROR(-20501, 'ERROR INTERNO:' ||
      ' El documento "' || pIdDoc || '" tiene estatus "' || vStsDoc ||
      '", pero debe tener "' || pStsDoc || '" para poder procesarlo.');
  END IF;

END;
--------------------------------------------------------------------------------
-- VALIDA_INDREVERSO: Asegura que el documento no tenga reversos finalizados
-- JR 14/07/2008 
PROCEDURE VALIDA_INDREVERSO(pIdDoc NUMBER) IS
--
  CURSOR C_INDREVERSO(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
	  SELECT IdDoc, IndReverso--, IdDocRef, TipoDoc, StsDoc, IndReverso
	  FROM   DOCS_PRESUP
	  WHERE  StsDoc IN ('VER')
	  AND    IndReverso = 'S'
	  CONNECT BY IdDocRef = PRIOR IdDoc
	  START WITH IdDoc = cIdDoc;
R_INDREVERSO C_INDREVERSO%ROWTYPE;
BEGIN
  BEGIN
  	  OPEN C_INDREVERSO(pIdDoc);
	  FETCH C_INDREVERSO INTO R_INDREVERSO;
	  IF C_INDREVERSO%FOUND THEN
	  	 CLOSE C_INDREVERSO;
      	 RAISE_APPLICATION_ERROR(-20504, 'ERROR INTERNO:' ||
      	 ' El documento "' || pIdDoc || '" no puede ser aceptado debido a que ' ||
      	 ' posee un documento hijo "' || R_INDREVERSO.IdDoc || '" con indicador de Reverso "' || R_INDREVERSO.IndReverso ||
	  	 '" Debe Reenviar el documento Padre y devolver el reverso ' ||SQLERRM);
	  END IF;
	  CLOSE C_INDREVERSO;
  END;
END;

/*********************************************************/
/* VERPKG: Retorna el numero de versión de este package. */
/*********************************************************/
FUNCTION VERPKG RETURN VARCHAR2
IS
BEGIN
  RETURN vVerPkg;
END VERPKG;
/********************************************************/
/* Procedimiento que crea el mensaje de Error           */
/********************************************************/
PROCEDURE CREA_MSG(cMsg VARCHAR2) IS
  BEGIN
    IF cMensaje IS NULL THEN
      cMensaje := RTRIM(cMsg);
    ELSE
       IF LENGTH(cMensaje) > 800 THEN
        LIMPIA_MENSAJE;
        cMensaje := '...'||CHR(13) || CHR(10);
      END IF;
      cMensaje := cMensaje || ' ' || CHR(13) || CHR(10) || ' ' || RTRIM(cMsg);
    END IF;
  END;
/*********************************************************/
/* Funcion que retorna el contenido de MENSAJE           */
/*********************************************************/
FUNCTION VER_MENSAJE RETURN VARCHAR2 IS
  BEGIN
    RETURN(cMensaje);
  END;
/*********************************************************/
/* Procedimiento que limpia la Variable cMensaje         */
/*********************************************************/
PROCEDURE LIMPIA_MENSAJE IS
BEGIN
  cMensaje := NULL;
END;
/****************************************************/
/* Selector de opciones adicionales                 */
/****************************************************/
PROCEDURE PROCVER (pIdDoc IN DOCS_PRESUP.IdDoc%TYPE,
                   pParamVer DEF_EVENTO_CP.ParamVer%TYPE)IS
BEGIN
  NULL;
END;

--------------------------------------------------------------------------------
-- ACT_DOC_DEV: Actualiza informacion del documento devuelto que se acepta
--
PROCEDURE ACT_DOC_DEV(pR_DOC      PROC_PRESUP.C_DOC%ROWTYPE,
                      pAno        EJS_PRESUP.Ano%TYPE,
                      pUltPeriodo EJS_PRESUP.Periodo%TYPE) IS

-- Variables de trabajo
vFecDoc DATE;
vR_DOC  PROC_PRESUP.C_DOC%ROWTYPE;
BEGIN
--
-- Se verifica si no es un ejercicio complementario
  IF pUltPeriodo > 12 THEN -- Ejercicio complementario
   --
   -- Se arma la fecha del documento a asignar
     vFecDoc :=   TO_DATE('01/'|| (pUltPeriodo - 12) || '/' || (pAno + 1) ,'DD/MM/RRRR');
  ELSE
     vFecDoc :=   TO_DATE('01/' || LPAD(TO_CHAR(pUltPeriodo),2,'0') || '/' || pAno,'DD/MM/RRRR');
  END IF;
--
-- Asigno el registro recibido al la variable de registro privada pàra ajustar la
-- informacion
  vR_DOC := pR_DOC;
--
-- Se actualiza informacion del documento en la variable de registro
   vR_DOC.Ano    := pAno ;                          -- Año del ejercicio abierto
   vR_DOC.FecDoc := vFecDoc;                        -- Fecha a colocar el documento
--
  BEGIN
    UPDATE DOCS_PRESUP
     SET FecDoc  = vFecDoc,
         Periodo = pUltPeriodo,
         Ano     = pAno
    WHERE IdDoc  = vR_DOC.IdDoc;
  EXCEPTION
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20481,'ERROR INTERNO: '||
       'Problema al actualizar el documento "' || vR_DOC.IdDoc || '", '|| SQLERRM);
  END;                                               

--
-- Se actualiza la informacion del documento origen
   PROC_VERIFICACION.ACTUALIZA_DOCORIGEN(pR_DOC.IdDoc);
  
END;

/****************************************/
/*Funcion que valida el documento       */
/****************************************/
FUNCTION VALDOC(pIdDoc IN DOCS_PRESUP.IdDoc%TYPE) RETURN BOOLEAN IS

  nAno            KNTSTD.Ano;
  cCodAccInt      GOBSTD.CodAccInt;
  cCodPrograma    GOBSTD.CodPrograma;
  nNumComprom     KNTSTD.Identificador;
  vNivelComprom   GOBSTD.NivelComprom;
  vTipoComprom    GOBSTD.TipoComprom;
  vNumBenef       BENEFICIARIOS.NumBenef%TYPE;
  vIndCodTrans    TIPOS_DOC_PPTO.INDCODTRANS%TYPE;
  cSts            KNTSTD.Estatus;
  nUltPeriodo     KNTSTD.Mes;
  nPeriodo        KNTSTD.Mes;
  nMtoDoc         KNTSTD.Monto;
  nSumMonto       KNTSTD.Monto;
  nCodCta         GOBSTD.CodCuenta;
  cCCosto         GOBSTD.CCosto;
  cEfectComprom   DEF_EVENTO_CP.EfectComprom%TYPE;
  nIdDocRef       KNTSTD.Identificador;
  nAnoRef         KNTSTD.Ano;
  dFecDoc         DATE;
  bEntrada        BOOLEAN;
  Temp            VARCHAR2 (1);
  cMsg            GOBSTD.Mensaje;
  vFecDoc         DOCS_PRESUP.FecDoc%TYPE;
  vPeriodo        DOCS_PRESUP.Periodo%TYPE;
  vExiste         NUMBER := 0;
  vStsDoc         DOCS_PRESUP.StsDoc%TYPE;
  vIndReverso     DOCS_PRESUP.IndReverso%TYPE;
  vNumPerAno      EJS_PRESUP.NumPerAno%TYPE;
  vAfectaFondo    BOOLEAN;


  -- Cursor con la Cuentas del Documento
  CURSOR C_CTAS IS
    SELECT CodCta, SUM(Monto) Monto
    FROM  CTAS_DOC
    WHERE IdDoc = pIdDoc
    GROUP BY CodCta;

  -- Cursor con la Cuentas, CC. y A.I del Documento
  CURSOR C_CTA IS
    SELECT CodCta, CodAccInt, CCosto
    FROM   CTAS_DOC CTA
    WHERE  IdDoc = pIdDoc;

  -- Cursor con el Total de las Cuenta/Centros de Costos del Documento
  CURSOR C_CCDOC IS
    SELECT IdDoc, SUM(Monto) Monto
    FROM  CTAS_CCOSTO_DOC
    WHERE IdDoc = pIdDoc AND
          CodCta = nCodCta
    GROUP BY IdDoc;
  R_CCDOC C_CCDOC%ROWTYPE;

  CURSOR C_CTAS_CLASE(pIdDocC NUMBER, pClaseCtaC VARCHAR2) IS
    SELECT DISTINCT CTA.CodCta
    FROM   CTAS_DOC CTA
    WHERE  IdDoc = pIdDocC
    MINUS
    SELECT DISTINCT CTA.CodCta
    FROM   CTAS_DOC CTA,
           CTAS_CLASE CLA
    WHERE  CLA.CodCta = CTA.CodCta
    AND    IdDoc = pIdDocC
    AND    CLA.ClaseCta = pClaseCtaC;

  -- Cursor con los Totales por CCosto del Documento
  CURSOR C_CCDOCORD IS
    SELECT CCosto, SUM(Monto) Monto
    FROM  CTAS_CCOSTO_DOC
    WHERE IdDoc = pIdDoc AND
          CodCta = nCodCta
    GROUP BY CCosto;

  -- Cursor con las Acciones Internas de la Cuenta/CCosto del Documento
  CURSOR C_DETACC IS
    SELECT 1
    FROM  DETS_ACC_INT
    WHERE Ano = nAno AND
          CodAccInt = cCodAccInt AND
          CodCta = nCodCta AND
          CCosto = cCCosto;

  -- Cursor con el indicador de referencia del tipo de documento.
  CURSOR C_TIPODOC (cTipoDoc TIPOS_DOCUMENTOS.TipoDoc%TYPE) IS
    SELECT IndRefDoc
    FROM  TIPOS_DOCUMENTOS
    WHERE TipoDoc = cTipoDoc;

-- IF 	07/02/08 -- No se utiliza
--  --Cursor para buscar los documentos hijos
--  CURSOR C_DOCREF IS
--    SELECT *
--	FROM DOCS_PRESUP	
--    WHERE  IdDocRef = pIdDoc;

  R_DOC PROC_PRESUP.C_DOC%ROWTYPE;

  R_DEF PROC_TIPODOCPPTO.C_DEF%ROWTYPE;
  
--  R_DOCREF C_DOCREF%ROWTYPE;

  R_TIPODOC C_TIPODOC%ROWTYPE;
  vEfecPPTO BOOLEAN := TRUE;
--
  BEGIN
    LIMPIA_MENSAJE;

    -- Busca el documento y su definicion del evento presupuestario.
    IF PROC_PRESUP.C_DOC%ISOPEN THEN
      CLOSE PROC_PRESUP.C_DOC;
    END IF;

    OPEN PROC_PRESUP.C_DOC(pIdDoc);
    FETCH PROC_PRESUP.C_DOC INTO R_DOC;
    IF PROC_PRESUP.C_DOC%NOTFOUND THEN
      CREA_MSG('No existe la definicion del Documento');
    END IF;

    CLOSE PROC_PRESUP.C_DOC;

    -- MRM 26/09/03 Busca el indicador de documento de referencia
    OPEN C_TIPODOC(R_DOC.TipoDoc);
    FETCH C_TIPODOC INTO R_TIPODOC;
    IF C_TIPODOC%NOTFOUND THEN
      CLOSE C_TIPODOC;
      CREA_MSG('No existe el tipo de documento ' || R_DOC.TipoDoc ||' en la tabla principal de tipos de documentos');
    END IF;
    BEGIN
      -- Busca los datos del ejercicio presupuestario para el a?o del documento.
      SELECT EJE.Ano, EJE.Sts, EJE.Periodo, EJE.NumPerAno
      INTO nAno, cStS, nUltPeriodo, vNumPerAno
      FROM EJS_PRESUP EJE
      WHERE EJE.Ano = R_DOC.Ano;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CREA_MSG('No existe el ejercicio presupuestario');
    END;

	
	---PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VALDOC',' VA A AFECTA_FONDO');
	
    -- Verificamos si tiene configuración para el manejo de los fondos
    vAfectaFondo := PROC_TIPODOCPPTO.AFECTA_FONDO(R_DOC.TipoDoc);
	
   PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VALDOC',' PASO AFECTA_FONDO');

    IF vAfectaFondo THEN
      BEGIN
        PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VALDOC',' VA A PROC_FONDOAV.VALIDA_DOC');
        PROC_FONDOAV.VALIDA_DOC(pIdDoc);
      EXCEPTION
        WHEN OTHERS THEN
          CREA_MSG(SQLERRM);
      END;

    -- Esta validación la hacemos sólo si no afecta fondos, porque
    -- si afecta fondos, es posible que no tenga ni TipoComprom, NivelComprom
    ELSE
  
      --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VALDOC',' R_DOC.TipoComprom = '|| R_DOC.TipoComprom);
	  
      --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VALDOC',' R_DOC.NivelComprom = '|| R_DOC.NivelComprom);

      IF R_DOC.TipoComprom IS NULL THEN
        CREA_MSG('El Tipo de Compromiso es inválido. Reprocese');
      END IF;

      IF R_DOC.NivelComprom NOT IN ('C', 'B') THEN
        CREA_MSG('El Nivel de Compromiso es inválido. Reprocese');
      END IF;

    END IF;

    --
    --BM 24/03/00 La fecha del documento debe ser anterior a sysdate.
    IF TRUNC(R_DOC.FecDoc) > TRUNC(SYSDATE) THEN
      CREA_MSG('La fecha del documento debe ser menor o igual a la fecha actual.');
    END IF;
	--
    -- 07/02/08: Se desactivo esta verificacion 
--	-- 02/03/2007 - AC 008879 - Se agrego validación de documentos asociados sin haber sido devueltos
--	FOR R_DOCREF IN C_DOCREF LOOP 
--		IF R_DOCREF.StsDoc = 'VER' THEN
--		    CREA_MSG('Existe documento asociado (' || R_DOCREF.IdDoc || ') con estatus VER');
--		END IF;
--    END LOOP;
	
	--
    -- VR 18/02/2005 para que pase por registrar sin qeu envie el mensaje

   IF NOT PROC_DOCUMENTOS.VALIDA_VER(R_DOC.Ano, R_DOC.EfectPago) THEN
      IF R_DOC.Periodo > vNumPerAno THEN
         CREA_MSG('El periodo del Documento debe ser menor o igual a los períodos definidos para el ejercicio');
      END IF;
   END IF;

    -- MV 07/05/2004: No estaba validando correctamente el estatus del ejercicio
    -- En formulación no se puede hacer nada
    IF cSts = 'FOR' THEN
      CREA_MSG('El ejercicio está en formulación, no se pueden procesar documentos.');

    -- En complementario, sólo sin afectar el compromiso
    ELSIF cSts = 'COM' THEN
      IF R_DOC.EfectComprom <> 'N' THEN
        CREA_MSG('El ejecicio está en período complementario, no se puede afectar el compromiso');
      END IF;

    -- Cerrado, sólo si afectan pago, para poder registrar
    ELSIF cSts = 'CER' THEN
      IF  R_DOC.EfectComprom = 'N'
      AND R_DOC.EfectEjec = 'N'
      AND R_DOC.EfectPago <> 'N' THEN
        NULL; -- OK
        vEfecPPTO := FALSE; -- IF 19/10/05: No afecta el presupuesto
      ELSE
        CREA_MSG('El ejecicio está cerrado, no se puede afectar el compromiso ni causado');
      END IF;

    END IF;

    -- MV 17/06/2004 (DEF#155) se comentó por error la validación que está mas abajo
    IF cSts IN ('EJE', 'COM')
    AND R_DOC.Periodo < nUltPeriodo THEN
    --
    -- IF 07/04/05: Solo se pueden aceptar los documentos "DEV" de periodos cerrados
      IF R_DOC.StsDoc != 'DEV' THEN
        CREA_MSG('El periodo Presupuestario ya esta cerrado');
      END IF;
    END IF;

--     IF cSts NOT IN ('EJE','COM') THEN
--       IF (cSts = 'CER' AND NVL(R_DOC.EfectPago,'N') = 'N') THEN
--         CREA_MSG('El periodo presupuestario no esta en Ejecucion');
--       END IF;
--     ELSE
--       IF R_DOC.IdDocRef IS NULL AND cSts != 'EJE' THEN
--         CREA_MSG('No se pueden establecer nuevos compromisos para este ejercicio!.');
--       ELSE
--         IF R_DOC.Periodo < nUltPeriodo THEN
--           CREA_MSG('El periodo Presupuestario ya esta cerrado');
--           --BM15/08/00: Temporal requerido por TSJ
--           --ELSIF R_DOC.Periodo > nUltPeriodo + 6 THEN
--           -- MV 14/03/2003: Eliminada la validación, dificulta la ejecución de los
--           -- scripts de prueba
--           -- ELSIF R_DOC.Periodo > nUltPeriodo + 12 THEN
--           --  CREA_MSG('El periodo es invalido. Supera los 12 meses de horizonte de cierre');
--         END IF;
--       END IF;
--     END IF;

    -- MRM 26/09/03 Si no es una devolución se valida que el indicador de referencia y el IdDocRef
    -- sean consistentes
    -- MRM 10/03/04 Se corrige error, ya que no se tomaba en cuenta los reversos
    IF R_DOC.StsDoc != 'DEV' THEN
      IF NVL(R_TIPODOC.IndRefDoc,'N') = 'N' AND
         R_DOC.IndReverso = 'N' AND
         R_DOC.IdDocRef IS NOT NULL THEN
         CREA_MSG('ERROR de configuración, el tipo de documento indica que no debe tener referencia pero ' ||
                  'el documento tiene IdDocRef!');
      END IF;
      IF R_DOC.IndReverso = 'S' AND
         R_DOC.IdDocRef IS NULL THEN
         CREA_MSG('ERROR DATOS: El documento es un reverso y no tiene indicado el IdDocRef!');
      END IF;
      IF NVL(R_TIPODOC.IndRefDoc,'N') = 'S' AND
         R_DOC.IdDocRef IS NULL THEN
         CREA_MSG('ERROR de configuración, el tipo de documento indica que debe tener referencia pero ' ||
                  'el documento NO tiene IdDocRef!');
      END IF;
      -- MRM 26/09/03 Comentado en el bloque siguiente y colocado aquí
      IF R_DOC.IdDocRef IS NULL AND
         (R_DOC.EfectRes = 'D' OR
          R_DOC.EfectComprom = 'D' OR
          R_DOC.EfectEjec = 'D' OR
          R_DOC.EfectPago = 'D') THEN
          CREA_MSG('ERROR de configuración, el documento tiene efectos que disminuyen pero no tiene IdDocRef!');
      END IF;
    END IF;
    --
    -- Validamos los efectos e IdDocRef que no sea una devolucion
/*    IF R_DOC.IdDocRef IS NULL AND
     R_DOC.StsDoc != 'DEV' AND
       (R_DOC.EfectRes = 'D' OR
        R_DOC.EfectComprom = 'D' OR
        R_DOC.EfectEjec = 'D' OR
        R_DOC.EfectPago = 'D') THEN
        CREA_MSG('ERROR de configuración, el documento tiene efectos que disminuyen pero no tiene IdDocRef!');
    END IF;*/

    nSumMonto := 0;
    FOR R_CTAS IN C_CTAS LOOP
      nSumMonto := R_CTAS.MONTO + nSumMonto;
    END LOOP;

    IF nSumMonto != R_DOC.MtoDoc THEN
      CREA_MSG('Los montos de las cuentas no corresponden con el monto del documento!');
    END IF;

    -- Validamos la clase de las cuentas del documento si es necesario
    R_DEF := PROC_TIPODOCPPTO.DEF(R_DOC.TipoDoc);

    IF R_DEF.ClaseCta IS NOT NULL THEN
      FOR R_CTAS_CLASE IN C_CTAS_CLASE(pIdDoc, R_DEF.ClaseCta) LOOP
        CREA_MSG('La cuenta "' || R_CTAS_CLASE.CodCta ||
                 '" no está asociada a la clase "' || R_DEF.ClaseCta || '", ' ||
                 'no se puede procesar por este tipo de documento!');
      END LOOP;
    END IF;

    BEGIN
      SELECT IndCodTrans
      INTO vIndCodTrans
      FROM TIPOS_DOC_PPTO
      WHERE TipoDoc = R_DOC.TipoDoc;

      IF vIndCodTrans = 'S' AND R_DOC.CodTrans IS NULL THEN
        CREA_MSG('Debe indicar el código de clasificación');
      END IF;
    END;

    IF R_DOC.IdDocRef IS NOT NULL THEN
      BEGIN
        -- MV 04/04/2002: Para validar Sts y reversos
        SELECT Ano, TipoComprom, NivelComprom,
               NumBenef, FecDoc, Periodo, StsDoc, IndReverso
        INTO   nAnoRef, vTipoComprom, vNivelComprom,
               vNumBenef, vFecDoc, vPeriodo, vStsDoc, vIndReverso
        FROM DOCS_PRESUP
        WHERE IdDoc = R_DOC.IdDocRef;

        IF nAnoRef != nAno THEN
          CREA_MSG('El Año del Documento debe ser igual al de su Referencia');
        END IF;

        IF TO_CHAR(R_DOC.FecDoc,'YYYY') > nAnoRef AND R_DOC.Periodo < 13 THEN
          CREA_MSG('El periodo del Documento debe ser Periodo Complementario');
        END IF;

        --
        -- BM 24/03/00 Las fechas y períodos de los hijos no deben ser posteriores
        -- a las fechas y períodos de los padres.
        -- EH 10112000: Se coloca el truncate para eliminar la hora.
        IF TRUNC(R_DOC.FecDoc) < TRUNC(vFecDoc) THEN
          CREA_MSG('La fecha del Documento: '|| TO_CHAR(R_DOC.FecDoc,'DD/MM/RRRR') ||
           ' debe ser posterior o igual a la de su Referencia: '|| TO_CHAR(vFecDoc,'dd/mm/rrrr'));
        END IF;

        IF R_DOC.Periodo < vPeriodo THEN
          CREA_MSG('El periodo del Documento debe ser posterior o igual al de su Referencia');
        END IF;
        --
        -- IF 19/10/05: El mensaje debe presentarce si el documento tiene algun efecto en presupuesto
        -- MV 04/04/2002: El padre debe estar verificado
        -- VN 14/09/2005  Se le agregó la condición para validar que el padre tambien puede estar devuelto.
        IF (vStsDoc NOT IN ('VER','DEV') AND vEfecPPTO ) THEN
          CREA_MSG('El documento de referencia debe estar verificado o devuelto');
        END IF;

        -- MV 04/04/2002: No se puede procesar el reverso de un reverso
        IF R_DOC.Indreverso = 'S' AND vIndReverso = 'S' THEN
          CREA_MSG('No se puede procesar el reverso de un reverso');
        END IF;

        --
        --BM 06/04/00 Cuando el documento establece compromiso el tipo de compromiso
        --no debe tomarse del documento de referencia.
        IF R_DOC.IndEstComprom = 'N' THEN
          IF R_DOC.TipoComprom != vTipoComprom THEN
            CREA_MSG('El Tipo Compromiso es DISTINTO al de Referencia. Reprocese');
          END IF;
        END IF;
        
        --
        -- IF 27/02/08: Se puede presentar una disminucion o aumento de reserva con otro 
        -- beneficiario 
        --BM 06/11/00: Si el doc. establece compromiso se peude modificar el beneficiario del mismo.
        --Modificaciones por incorporación de manejo de reservas en logística.
        IF R_DOC.NumBenef != vNumBenef AND
            R_DOC.NumBenef != '99999999' AND
            vNumBenef != '99999999'      AND 
            R_DOC.EfectRes not in ('D','A') THEN
            CREA_MSG('El Beneficiario es DISTINTO al de Referencia. Reprocese');
        END IF;
        

        IF R_DOC.NivelComprom != vNivelComprom THEN
          CREA_MSG('El Nivel Compromiso es DISTINTO al de Referencia. Reprocese');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          CREA_MSG('El documento de Referencia NO EXISTE');
      END;

      --
      --BM 18/05/00 Se debe validar que un documento tenga las mismas
      --combinaciones de AI, CC y Cta que el documento padre.
      FOR R_CTA IN C_CTA LOOP
        BEGIN
          SELECT 1
          INTO   vExiste
          FROM   CTAS_DOC
          WHERE  IdDoc = R_DOC.IdDocRef AND
                 CodCta = R_CTA.CodCta AND
                 CodAccInt = R_CTA.CodAccInt  AND
                 CCosto = R_CTA.CCosto;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            CREA_MSG('La combinación de Cta: '||R_CTA.CodCta||',  A.I: '||
                     R_CTA.CodAccInt||' y C.C: '||R_CTA.CCosto||
                     ' NO EXISTE en el Documento de Referencia');
        END;
      END LOOP;

    --
    ELSE
      IF NVL(R_DOC.IndEstComprom, 'N') <> 'S' AND
         R_DOC.TipoComprom != 'R' THEN

        IF NOT vAfectaFondo THEN
          CREA_MSG('Definición errónea del tipo de documento. Debe establecer '
                 || 'compromiso o tener documento de referencia');
        END IF;
      END IF;
    END IF;

	
    --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VALDOC','cMensaje = '|| cMensaje );
	
    cMensaje := VER_MENSAJE;

    IF cMensaje IS NULL THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;

  END;

/*************************************************************************/
/* Realiza las actualizaciones relacionadas con las cuentas del documento */
/*************************************************************************/
PROCEDURE ACTCTASDOC (R_DOC PROC_PRESUP.C_DOC%ROWTYPE) IS
  -- MV 09/06/00: Para tomar en cuenta los montos agrupando por C.C de formulación
  -- Cuentas del documento agrupadas por Centro de costo de formulación
  CURSOR C_CTA(pIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT CodCta,
           PROC_PRESUP.CCOSTO_FORMULACION(CCosto, DP.Ano) CCosto,
           CodPrograma,
           CodAccInt,
           SUM(Monto) Monto
    FROM   CTAS_DOC CD,
           DOCS_PRESUP DP
    WHERE  DP.IDDOC = pIdDoc AND
           CD.IdDoc = DP.IdDoc
    GROUP BY CodCta,
             PROC_PRESUP.CCOSTO_FORMULACION(CCosto, DP.Ano),
             CodPrograma,
             CodAccInt;

  -- ER 12/01/2004.. Datos de ejecución
  CURSOR C_EJE(cAno EJS_PRESUP.Ano%TYPE) IS
    SELECT CtrlDispCta
    FROM EJS_PRESUP
    WHERE Ano = cAno;

    R_EJE C_EJE%ROWTYPE;

BEGIN
  --
  -- ER 12/01/2004..Buscamos los datos del periodo presupuestario
  OPEN  C_EJE(R_DOC.Ano);
  FETCH C_EJE INTO R_EJE;
  CLOSE C_EJE;


  IF R_DOC.EfectRes   != 'N' OR
     R_DOC.EfectComprom != 'N' OR
     R_DOC.EfectEjec != 'N' OR
     R_DOC.EfectPago != 'N' THEN
    -- MV 09/06/00: Se cambió para que trabaje agrupando por el C.C. de formulación
    DBMS_OUTPUT.PUT_LINE('antes cursor ' || R_DOC.iddoc);

    FOR R_CTA IN C_CTA(R_DOC.IdDoc) LOOP  --29/12/99YCARREÑO:Se agregó el bucle con la finalidad de envias a los procedimientos
                                                   --los parámetros del cursor C_CTA
      IF R_DOC.StsDoc != 'DEV' THEN --BM 25/02/00 Si es una devolución no se actualiza el precompromiso.
        ACTPRECOMP(R_DOC,'R',R_CTA);
      END IF;
      -- 29/12/99YCARREÑO:Se agregaron los parámetros R_CTA.IdDoc, R_CTA.CodAccInt, R_CTA.CodCta, R_CTA.Ccosto,
      -- R_CTA.CodPrograma y R_CTA.Monto
      PROC_ACCINT.ACT_DISPON(R_DOC, R_CTA.CodAccInt, R_CTA.CodCta,
                             R_CTA.CCosto, R_CTA.CodPrograma, R_CTA.Monto);
    END LOOP;

      PROC_CTAS_PPTO.ACT_CODPROG(R_DOC);
    --
    --ER 12/01/2004.. Verifico si la disponibilidad es de tipo DETALLES o  CONTROL
    --ER 26/04/2004.. Se agrego condición que valide si hay algun efecto de reserva o compromiso
    IF R_EJE.CtrlDispCta = 'C'
    AND (R_DOC.EfectRes   != 'N' OR
         R_DOC.EfectComprom != 'N') THEN
      PROC_CTAS_PPTO.ACT_CODPROG_CTRL(R_DOC);
      PROC_ACCINT.ACT_ACCINT_CTRL(R_DOC);
    END IF;
    DBMS_OUTPUT.PUT_LINE('antes ACT_DISPON_COMP ' || R_DOC.iddoc);
    PROC_CTAS_PPTO.ACT_DISPON_COMP(R_DOC);
  END IF;
END;
/*********************************************************************/
/* ACTPRECOMP --Actualiza el Monto de "EN PROCESO" para la Cuenta.   */
/* El TipoAct indica si se aumenta el "EN PROCESO" o se Reversa (A-R)*/
/* depende quien lo invoque: La Codificacion o la Verificacion       */
/*********************************************************************/
PROCEDURE ACT_PRECOMPROMISO (R_DOC PROC_PRESUP.C_DOC%ROWTYPE, pTipoAct IN VARCHAR2,
                             R_CTA PROC_PRESUP.C_CTA%ROWTYPE) IS
--R_CTA PROC_PRESUP.C_CTA%ROWTYPE;
BEGIN
  IF R_DOC.EfectComprom IN ('A','D') THEN -- Afecta Compromiso
    IF (pTipoAct = 'A' AND R_DOC.EfectComprom = 'A') OR
      (pTipoAct = 'R' AND R_DOC.EfectComprom = 'D') THEN
      IF R_DOC.NivelComprom = 'C' THEN -- Aumenta el Nivel Central
      --FOR R_CTA IN PROC_PRESUP.C_CTA(R_DOC.IdDoc) LOOP BM 03/01/2000 MODF. PPTO
          UPDATE CTAS_COD_PROG
          SET PreCompNc = NVL(PreCompNc,0) + R_CTA.Monto --29/12/99YCARREÑO: Se cambió R_DOC.MtoDoc por R_CTA.Monto
          WHERE Ano = R_DOC.Ano AND
                CodPrograma = R_CTA.CodPrograma AND --29/12/99YCARREÑO: Se cambió R_DOC.CodPrograma por R_CTA.CodPrograma
                CodCta = R_CTA.CodCta;
        --END LOOP;
      ELSE -- Aumenta el Nivel Basico
        --FOR R_CTA IN PROC_PRESUP.C_CTA(R_DOC.IdDoc) LOOP
          UPDATE CTAS_COD_PROG
          SET PreCompNb = NVL(PreCompNb,0) + R_CTA.Monto --29/12/99YCARREÑO: Se cambió R_DOC.MtoDoc por R_CTA.Monto
          WHERE Ano     = R_DOC.Ano AND
                CodPrograma = R_CTA.CodPrograma AND --29/12/99YCARREÑO: Se cambió R_DOC.CodPrograma por R_CTA.CodPrograma
                CodCta  = R_CTA.CodCta;
        --END LOOP;
      END IF;
    --
    --BM 14/03/00 Se actualiza (Aumenta)el Precompromiso a nivel de Acción Interna.
    BEGIN
      UPDATE CTAS_CCOSTO_ACC_INT
      SET PreComprom = NVL(PreComprom,0) + R_CTA.Monto
      WHERE Ano       = R_DOC.Ano AND
            CCosto    = R_CTA.CCosto AND
            CodAccInt = R_CTA.CodAccInt AND
            CodCta    = R_CTA.CodCta;
    EXCEPTION
      WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR
            (-20202,'Problemas al actualizar CTAS_CCOSTO_ACC_INT.'|| SQLERRM||R_CTA.CCosto);
      END;
      IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR
          (-20223,'No se encontro el registro para ser actualizado '
          ||'en la tabla CTAS_CCOSTO_ACC_INT.' || SQLERRM||R_CTA.CCosto);
        END IF;
    --
    ELSIF (pTipoAct = 'A' AND R_DOC.EfectComprom = 'D') OR
          (pTipoAct = 'R' AND R_DOC.EfectComprom = 'A') THEN
      IF R_DOC.NivelComprom = 'C' THEN -- Disminuye Nivel Central
        --FOR R_CTA IN PROC_PRESUP.C_CTA(R_DOC.IdDoc) LOOP
          UPDATE CTAS_COD_PROG
          SET PreCompNc = NVL(PreCompNc,0) - R_CTA.Monto --29/12/99YCARREÑO: Se cambió R_DOC.MtoDoc por R_CTA.Monto
          WHERE Ano     = R_DOC.Ano AND
                CodPrograma = R_CTA.CodPrograma AND --29/12/99YCARREÑO: Se cambió R_DOC.CodPrograma por R_CTA.CodPrograma
                CodCta  = R_CTA.CodCta;
        --END LOOP;
      ELSE  -- Disminuye el Nivel Basico
        --FOR R_CTA IN PROC_PRESUP.C_CTA(R_DOC.IdDoc) LOOP
          UPDATE CTAS_COD_PROG
          SET PreCompNb = NVL(PreCompNb,0) - R_CTA.Monto --29/12/99YCARREÑO: Se cambió R_DOC.MtoDoc por R_CTA.Monto
          WHERE Ano     = R_DOC.Ano AND
                CodPrograma = R_CTA.CodPrograma AND --29/12/99YCARREÑO: Se cambió R_DOC.CodPrograma por R_CTA.CodPrograma
                CodCta  = R_CTA.CodCta;
        --END LOOP;
      END IF;
        --
    --BM 14/03/00 Se actualiza (Disminuye)el Precompromiso a nivel de Acción Interna.
    BEGIN
      UPDATE CTAS_CCOSTO_ACC_INT
      SET PreComprom = NVL(PreComprom,0) - R_CTA.Monto
      WHERE Ano       = R_DOC.Ano AND
          CCosto    = R_CTA.CCosto AND
              CodAccInt = R_CTA.CodAccInt AND
              CodCta    = R_CTA.CodCta;
    EXCEPTION
      WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR
            (-20204,'Problemas al actualizar CTAS_CCOSTO_ACC_INT.'|| SQLERRM||R_CTA.CCosto);
      END;
      IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR
          (-20224,'No se encontro el registro para ser actualizado ' ||
          'en la tabla CTAS_CCOSTO_ACC_INT.' ||SQLERRM||R_CTA.CCosto);
        END IF;
    --
    END IF;
  END IF;
END;
/********************************************************************/
/* PROCEDIMIENTO DE ACTUALIZACION DE EN PROCESO CON EL IDDOC        */
/********************************************************************/
PROCEDURE ACTPRECOMP (pIdDoc NUMBER, pTipoAct IN VARCHAR2) IS
R_DOC PROC_PRESUP.C_DOC%ROWTYPE;
BEGIN
  OPEN PROC_PRESUP.C_DOC(pIdDoc);
  FETCH PROC_PRESUP.C_DOC INTO R_DOC;
  CLOSE PROC_PRESUP.C_DOC;
  --BM 16/08/00:Cursor con las ctas y el Ccosto de formulación
  FOR R_CTACCF IN C_CTACCF(pIdDoc) LOOP
    ACT_PRECOMPROMISO(R_DOC,pTipoAct,R_CTACCF);
  END LOOP;
END;
/********************************************************************/
/* PROCEDIMIENTO DE ACTUALIZACION DE EN PROCESO CON EL REGISTRO     */
/********************************************************************/
PROCEDURE ACTPRECOMP (R_DOC PROC_PRESUP.C_DOC%ROWTYPE, pTipoAct IN VARCHAR2,
                      R_CTA PROC_PRESUP.C_CTA%ROWTYPE) IS
BEGIN
  ACT_PRECOMPROMISO(R_DOC,pTipoAct,R_CTA);
END;
--
-- MV 14/11/2001: Validación adicional requerida para poder verificar
/************************************************************************************
* NO_CHK_HIJOS_PEND - Valida que, si el efecto del documento es de rebaja, no existan
* hijos (del padre) pendientes por verificar (REC, COD, RCH), para evitar que éstos
* puedan quedar sin disponibilidad para verificarlos.
************************************************************************************/
FUNCTION NO_CHK_HIJOS_PEND (pIdDoc DOCS_PRESUP.IdDoc%TYPE) RETURN BOOLEAN IS
-- Hijos pendientes del documento
CURSOR C_HP (pIdDocPadre DOCS_PRESUP.IdDoc%TYPE,
             pIdDocHijo DOCS_PRESUP.IdDoc%TYPE) IS
  SELECT IdDoc, IdDocRef, TipoDoc, StsDoc
  FROM   DOCS_PRESUP
  WHERE  StsDoc IN ('REC', 'RCH', 'COD')
  AND    IdDoc <> pIdDocHijo -- Debemos obviar el doc. que estamos verificando
  AND    IdDocRef <> pIdDocPadre -- Debemos obviar los docs. con el mismo padre (o sea, hermanos)
  CONNECT BY IdDocRef = PRIOR IdDoc
  START WITH IdDoc = pIdDocPadre;
  --
  vOk         BOOLEAN := TRUE;
  vIdDocPadre DOCS_PRESUP.IdDoc%TYPE;
  R_DOC       PROC_PRESUP.C_DOC%ROWTYPE;
BEGIN
  --
  IF PROC_PRESUP.C_DOC%ISOPEN THEN
    CLOSE PROC_PRESUP.C_DOC;
  END IF;
  OPEN PROC_PRESUP.C_DOC(pIdDoc);
  FETCH PROC_PRESUP.C_DOC INTO R_DOC;
  --
  IF PROC_PRESUP.C_DOC%NOTFOUND THEN
    CREA_MSG('No se encontró la definición del efecto presupuestario!');
    vOk := FALSE;
  END IF;
  -- Se puso el CLOSE aquí para evitar que pueda quedar abierto
  CLOSE PROC_PRESUP.C_DOC;
  --
  -- Si el efecto del documento es de rebaja
  IF R_DOC.EfectComprom = 'D' OR
     R_DOC.EfectEjec    = 'D' OR
     R_DOC.EfectPago    = 'D' THEN
    -- Si el PADRE tiene hijos pendientes
    SELECT IdDocRef
    INTO   vIdDocPadre
    FROM   DOCS_PRESUP
    WHERE  IdDoc = pIdDoc;
    --
    FOR R_HP IN C_HP(vIdDocPadre, pIdDoc) LOOP
      vOk := FALSE;
      --
      CREA_MSG('El documento ' || R_HP.IdDoc || ' (' || R_HP.TipoDoc || ', ' || R_HP.StsDoc ||
               ') "hijo" de ' || R_HP.IdDocRef || ' no está verificado.');
    END LOOP;
    --
    IF NOT vOk THEN
      CREA_MSG('Debe verificar esos documentos antes de procesar este!');
    END IF;
  END IF;
  --
  RETURN( vOk );
END NO_CHK_HIJOS_PEND;
/*************************************************************************/
/* Realiza las actualizaciones relacionadas con las cuentas del documento */
/*************************************************************************/
PROCEDURE GEN_MOV_CONT (pIdDoc DOCUMENTOS_ORIGEN.IdDoc%TYPE,
                        pTipoGenContab EJS_PRESUP.TIPOGENCONTAB%TYPE) IS
  CURSOR C_CTA_C(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT CTA.CtaContab, CTA.CodAuxContab, SUM(Monto) Monto, CTA.IndDistribMto, DP.CodMonedaMtoDoc
    FROM   CTAS_DOC CD,
           DOCS_PRESUP DP,
		   CTAS_PRESUP CTA
    WHERE  DP.IdDoc = cIdDoc AND
           CD.IdDoc = DP.IdDoc AND
		   CTA.CodCta = CD.CodCta
    GROUP BY CTA.CtaContab,
             CTA.CodAuxContab,
             CTA.IndDistribMto,
			 DP.CodMonedaMtoDoc;

  CURSOR C_CTA_P(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT CD.CodCta, SUM(Monto) Monto ,DP.CodMonedaMtoDoc
    FROM   CTAS_DOC CD,
           DOCS_PRESUP DP
    WHERE  DP.IdDoc = cIdDoc AND
           CD.IdDoc = DP.IdDoc
    GROUP BY CD.CodCta,
          DP.CodMonedaMtoDoc;

  CURSOR C_DOC (cIdDoc NUMBER) IS
    SELECT *
    FROM   DOCUMENTOS_ORIGEN
    WHERE  IdDoc = cIdDoc;

  --
  -- RA 08/11/2004: Tipo registro de la tabla
  TYPE REC_CTA IS RECORD(
       rIdDoc             MOV_CONT_ADIC.IdDoc%TYPE,
       rNumMov            MOV_CONT_ADIC.NumMov%TYPE,
       rCodCuenta         MOV_CONT_ADIC.CodCuenta%TYPE,
       rCodAuxiliar       MOV_CONT_ADIC.CodAuxiliar%TYPE,
       rMonto             MOV_CONT_ADIC.Monto%TYPE,
	   rCodMonedaMtoDoc   DOCS_PRESUP.CodMonedaMtoDoc%TYPE	   
    );
  --
  -- RA 08/11/2004: Arreglo para generar las confirmaciones de pago
  TYPE TAB_CTA_S IS TABLE OF REC_CTA INDEX BY BINARY_INTEGER;

  -- RA 08/11/2004: Arreglo para generar las confirmaciones de pago
  TYPE TAB_CTA_N IS TABLE OF REC_CTA INDEX BY BINARY_INTEGER;


  T_CTA_S      TAB_CTA_S; -- Declaramos e inicializamos el arreglo
  T_CTA_N      TAB_CTA_N;
  R_CTA_S      REC_CTA;
  R_CTA_N      REC_CTA;
  vRegS        BINARY_INTEGER := 0;
  vRegN        BINARY_INTEGER := 0;
  vMtoRef      MOV_CONT_ADIC.Monto%TYPE;
  vMtoDist     MOV_CONT_ADIC.Monto%TYPE;
  vDistribuir  MOV_CONT_ADIC.Monto%TYPE;
  vValor       MOV_CONT_ADIC.Monto%TYPE;
  vMonto       MOV_CONT_ADIC.MONTO%TYPE;

  vNumMov MOV_CONT_ADIC.NumMov%TYPE := 0;

  R_DOC     C_DOC%ROWTYPE;
  R_TIPODOC PROC_TIPODOCPPTO.C_DEF%ROWTYPE;

BEGIN

   OPEN  C_DOC(pIdDoc);
   FETCH C_DOC INTO R_DOC;
   CLOSE C_DOC;

  -- ABR 14/05/2004 100391. Elimina lo que exista si existe
  BEGIN
    DELETE MOV_CONT_ADIC
	WHERE IdDoc = pIdDoc;
  END;

 -- IFLORES 04/01/2006: Función de configuración contexto
  PROC_CTX_PPTO.SETPLANCTAANO(R_DOC.Ano);

  IF pTipoGenContab = 'C' THEN -- Genera con el Codigo de Cuenta CONTABLE

     R_TIPODOC := PROC_TIPODOCPPTO.DEF(R_DOC.TipoDoc);

     IF R_TIPODOC.IndDistribMto = 'S' THEN

        FOR R_CTA IN C_CTA_C(pIdDoc) LOOP
            vNumMov := vNumMov + 1;
            -- Se llena el registro con solo los registros marcados para imprimir
            IF R_CTA.IndDistribMto = 'S' THEN
               R_CTA_S.rIdDoc           := pIdDoc;
               R_CTA_S.rNumMov          := vNumMov;
               R_CTA_S.rCodCuenta       := R_CTA.CtaContab;
               R_CTA_S.rCodAuxiliar     := R_CTA.CodAuxContab;
               R_CTA_S.rMonto           := R_CTA.Monto;
			   R_CTA_S.rCodMonedaMtoDoc := R_CTA.CodMonedaMtoDoc;
               --
               vMtoDist             := NVL(vMtoDist ,0) + NVL(R_CTA.Monto, 0);
               --
               vRegS := vRegS + 1;

               -- Se asigna la informacion del registro a la posicion del arreglo
               T_CTA_S(vRegS) := R_CTA_S;
            ELSIF R_CTA.IndDistribMto = 'N' THEN
                  R_CTA_N.rIdDoc       := pIdDoc;
                  R_CTA_N.rNumMov      := vNumMov;
                  R_CTA_N.rCodCuenta   := R_CTA.CtaContab;
                  R_CTA_N.rCodAuxiliar := R_CTA.CodAuxContab;
                  R_CTA_N.rMonto       := R_CTA.Monto;
				  R_CTA_N.rCodMonedaMtoDoc := R_CTA.CodMonedaMtoDoc;
                  --
                  vMtoRef              := NVL(vMtoRef ,0) + NVL(R_CTA.Monto,0);
                  --
                  vRegN := vRegN + 1;

                  -- Se asigna la informacion del registro a la posicion del arreglo
                  T_CTA_N(vRegN) := R_CTA_N;
            END IF;
        END LOOP;

        --
        -- Se recorre el arreglo para validaciones iniciales
        FOR i IN 1..vRegN LOOP
            --
            --
            vDistribuir := (NVL(T_CTA_N(i).rMonto,0) / NVL(vMtoRef,0)) * NVL(vMtoDist,0);
            vMtoDist    := NVL(vMtoDist,0) - NVL(vDistribuir ,0);
            vMtoRef     := NVL(vMtoRef,0)  - NVL(T_CTA_N(i).rMonto,0);
            vValor      := NVL(T_CTA_N(i).rMonto,0) + NVL(vDistribuir,0);
			
			IF T_CTA_N(i).rCodMonedaMtoDoc <> R_DOC.CodMonedaMtoDoc THEN
			   vValor := PROC_RECONV_KNT.MONTO_REEXPRESADO(vValor,T_CTA_N(i).rCodMonedaMtoDoc,R_DOC.CodMonedaMtoDoc); 
			END IF;
			
            --
            --
            INSERT INTO MOV_CONT_ADIC
              (IdDoc, NumMov, CodCuenta, CodAuxiliar, Monto)
            VALUES
              (T_CTA_N(i).rIdDoc, T_CTA_N(i).rNumMov, T_CTA_N(i).rCodCuenta, T_CTA_N(i).rCodAuxiliar, vValor);
            --
        END LOOP;
    ELSE
        FOR R_CTA IN C_CTA_C(pIdDoc) LOOP
            vNumMov := vNumMov + 1;
			
			IF R_CTA.CodMonedaMtoDoc <> R_DOC.CodMonedaMtoDoc THEN
			   vMonto := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_CTA.Monto,R_CTA.CodMonedaMtoDoc,R_DOC.CodMonedaMtoDoc);
			ELSE
			   vMonto := R_CTA.Monto;
			END IF;
			
            INSERT INTO MOV_CONT_ADIC
              (IdDoc, NumMov, CodCuenta, CodAuxiliar, Monto)
            VALUES
              (pIdDoc, vNumMov, R_CTA.CtaContab, R_CTA.CodAuxContab, vMonto);
        END LOOP;
     END IF;
  ELSIF pTipoGenContab = 'P' THEN -- Genera con el Codigo de Cuenta PRESUPUESTARIA
        FOR R_CTA IN C_CTA_P(pIdDoc) LOOP
            vNumMov := vNumMov + 1;
			
			IF R_CTA.CodMonedaMtoDoc <> R_DOC.CodMonedaMtoDoc THEN
			   vMonto := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_CTA.Monto,R_CTA.CodMonedaMtoDoc,R_DOC.CodMonedaMtoDoc);
			ELSE
			   vMonto := R_CTA.Monto;
			END IF;
						
            INSERT INTO MOV_CONT_ADIC
              (IdDoc, NumMov, CodCuenta, Monto)
            VALUES
              (pIdDoc, vNumMov, R_CTA.CodCta, vMonto);
        END LOOP;
  ELSE
    RAISE_APPLICATION_ERROR(-20150,'Error, el valor del campo de configuración Tipo de Generación esta vacio');
  END IF;
END GEN_MOV_CONT;
--------------------------------------------------------------------------------
-- PROCEDIMIENTO DE ACTUALIZACION INFORMACION TIPO Y NIVEL DE COMPROMISO  
--
PROCEDURE ACT_INF_TIPNIVCOMPROM (pIdDoc IN DOCS_PRESUP.IdDoc%TYPE) IS
 --
 -- Arbol de documentos  
 CURSOR C_DOCA (cIdDoc IN DOCS_PRESUP.IdDoc%TYPE) IS  
  SELECT NumComprom,
		TipoComprom, 
		NivelComprom
  FROM  DOCS_PRESUP
  WHERE StsDoc IN ('VER','DEV','REG')
  CONNECT BY IdDoc = PRIOR IdDocRef
  START WITH IdDoc = cIdDoc; 
 
  R_DOCA C_DOCA%ROWTYPE;
                                
BEGIN
  FOR R_DOCA IN C_DOCA(pIdDoc) LOOP
     --
	 -- Verifico cual tipo y nivel usar del arbol	  
     IF R_DOCA.TipoComprom IS NOT NULL AND nvl(R_DOCA.NivelComprom,'N') != 'N' THEN
	   --
	   -- Asigno informacion del primero que se encuentre 
	   UPDATE DOCS_PRESUP
	   SET TipoComprom  = R_DOCA.TipoComprom,
		   NivelComprom = R_DOCA.NivelComprom
	   WHERE IdDoc = pIdDoc;
	   --
	   -- No es necesario seguir buscando
	   --EXIT;
	 END IF;
  END LOOP;
END;
--
/****************************************************/
/* Procedimiento de verificacion de los documentos. */
/* Recibe el numero de documento                    */
/* y llama a los procesos de generacion de          */
/* documentos Originales, compromisos y evento      */
/****************************************************/
FUNCTION VERDOC (pIdDoc IN DOCS_PRESUP.IdDoc%TYPE) RETURN BOOLEAN IS
cParamVer       DEF_EVENTO_CP.ParamVer%TYPE;
cProxSis        GOBSTD.CodSis;
R_DOC           PROC_PRESUP.C_DOC%ROWTYPE;
vValOK          BOOLEAN := FALSE;
nNumComprom     DOCS_PRESUP.NUMCOMPROM%TYPE;
vIndEstComprom  DOCS_PRESUP.IndEstComprom%TYPE;
vIndGenContab   EJS_PRESUP.INDGENCONTAB%TYPE;
vTipoGenContab  EJS_PRESUP.INDGENCONTAB%TYPE;
--
BEGIN
  LIMPIA_MENSAJE;
  -- DBMS_OUTPUT.PUT_LINE('VERDOC ' || piddoc ||' '  || R_DOC.StsDoc );
  --
  -- MV 14/11/2001: Se reorganizó el código para facilitar la lectura y la
  -- inclusión de validaciones adicionales
  --
  -- MV 29/04/2002: Se cambió el nombre de la variable a vValOk para facilitar
  -- la lectura.
  --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' VA A VALDOC');

  
  vValOK := VALDOC(pIdDoc);
  
  --
  IF vValOK THEN
    ---PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' PASO VALDOC VA A DISPONIBILIDAD');
    vValOK := PROC_VERIFICACION.DISPONIBILIDAD (pIdDoc, 'VERIFICA');
  END IF;
  --
  IF vValOK THEN
    --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' PASO VALDOC VA A NO_CHK_HIJOS_PEND');
    vValOK := NO_CHK_HIJOS_PEND(pIdDoc);
  END IF;
  --
  IF vValOK THEN
    IF PROC_PRESUP.C_DOC%ISOPEN THEN
      CLOSE PROC_PRESUP.C_DOC;
    END IF;
    --
    OPEN PROC_PRESUP.C_DOC(pIdDoc);
    FETCH PROC_PRESUP.C_DOC INTO R_DOC;
    --
    IF PROC_PRESUP.C_DOC%NOTFOUND THEN
      CREA_MSG('No se encontró la definición del efecto presupuestario!');
      vValOK := FALSE;
    END IF;
    -- Se puso el CLOSE aquí para evitar que pueda quedar abierto
    CLOSE PROC_PRESUP.C_DOC;
  END IF;
  --
  IF vValOK THEN

    BEGIN
      SELECT ParamVer
      INTO   cParamVer
      FROM   DEF_EVENTO_CP
      WHERE  TipoDoc = R_DOC.TipoDoc AND
             TipoEvento = R_DOC.TipoEvento AND
             CodSisAprob = R_DOC.OrgEvento;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CREA_MSG('ERROR INTERNO: No se encontró la definición del efecto presupuestario!');
        vValOK := FALSE;
    END;
    --
    ---PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC','cParamVer = '|| cParamVer);
		
	
    IF cParamVer IS NOT NULL THEN
      PROCVER(pIdDoc, cParamVer);
    END IF;

	
   --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' R_DOC.StsDoc  = '||  R_DOC.StsDoc );
   	
   ---PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' pIdDoc = '||  pIdDoc  );
      
	
    --
    DBMS_OUTPUT.PUT_LINE('antes R_DOC.StsDoc != DEV ' || piddoc ||' '  || R_DOC.StsDoc );
    IF R_DOC.StsDoc != 'DEV' THEN -- Si no es una devolucion
      -- Actualiza el Numero del Compromiso
      BEGIN
        nNumComprom := R_DOC.NumComprom; -- Carga el Valor Actual
        IF R_DOC.NumComprom IS NULL AND -- No esta asociado a un Comp.
          R_DOC.TipoComprom != 'R' THEN -- y NO es RESERVA
          --
          vIndEstComprom := R_DOC.IndEstComprom;
          IF vIndEstComprom = 'S' AND  -- Establece compromiso
            R_DOC.IndReverso = 'N' THEN -- MV 29/03/00: y no es reverso
            SELECT SQ_NUMCOMPROM.NEXTVAL
            INTO   nNumComprom
            FROM   DUAL;
          ELSE -- Usa el del Padre

            -- MV 29/04/2002: Si tiene IdDocRef (puede no tenerlo si es un
            -- documento que sólo afecta fondos en avance
            IF R_DOC.IdDocRef IS NOT NULL THEN
              SELECT NumComprom
              INTO   nNumComprom
              FROM   DOCS_PRESUP
              WHERE  IdDoc = R_DOC.IdDocRef;
              -- MV 29/03/00: Apagamos IndEstComprom porque si es reverso no aplica
            END IF;

            vIndEstComprom := 'N';
          END IF;
 	      
		  --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' ACTUALIZA INF COMPROMISO' );
		  
          UPDATE DOCS_PRESUP -- Le asigna Numero
          SET    NumComprom = nNumComprom,
                 IndEstComprom = vIndEstComprom
          WHERE  IdDoc = R_DOC.IdDoc;
        END IF;
      END;
      
    END IF;

    --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' ACTCTASDOC' );
	
    --
    ACTCTASDOC(R_DOC);
	
    --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' PROC_VERIFICACION.ACTUALIZA_DOCORIGEN' );

    --Actualiza documento origen con datos del documento presupuestario
    PROC_VERIFICACION.ACTUALIZA_DOCORIGEN(R_DOC.IdDoc);
      
    --
    -- ABR 26/6/03. VERSION 5.5.0
    -- Llama al proceso de generacion de MOV_CONT_ADIC
	BEGIN
	  SELECT IndGenContab, TipoGenContab
	  INTO  vIndGenContab, vTipoGenContab
	  FROM EJS_PRESUP
	  WHERE Ano = R_DOC.Ano;
	EXCEPTION
	  WHEN OTHERS THEN
        CREA_MSG('No se encontró la definición del Ejercicio Presupuestario!');
        vValOK := FALSE;
    END;
	
	--PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.VERDOC',' vIndGenContab = '||  vIndGenContab  );
	
	IF vIndGenContab = 'S' THEN -- Esta configurado para generar inf. contable
      GEN_MOV_CONT(R_DOC.IdDoc,vTipoGenContab);
	END IF;
	
  END IF;
  RETURN (vValOK);
END;
/*****************************************************************/
/* Genera_Reverso. Genera un documento origen de reverso. Recibe */
/* como parámetro el identificador del documento original.       */
/*****************************************************************/
FUNCTION GENERA_REVERSO (pIdDoc DOCS_PRESUP.IdDoc%TYPE)
RETURN NUMBER IS
vOrigen GOBSTD.CodSis;
vIdDoc  KNTSTD.Identificador;
vNivelUsuario  USUARIOS_CP.NivelUsuario%TYPE;
vStsDoc        DOCS_PRESUP.StsDoc%TYPE;
vIndReverso    DOCS_PRESUP.IndReverso%TYPE;
vFecReconv     CONTROL_KNT.FECRECONV%TYPE := PROC_RECONV_KNT.FECHA_RECONV; --JR03-12-2007: Fecha de reconversion
vMontoDoc      DOCS_PRESUP.MtoDoc%TYPE;	 								  --JR03-12-2007: MOnto del Documento
vCodMonedaDoc  CONTROL_KNT.FECRECONV%TYPE;								  --JR03-12-2007: CODMONEDA del documento 
vCodMonedaSys  CONTROL_KNT.FECRECONV%TYPE := PROC_INSTALACION.CODMONEDAINST(trunc(SYSDATE));--JR03-12-2007: CODMONEDA de la fecha actual 

CURSOR C_DOC IS
  SELECT IdDoc, DescDoc, Origen,
         NumBenef, RefDoc, MtoDoc, StsDoc,
         FecDoc, TipoDoc, Ano,
         NumComProm, IdDocRef, CcostoDoc, CodSitio --(*)
  FROM DOCS_PRESUP
  WHERE IdDoc = pIdDoc;
BEGIN
  -- YC23/09/99: Busca el código de la aplicación.
  vOrigen := 'PPTO';
   --vOrigen := APLICACION.OBTIENE_APLIC;
  BEGIN
    SELECT StsDoc, IndReverso
  INTO vStsDoc, vIndReverso
  FROM DOCS_PRESUP
  WHERE IdDoc = pIdDoc;
  END;
  --BM 06/04/00 No se pueden generar reversos de un reverso.
  IF vIndReverso = 'S' THEN
     RAISE_APPLICATION_ERROR
        (-20050,'No se puede generar un Reverso de un documento de Reverso.');
  END IF;
  -- YC>29/09/99: Si el estatus del documento no es VER, no se genera el
  -- el documento reverso.
  IF vStsDoc = 'VER' THEN
    BEGIN
    --YC>29/09/99: Determina si el usuario es Codificador o Supervisor para
    -- generar el documento.
      SELECT NivelUsuario
       INTO vNivelUsuario
    FROM USUARIOS_CP
    WHERE CodUsuario = SUBSTR(USER,1,15)
    AND NivelUsuario IN ('S','C');
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR
        (-20042,'No se generó el documento, el usuario debe ser codificador o supervisor.'
      || SQLERRM);
    END;
    BEGIN
      -- YC23/09/99: Toma el próximo número del documento origen
      SELECT SQ_IdDoc.NEXTVAL
      INTO vIdDoc
      FROM DUAL;
    END;
    FOR R_DOC IN C_DOC LOOP
      BEGIN
      -- Crea el documento origen con los datos del documento presupuestario que
      -- se está reversando.
	  --JRONDON: 03/12/2007, Se crean condiciones para valorar cuando el documento es reverso y que no está dentro de la 
	  --reconversión ni reexpresion monetaria de lo contrario reexpresará los montos a la moneda del sysdate.
	vCodMonedaDoc := PROC_INSTALACION.CODMONEDAINST(trunc(R_DOC.FecDoc));
	IF (R_DOC.FecDoc < vFecReconv) AND (TRUNC(SYSDATE) >= vFecReconv) THEN
	   vMontoDoc := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_DOC.MtoDoc,vCodMonedaDoc,vCodMonedaSys);
   	 
	ELSE
	   vMontoDoc:= R_DOC.MtoDoc;
   
	END IF;--JR03-12-2007: Fin condición de reverso a la reexpresión monetaria dependiendo del sysdate 
	   
        INSERT INTO DOCUMENTOS_ORIGEN
           (IdDoc, DescDoc, Origen, NumBenef,
            RefDoc, MtoDoc, FecDoc, TipoDoc,
          Ano, IndReverso, NumComProm, IdDocRef,
          Ccosto, UsrCre, UsrCod, UsrRec,
		  CodSitio,CodMoneda,Tasa,CodMonedaMtoDoc,MontoOrig)
      VALUES (vIdDoc, 'Reverso ' || SUBSTR(R_DOC.DescDoc,1,52), vOrigen, R_DOC.NumBenef,
          R_DOC.RefDoc, vMontoDoc, SYSDATE, R_DOC.TipoDoc,
          TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')), 'S', R_DOC.NumComProm, pIdDoc,
          R_DOC.CcostoDoc, SUBSTR(USER,1,15), SUBSTR(USER,1,15), SUBSTR(USER,1,15),
		  R_DOC.CodSitio,vCodMonedaSys, 1,vCodMonedaSys,vMontoDoc); --(*)
          -- YC23/09/99: Invoca al mensajero para que genere el documento presupuestario.
          PROC_MENSAJERO.GENERA_DOC(vIdDoc,vOrigen);
    EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR
       (-20040,'Problemas al Insertar en DOCUMENTOS_ORIGEN.' || SQLERRM);
      END;
    END LOOP;
    RETURN(vIdDoc);
  ELSE
    RAISE_APPLICATION_ERROR
       (-20042,'No se puede generar el documento reverso, si el documento no está verificado.'
     || SQLERRM);
  END IF;
END GENERA_REVERSO;

-- MV 03/05/2002: Se movió aquí para que estuviera visible a PROCESA_AUTOMATICOS
/****************************************************************************/
/******** BM 15/02/00 Actualiza CTAS_DOC al REG. un documento ***************/
/****************************************************************************/
PROCEDURE ACTCTAS_DOCREGISTRADO(R_DOC PROC_PRESUP.C_DOC%ROWTYPE, pIdDocRef NUMBER)IS
--
vMtoPago      KNTSTD.Monto := 0;
R_CTA         PROC_PRESUP.C_CTA%ROWTYPE;
R_EJS         C_EJS%ROWTYPE;

--
BEGIN
  -- Lee las cuentas del documento.
  FOR R_CTA IN PROC_PRESUP.C_CTA(R_DOC.IdDoc) LOOP
    vMtoPago  := 0;
    -- Si afecta Pagos
    IF R_DOC.EfectPago = 'A' THEN
      vMtoPago := NVL(R_CTA.Monto,0);
    ELSIF R_DOC.EfectPago = 'D' THEN
      vMtoPago := NVL(R_CTA.Monto,0) * -1;
    END IF;


    OPEN C_EJS(R_DOC.Ano);
    FETCH C_EJS INTO R_EJS;
    CLOSE C_EJS;

    -- Actualiza los Acumulados de las Cuentas de Documentos
    UPDATE CTAS_DOC
    SET PagoAcum  = NVL(PagoAcum,0)  + vMtoPago
    WHERE
        IdDoc = pIdDocRef AND
        CodCta    = R_CTA.CodCta AND
        CodAccInt = R_CTA.CodAccInt AND
        CCosto    = R_CTA.CCosto AND --BM 20/01/00 Modif. por Multi. Imp.
		CodEstruct = R_EJS.CodEstruct; -- Manejo de estructuras

    IF R_DOC.IdDoc = pIdDocRef THEN -- Actualiza los Montos en el Documento Aprobado
      UPDATE CTAS_DOC
      SET PagoDoc  = vMtoPago
      WHERE
          IdDoc = R_DOC.IdDoc AND
          CodCta    = R_CTA.CodCta AND
          CodAccInt = R_CTA.CodAccInt AND
          CCosto    = R_CTA.CCosto AND --BM 20/01/00 Modif. por Multi. Imp.
		  CodEstruct = R_EJS.CodEstruct;
    END IF;
  END LOOP;
END;
--------------------------------------------------------------------------------
-- ACTCTAS_REGISTRO: Actualiza las cuentas del documento presupuestario que se
-- está registrando
-- MR 31/05/2002
PROCEDURE ACTCTAS_REGISTRO (R_DOC PROC_PRESUP.C_DOC%ROWTYPE) IS
-- Cursor con el Documento y sus Superiores.

CURSOR C_DOCP IS
  SELECT IdDoc, IdDocRef, Ano, CodAccIntDoc, CCostoDoc
  FROM DOCS_PRESUP
  CONNECT BY IdDoc = PRIOR IdDocRef
  START WITH IdDoc = R_DOC.IdDoc;

BEGIN
  FOR R_DOCP IN C_DOCP  LOOP
    -- Actualiza la disponibilidad del Documento leido.
    ACTCTAS_DOCREGISTRADO(R_DOC, R_DOCP.IdDocRef);
  END LOOP;
  ACTCTAS_DOCREGISTRADO(R_DOC, R_DOC.IdDoc);
END;
/*****************************************************************************/
/*********BM 15/02/01: Función para registrar documentos**********************/
/*****************************************************************************/
FUNCTION REGDOC (pIdDoc IN DOCS_PRESUP.IdDoc%TYPE) RETURN BOOLEAN IS
cParamVer      DEF_EVENTO_CP.ParamVer%TYPE;
cProxSis       GOBSTD.CodSis;
R_DOC          PROC_PRESUP.C_DOC%ROWTYPE;
vSalida        BOOLEAN := TRUE;
nNumComprom    DOCS_PRESUP.NUMCOMPROM%TYPE;
vIndEstComprom DOCS_PRESUP.IndEstComprom%TYPE;
-- Cursor con el Documento y sus Superiores.
--CURSOR C_DOCP IS
--  SELECT IdDoc, IdDocRef, Ano, CodAccIntDoc, CCostoDoc
--  FROM DOCS_PRESUP
--  CONNECT BY IdDoc = PRIOR IdDocRef
--  START WITH IdDoc = pIdDoc;
--
BEGIN
  LIMPIA_MENSAJE;
  --
  IF VALDOC(pIdDoc) THEN
    IF PROC_VERIFICACION.DISPONIBILIDAD (pIdDoc,'VERIFICA') THEN
      -- 27/05/2003 - RRR - Se verificó que todas las referencias a PROC_PRESUP.C_DOC
      -- en VALDOC y PROC_VERIFICACION.DISPONIBILIDAD fuesen cerradas correctamente.
--      IF PROC_PRESUP.C_DOC%ISOPEN THEN
--        CLOSE PROC_PRESUP.C_DOC;
--      END IF;
      OPEN PROC_PRESUP.C_DOC(pIdDoc);
      FETCH PROC_PRESUP.C_DOC INTO R_DOC;
      -- 27/05/2003 - RRR - Cambio en la lógica de decisión para evitar IF ISOPEN THEN CLOSE
      vSalida := PROC_PRESUP.C_DOC%FOUND;
      CLOSE PROC_PRESUP.C_DOC;
      IF vSalida THEN
        --Actualiza documento origen con datos del documento presupuestario
        PROC_VERIFICACION.ACTUALIZA_DOCORIGEN(R_DOC.IdDoc);
        -- Lee el Documento y sus relacionados superiores.
        ACTCTAS_REGISTRO(R_DOC);
--        FOR R_DOCP IN C_DOCP  LOOP
          -- Actualiza la disponibilidad del Documento leido.
--           ACT_CTAS_DOC(R_DOC, R_DOCP.IdDocRef);
--        END LOOP;
--          ACT_CTAS_DOC(R_DOC, R_DOC.IdDoc);
      END IF;
    ELSE
     vSalida := FALSE;
    END IF;
  ELSE
    vSalida := FALSE;
  END IF;
  -- 27/05/2003 - RRR - Cambio en la lógica de decisión para evitar IF ISOPEN THEN CLOSE
  --  CLOSE PROC_PRESUP.C_DOC;
  RETURN vSalida;
END;

/*************************************************************/
/* PROCESA_AUTOMATICOS - Procesa todos los documentos        */
/* pendientes, que tienen el indicador de proceso automático */
/*************************************************************/
PROCEDURE PROCESA_AUTOMATICOS IS
  CURSOR C_DOC_AUTO IS
    SELECT DISTINCT
      DP.IdDoc, DP.Ano, DEFEV.EfectPago
    FROM
      DOCS_PRESUP DP,
      TIPOS_DOC_PPTO TDP,  
      DEF_EVENTO_CP DEFEV,
      V_EVENTOCP EVE
    WHERE
      DP.TipoDoc = TDP.TipoDoc           AND
      DP.TipoDoc = EVE.TipoDoc           AND  -- La ruta lo trae a PPTO...
      EVE.TipoEvento IN ('PRO', 'GEN')   AND  -- Procesado por otro sistema
      DP.StsDoc IN ( 'PEN', 'REC','RCH') AND  -- Esta pendiente por recibir o rechazados
      TDP.IndProcAuto = 'S'              AND  -- Tiene proceso automático
      DP.IdDocRef IS NOT NULL            AND  -- Tiene documento de referencia
      DEFEV.TipoDoc = TDP.TipoDoc        --AND  
--	  DP.Iddoc = CDOC.Iddoc                   -- JR: 16/04/2008 Documento Con cuentas 
      order by DP.IdDoc;
--	        
  vCodProxSis GOBSTD.CodSis;
  vSts        KNTSTD.Estatus;
  vNivel      USUARIOS_CP.NivelUsuario%TYPE;
  vSuperv     USUARIOS_CP.CodUsuarioSup%TYPE;
  vMensaje    DOCS_PRESUP.Mensaje%TYPE;
  R_DOC       PROC_PRESUP.C_DOC%ROWTYPE;
  vCont       NUMBER;                             
  vLoops 	  NUMBER;
  vSqlCode    NUMBER;
BEGIN
  --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' INI');  
  SELECT NivelUsuario, CodUsuarioSup
  INTO   vNivel, vSuperv
  FROM   USUARIOS_CP
  WHERE  CodUsuario = USER;
  --
  IF vNivel = 'C' THEN
    NULL;
  ELSIF vNivel = 'S' THEN
    vSuperv := USER;
  ELSE
    RAISE_APPLICATION_ERROR(-20400,
      'El usuario debe ser un codificador o supervisor!');
  END IF;
  
  --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' vNivel '|| vNivel);
  --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' vSuperv '|| vSuperv);
  --
  vCont := 0;
  FOR R_DOC_AUTO IN C_DOC_AUTO LOOP
  
  -- MV: Si manejamos una confirmación de pago
  -- puede ser necesario recalcular los montos  
  -- y reintentar el proceso
  -- en especial para las confirmaciones de pago
    IF R_DOC_AUTO.EfectPago <> 'N' THEN
      vLoops := 1;
    ELSE
      vLoops := 2;
    END IF; 
  
    vMensaje :='';

    --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' R_DOC_AUTO.Ano '|| R_DOC_AUTO.Ano);
  
    --AP (20/01/2006) Se agrego la definición del contexto para procesos automaticos
    PROC_CTX_PPTO.SETPLANCTAANO(R_DOC_AUTO.Ano);


    IF PROC_PRESUP.C_DOC%ISOPEN THEN
      CLOSE PROC_PRESUP.C_DOC;
    END IF;

    OPEN PROC_PRESUP.C_DOC(R_DOC_AUTO.IdDoc);
    FETCH PROC_PRESUP.C_DOC INTO R_DOC;
    CLOSE PROC_PRESUP.C_DOC;
    
    -- MV: Si manejamos una confirmación de pago
    -- puede ser necesario recalcular los montos  
    -- y reintentar el proceso
    -- en especial para las confirmaciones de pago
    IF R_DOC_AUTO.EfectPago <> 'N' THEN
      vLoops := 1;
    ELSE
      vLoops := 2;
    END IF;
      
    WHILE vLoops > 0 loop
                           
      vLoops := vLoops - 1;    
	
      --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' R_DOC_AUTO.IdDoc '|| R_DOC_AUTO.IdDoc);
      --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' R_DOC.EfectPag '|| R_DOC.EfectPago);	
      --Verifico si el documento debe ser REG o VER
      IF VALIDA_VER(R_DOC_AUTO.Ano, R_DOC.EfectPago) THEN
      --Registro el documento.
        IF REGDOC(R_DOC_AUTO.IdDoc) THEN
          BEGIN
            vCodProxSis := PROC_MENSAJERO.APRUEBA_DOC(R_DOC_AUTO.IdDoc, 'PPTO');
            vSts := 'REG';
            -- En este caso no intentamos ajustar la imputación 
            vLoops := 0;
          EXCEPTION WHEN OTHERS THEN
            vSts := 'RCH';
            vMensaje := '. '||SQLERRM;
          END;               
        ELSE
          vSts := 'RCH';
        END IF;
      ELSE
        IF VERDOC(R_DOC_AUTO.IdDoc) THEN
          -- Genera un evento de aprobación.
          -- MT. 19/05/2000. Se maneja la exception
          BEGIN
            vCodProxSis := PROC_MENSAJERO.APRUEBA_DOC(R_DOC_AUTO.IdDoc, 'PPTO');
            vSts := 'VER';
            -- En este caso no intentamos ajustar la imputación 
            vLoops := 0;
          EXCEPTION WHEN OTHERS THEN
            vSts := 'RCH';
            vMensaje := '. '||SQLERRM;
          END;
        ELSE
          vSts := 'RCH';
        END IF;
      END IF;
    -- Si estamos en el primer ciclo, y el documento quedó rechazado, 
    -- tratamos de ajustar la imputación
      IF  vSts = 'RCH'
        AND vLoops = 1 THEN
        --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ASIGNA_INF_DOCUMENTO_REF ');
          PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF(R_DOC_AUTO.IdDoc);
        --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ASIGNO INF_DOCUMENTO_REF ');
      END IF;
            
    END LOOP;
--
    PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS',' vSts ' ||vSts);

    UPDATE DOCS_PRESUP
    SET    StsDoc = vSts,
           UsuRec = USER,
           FecRec = SYSDATE,
           UsuCod = USER,
           FecCod = SYSDATE,
           UsuVer = DECODE(vSts, 'VER', vSuperv, 'REG', vSuperv, NULL),
           FecVer = DECODE(vSts, 'VER', SYSDATE, 'REG', SYSDATE, NULL),
           Mensaje = Mensaje || vMensaje
    WHERE  IdDoc = R_DOC_AUTO.IdDoc;
    --
    -- MV 22/01/01: Para hacer commit regularmente y evitar bloqueos excesivamente
    -- largos (y problemas con los ROLL BACK SEGMENTS)
    vCont := vCont + 1;
    IF vCont = 10 THEN
      vCont := 0;
      COMMIT;
    END IF;
    --
--     IF SQL%NOTFOUND THEN
--       RAISE_APPLICATION_ERROR(-20041,'No se pudo actualizar el documento '||TO_CHAR(R_DOC_AUTO.IdDoc)||SQLERRM);
--     END IF;
  END LOOP;
--  SELECT NivelUsuario, CodUsuarioSup
--  INTO   vNivel, vSuperv
--  FROM   USUARIOS_CP
--  WHERE  CodUsuario = USER;
--  --
--  IF vNivel = 'C' THEN
--    NULL;
--  ELSIF vNivel = 'S' THEN
--    vSuperv := USER;
--  ELSE
--    RAISE_APPLICATION_ERROR(-20400,
--      'El usuario debe ser un codificador o supervisor!');
--  END IF;
--  --
--  vCont := 0;
--  FOR R_DOC_AUTO IN C_DOC_AUTO LOOP
--  
--    LIMPIA_MENSAJE;
--  

--    --AP (20/01/2006) Se agrego la definición del contexto para procesos automaticos
--    PROC_CTX_PPTO.SETPLANCTAANO(R_DOC_AUTO.Ano);

--    OPEN  PROC_PRESUP.C_DOC(R_DOC_AUTO.IdDoc);
--    FETCH PROC_PRESUP.C_DOC INTO R_DOC;
--    CLOSE PROC_PRESUP.C_DOC;

--    -- MV: Si manejamos una confirmación de pago
--    -- puede ser necesario recalcular los montos  
--    -- y reintentar el proceso
--    -- en especial para las confirmaciones de pago
--    IF R_DOC_AUTO.EfectPago <> 'N' THEN
--      vLoops := 1;
--    ELSE
--      vLoops := 2;
--    END IF;
--      
--    WHILE vLoops > 0 loop
--                           
--      vLoops := vLoops - 1;
--    
--      --Verifico si el documento debe ser REG o VER
--      IF VALIDA_VER(R_DOC_AUTO.Ano, R_DOC.EfectPago) THEN
--      
--        -- pROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','A REGDOC ');
--        --Registro el documento.
--        IF REGDOC(R_DOC_AUTO.IdDoc) THEN
--          PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','PASO REGDOC ');
--          BEGIN            
--            vCodProxSis := PROC_MENSAJERO.APRUEBA_DOC(R_DOC_AUTO.IdDoc, 'PPTO');
--            PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','APROBADO (REG) IdDoc  = ' || R_DOC_AUTO.IdDoc);
--            vSts := 'REG';
--		  EXCEPTION
--		     WHEN OTHERS THEN
--             PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR MENSAJERO (REG) SQLERRM = '|| SQLERRM);
--			 PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR MENSAJERO (REG) VER_MENSAJE= '|| VER_MENSAJE);
--            vSts := 'RCH';
--			IF VER_MENSAJE IS NULL THEN 
--               vMensaje := '. '||SQLERRM;
--			ELSE
--			    vMensaje := '. '||VER_MENSAJE;
--			END IF;  	
--          END;

--          -- En este caso no intentamos ajustar la imputación 
--          vLoops := 0;
--          
--        ELSE
--          PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR EN REGDOC = '||SQLERRM );
--          PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR EN REGDOC VER_MENSAJE = '|| VER_MENSAJE);
--          vSts := 'RCH';
--        END IF;
--      
--      ELSE         
--        --PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','A VERDOC ');
--        IF VERDOC(R_DOC_AUTO.IdDoc) THEN
--          PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','PASO VERDOC ');
--          -- Genera un evento de aprobación.
--          -- MT. 19/05/2000. Se maneja la exception
--          BEGIN
--            vCodProxSis := PROC_MENSAJERO.APRUEBA_DOC(R_DOC_AUTO.IdDoc, 'PPTO');
--            PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','APROBADO (VER) IdDoc  = ' || R_DOC_AUTO.IdDoc);
--            vSts := 'VER';
--          EXCEPTION WHEN OTHERS THEN
--            PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR MENSAJERO SQLERRM = '|| SQLERRM);
--            PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR MENSAJERO VER_MENSAJE = '|| VER_MENSAJE);
--            vSts := 'RCH';
--           	IF VER_MENSAJE IS NULL THEN 
--               vMensaje := '. '||SQLERRM;
--			ELSE
--			    vMensaje := '. '||VER_MENSAJE;
--			END IF;
--          END;
--          
--          -- En este caso no intentamos ajustar la imputación 
--          vLoops := 0;
--                    
--        ELSE
--          vSts := 'RCH';
--          PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR EN VERDOC SQLERRM = '||SQLERRM );
--		  PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ERROR EN VER_MENSAJE = '|| VER_MENSAJE);
--        END IF;
--      
--      END IF;

--      -- Si estamos en el primer ciclo, y el documento quedó rechazado, 
--      -- tratamos de ajustar la imputación
--      IF  vSts = 'RCH'
--      AND vLoops = 1 THEN
--        PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ASIGNA_INF_DOCUMENTO_REF ');
--        PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF(R_DOC_AUTO.IdDoc);
--        PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','ASIGNO INF_DOCUMENTO_REF ');
--      END IF;
--            
--    END LOOP;
--      
--    PROC_DEBUG.REGISTRAR('PROC_DOCUMENTOS.PROCESA_AUTOMATICOS','vSts = '|| vSts);
--    
--    UPDATE DOCS_PRESUP
--    SET    StsDoc = vSts,
--           UsuRec = USER,
--           FecRec = SYSDATE,
--           UsuCod = USER,
--           FecCod = SYSDATE,
--           UsuVer = DECODE(vSts, 'VER', vSuperv, 'REG', vSuperv, NULL),
--           FecVer = DECODE(vSts, 'VER', SYSDATE, 'REG', SYSDATE, NULL),
--           Mensaje = vMensaje
--    WHERE  IdDoc = R_DOC_AUTO.IdDoc;
--    --
--    -- MV 22/01/01: Para hacer commit regularmente y evitar bloqueos excesivamente
--    -- largos (y problemas con los ROLL BACK SEGMENTS)
--    vCont := vCont + 1;
--    IF vCont = 10 THEN
--      vCont := 0;
--      COMMIT;
--    END IF;
--    --
----     IF SQL%NOTFOUND THEN
----       RAISE_APPLICATION_ERROR(-20041,'No se pudo actualizar el documento '||TO_CHAR(R_DOC_AUTO.IdDoc)||SQLERRM);
----     END IF;
--  END LOOP;
END PROCESA_AUTOMATICOS;

--------------------------------------------------------------------------------
-- CTA_ADIC: Inserta las cuentas adicionales en los documentos padres
-- RA 02/02/2005
PROCEDURE CTA_ADIC(pIdDoc NUMBER) IS

CURSOR C_DOCREF (cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT IdDoc, IdDocRef, Ano
    FROM   DOCS_PRESUP
    CONNECT BY IdDoc = PRIOR IdDocRef
    START WITH IdDoc = pIdDoc;

-- Cursor con la Cuentas del Documento
CURSOR C_CTAS(cIdDoc CTAS_DOC.IdDoc%TYPE)IS
    SELECT CodAccInt,
           Ccosto,
           CodCta,
           CodPrograma
    FROM  CTAS_DOC
    WHERE IdDoc = cIdDoc
    GROUP BY CodAccInt,
             Ccosto,
             CodCta,
             CodPrograma;

    -- Cursor con la Cuentas del Documento
CURSOR C_CTAREF(cIdDoc     CTAS_DOC.IdDoc%TYPE,
                cCodAccInt CTAS_DOC.CodAccInt%TYPE,
                cCCosto    CTAS_DOC.Ccosto%TYPE,
                cCodCta    CTAS_DOC.CodCta%TYPE)
  IS
    SELECT CodCta
    FROM  CTAS_DOC
    WHERE IdDoc     = cIdDoc
    AND   CodAccInt = cCodAccInt
    AND   CCosto    = cCcosto
    AND   CodCta    = cCodCta
    GROUP BY CodCta;

R_CTAREF C_CTAREF%ROWTYPE;
R_EJS    C_EJS%ROWTYPE;

BEGIN

  FOR R_DOCREF IN C_DOCREF(pIdDoc) LOOP

      OPEN C_EJS(R_DOCREF.Ano);
      FETCH C_EJS INTO R_EJS;
      CLOSE C_EJS;

      IF R_DOCREF.IdDocRef IS NOT NULL THEN

         FOR R_CTAS IN C_CTAS(pIdDoc) LOOP

             OPEN  C_CTAREF(R_DOCREF.IdDocRef, R_CTAS.CodAccInt, R_CTAS.Ccosto, R_CTAS.CodCta);
             FETCH C_CTAREF INTO R_CTAREF;
             IF C_CTAREF%NOTFOUND THEN
                CLOSE C_CTAREF;
                BEGIN
                  INSERT INTO CTAS_DOC
                              (IdDoc,
                               CodAccInt,
                               Ccosto,
                               CodCta,
                               CodPrograma,
							   CodEstruct
                              )VALUES
                              (R_DOCREF.IdDocRef,
                               R_CTAS.CodAccInt,
                               R_CTAS.Ccosto,
                               R_CTAS.CodCta,
                               R_CTAS.CodPrograma,
							   R_EJS.CodEstruct
                              );
                EXCEPTION
                WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20020,'ERROR DE DATOS: Insertando cuentas adicionales para el documento ['
                     || R_DOCREF.IdDocRef || '] accion interna ['|| R_CTAS.CodAccInt ||'] centro de costo ['
                     || R_CTAS.Ccosto || '] y cuenta ['|| R_CTAS.CodCta ||']'|| SQLERRM);
                END;
             END IF;
             IF C_CTAREF%ISOPEN THEN
                CLOSE C_CTAREF;
             END IF;
         END LOOP;
      END IF;
  END LOOP;
END;

--------------------------------------------------------------------------------
-- CODIFICA_DOC: Codifica el documento presupuestario indicado
-- MV 29/04/2002
FUNCTION CODIFICA_DOC (pIdDoc NUMBER) RETURN BOOLEAN IS

  vValOK   BOOLEAN := FALSE;
  vMensaje DOCS_PRESUP.Mensaje%TYPE;
  R_CUOTA  C_CUOTA%ROWTYPE;
BEGIN

  LIMPIA_MENSAJE;

  SAVEPOINT COD;
  --Inserta las cuentas adicionales en documnetos padres en caso de que existan
  CTA_ADIC(pIdDoc);

  vValOK := VALDOC(pIdDoc);

  ROLLBACK TO COD;

  VALIDA_STS(pIdDoc, 'REC, RCH');

  IF vValOK THEN
    vValOK := PROC_VERIFICACION.DISPONIBILIDAD(pIdDoc, 'CODIFICA');
  END IF;

  -- MRM 03/08/2003.. Vamos a ejecutar la cuota de compromiso si establece
  -- compromiso y el módulo indica que afecta cuota y, si todo está bien,
  -- la deshacemos, ya que eso es parte de la verificación.
  OPEN  C_CUOTA(pIdDoc);
  FETCH C_CUOTA INTO R_CUOTA;
  IF C_CUOTA%NOTFOUND THEN
    CLOSE C_CUOTA;
      RAISE_APPLICATION_ERROR(-20030,'ERROR DE DATOS: ' ||
           'No está definido el año presupuestario ' || R_CUOTA.Ano );
  END IF;
  CLOSE C_CUOTA;
  SAVEPOINT COD;
  IF R_CUOTA.IndEstComprom = 'S' AND R_CUOTA.IndCtrlCuota = 'S' THEN
    PROC_CUOTAS_COMP.CARGA_EJECUTADO(pIdDoc);
    ROLLBACK TO COD;
  END IF;

  IF vValOK THEN

    BEGIN
      UPDATE DOCS_PRESUP
      SET    StsDoc = 'COD',
             FecCod = SYSDATE,
             UsuCod = SUBSTR(USER, 1, 15)
      WHERE  IdDoc = pIdDoc;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20451, 'ERROR INTERNO:' ||
          ' Actualizando el estatus del Documento: "' || pIdDoc ||
          '" a "COD". ' || SQLERRM);
    END;

  ELSE

    vMensaje := VER_MENSAJE;
    BEGIN
      UPDATE DOCS_PRESUP
      SET    Mensaje = vMensaje
      WHERE  IdDoc = pIdDoc;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20452, 'ERROR INTERNO:' ||
          ' Actualizando el mensaje de validación del Documento: "' || pIdDoc ||
          '" . ' || SQLERRM);
    END;

  END IF;

  RETURN(vValOK);

END;

/***************************************************************/
/*BM 28/11/2001: Función que busca documentos hijos no anulados*/
/*para un documento que se desea anular                        */
/***************************************************************/
FUNCTION CHK_ANULA_DOC(pIdDoc NUMBER) RETURN BOOLEAN IS

CURSOR C_DOC IS
  SELECT *
  FROM   DOCS_PRESUP
  WHERE  StsDoc <> 'ANU'
  AND IdDoc <> pIdDoc
  CONNECT BY IdDocRef = PRIOR IdDoc
  START WITH IdDoc = pIdDoc;

vAnula     BOOLEAN;
vCompAcum  KNTSTD.Monto := 0;
vCausaAcum KNTSTD.Monto := 0;
vPagoAcum  KNTSTD.Monto := 0;
vCompDoc   KNTSTD.Monto := 0;
vCausaDoc  KNTSTD.Monto := 0;
vPagoDoc   KNTSTD.Monto := 0;
R_DOC      C_DOC%ROWTYPE;

BEGIN
  --BM 28/11/2001: Se abre el cursor si se encuentran registros
  --no se permite la anulación del documento hasta que no se
  --hayan anulados sus hijos.
  BEGIN
    SELECT NVL(SUM(CompAcum),0), NVL(SUM(CausaAcum),0), NVL(SUM(PagoAcum),0)
    INTO   vCompAcum, vCausaAcum, vPagoAcum
    FROM CTAS_DOC
    WHERE IdDoc = pIdDoc;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vCompAcum  := 0;
      vCausaAcum := 0;
      vPagoAcum  := 0;
  END;
  FOR R_DOC IN C_DOC LOOP
    vCompDoc   := 0;
    vCausaDoc  := 0;
    vPagoDoc   := 0;
      BEGIN
        SELECT NVL(SUM(CompDoc),0), NVL(SUM(CausaDoc),0), NVL(SUM(PagoDoc),0)
        INTO   vCompDoc, vCausaDoc, vPagoDoc
        FROM CTAS_DOC
        WHERE IdDoc = R_DOC.IdDoc;
      END;
      IF vCompDoc <> 0 AND vCompAcum <> 0 THEN
        vAnula := FALSE;
      ELSIF vCausaDoc <> 0 AND vCausaAcum <> 0 THEN
        vAnula := FALSE;
      ELSIF vPagoDoc <> 0 AND vPagoAcum <> 0 THEN
        vAnula := FALSE;
      END IF;
    IF NOT vAnula THEN
      RETURN(vAnula);
    END IF;
  END LOOP;
  RETURN(TRUE);
END;

--------------------------------------------------------------------------------
-- ANULA_DOC: Anula el documento presupuestario indicado
-- MV 03/05/2002
PROCEDURE ANULA_DOC (pIdDoc NUMBER) IS

  vValOK   BOOLEAN := FALSE;
  vMensaje DOCS_PRESUP.Mensaje%TYPE;
  vOrigen  DOCS_PRESUP.Origen%TYPE;
  R_DOCT        PROC_DOCSTRANSF.C_DOCT%ROWTYPE;
BEGIN

  BEGIN
    SELECT Origen
    INTO   vOrigen
    FROM   DOCS_PRESUP
    WHERE  IdDoc = pIdDoc;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20531, 'ERROR INTERNO:' ||
        ' Buscado origen del documento "' || pIdDoc ||
        '". ' || SQLERRM);
  END;

  IF vOrigen <> 'PPTO' THEN
    RAISE_APPLICATION_ERROR(-20532, 'ERROR DE DATOS:' ||
      ' El origen del documento "' || pIdDoc ||
      '" es "' || vOrigen ||
      '", por lo tanto presupuesto (PPTO) no puede anularlo.');
  END IF;

  VALIDA_STS(pIdDoc, 'REC, COD, RCH');

  IF NOT CHK_ANULA_DOC(pIdDoc) THEN
    RAISE_APPLICATION_ERROR(-20530, 'ERROR DE DATOS:' ||
      ' No se puede anular el documento "' || pIdDoc ||
      '" porque tiene documentos no anulados que lo referencian.');
  END IF;
  --
  -- IF (27/08/2003): Se verifica si se anula un documento generado por transferencia
  --
  -- Se obtiene la información de la transferencia
  OPEN PROC_DOCSTRANSF.C_DOCT(pIdDoc);
  FETCH PROC_DOCSTRANSF.C_DOCT INTO R_DOCT;
  IF PROC_DOCSTRANSF.C_DOCT%FOUND THEN
    --
    -- Se blanquea las columnas que contiene información de la transferencia al
    -- documento a anular
    UPDATE DOCS_PRESUP
    SET  IdDocOrigTransf = NULL
    WHERE IdDoc          = pIdDoc;
  --
  -- Se verifica el tipo de transferencia
    IF R_DOCT.TipoTransf = '{COMP-NO-CAUS}' THEN  -- Comprometido no causado
    --
    -- Se blanquea las columnas que contiene información de la transferencia
    -- al documento que genero la transferencia
      BEGIN
        UPDATE DOCS_PRESUP
        SET  IdDocTransf = NULL
        WHERE IdDoc      = R_DOCT.IdDoc;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20566,'ERROR INTERNO: '||
            'Al actualizar las columnas que contiene información de la transferencia, '||SQLERRM);
      END;

    ELSIF R_DOCT.TipoTransf = '{CAUS-NO-PAG}' THEN -- Causado no pagado
    --
    -- Se devuelve el estatus a la solicitu de pago

      -- MV 27/05/2004: Comentado porque crea una dependencia indebida de PPTO hacia TESO
      --VN 14/09/2005 Se volvio activar la llamada al proceso PROC_DOCS_TESO.
      PROC_DOCS_TESO.REVERSA_TRANSFDOC (R_DOCT.IdDoc,R_DOCT.StsDoc);
      ---RAISE_APPLICATION_ERROR(-20001, 'ERROR INTERNO: NO SE PUEDE EJECUTAR PROC_DOCS_TESO!');

    END IF;
  --
  -- Elimina el registro de la transferencia
    PROC_DOCSTRANSF.ELIMINA_TRANSF(R_DOCT.IdDoc);
  END IF;
  CLOSE PROC_DOCSTRANSF.C_DOCT;
--
-- Se anula el documento
  BEGIN
    UPDATE DOCS_PRESUP
    SET    StsDoc = 'ANU'
    WHERE  IdDoc = pIdDoc;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20533, 'ERROR INTERNO:' ||
        ' Actualizando el estatus del Documento: "' || pIdDoc ||
        '" a "ANU". ' || SQLERRM);
  END;

  PROC_MENSAJERO.ANULA_DOC(pIdDoc, 'PPTO', 'Anulado en Presupuesto');

END;

/*******************************************************************************/
/* VERIFICA_HERMANOS: valida que los documento con un mismo IdDocRef deban ser */
/* verificados en orden segun su fecha                                         */
/*******************************************************************************/
PROCEDURE VERIFICA_HERMANOS(pIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
  CURSOR C_IDDOC (cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT *
    FROM DOCS_PRESUP DPR
    WHERE IdDoc = cIdDoc;

  CURSOR C_FECDOC (cIdDocRef DOCS_PRESUP.IdDocRef%TYPE,
                   cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT *
    FROM DOCS_PRESUP DPR
    WHERE IdDocRef = cIdDocRef
    AND   IdDoc <> cIdDoc
    AND   StsDoc IN ('COD','PEN','RCH','REC');

BEGIN
  FOR R_IDDOC IN C_IDDOC(pIdDoc) LOOP
    IF R_IDDOC.IdDocRef IS NOT NULL THEN
      FOR R_FECDOC IN C_FECDOC(R_IDDOC.IdDocRef, pIdDoc) LOOP
        IF TRUNC(R_IDDOC.FecDoc) > TRUNC(R_FecDoc.FecDoc) THEN
          RAISE_APPLICATION_ERROR(-20577, 'ERROR INTERNO:' ||
          'Existe uno o más documentos con el mismo documento de referencia ' ||
          R_IDDOC.IdDocRef || ' con fecha anterior al documento a verificar (IdDoc: ' ||
          pIdDoc || ', Fecha: ' || TO_CHAR(R_IDDOC.FecDoc,'DD/MM/YYYY') || '). '|| SQLERRM);
        ELSIF TRUNC(R_IDDOC.FecDoc) = TRUNC(R_FecDoc.FecDoc) THEN
          IF R_IDDOC.IdDoc > R_FecDoc.IdDoc THEN
            RAISE_APPLICATION_ERROR(-20578, 'ERROR INTERNO:' ||
            'Existe uno o más documentos con el mismo documento de referencia ' ||
            R_IDDOC.IdDocRef || '. Debe verificar el orden de proceso de los documento.'
            ||SQLERRM);
          END IF;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
END;

/*******************************************************************************/
/* BM 08/05/00: Función que invoca a la verificación de Documentos             */
/*******************************************************************************/
FUNCTION VERIFICA_DOC(pIdDoc DOCS_PRESUP.IdDoc%TYPE, pModo VARCHAR2)
RETURN VARCHAR2 IS

 /* CURSOR C_IND(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT DPR.Ano,
           DPR.IndEstComprom,
           EJS.IndCtrlCuota
    FROM   DOCS_PRESUP DPR,
           EJS_PRESUP  EJS
    WHERE DPR.Ano = EJS.Ano
    AND   DPR.IdDoc = cIdDoc;*/

  vProxSis       GOBSTD.CodSis;
  vStsDoc        DOCS_PRESUP.StsDoc%TYPE;
  vTipoDoc       DOCS_PRESUP.TipoDoc%TYPE;
  vMensaje       DOCS_PRESUP.Mensaje%TYPE;
  vUsuVer        DOCS_PRESUP.UsuVer%TYPE;
  vFecVer        DATE;
  vDev           BOOLEAN;
  vIndEstComprom DOCS_PRESUP.IndEstComprom%TYPE;
  vIndCtrlCuota  EJS_PRESUP.IndCtrlCuota%TYPE;
  R_CUOTA        C_CUOTA%ROWTYPE;
  R_EFECTO       PROC_PRESUP.C_DOC%ROWTYPE;
  vVerHerm       BOOLEAN := TRUE;
BEGIN
  LIMPIA_MENSAJE;
  vMensaje := NULL;

  --Inserta las cuentas adicionales en documnetos padres en caso de que existan
  CTA_ADIC(pIdDoc);

  VALIDA_STS(pIdDoc, 'COD');

  vUsuVer := SUBSTR(USER, 1, 15);
  vFecVer := SYSDATE;
  
  --
  -- IF 27/03/08: Se determina la configuracion del documento 
  OPEN  PROC_PRESUP.C_DOC(pIdDoc);
  FETCH PROC_PRESUP.C_DOC INTO R_EFECTO;
  CLOSE PROC_PRESUP.C_DOC;

 --
 -- IF 27/03/08: NO se verificar los hermanos si el documento aumenta el CAUSADO
 -- para manejar temporarmente los documentos asociados a NOMINAS que puedes 
 -- presentar problema en la secuencia (orden) al procesarlos. 
  IF (R_EFECTO.EfectEjec = 'A' AND R_EFECTO.EfectComprom= 'N' )  THEN
   vVerHerm := FALSE;        
  END IF;    


  IF vVerHerm THEN
  --
  -- ER 09/09/2003 .. Toma los documentos que posean el mismo IdDocRef y verifica su
  -- orden de de proceso según su fecha y si las fechas son iguales según su IdDoc.
  -- Obliga a que los documentos hermanos deban ser verificados en orden.
    VERIFICA_HERMANOS(pIdDoc);
  END IF; 

  BEGIN

    SELECT DPR.TipoDoc, DPR.StsDoc
    INTO   vTipoDoc, vStsDoc
    FROM   DOCS_PRESUP DPR
    WHERE IdDoc = pIdDoc;

    -- MV 29/04/2002: Si afecta fondos registro el documento
    IF PROC_TIPODOCPPTO.AFECTA_FONDO(vTipoDoc) THEN
      PROC_FONDOAV.REGISTRA_DOC(pIdDoc);
    END IF;

    --
    -- ER 15/07/2003.. Verifico los indicadores para conocer si se afectará una cuota
    OPEN  C_CUOTA(pIdDoc);
     FETCH C_CUOTA INTO R_CUOTA;
     IF C_CUOTA%NOTFOUND THEN
       CLOSE C_CUOTA;
         RAISE_APPLICATION_ERROR(-20030,'ERROR DE DATOS: ' ||
           'No está definido el año presupuestario ' || R_CUOTA.Ano );
     END IF;
     CLOSE C_CUOTA;
     --
     -- ER 15/07/2003.. Si establece compromiso e indica trabajar con cuota
     IF R_CUOTA.IndEstComprom = 'S' AND R_CUOTA.IndCtrlCuota = 'S' THEN
        PROC_CUOTAS_COMP.CARGA_EJECUTADO(pIdDoc);
     END IF;


  EXCEPTION
    WHEN OTHERS THEN
      vMensaje := SQLERRM;
  END;

  -- Verificamos si es una devolución
  --vDev := (vStsDoc = 'DEV');

  -- Lo suponemos rechazado a menos que TODO vaya bien
  --vStsDoc := 'RCH';
  DBMS_OUTPUT.PUT_LINE('antes IF MENSAJE ' || piddoc);
  IF vMensaje IS NULL THEN
    IF pModo = 'VERIFICAR' THEN
    DBMS_OUTPUT.PUT_LINE('antes de verdoc ' || piddoc);
      IF VERDOC(pIdDoc) THEN
        vStsDoc := 'VER';
      END IF;
    ELSIF pModo = 'REGISTRAR' THEN
      IF REGDOC(pIdDoc) THEN
        vStsDoc := 'REG';
      END IF;
    END IF;

    vMensaje := VER_MENSAJE;

  END IF;

  -- Si es una devolución siempre queda rechazado
  -- Si hay algún mensaje rechazamos

--  IF vDev OR vMensaje IS NOT NULL THEN
--  vStsDoc := 'RCH';
--  END IF;

  IF vMensaje IS NULL THEN
    --A1ctualizo Documentos Origen y se invoca al mensajero
    PROC_VERIFICACION.ACTUALIZA_DOCORIGEN(pIdDoc);
    vProxSis := PROC_MENSAJERO.APRUEBA_DOC(pIdDoc, 'PPTO');

--  ELSE
--    vUsuVer := NULL;
--    vFecVer := NULL;
--  END IF;

  -- Actualizamos el documento
    BEGIN

      UPDATE DOCS_PRESUP
      SET    StsDoc  = vStsDoc,
             UsuVer  = vUsuVer,
             FecVer  = vFecVer
      WHERE  IdDoc = pIdDoc;

    EXCEPTION
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20017, 'ERROR INTERNO:' ||
           ' Actualizando el documento: "' || pIdDoc || '". ' || SQLERRM);
    END;

    IF SQL%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(-20018, 'ERROR INTERNO:' ||
        ' No existe el documento: "' || pIdDoc || '". ' || SQLERRM);
    END IF;
  ELSE
    --
    -- IF (07/07/2003) : Se crea el mensaje con el error para ser mostrado en la
    --                   pantalla
--    CREA_MSG(vMensaje);

    -- Actualizamos el MENSAJE del documento
    BEGIN

      UPDATE DOCS_PRESUP
      SET    Mensaje = vMensaje
      WHERE  IdDoc = pIdDoc;

    EXCEPTION
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20028, 'ERROR INTERNO:' ||
           ' Actualizando el mensaje del documento: "' || pIdDoc || '". ' || SQLERRM);
    END;

    IF SQL%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(-20029, 'ERROR INTERNO:' ||
        ' No existe el documento: "' || pIdDoc || '". ' || SQLERRM);
    END IF;
  END IF;

  RETURN vProxSis;

END VERIFICA_DOC;

/*******************************************************************************/
/***** BM 15/02/01: Funición que verifica si el doc. debe ser VER o REG ********/
/*******************************************************************************/
FUNCTION VALIDA_VER(pAno EJS_PRESUP.Ano%TYPE, pEfectPago DEF_EVENTO_CP.EfectPago%TYPE)
RETURN BOOLEAN IS
vSts    EJS_PRESUP.Sts%TYPE;
vValida BOOLEAN;
BEGIN
  BEGIN
    SELECT Sts
    INTO vSts
    FROM EJS_PRESUP
    WHERE Ano = pAno;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR
        (-20054,'No Existe el Ejercicio Presupuestario para el Año: '||TO_CHAR(pAno) ||'. '||SQLERRM);
  END;

  IF vSts = 'CER' AND pEfectPago != 'N' THEN
    vValida := TRUE;
  ELSE
    vValida := FALSE;
  END IF;
  RETURN vValida;
END;

/********************************************************************************/
/* ACEPTAR_DEV: Acepta la devolución del documento presupuestario indicado      */
/* 30/05/2002                                                                */
/********************************************************************************/
FUNCTION ACEPTAR_DEV (pIdDoc NUMBER) RETURN BOOLEAN IS

  CURSOR C_IND(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT DPR.Ano,
           DPR.IndEstComprom,
           EJS.IndCtrlCuota
    FROM   DOCS_PRESUP DPR,
           EJS_PRESUP  EJS
    WHERE DPR.Ano = EJS.Ano
    AND   DPR.IdDoc = cIdDoc;
--
-- IF 23/05/05: Inf. del ejercicio
  CURSOR C_EJE (cAnno EJS_PRESUP.Ano%TYPE) IS
    SELECT EJE.Ano, EJE.Sts,
           EJE.Periodo, EJE.NumPerAno
    FROM EJS_PRESUP EJE
    WHERE EJE.Ano = cAnno;
--
-- Variables de trabajo
  vValOK   BOOLEAN := FALSE;
  vMensaje DOCS_PRESUP.Mensaje%TYPE;
  R_DOC    PROC_PRESUP.C_DOC%ROWTYPE;
  R_IND    C_IND%ROWTYPE;
  R_EJE    C_EJE%ROWTYPE;

BEGIN

  LIMPIA_MENSAJE;
  vMensaje := NULL;

  VALIDA_STS(pIdDoc, 'DEV');
  VALIDA_INDREVERSO(pIdDoc);
  vValOK := VALDOC(pIdDoc);

 --
  IF vValOK THEN
    vValOK := PROC_VERIFICACION.DISPONIBILIDAD(pIdDoc, 'VERIFICA');
  END IF;

  --
  -- IF 23/05/05: Determina si el CURSOR esta abierto y se cierra
  IF PROC_PRESUP.C_DOC%ISOPEN THEN
    CLOSE PROC_PRESUP.C_DOC;
  END IF;
  --
  -- IF 23/05/05: Busca el documento y su definicion del evento presupuestario.
  OPEN PROC_PRESUP.C_DOC(pIdDoc);
  FETCH PROC_PRESUP.C_DOC INTO R_DOC;
  IF PROC_PRESUP.C_DOC%NOTFOUND THEN
    CLOSE PROC_PRESUP.C_DOC;
    RAISE_APPLICATION_ERROR(-20481,'ERROR DE DATOS: '||
       'No se encontró la definición del efecto presupuestario.');
  END IF;
  CLOSE PROC_PRESUP.C_DOC;
  --
  -- IF 23/05/05: Busca los datos del ejercicio presupuestario para el año del documento.
  OPEN C_EJE(R_DOC.Ano);
  FETCH C_EJE INTO R_EJE;
  IF C_EJE%NOTFOUND THEN
    CLOSE C_EJE;
    RAISE_APPLICATION_ERROR(-20482,'ERROR DE DATOS: '||
       'No se encontró el ejercicio presupuestario con año "'|| R_DOC.Ano ||'"');
  END IF;
  CLOSE C_EJE;
  --
  -- IF 23/05/05: Se verifica el estatus del ejercicio para determinar si se debe generar
  --              historico.
  IF R_EJE.Sts IN ('EJE', 'COM')
     AND R_DOC.Periodo < R_EJE.Periodo THEN
    --
    --
    -- Se registra la historia del documento con la informacion original
      PROC_HISTDOCS.REGISTRAR_HIST ( R_DOC , 1);
    --
    -- Se actualiza la informacion del ejercicio del documento a aceptar
       ACT_DOC_DEV( R_DOC, R_EJE.Ano, R_EJE.Periodo);
    --
    -- Ubico de nuevo el documento actualizado
      IF PROC_PRESUP.C_DOC%ISOPEN THEN
        CLOSE PROC_PRESUP.C_DOC;
      END IF;
    --
      OPEN PROC_PRESUP.C_DOC(pIdDoc);
      FETCH PROC_PRESUP.C_DOC INTO R_DOC;
      CLOSE PROC_PRESUP.C_DOC;
      -- Se registra la historia del documento ya actualizado
      PROC_HISTDOCS.REGISTRAR_HIST ( R_DOC , -1);
  END IF;


  IF vValOK THEN
    IF PROC_PRESUP.C_DOC%ISOPEN THEN
      CLOSE PROC_PRESUP.C_DOC;
    END IF;
    --
    OPEN PROC_PRESUP.C_DOC(pIdDoc);
    FETCH PROC_PRESUP.C_DOC INTO R_DOC;
    --
    IF PROC_PRESUP.C_DOC%NOTFOUND THEN
      CLOSE PROC_PRESUP.C_DOC;
      RAISE_APPLICATION_ERROR(-20480,'No se encontró la definición del efecto ' ||
        'presupuestario!');
    END IF;
    --
    CLOSE PROC_PRESUP.C_DOC;
    --

    -- MV 21/02/2003: Actualización del reverso del fondo,
    -- en caso que el documento haya afectado a un fondo
    IF R_DOC.IdFondo IS NOT NULL THEN
      PROC_FONDOAV.REVERSA_DOC(pIdDoc);
    END IF;

    IF R_DOC.IndRegistrado = 'S' THEN
      ACTCTAS_REGISTRO(R_DOC);
    ELSE
      ACTCTASDOC(R_DOC);
    END IF;

    --
    -- ER 25/07/2003.. Verifico los indicadores para conocer si se afectará una cuota
    OPEN  C_IND(pIdDoc);
     FETCH C_IND INTO R_IND;
     IF C_IND%NOTFOUND THEN
       CLOSE C_IND;
         RAISE_APPLICATION_ERROR(-20481,'ERROR INTERNO: No existe el Año ' || R_IND.Ano ||
         ' del IdDoc : ' || pIdDoc || ', en la tabla EJS_PRESUP.');
     END IF;
     CLOSE C_IND;
     --
     -- ER 25/07/2003.. Si establece compromiso e indica trabajar con cuota
     IF R_IND.IndEstComprom = 'S' AND R_IND.IndCtrlCuota = 'S' THEN
        PROC_CUOTAS_COMP.CARGA_EJECUTADO(pIdDoc, -1);
     END IF;

    BEGIN
      UPDATE DOCS_PRESUP
      SET    StsDoc = 'RCH',
             IdFondo = NULL  -- MV 21/02/2003 Lo borramos porque se asigna al verificar
      WHERE  IdDoc = pIdDoc;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20458, 'ERROR INTERNO:' ||
          ' Actualizando el estatus del Documento: "' || pIdDoc ||
          '" a "RCH". ' || SQLERRM);
    END;
  ELSE
    vMensaje := VER_MENSAJE;
    BEGIN
      UPDATE DOCS_PRESUP
      SET    Mensaje = vMensaje
      WHERE  IdDoc = pIdDoc;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20459, 'ERROR INTERNO:' ||
          ' Actualizando el mensaje de validación del Documento: "' || pIdDoc ||
          '" . ' || SQLERRM);
    END;
  END IF;
  RETURN (vValOk);

END;
--------------------------------------------------------------------------------
-- DEVOLVER_DOC: Devuelve el documento presupuestario indicado
-- MR 06/08/2002
FUNCTION DEVOLVER_DOC (pIdDoc NUMBER, pCodSis VARCHAR2, pMensaje VARCHAR2) RETURN VARCHAR2 IS

--
-- IF 31/01/08: Ya no se usa
--Cursor para buscar los documentos hijos
--  CURSOR C_DOCREF IS
--    SELECT *
--	FROM DOCS_PRESUP	
--    WHERE  IdDocRef = pIdDoc;
--
  vSistDest SISTEMAS.CodSis%TYPE;  
--
BEGIN
  -- Valida que el documento se encuentre REC o RCH
  VALIDA_STS(pIdDoc, 'REC,RCH');
  
--
-- IF 31/01/08: Se desactivo la validacion   	
-- 02/03/2007 - AC 008879 - Se agrego validación de documentos asociados sin haber sido devueltos
--   FOR R_DOCREF IN C_DOCREF LOOP 
--	   IF R_DOCREF.StsDoc in  ('VER','REC','PEN','RCH','COD') THEN
--		    RAISE_APPLICATION_ERROR(-20488,'Existe documento asociado (' || 
--			       R_DOCREF.IdDoc || ') con estatus ' || R_DOCREF.StsDoc);
--	    END IF;
--    END LOOP;
    
  
  --
  -- Elimina las cuentas del documento presupuestario
  BEGIN
    DELETE FROM CTAS_DOC
    WHERE IdDoc = pIdDoc;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20489, 'ERROR INTERNO:' ||
        ' Eliminando las cuentas del documento : "' || pIdDoc ||
        '" . ' || SQLERRM);
  END;
  BEGIN
    DELETE FROM CTAS_CCOSTO_DOC
    WHERE IdDoc = pIdDoc;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20490, 'ERROR INTERNO:' ||
        ' Eliminando las cuentas por centro de costo del documento : "' ||
        pIdDoc || '" . ' || SQLERRM);
  END;

  BEGIN
    UPDATE DOCS_PRESUP
    SET    StsDoc = 'REV'
    WHERE IdDoc = pIdDoc;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20491, 'ERROR INTERNO:' ||
        ' Eliminando el documento : "' || pIdDoc || '" . ' || SQLERRM);
  END;

  vSistDest := PROC_MENSAJERO.DEVUELVE_DOC(pIdDoc, pCodSis, pMensaje);

  RETURN vSistDest;

END;

--------------------------------------------------------------------------------
-- CARGA_TRANSFDOC: Carga el documento para ser transferido
-- IF 18/08/2003
PROCEDURE CARGA_TRANSFDOC (pIdDoc        DOCS_PRESUP.IdDoc%TYPE,
                           pTipoTransf   DOCS_PRESUP.TipoDoc%TYPE,
                           pMtoNoCausado    NUMBER) IS
--
  R_DOCTRF DOCS_TRANSF%ROWTYPE;
-- Documentos
  CURSOR C_DOC (cIdDoc   DOCS_PRESUP.IdDoc%TYPE) IS
    SELECT   doc.*
    FROM DOCS_PRESUP DOC,
         TIPOS_DOC_PPTO TD,
         (SELECT IdDoc, SUM(CompAcum) - SUM(CausaAcum)
          FROM CTAS_DOC CTA
		  WHERE CTA.IdDoc = cIdDoc
		  GROUP BY IdDoc
		  HAVING SUM(CompAcum) - SUM(CausaAcum) > 0) CTAS,
         DEF_EVENTO_CP DECP
   WHERE DOC.iddoc    = ciddoc
     AND DECP.TipoDoc = DOC.TipoDoc
     AND TD.TipoDoc   = DOC.TipoDoc
	 AND CTAS.IdDoc   = cIdDoc
     AND DOC.stsdoc = 'VER'
     AND doc.iddoc NOT IN (SELECT dt.iddoc FROM DOCS_TRANSF DT)
     AND (
	      (doc.iddocref IS NULL 
           AND td.indestcomprom = 'S'
           AND DECP.efectcomprom = 'A'
		  )
		 OR
		  (DECP.efectres = 'D'
		  )
		 );
/* ABR 101139 - 21/08/2007 
  Query original cambiado por "criptico" 
  SELECT   doc.*
    FROM docs_presup doc,
         tipos_doc_ppto td,
         (SELECT   iddoc, (SUM (compacum) - SUM (causaacum)) nocausado
          FROM ctas_doc
          GROUP BY iddoc) ctas,
         def_evento_cp ep
   WHERE doc.iddoc = ciddoc
     AND (   doc.iddocref IS NULL
          OR doc.iddoc IN (
                SELECT dp.iddoc
                  FROM def_evento_cp dc, docs_presup dp
                 WHERE dc.efectres = 'D'
                   AND dc.tipodoc = dp.tipodoc
                   AND dp.stsdoc = 'VER')
         )
     AND doc.stsdoc IN ('VER')
     AND doc.tipodoc = td.tipodoc
     AND doc.iddoc NOT IN (SELECT dt.iddoc
                             FROM docs_transf dt)
     AND td.indestcomprom = 'S'
     AND td.tipodoc = ep.tipodoc
     AND ep.efectcomprom = 'A'
     AND doc.iddoc = ctas.iddoc
     AND ctas.nocausado > 0;
*/ 
--
-- Cuentas
  CURSOR C_CTAS(cIdDoc   DOCS_PRESUP.IdDoc%TYPE) IS
   SELECT 'ok'
   FROM  CTAS_DOC CTA
   WHERE CTA.IdDoc = cIdDoc;
--
-- Variables de trabajo
 vElegible       BOOLEAN := FALSE;
 R_CTAS          C_CTAS%ROWTYPE;
 R_DOC           C_DOC%ROWTYPE;
 NO_CARGA        EXCEPTION;
BEGIN
  --
  -- Se verifica si existe el documentos
  OPEN C_DOC(pIdDoc);
  FETCH C_DOC INTO R_DOC;
  IF C_DOC%FOUND THEN
   CLOSE C_DOC;

    OPEN C_DOC(pIdDoc);
    LOOP
     FETCH C_DOC INTO R_DOC;
     EXIT WHEN C_DOC%NOTFOUND;
     --
     -- Se determina si tiene cuentas
        OPEN C_CTAS(R_DOC.IdDoc);
        FETCH C_CTAS INTO R_CTAS;
        IF C_CTAS%NOTFOUND THEN
          CLOSE C_CTAS;
        --
        -- Se verifica el modo para determinar si se construye mensaje o se realiza RAISE
            RAISE_APPLICATION_ERROR(-20492, 'ERROR DE DATOS:' ||
            ' El documento "'||R_DOC.IdDoc||'" no contiene cuentas registradas');
        ELSE
          CLOSE C_CTAS;
          vElegible := FALSE;
             BEGIN
			    -- Ahora se pasa el cursor completo de DOCS_PRESUP 
   			    R_DOCTRF.IdDoc           := R_DOC.IdDoc;
	   			R_DOCTRF.FecDoc          := R_DOC.FecDoc;
	   			R_DOCTRF.TipoDoc         := R_DOC.TipoDoc;
			    R_DOCTRF.Ano             := R_DOC.Ano;
			    R_DOCTRF.TipoTransf      := pTipoTransf;    
			    R_DOCTRF.MtoDocGen       := pMtoNoCausado; 
			    R_DOCTRF.StsDoc          := R_DOC.StsDoc;
			    R_DOCTRF.StsTransf       := R_DOC.StsDoc;
			    R_DOCTRF.CodSitio        := R_DOC.CodSitio;
			    R_DOCTRF.CodMoneda       := R_DOC.CodMoneda;
			    R_DOCTRF.Tasa            := R_DOC.Tasa;
			    R_DOCTRF.MontoOrig       := R_DOC.MontoOrig;
                R_DOCTRF.CodMonedaMtoDoc := R_DOC.CodMonedaMtoDoc;
    
                -- Se carga el documento para procesar desde prespuesto la transferencia
				PROC_DOCSTRANSF.CREA_DOC(R_DOCTRF);
/*
                PROC_DOCSTRANSF.CREA_DOC(R_DOC.IdDoc,
                                         R_DOC.FecDoc,
                                         R_DOC.TipoDoc,
                                         R_DOC.Ano,
                                         pTipoTransf,
                                         pMtoNoCausado,
                                         R_DOC.StsDoc,
                                         R_DOC.StsDoc);
*/										 
                vElegible    := TRUE;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20492, 'ERROR DE DATOS:' ||
                  'Al crear  el documento "'||R_DOC.IdDoc||'" como elegible, '
                  ||SQLERRM);
              END;
        END IF; -- Fin C_CTAS%NOTFOUND
      END LOOP;
      --
      -- Se cierra el cursor principal
      CLOSE C_DOC;
  END IF; -- Fin C_DOC%FOUND
END;


--------------------------------------------------------------------------------
-- CONFIRMA_TRANSFDOC: Confirma la tranferencia del documento presupuestario indicado
-- IF 18/08/2003
FUNCTION CONFIRMA_TRANSFDOC (pIdDoc        DOCS_PRESUP.IdDoc%TYPE,
                             pImputacion   VARCHAR2,
                             pAnoDest      DOCS_PRESUP.Ano%TYPE,
                             pPeriodoDest  DOCS_PRESUP.Periodo%TYPE,
                             pTipoDocDest  DOCS_PRESUP.TipoDoc%TYPE,
                             pFecDoc       DOCS_PRESUP.FecDoc%TYPE,
                             pCodCta       CTAS_DOC.CODCTA%TYPE) RETURN BOOLEAN IS
--
-- Documento
  CURSOR C_DOCP(cIdDoc DOCS_PRESUP.IdDoc%TYPE) IS
   SELECT *
   FROM DOCS_PRESUP
   WHERE IdDoc = cIdDoc;

--AC008789 - 26/02/2007 - Se elimino el parametro de periodo
-- Verificación de información del ejercicio destino
  CURSOR C_EJE (cAnno    EJS_PRESUP.Ano%TYPE
               /* cPeriodo EJS_PRESUP.Periodo%TYPE*/) IS
   SELECT 'ok'
   FROM EJS_PRESUP
   WHERE Ano     = cAnno
--    AND  Periodo = cPeriodo
    AND  Sts     = 'EJE';
-- Cuentas del documento
   CURSOR C_CTAS (cIdDoc CTAS_DOC.IdDoc%TYPE) IS
   SELECT *
   FROM CTAS_DOC
   WHERE IdDoc = cIdDoc;
--
CURSOR C_DEF(cTipoDoc VARCHAR2) IS
  SELECT 'ok'
  FROM   TIPOS_DOC_PPTO tp,
         DEF_EVENTO_CP  df
  WHERE  tp.TipoDoc = cTipoDoc
   AND   tp.TipoDoc = df.TipoDoc;
--
-- Variables de trabajo
 NO_TRANSFIERE EXCEPTION;
 R_DOCP        C_DOCP%ROWTYPE;
 R_DOCT        PROC_DOCSTRANSF.C_DOCT%ROWTYPE;
 R_EJE         C_EJE%ROWTYPE;
 R_CTAS        C_CTAS%ROWTYPE;
 R_DEF         C_DEF%ROWTYPE;
 vIdDocGen     DOCUMENTOS_ORIGEN.IdDoc%TYPE;
 vFormulada    BOOLEAN := TRUE;
 vMonto        CTAS_DOC.Monto%TYPE := 0;
 vMtoCNP       CTAS_DOC.Monto%TYPE := 0;
 vMensaje      DOCS_TRANSF.Mensaje%TYPE;
BEGIN
--
-- Limia variables mensaje interno
  LIMPIA_MENSAJE;
--
-- Limia mensaje de la tabla
  PROC_DOCSTRANSF.LIMPIA_MENSAJE(pIdDoc);
--
-- Se validan los parametros recibidos
  IF   pAnoDest IS NULL THEN
    CREA_MSG('ERROR INTERNO: El año recibido del ejercicio no es valido, no contiene valor.');
    RAISE NO_TRANSFIERE;
  ELSIF pPeriodoDest IS NULL THEN
    CREA_MSG('ERROR INTERNO: El periodo recibido del ejercicio no es valido, no contiene valor.');
    RAISE NO_TRANSFIERE;
  ELSIF pTipoDocDest IS NULL THEN
    CREA_MSG('ERROR INTERNO: El tipo de documento recibido para crear el documento'||
             ' de transferencia no es valido, no contiene valor.');
    RAISE NO_TRANSFIERE;
   ELSIF pFecDoc  IS NULL THEN
     CREA_MSG('ERROR INTERNO: La fecha del documento recibida para crear el documento'||
              ' de transferencia no es valido, no contiene valor.');
     RAISE NO_TRANSFIERE;
  END IF;
--
-- Se verifica si esta configurado
  OPEN C_DEF(pTipoDocDest);
  FETCH C_DEF INTO R_DEF;
  IF C_DEF%NOTFOUND THEN
    CLOSE C_DEF;
    CREA_MSG('ERROR DE CONFIGURACION: EL tipo de documento "'||pTipoDocDest||'"'||
             ' no esta configurado en el módulo');
     RAISE NO_TRANSFIERE;
  END IF;
  CLOSE C_DEF;
--
-- Se verifica si el ejercicio esta en ejecución
  OPEN C_EJE(pAnoDest);
  FETCH C_EJE INTO R_EJE;
  IF C_EJE%NOTFOUND THEN  -- No esta en ejecución
    CLOSE C_EJE;
    CREA_MSG('ERROR INTERNO: El año "'||pAnoDest||'" recibido'||
    ' no existe como ejercicio presupuestario o no esta en ejecución.');
    RAISE NO_TRANSFIERE;
  ELSE -- Esta en ejecución 
    -- Setea el año para las estructuras 
    PROC_CTX_PPTO.SETPLANCTAANO(pAnoDest);
    CLOSE C_EJE;
    -- Se obtiene la información de la transferencia
    OPEN PROC_DOCSTRANSF.C_DOCT(pIdDoc);
    FETCH PROC_DOCSTRANSF.C_DOCT INTO R_DOCT;
    IF PROC_DOCSTRANSF.C_DOCT%NOTFOUND THEN
      CLOSE PROC_DOCSTRANSF.C_DOCT;
      CREA_MSG('ERROR INTERNO: El documento "'||pIdDoc||'" no existe como elegible para ser'||
               ' transferido');
     RAISE NO_TRANSFIERE;
    END IF;
    CLOSE PROC_DOCSTRANSF.C_DOCT;
    -- Se verifica el tipo de transferencia 
    IF R_DOCT.TipoTransf = '{COMP-NO-CAUS}' THEN -- Es compromiso NO Causado 
    -- Valida que el documento se encuentre VER solo para los compromisos
      BEGIN
        -- Se obtiene la información del documento
        OPEN C_DOCP(pIdDoc);
        FETCH C_DOCP INTO R_DOCP;
        CLOSE C_DOCP;
        VALIDA_STS(pIdDoc, 'VER');
      EXCEPTION
        WHEN OTHERS THEN
          CREA_MSG('ERROR INTERNO: Problema al verificar el estatus del documento "'||
                 pIdDoc||'", '||SQLERRM);
           RAISE NO_TRANSFIERE;
      END;
    END IF;
    -- Se confirma la transferencia generando un nuevo Documento 
    IF NOT PROC_DOCSTRANSF.CONFIRMA_TRANSF(R_DOCT.IdDoc    , -- Id. del documento
                                           pFecDoc         , -- Fecha doc
                                           pTipoDocDest    , -- Tipo doc
                                           R_DOCT.MtoDocGen, -- Mto del doc
                                           pAnoDest        , -- Año del doc
                                           vIdDocGen)        -- IdDoc. generado
    THEN  -- Ocurrio un problema
      CREA_MSG('ERROR INTERNO: Al confirmar la transferencia del documento "'||pIdDoc||'"');
      RAISE NO_TRANSFIERE;
    END IF;
    -- Se determina si se debe mantener la información del documento origen
	-- Si es "M", quiere las mismas cuentas, si es "A" quiere agrupar en una 
	-- sola cuenta (que paso por parametro), si no es ni M ni A, asumo que NO
	-- quiere cuentas  
    IF pImputacion = 'M' THEN -- El usuario quiere las Mismas cuentas 
      -- Se obtiene la información de las cuentas originales
      FOR R_CTAS IN C_CTAS(pIdDoc) LOOP
		IF R_DOCT.TipoTransf = '{COMP-NO-CAUS}' THEN -- Es compromiso NO causado 
          -- Se calcula el monto del Comprometido NO causado 
          vMonto := R_CTAS.CompAcum - R_CTAS.CausaAcum;
		ELSIF R_DOCT.TipoTransf = '{CAUS-NO-PAG}' THEN -- Es Causado NO Pagado 
          vMonto := R_CTAS.CausaAcum - R_CTAS.PagoAcum;
        END IF;
        -- Se crea el registro en cuentas adic.
        BEGIN
          INSERT INTO CTAS_DOC_ADIC
            (IDDOC ,CODCTA,MONTO)
          VALUES 
			(vIdDocGen,R_CTAS.CodCta,vMonto);
        EXCEPTION
          WHEN OTHERS THEN
            CREA_MSG('ERROR INTERNO: Al crear los registros de la imputación con las '||
                     'cuentas originales del documento "'|| pIdDoc ||'" para el documento'||
                     ' transferencia, '||SQLERRM);
            RAISE NO_TRANSFIERE;
        END;
      END LOOP; -- Cursor de las cuentas originales del Documento 
    ELSIF pImputacion = 'A' THEN -- El usuario quiere todo el monto en una sola cuenta (parametro) 
      -- Se crea el registro en cuentas adic.
      BEGIN
        INSERT INTO CTAS_DOC_ADIC
           (IDDOC ,CODCTA,MONTO)
        VALUES 
		   (vIdDocGen,pCodCta,R_DOCT.MtoDocGen);
      EXCEPTION
          WHEN OTHERS THEN
            CREA_MSG('ERROR INTERNO: Al crear los registros de la imputación del documento de'||
                     ' transferencia, '||SQLERRM);
            RAISE NO_TRANSFIERE;
      END;	  
    END IF; -- Fin pEspCtas
   --
   -- Se verifica el tipo de transferencia para decidir si se actualiza en presupuesto
    IF R_DOCT.TipoTransf = '{COMP-NO-CAUS}' THEN
    --
    -- Se confirma la transferencia
      BEGIN
        UPDATE DOCS_PRESUP
        SET IdDocTransf = vIdDocGen
        WHERE IdDoc    = pIdDoc;
        IF SQL%NOTFOUND THEN
          CREA_MSG('ERROR DE DATOS: No se encontro el documento "'||pIdDoc||'" '||
                   ' `para ser actualizado');
          RAISE NO_TRANSFIERE;
        END IF;
       EXCEPTION
         WHEN OTHERS THEN
           CREA_MSG('ERROR INTERNO: Al actualizar la información de transferencia del'||
           ' documento "'||pIdDoc||'" ,'||SQLERRM);
             RAISE NO_TRANSFIERE;
       END;
    END IF;
  END IF; --Fin C_EJE%NOTFOUND
---
  RETURN(TRUE);
EXCEPTION
 WHEN NO_TRANSFIERE THEN
   vMensaje := VER_MENSAJE;
   UPDATE DOCS_TRANSF
   SET Mensaje =  Mensaje|| CHR(10) || vMensaje,
       StsTransf = 'ERR'
   WHERE IdDoc = pIdDoc;
   RETURN(FALSE);
END;

--------------------------------------------------------------------------------
-- REVERSA_TRANSFDOC: Reversa carga del documento elegibles para transferir
-- IF 18/08/2003
PROCEDURE REVERSA_TRANSFDOC (pIdDoc DOCS_PRESUP.IdDoc%TYPE)  IS
--
-- Variables de trabajo
 R_DOCT        PROC_DOCSTRANSF.C_DOCT%ROWTYPE;
BEGIN
--
-- Se obtiene la información de la transferencia
  OPEN PROC_DOCSTRANSF.C_DOCT(pIdDoc);
  FETCH PROC_DOCSTRANSF.C_DOCT INTO R_DOCT;
  IF PROC_DOCSTRANSF.C_DOCT%NOTFOUND THEN
    CLOSE PROC_DOCSTRANSF.C_DOCT;
    RAISE_APPLICATION_ERROR(-20497,'ERROR DE DATOS: '||
     'El documento "'||pIdDoc||'" no existe como elegible para ser'||
     ' transferido');
  END IF;
  CLOSE PROC_DOCSTRANSF.C_DOCT;
  --
  -- Se verifica el estatus de la transferencia para identificar las acciones a tomar
  IF R_DOCT.Ststransf IN ('PEN','ERR') THEN
   --
   -- Se verifica el estatus y el mensajero no la confirmo
     IF R_DOCT.Ststransf IN ('ERR') AND    -- No confirmo por mensajero
           R_DOCT.IdDocGen IS NOT NULL THEN
     --
     -- Se anula el documento
        PROC_MENSAJERO.ANULA_DOC(R_DOCT.IdDocGen,'PPTO',
                'Documento anulado por reverso de la transferencia del documento "'||
                pIdDoc||'" que lo genero');

     ELSIF R_DOCT.Ststransf IN ('PEN')
       AND R_DOCT.TipoTransf = '{COMP-NO-CAUS}' THEN -- Pendiente o no confirmado
                                                     --  solo aplica para compromisos
      --
      -- Valida que el documento original se encuentre VER en presupuesto
        VALIDA_STS(pIdDoc, 'VER');
     END IF;
  ELSIF R_DOCT.Ststransf IN ('PRO','CER') THEN -- Confirmada o cerrada
    --
    -- Valida que el documento generado por la confirmacion no se encuentre VER
      VALIDA_STS(R_DOCT.IdDocGen, 'REC,COD,RCH');
    --
    -- Se anula el documento en presupuesto
      ANULA_DOC(R_DOCT.IdDocGen);
  END IF;
--
-- Se verifica la clase de transferencia para saber que accion tomar
  IF R_DOCT.TipoTransf = '{COMP-NO-CAUS}' THEN
  --
  -- Se verifica el estatus de la transferencia y que la confirmacion genero documento
    IF R_DOCT.Ststransf IN ('PRO','ERR') AND
      R_DOCT.IdDocGen IS NOT NULL THEN
    --
    -- Se blanquea las columnas que contiene información de la transferencia
      BEGIN
        UPDATE DOCS_PRESUP
        SET  IdDocTransf = NULL
        WHERE IdDoc      = pIdDoc;


        UPDATE DOCS_PRESUP
        SET  IdDocOrigTransf = NULL
        WHERE IdDoc          = R_DOCT.IdDocGen;

      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20498,'ERROR INTERNO: '||
            'Al actualizar las columnas que contiene información de la transferencia, '||SQLERRM);
      END;
    END IF;
  ELSIF R_DOCT.TipoTransf = '{CAUS-NO-PAG}' THEN -- Causado no pagado
  --
  -- Se devuelve el estatus a la solicitu de pago

    -- MV 27/05/2004: Comentado porque crea una dependencia indebida de PPTO hacia TESO
    -- MV 03/09/2007: Reactivado para resolver problema de llamada 9395 del INE
    PROC_DOCS_TESO.REVERSA_TRANSFDOC (pIdDoc,R_DOCT.StsDoc);
    RAISE_APPLICATION_ERROR(-20001, 'ERROR INTERNO: NO SE PUEDE EJECUTAR PROC_DOCS_TESO!');
  END IF;
--
-- Elimina el registro de la transferencia
  PROC_DOCSTRANSF.ELIMINA_TRANSF(pIdDoc);
END;
--------------------------------------------------------------------------------------------------
-- RECHAZAR_DOC: Reenvio de documentos devueltos
FUNCTION REENVIAR_DOC(pIdDoc DOCS_PRESUP.IdDoc%TYPE)  RETURN VARCHAR2 IS
--
-- Variables de trabajo
vCodProxSis  GOBSTD.CodSis;
rEvento     EVENTOS_ADMON%ROWTYPE;
BEGIN
-- Valida que el documento este devuelto
 VALIDA_STS(pIdDoc, 'DEV');
--
-- Busca todos los datos del último evento del documento.
  rEvento := PROC_MENSAJERO.BUSCA_ULT_EVENTO(pIdDoc);
--
--
  vCodProxSis := PROC_MENSAJERO.RECHAZA_DOC_DEV(pIdDoc, rEvento.IdEvento);
-- Coloca el documento en estado VER
  BEGIN
    UPDATE DOCS_PRESUP
    SET    StsDoc = 'VER',
           UsuVer = SUBSTR(USER,1,15),
           FecVer = SYSDATE
    WHERE  IdDoc = pIdDoc;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20200,'ERROR INTERNO: '||
        'Problemas al actualizar el documento "' || pIdDoc ||'", ' || SQLERRM);
  END;
  IF SQL%NOTFOUND THEN
     RAISE_APPLICATION_ERROR(-20210,'ERROR DE DATOS: '||
     'No se encontró el documento "'|| pIdDoc ||'" para ser actualizado');
  END IF;
--
 RETURN vCodProxSis;
END;
--
/*****FIN DEL PACKAGE*****/
END;

/
