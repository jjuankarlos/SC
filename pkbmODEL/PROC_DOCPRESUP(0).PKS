CREATE OR REPLACE PACKAGE      PROC_DOCPRESUP IS
FUNCTION RECIBE_DOC_AUTO(R_EVE PROC_MENSAJERO.C_EVE%ROWTYPE )RETURN BOOLEAN;
--
-- IF 04/05/04: Ahora no recibe el codigo de sistema ni el tipo de evento
PROCEDURE ASIGNA_INF_DOCUMENTO_REF (
  pIdDoc          DOCS_PRESUP.IdDoc%TYPE,
  pAjustaMtoDoc   boolean default false,
  pIndDistCtaAdic BOOLEAN DEFAULT FALSE)
;

vMensaje  GOBSTD.Mensaje;
--
-- Versión del package (Siempre debe ser la ultima función en el package)
FUNCTION VERPKG RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(VERPKG, WNDS);
END; 
/
