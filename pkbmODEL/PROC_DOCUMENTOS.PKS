CREATE OR REPLACE PACKAGE PROC_DOCUMENTOS IS

PROCEDURE CREA_MSG(cMsg VARCHAR2);

FUNCTION VER_MENSAJE RETURN VARCHAR2;

PROCEDURE LIMPIA_MENSAJE;

FUNCTION VALDOC(pIdDoc IN DOCS_PRESUP.IdDoc%TYPE) RETURN BOOLEAN;

PROCEDURE ACTPRECOMP (R_DOC PROC_PRESUP.C_DOC%ROWTYPE, pTipoAct IN VARCHAR2,R_CTA PROC_PRESUP.C_CTA%ROWTYPE);

PROCEDURE ACTPRECOMP (pIdDoc NUMBER, pTipoAct IN VARCHAR2);

FUNCTION GENERA_REVERSO (pIdDoc DOCS_PRESUP.IdDoc%TYPE) RETURN NUMBER;

PROCEDURE PROCESA_AUTOMATICOS;

FUNCTION VERIFICA_DOC(pIdDoc DOCS_PRESUP.IdDoc%TYPE,pModo VARCHAR2) RETURN VARCHAR2;

cMensaje GOBSTD.Mensaje;

FUNCTION VALIDA_VER(pAno EJS_PRESUP.Ano%TYPE, pEfectPago DEF_EVENTO_CP.EfectPago%TYPE)
RETURN BOOLEAN;

--------------------------------------------------------------------------------
-- CODIFICA_DOC: Codifica el documento presupuestario indicado
FUNCTION CODIFICA_DOC (pIdDoc NUMBER) RETURN BOOLEAN
;
--------------------------------------------------------------------------------
-- ANULA_DOC: Anula el documento presupuestario indicado
PROCEDURE ANULA_DOC (pIdDoc NUMBER)
;
--------------------------------------------------------------------------------
-- ACEPTAR_DEV: Acepta la devolución del documento presupuestario indicado
-- MR 30/05/2002
FUNCTION ACEPTAR_DEV (pIdDoc NUMBER) RETURN BOOLEAN
;
--------------------------------------------------------------------------------
-- DEVOLVER_DOC: Devuelve el documento presupuestario indicado
-- MR 06/08/2002
FUNCTION DEVOLVER_DOC (pIdDoc NUMBER, pCodSis VARCHAR2, pMensaje VARCHAR2) RETURN VARCHAR2
;

--------------------------------------------------------------------------------
-- CARGA_TRANSFDOC: Carga el documento para ser transferido
-- IF 18/08/2003
PROCEDURE CARGA_TRANSFDOC (pIdDoc        DOCS_PRESUP.IdDoc%TYPE,
                           pTipoTransf   DOCS_PRESUP.TipoDoc%TYPE,
                           pMtoNoCausado NUMBER)
;

--------------------------------------------------------------------------------
-- CONFIRMA_TRANSFDOC: Confirma la tranferencia del documento presupuestario indicado
-- IF 18/08/2003
FUNCTION CONFIRMA_TRANSFDOC (pIdDoc        DOCS_PRESUP.IdDoc%TYPE,
                             pImputacion   VARCHAR2,
                             pAnoDest      DOCS_PRESUP.Ano%TYPE,
                             pPeriodoDest  DOCS_PRESUP.Periodo%TYPE,
                             pTipoDocDest  DOCS_PRESUP.TipoDoc%TYPE,
                             pFecDoc       DOCS_PRESUP.FecDoc%TYPE,
                             pCodCta       CTAS_DOC.CODCTA%TYPE) RETURN BOOLEAN
;

--------------------------------------------------------------------------------
-- REVERSA_TRANSFDOC: Reversa carga del documento elegibles para transferir
-- IF 18/08/2003
PROCEDURE REVERSA_TRANSFDOC (pIdDoc  DOCS_PRESUP.IdDoc%TYPE)
;

--------------------------------------------------------------------------------
-- VERPKG: Versión del package (Siempre debe ser la ultima función en el package)
FUNCTION VERPKG RETURN VARCHAR2
;
PRAGMA RESTRICT_REFERENCES(VERPKG, WNDS)
;
--------------------------------------------------------------------------------
-- C_CTACCF: Cursor con cuentas del documento mostrando el centro de costos de
-- formulación
CURSOR C_CTACCF
       (pIdDocC NUMBER) -- Identificador del documento
IS
  SELECT CodCta, PROC_PRESUP.CCOSTO_FORMULACION(CCosto, DP.Ano) CCosto,
         CodPrograma, CodAccInt, SUM(Monto) Monto
  FROM   CTAS_DOC CD,
         DOCS_PRESUP DP
  WHERE  DP.IDDOC = pIdDocC
  AND    CD.IdDoc = DP.IdDoc
  GROUP BY CodCta,
           PROC_PRESUP.CCOSTO_FORMULACION(CCosto, DP.Ano),
           CodPrograma,
           CodAccInt;
--------------------------------------------------------------------------------
-- CTA_ADIC: Inserta las cuentas adicionales en los documentos padres
--
PROCEDURE CTA_ADIC(pIdDoc NUMBER)
;

-- REENVIAR_DOC: Reenvio de documentos devueltos
FUNCTION REENVIAR_DOC(pIdDoc  DOCS_PRESUP.IdDoc%TYPE) RETURN VARCHAR2;


--------------------------------------------------------------------------------
-- PROCEDIMIENTO DE ACTUALIZACION INFORMACION TIPO Y NIVEL DE COMPROMISO  
--
PROCEDURE ACT_INF_TIPNIVCOMPROM (pIdDoc IN DOCS_PRESUP.IdDoc%TYPE);

END;

/
