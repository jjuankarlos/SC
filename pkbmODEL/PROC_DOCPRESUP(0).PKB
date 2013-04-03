CREATE OR REPLACE PACKAGE BODY      PROC_DOCPRESUP IS
-- Número de versión del package
vVerPkg VARCHAR2(10) := '4.2.1';
--
/* INI:KNTDocVer *********************************************************************
 REVISIONES (en orden inverso):
 Vers        Fecha       Autor        Lista de reportes de falla (ej: 123, 4678, 45.3)
 ----------  ----------  -----------  ------------------------------------------------
 4.2.1       25/06/2008  M.Veloso     101168
 Cuando el tipo de documento indicaba que la distribución era no preferencial, pero
 la cuenta de imputación preferencial tenía valor, hacía la distribución como si fuera
 preferencial. Ahora toma en cuenta tanto el modo como que tenga la cuenta para 
 la imputación preferencial.
 También se incluyó la verificación en los querys que hacían referencia a CodCtaImputPref 
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 4.2.0       06/05/2008  M.Veloso     101168
 Ahora puede utilizar la imputación externa que venga por CTAS_DOC_ADIC para hacer una 
 imputación parcial y el resto tomarla de las cuentas del documento padre, como hasta 
 ahora.
 -------------------------------------------------------------------------------------
 4.1.2       29/02/2007  IFLORES      010781
 Ahora en la PROCEDURE ASIGNA_INF_DOCUMENTO_REF en el manejo de ajuste del monto se
 determina la cantidad de hermanos del documento para utilizarlo como factor en
 la multiplicacion de la diferencia que debe debe cumplir el monto para
 ser ajustado.  
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 4.1.1       24/01/2007  IFLORES      010781
 Ahora en la PROCEDURE ASIGNA_INF_DOCUMENTO_REF en el manejo de ajuste del monto
 del documento se amplio a 20 la maxima diferencia que debe debe cumplir el monto para
 ser ajustado.  
 -------------------------------------------------------------------------------------
 4.1.0       25/10/2007  CPRINS       101139
 Se colocó información monetaria en el package RECIBE_DOC_AUTO.
 -------------------------------------------------------------------------------------
 4.0.1       26/01/2007  RARRIETA     008757
 Se modificó el proceso de validación  de imputaciones adicionales para que se tome en 
 cuanta las imputaciones de cuentas externas (en caso de tenerlas) y no distribuya los 
 montos con las cuentas del documento padre. Tambien se valida si en realidad estan 
 cargadas las cuentas de lo contrario toman las del padre.
 -------------------------------------------------------------------------------------
 4.0.0       13/01/2006  APIMENTEL    007050
 Se agrego el campo del código de estructura al insert de CTAS_DOC
 -------------------------------------------------------------------------------------
 3.3.3       20/01/2005  VNEGRIN      100516
 Se le agrego el campo de la descripción extendida del documentos en la Función
 RECIBE_DOC_AUTO
 -------------------------------------------------------------------------------------
 3.3.2       18/01/2005  MRosito      005675
 Se modifica RECIBE_DOC_AUTO para colocar la condición al UPDATE de docs_presup que
 se hace cuando llega un documento que ha sido devuelto. El UPDATE estaba sin condición
 y al tratar de modificar todos los documentos fallaba el trigger de la tabla.
 -----------------------------------------------------------------------------------
 3.3.1       02/12/2004  RARRIETA     005074
 Se modificó la recepción de docs para actualizalo si existe y tiene estaus REV.
 -----------------------------------------------------------------------------------
 3.3.0       04/05/2004   IFLORES     004623
 Correción PROCEDURE ASIGNA_INF_DOCUMENTO_REF al buscar la definicion del tipo de
 documento padre con la informacion registrada en DOCS_PRESUP, ademas ahora el
 PROCEDURE no recibe ni es codigo de sistema que aprueba ni el tipo de evento.
 -----------------------------------------------------------------------------------
 3.2.0       05/04/2004  A. Botana
 Se corrige la falla eventual cuando distribuye el monto en las cuentas del padre
 en el caso que el tipo de documento del padre tuviera mas de una definicion en la
 tabla de eventos presupuestarios. Al buscar la definicion solo con el tipo de documento
 podia estar tomando el evento incorrecto (un tipodoc que tuvo un cambio de ruta)
 -----------------------------------------------------------------------------------
 3.1.2       12/02/2004  M.Veloso     004304
 Se corrigió un problema ocasional de distribución del monto de un documento entre las
 cuentas del documento de referencia, cuando se agregaban cuentas al documento padre
 que no existían originalmente.
 -----------------------------------------------------------------------------------
 3.1.1       19/08/2003  IF           100191
 Se adapto la FUNCTION RECIBE_DOC_AUTO para no permitir aceptar la devolución de un
 documento que este elegible para transferencia.

 Se adapto la FUNCTION RECIBE_DOC_AUTO para verificar si se recibe un documento de
 transferencia para registrar el documento de origen de la misma.
 -----------------------------------------------------------------------------------
 3.1.0       14/07/2003  M.Veloso
 Se cambió llamada a PROC_ADICIONAL por PROC_ADICIONAL_PPTO.
 -----------------------------------------------------------------------------------
 3.0.8       25/06/2003  M.Veloso
 Error en la distribución del monto, se borraba el monto de la referencia y no hacía la
 distribución.
 -----------------------------------------------------------------------------------
 3.0.7       18/06/2003  M.Veloso
 Se modificó la función que distribuye el monto del documento según las cuentas del
 documento padre, para que maneje el caso en que al padre se le agregaron cuentas
 a traves de una modificación.
 -----------------------------------------------------------------------------------
 3.0.6       20/05/2003  M.Veloso
 Ajuste para evitar división por cero al preparar la imputación a partir del
 documento de referencia, cuando este tiene cuentas nuevas, con monto cero.
 -----------------------------------------------------------------------------------
 3.0.5       06/03/2003  IF
 Cambio en el manejo de la construcción de los mensajes de error que se pueden presentar
 al recibir un determinado documento en la function RECIBE_DOC_AUTO utilizando la
 funcionalidad de PROC_DOCUMENTOS.CREA_MSG.
 -----------------------------------------------------------------------------------
 3.0.4       29/04/2002  M.Veloso
 Incorporación de modificaciones menores en RECIBE_DOC_AUTO para permitir el proceso
 mediante los scripts de pruebas, haciendo algunas de las funciones que hace actualmente
 FDPCOD.
 -----------------------------------------------------------------------------------
 3.0.3       23/04/02    IF
 Se incorporó a la función RECIBE_DOC_AUTO la posibilidad de registrar en una forma mas
 clara la causa de la no recepción de algun tipo de documento.
 -----------------------------------------------------------------------------------
 3.0.2       18/04/02    MRM
 Se chequea si el doocumento de referencia existe en presupuesto antes de tomar
 la información necesaria.
 -----------------------------------------------------------------------------------
 3.0.1       21/03/02    MRM
 Se toma el año de la fecha del documento para compararla con el campo año del
 documento padre(IdDocRef) para determinar si es semestre complementario. Se
 determinó que pueden llegar doc. con ejercicio presup. 2001 y fecha 2002 y ser
 semestres complementarios .
 -----------------------------------------------------------------------------------
 3.0.0       22/02/01    BM
 Se comentaron algunas líneas que hacen referencia a las tablas CTAS_CCOSTO_DOC y
 CENTS_COSTO_DOC debido que estas ya no se usan.
 -----------------------------------------------------------------------------------
 2.0.0       12/02/01    MT
 Se borran el documento con sus cuentas cuando ocurre una EXCEPTION
 -----------------------------------------------------------------------------------
 1.0.0       15/01/01    BM
 Numeración inicial.
 -----------------------------------------------------------------------------------
** FIN:KNTDocVer *********************************************************************/

--AP(16/01/2006) Cursor para traer el código de estructura del ejercicio presupuestario
CURSOR C_EJS (pAno NUMBER) IS
	SELECT EJS.CodEstruct
	FROM   EJS_PRESUP EJS
	WHERE  EJS.Ano = pAno;
--
/*********************************************************/
/* VERPKG: Retorna el numero de versión de este package. */
/*********************************************************/
FUNCTION VERPKG RETURN VARCHAR2
IS
BEGIN
  RETURN vVerPkg;
END VERPKG;
/*************************************************************/
--
FUNCTION RECIBE_DOC_AUTO(R_EVE PROC_MENSAJERO.C_EVE%ROWTYPE) RETURN BOOLEAN IS

  --
  -- Variables de trabajo
  nAnoRef         KNTSTD.Ano;
  --MRM21/03/02 Se toma el año de la fecha del documento. Esto se hace para determinar
  -- más abajo si es un semestre complementario.
  --nAno            KNTSTD.Ano := R_EVE.Ano;
  nAno            KNTSTD.Ano := TO_NUMBER(TO_CHAR(R_Eve.FecDoc, 'YYYY'));
  nPeriodo        KNTSTD.Mes := TO_NUMBER(TO_CHAR(R_Eve.FecDoc, 'MM'));
  cIndProcAuto    KNTSTD.Indicador;
  lCreado         BOOLEAN;
  vAdicional      BOOLEAN;
  cStsDoc         KNTSTD.Estatus;
  cSts            KNTSTD.Estatus;
  cCodAccInt      GOBSTD.CodAccInt;
  cCodPrograma    GOBSTD.CodPrograma;
  cIndDistCC      KNTSTD.Indicador;
  cIndCcMultiple  KNTSTD.Indicador;
  cIndAccInt      KNTSTD.Indicador;
  cIndCodProg     KNTSTD.Indicador;
  vIndEstComprom  KNTSTD.Indicador;
  cTipoCompromRef GOBSTD.TipoComprom;
  vTipoComprom    GOBSTD.TipoComprom;
  cNivelComprom   GOBSTD.NivelComprom;
  nClaseComprom   GOBSTD.ClaseComprom;
  cIndAuto        KNTSTD.Indicador;
  cIndCCosto      KNTSTD.Indicador;
  cIndTransf      KNTSTD.Indicador;
  cCcosto         GOBSTD.CCosto;
  cCodUsuario     KNTSTD.CodUsuario;
  cMensaje        GOBSTD.Mensaje;
  cCodProxSis     GOBSTD.CodSis;
  vParamRec       DEF_EVENTO_CP.ParamRec%TYPE;
  vDummy          NUMBER(1);
  vStsDocRef      DOCS_PRESUP.StsDoc%TYPE;
  vFecReconv      DATE;
  vMtoDoc         DOCS_PRESUP.MTODOC%TYPE;
  vCodMonedaMtoDoc DOCS_PRESUP.CODMONEDAMTODOC%TYPE;
  vCodMoneda       DOCS_PRESUP.CODMONEDA%TYPE;
  vMontoOrig       DOCS_PRESUP.MontoOrig%TYPE;
  vTasa            DOCS_PRESUP.TASA%TYPE;
  vFactorReconv   CONTROL_KNT.FACTRECONV%TYPE;
  R_DOC           PROC_PRESUP.C_DOC%ROWTYPE;
  R_DOCT          PROC_DOCSTRANSF.C_DOCT%ROWTYPE;
  R_DOCTG         PROC_DOCSTRANSF.C_DOCTG%ROWTYPE;
  R_DOCPRE        DOCS_PRESUP%ROWTYPE;
  NO_RECIBE       EXCEPTION;
  NO_RECIBE_DEV   EXCEPTION;

  vIndDistCtaAdic BOOLEAN;
--

  --02/12/2004RA:Cursor para buscar documentos en DOCS_PRESUP
  CURSOR C_DOCSPRE(cIdDoc DOCS_PRESUP.IdDoc%TYPE)
  IS
    SELECT *
    FROM DOCS_PRESUP
    WHERE IdDoc = cIdDoc;
    
  -- Cuentas adicionales del documento
  CURSOR C_CTA(cIdDoc NUMBER) IS
    SELECT CodAccInt, CCosto, CodCta, CodPrograma, SUM(Monto) Monto
    FROM   CTAS_DOC_ADIC
    WHERE  IdDoc = cIdDoc
    GROUP BY CodAccInt, CCosto, CodCta, CodPrograma;
    
R_CTA C_CTA%ROWTYPE;    

BEGIN
  PROC_DOCUMENTOS.LIMPIA_MENSAJE;
  
  vFecReconv := PROC_RECONV_KNT.FECHA_RECONV;

  BEGIN
    SELECT 1
    INTO vDummy
    FROM DEF_EVENTO_CP DEF,
         V_EVENTOCP EVE
    WHERE DEF.TipoDoc = R_EVE.TipoDoc AND
          DEF.TipoDoc = EVE.TipoDoc AND
          DEF.CodSisAprob = EVE.CodSisAprob AND
          DEF.TipoEvento = EVE.TipoEvento;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       PROC_DOCUMENTOS.CREA_MSG('-20201, El tipo de documento: ' || R_EVE.TipoDoc ||
                  ' indicado no está definido en presupuesto.' ||SQLERRM);
      RAISE NO_RECIBE;
    WHEN OTHERS THEN
       PROC_DOCUMENTOS.CREA_MSG('-20202, Problema al tratar de obtener la definición para el tipo '||
                  'de documento '||R_EVE.TipoDoc ||' en la tabla DEF_EVENTO_CP. '||SQLERRM);
      RAISE NO_RECIBE;
  END;

  -- MV 29/04/2002: Nos traemos también el nivel de compromiso, para disminuir
  -- la dependencia de FDPCOD y poder utilizar los scripts de pruebas
  BEGIN
    SELECT IndProcAuto, TipoComprom, IndEstComprom, NivelComprom
    INTO   cIndProcAuto, vTipoComprom, vIndEstComprom, cNivelComprom
    FROM   TIPOS_DOC_PPTO
    WHERE  TipoDoc = R_EVE.TipoDoc;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
     PROC_DOCUMENTOS.CREA_MSG('-20203, El tipo de documento: ' || R_EVE.TipoDoc ||
                ' indicado no está definido en presupuesto en la tabla TIPOS_DOC_PPTO.' ||SQLERRM);
      RAISE NO_RECIBE;
    WHEN OTHERS THEN
       PROC_DOCUMENTOS.CREA_MSG('-20204, Problema al tratar de obtener información para el tipo '||
                  'de documento '||R_EVE.TipoDoc ||' en la tabla TIPOS_DOC_PPTO. '||SQLERRM);
      RAISE NO_RECIBE;
  END;

  IF R_EVE.TipoEvento = 'DEV' THEN
  --
  -- IF (19/08/2003): Se verifica si el documento devuelto no esta elegible para
  --                  ser transferido.
    OPEN PROC_DOCSTRANSF.C_DOCT(R_EVE.IdDoc);
    FETCH PROC_DOCSTRANSF.C_DOCT INTO R_DOCT;
    IF PROC_DOCSTRANSF.C_DOCT%NOTFOUND THEN  -- No es un elegible para transferir
      CLOSE PROC_DOCSTRANSF.C_DOCT;
      lCreado := TRUE;
      UPDATE DOCS_PRESUP
      SET StsDoc = 'DEV',
          Mensaje = R_EVE.Mensaje
      WHERE IdDoc = R_EVE.IdDoc;
    ELSE
       CLOSE PROC_DOCSTRANSF.C_DOCT;
       PROC_DOCUMENTOS.CREA_MSG('-20300, ERROR INTERNO: '||
       ' La devolución del documento "'||R_EVE.IdDoc||'" no se puede recibir porque el'||
       ' el documento esta en proceso o fué transfererido a un nuevo ejercicio.');
      RAISE NO_RECIBE_DEV;
    END IF;

  ELSE
  --
  -- IF (19/08/2003): Se verifica si el documento es una transferido.
    OPEN PROC_DOCSTRANSF.C_DOCTG(R_EVE.IdDoc);
    FETCH PROC_DOCSTRANSF.C_DOCTG INTO R_DOCTG;
    IF PROC_DOCSTRANSF.C_DOCTG%FOUND THEN  -- Es una transf.
      cIndTransf := 'S';
    ELSE
      cIndTransf := 'N';
    END IF;
    CLOSE PROC_DOCSTRANSF.C_DOCTG;
  --
    cMensaje := NULL;
    IF R_EVE.TipoEvento = 'RCM' THEN
      cStsDoc := 'REC';
      cIndAuto := 'N';
      cCodUsuario := R_EVE.UsrCod;
    ELSE
      cStsDoc := 'PEN';
      cIndAuto := 'S';
      cCodUsuario := NULL;
    END IF;

    cCodAccInt := R_EVE.CodProyInt;
    IF cCodAccInt IS NOT NULL THEN
      cIndAccInt := 'S';
      cIndCodProg := 'S';

      BEGIN
        SELECT CodPrograma
        INTO   cCodPrograma
        FROM   ACCS_INT
        WHERE  Ano       = R_EVE.Ano
        AND    CodAccInt = cCodAccInt;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          cCodPrograma := NULL;
          cIndCodProg  := 'N';
      END;

    END IF;

    cCCosto := R_EVE.CCosto;
    IF cCCosto IS NOT NULL THEN
      cIndCCosto := 'S';
    END IF;

    IF R_EVE.IdDocRef IS NOT NULL THEN  --Tiene Referencia
      OPEN PROC_PRESUP.C_DOC(R_EVE.IdDocRef);
      FETCH PROC_PRESUP.C_DOC INTO R_DOC;

      -- MRM 18/04/02: Se chequea que el iddocref exista en ppto.
      IF PROC_PRESUP.C_DOC%NOTFOUND THEN
        CLOSE PROC_PRESUP.C_DOC;
         PROC_DOCUMENTOS.CREA_MSG('-20200, El documento de referencia ' || R_EVE.IdDocRef ||
                    ' indicado en el documento no existe en presupuesto.' ||
                    SQLERRM);
        RAISE NO_RECIBE;
      END IF;

      CLOSE PROC_PRESUP.C_DOC;

      nAno := R_DOC.Ano;
      IF R_DOC.Ano < TO_NUMBER(TO_CHAR(R_Eve.FecDoc, 'YYYY')) THEN -- Es Semestre
        nPeriodo := nPeriodo + 12;
      END IF;

      -- Sólo nos traemos información del padre, si no tiene información
      IF cCodAccInt IS NULL THEN
        cCodAccInt      := R_DOC.CodAccInt;
        cIndAccInt      := R_DOC.IndAccInt;
      END IF;

      IF cCodPrograma IS NULL THEN
        cCodPrograma    := R_DOC.CodPrograma;
        cIndCodProg     := R_DOC.IndCodProg;
      END IF;

      IF cCCosto IS NULL THEN
        cCCosto         := R_DOC.CCosto;
        cIndCCosto      := R_DOC.IndCCosto;
      END IF;

      cTipoCompromRef := R_DOC.TipoComprom;
      cNivelComprom   := R_DOC.NivelComprom;
      nClaseComprom   := R_DOC.ClaseComprom;
      vStsDocRef      := R_DOC.StsDoc;

    END IF;

    --BM 06/04/00 Cuando un documento establece compromiso, el tipo de compromiso
    --debe ser igual al tipo de compromiso de la definición del documento, y no
    --el tipo de compromiso del documento padre en caso de tenerlo.
    IF vIndEstComprom = 'N' THEN
      vTipoComprom := cTipoCompromRef;
    END IF;

    -- AB:02.08.00 Si el usuario verificador del sistema anterior(origen) tiene nivel Codificador o
    -- Supervisor en ORPA, se realiza la recepción del Doc. Automaticamente.
    IF PROC_PRESUP.USRVER_CODPPTO(R_EVE.UsrVer) AND cStsDoc = 'PEN' THEN
      cStsDoc := 'REC';
      cCodUsuario := R_EVE.UsrVer;
    END IF;
    
    BEGIN

      IF R_EVE.IdDocRef IS NOT NULL THEN

        OPEN  C_DOCSPRE(R_EVE.IdDocRef);
        FETCH C_DOCSPRE INTO R_DOCPRE;
        CLOSE C_DOCSPRE;

        IF R_DOCPRE.IdDoc IS NULL THEN        
          PROC_DOCUMENTOS.CREA_MSG('-20101, El documento de referencia con el IdDoc ' || R_EVE.IdDocRef || ' no existe' );
          RAISE NO_RECIBE;
        ELSE -- Verificamos que el documento padre este verificado en el modulo
           IF R_DOCPRE.StsDoc != 'VER' THEN
           PROC_DOCUMENTOS.CREA_MSG('-20101, El documento de referencia con el IdDoc ' || R_EVE.IdDocRef || ' no esta verificado en el modulo' );
          RAISE NO_RECIBE;
           END IF;          
        END IF;
        
        vMtoDoc          := PROC_RECONV_KNT.MONTO_REEXPRESADO(R_EVE.MtoDoc, R_EVE.CodMonedaMtoDoc, 
                            R_DOCPRE.CodMonedaMtoDoc);
                            
        vCodMonedaMtoDoc := R_DOCPRE.CodMonedaMtoDoc;

        vTasa            := PROC_MONEDA.TASA(PROC_INSTALACION.SitioInst,R_EVE.CodMonedaMtoDoc, 
                            R_DOCPRE.CodMonedaMtoDoc, R_EVE.FecDoc);		   
        vMontoOrig       := R_EVE.MtoDoc;
        vCodMoneda       := R_EVE.CodMonedaMtoDoc;         
      ELSE
        vMtoDoc          :=  R_EVE.MtoDoc;
        vCodMonedaMtoDoc :=  R_EVE.CodMonedaMtoDoc;
        vTasa            :=  R_EVE.Tasa;	  
        vMontoOrig       :=  R_EVE.MontoOrig;
        vCodMoneda       :=  R_EVE.CodMoneda; 
      END IF;	 

	   	
      OPEN C_DOCSPRE(R_EVE.IdDoc);
      FETCH C_DOCSPRE INTO R_DOCPRE;      
    
      IF C_DOCSPRE%NOTFOUND THEN  -- No existe el documento en la tabla DOCS_PRESUP
         CLOSE C_DOCSPRE;
         INSERT INTO DOCS_PRESUP
               (Ano, IdDoc, TipoDoc,
                FecDoc, StsDoc, DescDoc, RefDoc,
                MtoDoc, NumBenef, IndAuto, Origen, TipoEvento,
                OrgEvento, IdDocRef, Periodo, Mensaje,
                CodAccIntDoc, CodProgramaDoc, IndDistCc, IndCcMultiple, IndAccInt,
                IndCodProg, TipoComprom, NivelComprom, ClaseComprom, CCostoDoc,-- (*)
                FecRec, UsuRec, UsuCod, IndReverso, IndCCosto,
                IndEstComprom,IdDocOrigTransf,DescDocExt,
  			  CodMoneda,CodSitio,Tasa,MontoOrig,CodMonedaMtoDoc)
         VALUES
               (nAno, R_EVE.IdDoc, R_EVE.TipoDoc,
                R_EVE.FecDoc, cStsDoc, R_EVE.DescDoc, R_EVE.RefDoc,
                vMtoDoc, R_EVE.NumBenef, cIndAuto, R_EVE.Origen, R_EVE.TipoEvento,
                R_EVE.CodSisGen, R_EVE.IdDocRef, nPeriodo, R_EVE.Mensaje,
                cCodAccInt, cCodPrograma, cIndDistCc, cIndCcMultiple, cIndAccInt,
                cIndCodProg, vTipoComprom, cNivelComprom, nClaseComprom, cCCosto,
                SYSDATE, R_EVE.UsrRec, cCodUsuario, R_EVE.IndReverso,cIndCCosto,
                vIndEstComprom,DECODE(cIndTransf,'S',R_DOCTG.IdDoc,NULL), R_EVE.DescDocExt,
  			  vCodMoneda,R_EVE.CodSitio,vTasa,vMontoOrig,vCodMonedaMtoDoc);

      ELSE
        CLOSE C_DOCSPRE;
        IF R_DOCPRE.StsDoc = 'REV' THEN
        --MRM 18/01/05 Se coloca condición
           UPDATE DOCS_PRESUP SET
                  Ano   	        = nAno,
                  IdDoc           = R_EVE.IdDoc,
                  TipoDoc	        = R_EVE.TipoDoc,
                  FecDoc	        = R_EVE.FecDoc,
                  StsDoc	        = cStsDoc,
                  DescDoc	        = R_EVE.DescDoc,
                  RefDoc	        = R_EVE.RefDoc,
                  MtoDoc	        = vMtoDoc,
                  NumBenef	      = R_EVE.NumBenef,
                  IndAuto	        = cIndAuto,
                  Origen	        = R_EVE.Origen,
                  TipoEvento      = R_EVE.TipoEvento,
                  OrgEvento  	    = R_EVE.CodSisGen,
                  IdDocRef	      = R_EVE.IdDocRef,
                  Periodo	        = nPeriodo,
                  Mensaje	        = R_EVE.Mensaje,
                  CodAccIntDoc    = cCodAccInt,
                  CodProgramaDoc  = cCodPrograma,
                  IndDistCc       = cIndDistCc,
                  IndCcMultiple   = cIndCcMultiple,
                  IndAccInt       = cIndAccInt,
                  IndCodProg      = cIndCodProg,
                  TipoComprom     = vTipoComprom,
                  NivelComprom    = cNivelComprom,
                  ClaseComprom    = nClaseComprom,
                  CCostoDoc       = cCCosto,
                  FecRec          = SYSDATE,
                  UsuRec          = R_EVE.UsrRec,
                  UsuCod          = cCodUsuario,
                  IndReverso      = R_EVE.IndReverso,
                  IndCCosto       = cIndCCosto,
                  IndEstComprom   = vIndEstComprom,
                  IdDocOrigTransf = DECODE(cIndTransf,'S',R_DOCTG.IdDoc,NULL),
                  DescDocExt      = R_EVE.DescDocExt,
  				CodMoneda       = vCodMoneda,
  				CodSitio        = R_EVE.CodSitio,
  				Tasa            = vTasa,
  				MontoOrig       = vMontoOrig,
  				CodMonedaMtoDoc = vCodMonedaMtoDoc
              WHERE IdDoc = R_EVE.IdDoc;
           ELSE
               PROC_DOCUMENTOS.CREA_MSG('-20111, ERROR DE PROCESO: Ya existe el documento ['||R_DOCPRE.IdDoc ||']'
               ||' para poder procesarlo debe tener estatus REV, Actualmente se encuentra '|| R_DOCPRE.StsDoc);
               RAISE NO_RECIBE;
           END IF;
      END IF;                     
      
    EXCEPTION  WHEN OTHERS THEN
       PROC_DOCUMENTOS.CREA_MSG('-20100, Problemas al insertar en documentos presupuestarios'
                  || SQLERRM);
      RAISE NO_RECIBE;
    END;
    
    vAdicional      := FALSE;   
    vIndDistCtaAdic := FALSE;
    
    --RA:Se verifica si tiene cuentas adicionales
    OPEN  C_CTA(R_EVE.IdDoc);
    FETCH C_CTA INTO R_CTA;
    
    IF C_CTA%FOUND THEN
      -- Para ser una imputación válida debe tener estos tres valores
      IF  R_CTA.CodCta    IS NOT NULL  
      AND R_CTA.CCosto    IS NOT NULL 
      AND R_CTA.CodAccInt IS NOT NULL THEN
        vAdicional := true;
        
      -- MV: Verificamos si sólo viene la cuenta, en cuyo caso hay que hacer 
      -- una distribución en función de las cuentas del documento de referencia
      ELSIF R_CTA.CodCta    IS NOT NULL  
      AND   R_CTA.CCosto    IS NULL 
      AND   R_CTA.CodAccInt IS NULL THEN
        vIndDistCtaAdic := TRUE;
      END IF;
      
    END IF;
    
    CLOSE C_CTA;
    
    --
    -- Se verifica si existe parámetro de proceso
    BEGIN
      SELECT ParamRec
      INTO vParamRec
      FROM DEF_EVENTO_CP
      WHERE TipoDoc = R_EVE.TipoDoc AND
            CodSisAprob = R_EVE.CodSisGen AND
            TipoEvento = R_EVE.TipoEvento;

    EXCEPTION
      WHEN OTHERS THEN
         PROC_DOCUMENTOS.CREA_MSG('-20101, Problema obteniendo el parámetro de proceso asociado el tipo '||
                    'documento: '|| R_EVE.TipoDoc || 'de la tabla DEF_EVENTO_CP. '||SQLERRM);
        RAISE NO_RECIBE;
    END;
    
    --Verifica si tiene el parametro configurado y las cuentas adicionales cargadas
    IF vParamRec IS NOT NULL AND vAdicional THEN
      IF NOT PROC_ADICIONAL_PPTO.RECIBE_ADICIONAL(vParamRec, R_EVE.IdDoc) THEN
        RAISE NO_RECIBE;
      ELSE
        -- IF (25/08/2003) : Se comento la sentencia return y se sutituyo por la variable
        --                   lCreado
        --RETURN(TRUE);
        lCreado :=  TRUE;
      END IF;
      
    ELSE
      --
      -- IF 04/05/04: Ahora no se envia codigo de sistema genera ni el tipo de evento
      --
      -- Asigna los datos del documento de referencia al documento referenciado
      -- MV 18/06/03: Solo si tiene documento de referencia
      IF R_EVE.IdDocRef IS NOT NULL THEN
        ASIGNA_INF_DOCUMENTO_REF (R_EVE.IdDoc, FALSE, vIndDistCtaAdic);
      END IF;                                  
      
      lCreado :=  TRUE;
    END IF;

  END IF;

  RETURN(lCreado);

EXCEPTION
--      DBMSOUTPUT.PUTLINE('EXCEPTION ');
  WHEN NO_RECIBE THEN
    vMensaje := PROC_DOCUMENTOS.VER_MENSAJE;
   -- MT.12/02/01. Se borra el doc y las ctas del doc si ocurre una exception
    DELETE CTAS_DOC
    WHERE IdDoc = R_EVE.IdDoc;
    DELETE  DOCS_PRESUP
    WHERE IdDoc = R_EVE.IdDoc;
    UPDATE DOCUMENTOS_ORIGEN
    SET Mensaje = vMensaje
    WHERE IdDoc = R_EVE.IdDoc;
    UPDATE DOCS_TRANSF
    SET Mensaje   = vMensaje,
        StsTransf = 'ERR'
    WHERE IdDocGen = R_EVE.IdDoc;

    RETURN(FALSE);
  --
  -- IF (19/08/2003) : Nueva exception para la no recepción de devolución
  WHEN NO_RECIBE_DEV THEN
   vMensaje := PROC_DOCUMENTOS.VER_MENSAJE;
    UPDATE  DOCS_PRESUP
    SET Mensaje = vMensaje
    WHERE IdDoc = R_EVE.IdDoc;
    UPDATE DOCUMENTOS_ORIGEN
    SET Mensaje = vMensaje
    WHERE IdDoc = R_EVE.IdDoc;
    RETURN(FALSE);
END;


/***********************************************************************/
/*Proceso de asignación de información del documento referenciado      */
/***********************************************************************/
--
-- IF 04/05/04: Ahora no recibe el codigo de sistema ni el tipo de evento
PROCEDURE DISTRIBUIR_CUENTAS_DOC_REF (
  pIdDoc      DOCS_PRESUP.IdDoc%TYPE,
  pMtoDist    DOCS_PRESUP.MtoDoc%type,
  pCtaDistrib CTAS_DOC.CodCta%type, -- Cuenta a distribuir
  pCtaExcluir CTAS_DOC.CodCta%type) -- Cuenta a exlcuir de la distribución
IS
  --Selecciona las cuentas del documento de referencia
  CURSOR C_CTAS(
    cIdDocRef   NUMBER,
    cTipoCta    VARCHAR2,
    cTipoDoc    VARCHAR2,
    cCtaDistrib NUMBER,
    cCtaExcluir NUMBER)  
  IS 
    SELECT CodCta,
           CodAccInt,
           CCosto,
           CodPrograma,              
           Monto,        
           ReservaAcum,
           CompAcum,
           CausaAcum,
           PagoAcum,
           ReservaAcum - CompAcum  SaldoComp,
           CompAcum    - CausaAcum SaldoCausa,
           CausaAcum   - PagoAcum  SaldoPago
    FROM   (         
           -- Cuenta para imputación uniforme
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'UNIFORME'
           UNION ALL
           -- Cuenta de imputación preferencial del tipo de documento
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'PREF-DOC'
           AND    (CodEstruct, CodCta) IN (
                  SELECT CodEstructImputPref, CodCtaImputPref
                  FROM   TIPOS_DOC_PPTO
                  WHERE  TipoDoc = cTipoDoc      
                  AND    ModoImputDocRef = 'P'
                  AND    CodCtaImputPref IS NOT NULL)
           UNION ALL
           -- Cuentas de imputación preferencial
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'PREF-OTRAS'
           AND    (CodEstruct, CodCta) IN (
                  SELECT CodEstructImputPref, CodCtaImputPref
                  FROM   TIPOS_DOC_PPTO
                  WHERE  TipoDoc <> cTipoDoc
                  AND    ModoImputDocRef = 'P'
                  AND    CodCtaImputPref IS NOT NULL)
           UNION ALL
           -- Cuentas que no son imputación preferencial de ningún tipo de documento       
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'NO-PREF'
           AND    (CodEstruct, CodCta) NOT IN (
                  SELECT CodEstructImputPref, CodCtaImputPref
                  FROM   TIPOS_DOC_PPTO
                  WHERE  ModoImputDocRef = 'P'
                  AND    CodCtaImputPref IS NOT NULL)
           )
    WHERE  CodCta =  NVL(cCtaDistrib, CodCta) -- Si hay valor sólo usamos esta cuenta
    AND    CodCta <> NVL(cCtaExcluir, 0);     -- Si hay valor excluimos esta cuenta
    

  --
  -- IF 04/05/04: Ahora utiliza el codigo de sistema y tipo de evento origen de
  --              DOCS_PRESUP
  -- MV 18/06/2003: Cursor con configuración del tipo de documento
  CURSOR C_TPDOC(cIdDoc NUMBER) IS
    SELECT DP.TipoDoc, DP.Ano,
           TDOP.CodEstructImputPref, TDOP.CodCtaImputPref,
           DEFEV.EfectRes, DEFEV.EfectComprom, DEFEV.EfectEjec, DEFEV.EfectPago,
           TDOP.ModoImputDocRef           
    FROM   DOCS_PRESUP DP,
           TIPOS_DOC_PPTO TDOP,
           DEF_EVENTO_CP DEFEV
    WHERE  DP.IdDoc          = cIdDoc
    AND    TDOP.TipoDoc      = DP.TipoDoc
    AND    DEFEV.TipoDoc     = DP.TipoDoc
    AND    DEFEV.CodSisAprob = DP.OrgEvento
    AND    DEFEV.TipoEvento  = DP.TipoEvento;

  R_TPREF C_TPDOC%ROWTYPE;
  R_TPDOC C_TPDOC%ROWTYPE;

  -- MV 18/06/2003: Suma de las cuentas del documento
  CURSOR C_SUMCTA(
    cIdDocRef   NUMBER,
    cTipoCta    VARCHAR2,
    cTipoDoc    VARCHAR2,
    cCtaDistrib NUMBER,
    cCtaExcluir NUMBER) 
  IS
    SELECT SUM(Monto)                   Monto,
           SUM(ReservaAcum)             ReservaAcum,
           SUM(CompAcum)                CompAcum,
           SUM(CausaAcum)               CausaAcum,
           SUM(PagoAcum)                PagoAcum,
           SUM(ReservaAcum - CompAcum)  SaldoComp,
           SUM(CompAcum    - CausaAcum) SaldoCausa,
           SUM(CausaAcum   - PagoAcum)  SaldoPago
    FROM   (       
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'UNIFORME'
           UNION ALL         
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'PREF-DOC'
           AND    (CodEstruct, CodCta) IN (
                  SELECT CodEstructImputPref, CodCtaImputPref
                  FROM   TIPOS_DOC_PPTO
                  WHERE  TipoDoc = cTipoDoc
                  AND    ModoImputDocRef = 'P'
                  AND    CodCtaImputPref IS NOT NULL)
           UNION ALL         
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'PREF-OTRAS'
           AND    (CodEstruct, CodCta) IN (
                  SELECT CodEstructImputPref, CodCtaImputPref
                  FROM   TIPOS_DOC_PPTO
                  WHERE  TipoDoc <> cTipoDoc
                  AND    ModoImputDocRef = 'P'
                  AND    CodCtaImputPref IS NOT NULL)
           UNION ALL         
           SELECT *
           FROM   CTAS_DOC
           WHERE  IdDoc = cIdDocRef
           AND    cTipoCta = 'NO-PREF'
           AND    (CodEstruct, CodCta) NOT IN (
                  SELECT CodEstructImputPref, CodCtaImputPref
                  FROM   TIPOS_DOC_PPTO
                  WHERE  ModoImputDocRef = 'P'
                  AND    CodCtaImputPref IS NOT NULL)
           )
    WHERE  CodCta =  NVL(cCtaDistrib, CodCta) -- Si hay valor sólo usamos esta cuenta
    AND    CodCta <> NVL(cCtaExcluir, 0);     -- Si hay valor excluimos esta cuenta      

  R_SUMCTA C_SUMCTA%ROWTYPE;
                               
  -- Monto total a distribuir (vMtoDoc)
  vMtoDist       KNTSTD.Monto := 0;
  -- Monto de referencia para eliminar errores de redondeo.
  vMtoRef        KNTSTD.Monto := 0;

  vTipoProc        VARCHAR2(5);        
  vModoImputDocRef VARCHAR2(1);

--
  R_EJS  C_EJS%ROWTYPE;
  R_DOC  DOCS_PRESUP%ROWTYPE;

  -- Determina el tipo de proceso de distribución a realizar
  function DETERMINAR_TIPO_PROCESO      
    RETURN VARCHAR2 
  IS    
    sTipoProc VARCHAR2(5);
  BEGIN
                            
    -- Probamos cada efecto por separado, para trabajar con la última condición

    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DETERMINAR_TIPO_PROCESO', 'Efectos(REF) = ' || 
      R_TPREF.EfectRes || R_TPREF.EfectComprom || R_TPREF.EfectEjec || R_TPREF.EfectPago);
     
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DETERMINAR_TIPO_PROCESO', 'Efectos(DOC) = ' || 
      R_TPDOC.EfectRes || R_TPDOC.EfectComprom || R_TPDOC.EfectEjec || R_TPDOC.EfectPago);
     
    -- si el padre reserva... 
    IF  R_TPREF.EfectRes <> 'N' THEN
    
      -- Si el documento actual no reserva pero si compromete, usamos el saldo por comprometer   
      IF  R_TPDOC.EfectRes      = 'N' 
      AND R_TPDOC.EfectComprom <> 'N' THEN
        sTipoProc := 'S-CMP';
        
      -- En caso contrario usamos el monto de la reserva
      ELSE
        sTipoProc := 'M-RES';
      END IF;

    END IF;                
    
    -- si el padre compromete... 
    IF  R_TPREF.EfectComprom <> 'N' THEN
    
      -- Si el documento actual no compromete pero si causa, usamos el saldo por causar   
      IF  R_TPDOC.EfectComprom = 'N' 
      AND R_TPDOC.EfectEjec   <> 'N' THEN
        sTipoProc := 'S-CAU';
        
      -- En caso contrario usamos el monto de lo comprometido
      ELSE
        sTipoProc := 'M-CMP';
      END IF;

    END IF;                
    
    -- si el padre causa... 
    IF  R_TPREF.EfectEjec <> 'N' THEN
    
      -- Si el documento actual no causa pero si paga, usamos el saldo por pagar   
      IF  R_TPDOC.EfectEjec  = 'N' 
      AND R_TPDOC.EfectPago <> 'N' THEN
        sTipoProc := 'S-PAG';
        
      -- En caso contrario usamos el monto de lo causado
      ELSE
        sTipoProc := 'M-CAU';
      END IF;

    END IF;                
    
    -- si el padre paga... 
    IF  R_TPREF.EfectPago <> 'N' THEN
      
      -- Como este es el último momento, sólo nos queda usar el monto de lo pagado                 
      sTipoProc := 'M-PAG';
      
    END IF;                
    
    -- Si en este punto todavía no sabemos que vamos a usar (aunque no deberia pasar)
    -- usamos como referencia el monto total
    if sTipoProc is null then
      sTipoProc := 'M-DOC';
    END IF;  
    
    RETURN(sTipoProc);
         
  END;
                                         
  -- MV: Calcula el monto de referencia sub-rutina interna al procedure
  FUNCTION CALCULAR_MTO_REF(
    sTipoCta  VARCHAR2,
    sTipoProc VARCHAR2,
    sTipoDoc  VARCHAR2)           
    RETURN NUMBER
  IS
    sMtoRef NUMBER;
  BEGIN
    -- MV 18/06/2003: Sumamos las cuentas del documento padre
    OPEN  C_SUMCTA(R_DOC.IdDocRef, sTipoCta, sTipoDoc, pCtaDistrib, pCtaExcluir);
    FETCH C_SUMCTA INTO R_SUMCTA;
    CLOSE C_SUMCTA;

    -- Determinamos cual es el monto de referencia
    IF    sTipoProc = 'M-RES' THEN sMtoRef := R_SUMCTA.ReservaAcum;
    ELSIF sTipoProc = 'S-CMP' THEN sMtoRef := R_SUMCTA.SaldoComp;
    ELSIF sTipoProc = 'M-CMP' THEN sMtoRef := R_SUMCTA.CompAcum;
    ELSIF sTipoProc = 'S-CAU' THEN sMtoRef := R_SUMCTA.SaldoCausa;
    ELSIF sTipoProc = 'M-CAU' THEN sMtoRef := R_SUMCTA.CausaAcum;
    ELSIF sTipoProc = 'S-PAG' THEN sMtoRef := R_SUMCTA.SaldoPago;
    ELSIF sTipoProc = 'M-PAG' THEN sMtoRef := R_SUMCTA.PagoAcum;
    ELSE                           sMtoRef := R_SUMCTA.Monto;
    END IF;
                    
    --IF NVL(sMtoDist
    RETURN(NVL(sMtoRef, 0));
  END;
  
  -- Distribuye el monto entre las cuentas
  PROCEDURE DISTRIBUIR_MTO_CTAS(
    sTipoCta  VARCHAR2,
    sTipoProc VARCHAR2,
    sTipodoc  VARCHAR2,
    sMtoDist  IN OUT NUMBER,
    sMtoRef   IN OUT NUMBER)
  IS
    -- Monto a distribuir para un documento
    sMtoDistDoc    KNTSTD.Monto := 0;
    sMtoSobrante   KNTSTD.Monto := 0;
    sMontoCta      KNTSTD.Monto := 0;
  begin                                   
  
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sTipoCta = ' || sTipoCta);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sTipoProc = ' || sTipoProc);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sTipodoc = ' || sTipodoc);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'R_DOC.IdDocRef = ' || R_DOC.IdDocRef);

    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoDist.1 = ' || sMtoDist);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoRef.1 = ' || sMtoRef);

    -- Si el monto a distribuir es mayor que el monto de referencia ajustamos
    -- y guardamos la diferencia como sobrante
    IF sMtoDist > sMtoRef THEN
      sMtoSobrante := sMtoDist - sMtoRef;
      sMtoDist     := sMtoRef;  
    END IF;
                     
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoDist.2 = ' || sMtoDist);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoRef.2 = ' || sMtoRef);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoSobrante = ' || sMtoSobrante);

    IF sMtoRef <> 0 THEN
    
      FOR R_CTAS IN C_CTAS(R_DOC.IdDocRef, sTipoCta, sTipoDoc, pCtaDistrib, pCtaExcluir) LOOP   
      
        PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'R_CTAS.CodCta = ' || R_CTAS.CodCta);

        IF    sTipoProc = 'M-RES' THEN sMontoCta := R_CTAS.ReservaAcum;
        ELSIF sTipoProc = 'S-CMP' THEN sMontoCta := R_CTAS.SaldoComp;  
        ELSIF sTipoProc = 'M-CMP' THEN sMontoCta := R_CTAS.CompAcum;  
        ELSIF sTipoProc = 'S-CAU' THEN sMontoCta := R_CTAS.SaldoCausa;
        ELSIF sTipoProc = 'M-CAU' THEN sMontoCta := R_CTAS.CausaAcum; 
        ELSIF sTipoProc = 'S-PAG' THEN sMontoCta := R_CTAS.SaldoPago; 
        ELSIF sTipoProc = 'M-PAG' THEN sMontoCta := R_CTAS.PagoAcum;  
        ELSE                           sMontoCta := R_CTAS.Monto;  
        END IF;
                                     
        PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMontoCta = ' || sMontoCta);

        sMtoDistDoc := ROUND(sMtoDist * sMontoCta / sMtoRef, 2);
        sMtoRef     := sMtoRef - sMontoCta;  

        -- Estos asjustes eliminan los errores de redondeo
        sMtoDist := sMtoDist - sMtoDistDoc;   -- Rebajamos el monto a distribuir

        PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoDistDoc = ' || sMtoDistDoc);
        PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoRef = ' || sMtoRef);
        PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.DISTRIBUIR_MTO_CTAS', 'sMtoDist = ' || sMtoDist);

        -- MV 18/06/2003: Sólo insertamos si el monto a distribuir es mayor a cero
        IF sMtoDistDoc > 0 THEN
          INSERT INTO CTAS_DOC
                 (IdDoc, CodCta, Monto,
                  CodAccInt, CCosto, CodPrograma, CodEstruct)
          VALUES (pIdDoc, R_CTAS.CodCta, sMtoDistDoc,
                  R_CTAS.CodAccInt, R_CTAS.CCosto, R_CTAS.CodPrograma, R_EJS.CodEstruct);
        END IF;

        -- MV 12/02/2004: Si se acabó el monto de referncia es porque debemos haber terminado
        -- si no terminamos la distribución, debe fallar la validación de vMtoDist fuera del lazo
        EXIT WHEN sMtoRef = 0;

      END LOOP;
      
    END IF;  
    
    -- Si había sobrante al principio ahora lo devolvemos para que 
    -- quede como pendiente por distribuir
    sMtoDist := sMtoDist + sMtoSobrante;
  END;  

   
BEGIN
  -- Buscamos el documento
  SELECT *
  INTO   R_DOC
  FROM   DOCS_PRESUP
  WHERE  IdDoc = pIdDoc;
    
  -- Buscamos la configuración del documento
  OPEN  C_TPDOC(pIdDoc);
  FETCH C_TPDOC INTO R_TPDOC;
  CLOSE C_TPDOC;

  -- MV 18/06/2003: Buscamos la configuración del padre
  OPEN  C_TPDOC(R_DOC.IdDocRef);
  FETCH C_TPDOC INTO R_TPREF;
  CLOSE C_TPDOC;

  OPEN  C_EJS(R_TPREF.Ano);
  FETCH C_EJS INTO R_EJS;
  CLOSE C_EJS;             
  
  PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'pIdDoc = ' || pIdDoc);
  PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'R_TPDOC.TipoDoc = ' || R_TPDOC.TipoDoc);
  PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'R_DOC.MtoDoc = ' || R_DOC.MtoDoc);

  -- Ahora vamos a determinar el tipo de proceso de distribución
  vTipoProc := DETERMINAR_TIPO_PROCESO;

  PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vTipoProc = ' || vTipoProc);
               
  -- Monto a distribuir para eliminar errores de redondeo
  vMtoDist := pMtoDist;              
                     
  -- Si estamos trabajando con imputación externa, ésta es la que vale, por lo tanto
  -- Consideramos la distribución como uniforme
  IF pCtaDistrib IS NOT NULL
  OR pCtaExcluir IS NOT NULL THEN
    vModoImputDocRef := 'U';
  ELSE  
    vModoImputDocRef := R_TPDOC.ModoImputDocRef;
  END IF;   
                                     
  -- Si usamos la distribución uniforme
  IF vModoImputDocRef = 'U' THEN
    -- Primero distribuimos a las cuentas preferenciales
    vMtoRef := CALCULAR_MTO_REF('UNIFORME', vTipoProc, R_TPDOC.TipoDoc);

    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(uniforme) = ' || vMtoRef);

    DISTRIBUIR_MTO_CTAS('UNIFORME', vTipoProc, R_TPDOC.TipoDoc, vMtoDist, vMtoRef);
                                                        
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoDist(uniforme) = ' || vMtoDist);
    PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(uniforme.fin) = ' || vMtoRef);

  ELSE
    -- Si el tipo tiene imputación preferencial
    IF  vModoImputDocRef = 'P' -- MV 25/06/2008: Ahora verificamos si es preferencial explícitamente  
    AND R_TPDOC.CodCtaImputPref IS NOT NULL THEN
      -- Primero distribuimos a las cuentas preferenciales
      vMtoRef := CALCULAR_MTO_REF('PREF-DOC', vTipoProc, R_TPDOC.TipoDoc);

      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(pref-doc) = ' || vMtoRef);

      DISTRIBUIR_MTO_CTAS('PREF-DOC', vTipoProc, R_TPDOC.TipoDoc, vMtoDist, vMtoRef);
                                                        
      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoDist(pref-doc) = ' || vMtoDist);
      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(pref-doc.fin) = ' || vMtoRef);

    END IF;  

    -- Si queda algo por distribuir, lo asignamos al resto de las cuentas que no tienen
    -- imputación preferencial
    IF vMtoDist <> 0 THEN
      vMtoRef := CALCULAR_MTO_REF('NO-PREF', vTipoProc, R_TPDOC.TipoDoc);

      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(no-pref) = ' || vMtoRef);

      DISTRIBUIR_MTO_CTAS('NO-PREF', vTipoProc, R_TPDOC.TipoDoc, vMtoDist, vMtoRef);

      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoDist(no-pref) = ' || vMtoDist);
      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(no-pref.fin) = ' || vMtoRef);

    END IF;
                                                                         
    -- Si queda algo por distribuir, lo asignamos las otras cuentas que tienen
    -- imputación preferencial
    IF vMtoDist <> 0 THEN

      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'TIPO = PREF-OTRAS ');

      vMtoRef := CALCULAR_MTO_REF('PREF-OTRAS', vTipoProc, R_TPDOC.TipoDoc);

      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(pref-otras) = ' || vMtoRef);

      DISTRIBUIR_MTO_CTAS('PREF-OTRAS', vTipoProc, R_TPDOC.TipoDoc, vMtoDist, vMtoRef);

      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoDist(pref-otras) = ' || vMtoDist);
      PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoRef(pref-otras.fin) = ' || vMtoRef);

    END IF;
    
  END IF; 
  
  PROC_DEBUG.REGISTRAR('PROC_DOCPRESUP.ASIGNA_INF_DOCUMENTO_REF', 'vMtoDist = ' || vMtoDist);    
  
END;

--------------------------------------------------------------------------------
-- ASIGNA_INF_DOCUMENTO_REF: Asigna la información del documento de referencia 
PROCEDURE ASIGNA_INF_DOCUMENTO_REF (
  pIdDoc          DOCS_PRESUP.IdDoc%TYPE,
  pAjustaMtoDoc   boolean default false,
  pIndDistCtaAdic BOOLEAN DEFAULT FALSE)
is
   -- IF 29/02/2008: Determina cantidad de hermanos
   CURSOR C_HER(cIdDoc    DOCS_PRESUP.IdDoc%TYPE,
                cIdDocRef DOCS_PRESUP.IdDoc%TYPE) IS        
    SELECT COUNT(*) CantHerm
    FROM DOCS_PRESUP DPR,
         DEF_EVENTO_CP DEFEV
    WHERE DPR.IdDocRef = cIdDocRef
    AND   DPR.IdDoc    <> cIdDoc
    AND   DPR.StsDoc   IN ('VER', 'DEV')
    AND   DPR.Tipodoc  = DEFEV.Tipodoc
    AND   DEFEV.EfectPago  = 'A';            
                                       
  -- Cuentas adicionales
  CURSOR C_CTAS_ADIC(
    cIdDoc DOCUMENTOS_ORIGEN.IdDoc%type)
  is
    SELECT CodCta, SUM(Monto) Monto
    FROM   CTAS_DOC_ADIC
    WHERE  IdDoc = cIdDoc
    GROUP BY CodCta;
    
  R_HER      C_HER%Rowtype;  
  R_DOC      DOCS_PRESUP%ROWTYPE;
  R_CTA_ADIC C_CTAS_ADIC%ROWTYPE;
  R_CHK_ADIC C_CTAS_ADIC%ROWTYPE;     
  
  vMtoCtasDoc NUMBER;
  vDifMtoDoc  NUMBER;
  
begin

  -- Traemos la información del documento
  SELECT *
  INTO   R_DOC
  FROM   DOCS_PRESUP
  WHERE  IdDoc = pIdDoc;

  -- Borramos las cuentas del documento  
  DELETE CTAS_DOC
  WHERE  IdDoc = pIdDoc;
  
  -- Si estamos distribuyendo la cuenta adicional (por ahora sólo manejamos una cuenta)
  IF pIndDistCtaAdic THEN
    
    OPEN  C_CTAS_ADIC(pIdDoc);
    FETCH C_CTAS_ADIC INTO R_CTA_ADIC;
    FETCH C_CTAS_ADIC INTO R_CHK_ADIC;
    
    IF C_CTAS_ADIC%FOUND THEN
      CLOSE C_CTAS_ADIC;
      
      RAISE_APPLICATION_ERROR(-20901, 
        'ERROR DE DATOS: Sólo se puede hacer distribución general para una cuenta, pero el documento ' || pIdDoc ||
        ' más de una!');
    END IF; 
    CLOSE C_CTAS_ADIC;
    
    -- Distribuimos sólo la cuenta adicional
    DISTRIBUIR_CUENTAS_DOC_REF(pIdDoc, R_CTA_ADIC.Monto, R_CTA_ADIC.CodCta, NULL);     
                              
    -- Distribuimos el resto de las cuentas 
    IF R_DOC.MtoDoc > R_CTA_ADIC.Monto THEN 
      DISTRIBUIR_CUENTAS_DOC_REF(pIdDoc, R_DOC.MtoDoc - R_CTA_ADIC.Monto, NULL, R_CTA_ADIC.CodCta);
    END IF;  
    
  -- Sino, se hace una sola distribución del monto total del documento   
  ELSE
    DISTRIBUIR_CUENTAS_DOC_REF(pIdDoc, R_DOC.MtoDoc, NULL, NULL);
    
  END IF;  
  
  -- IF 29/02/08: Si se va ajustar el documento se derteminado 
  -- la cantidad de los hermanos verificados que paguen para el calculo 
  -- de la diferencia por reconversion de pase de VEF a VEB   
  IF pAjustaMtoDoc THEN
    OPEN  C_HER(R_DOC.IdDoc, R_DOC.IdDocRef);
    FETCH C_HER INTO R_HER;
    CLOSE C_HER;
    
    IF  R_HER.CantHerm = 0 THEN
      R_HER.CantHerm := 1;
    END IF;
    
    SELECT SUM(Monto)
    INTO   vMtoCtasDoc
    FROM   CTAS_DOC
    WHERE  IdDoc = pIdDoc;
                                             
    -- Calculamos la diferencia 
    vDifMtoDoc := R_DOC.MtoDoc - vMtoCtasDoc; 
    
    IF  R_DOC.IdDocRef IS NOT NULL
    AND vDifMtoDoc > 0 
    AND vDifMtoDoc < R_DOC.MtoDoc
    --
    -- IF 24/01/08 -- El error máximo es producto del redondeo de la reconversión 
    -- por la cantidad de hermanos 
    AND vDifMtoDoc < 10 * NVL(R_HER.CantHerm, 1)
    AND R_DOC.CodMoneda = 'VEF'
    AND R_DOC.CodMonedaMtoDoc = 'VEB' THEN       
    
      UPDATE DOCS_PRESUP
      SET    MtoDoc = MtoDoc - vDifMtoDoc
      WHERE  IdDoc = pIdDoc;                
    
    END IF;
  END IF;

end;

-- Fin del Package
END; 
/
