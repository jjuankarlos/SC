CREATE OR REPLACE PACKAGE BODY PROC_ITMALM IS
-- Número de versión del package
vVerPkg VARCHAR2(10) := '3.1.1a';
--
/* INI:KNTDocVer *********************************************************************
 REVISIONES (en orden inverso):
 Vers        Fecha       Autor        Lista de reportes de falla (ej: 123, 4678, 45.3)
 ----------  ----------  -----------  ------------------------------------------------
 3.1.1       16/04/2007  VNEGRIN      009073
 Se agregó la llamada a la funcion PROC_CATALOGO.GRUPO_ITEM que permite obtener el grupo
 asociado al nombre nomalizado del item, y si crar el item solo para el almacen 
 que esta relacionado con el grupo en la tabla GRUPOS_ALMS 
 -----------------------------------------------------------------------------------  
 3.1.0       27/10/2004  IFLORES      005274
 Se ajustó el procesure SALIDA_INT para verificar si la salida es por el total de la
 existencia si es asi el valor a utilizar es que este registrado como valor total
 a nivel de item.
 -----------------------------------------------------------------------------------
 3.0.0       01/07/2003  IF
 Se creo el procedure RECIBE_DEVMOV con la finalidad de permite actualizar el item 
 asociado al movimiento que se esta reversando.
 ----------------------------------------------------------------------------------- 
 2.1.0       30/08/2002  IF
 Incorporó el procedure VERIF_ITMALM con la finalidad de verificar la existencia de
 un determinado item en un almacen especifico.
 -----------------------------------------------------------------------------------
 2.0.0       17/04/2002  M.Veloso
 Modificación del procedure CREA_ITEM_ALMACENES, cambio del tipo de dato del parametro
 pCodClase de NUMBER a VARCHAR2.
 -----------------------------------------------------------------------------------
 1.2.0       17/04/2002  M.Veloso
 Inclusión de funciones de soporte para canalizar solicitudes por almacenes
 especializados
 -----------------------------------------------------------------------------------
 1.0.0       06/03/2002  IF
 Inicio de la numeración de versiones de packages
 -----------------------------------------------------------------------------------
** FIN:KNTDocVer *********************************************************************/
--
/*********************************************************/
/* VERPKG: Retorna el numero de versión de este package. */
/*********************************************************/
FUNCTION VERPKG RETURN VARCHAR2
IS
BEGIN
  RETURN vVerPkg;
END VERPKG;
---

--------------------------------------------------------------------------------
-- ASEGURA_EXISTENCIA: Verifica que la existencia sea positiva
PROCEDURE ASEGURA_EXISTENCIA(pCodAlm NUMBER, pCodItem VARCHAR2) IS
  vExistencias NUMBER;
BEGIN
  BEGIN
    SELECT NVL(Existencias,0)
    INTO   vExistencias
    FROM   ITEMS_ALMACEN
    WHERE  CodAlmacen = pCodAlm
    AND    CodItem    = pCodItem;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR (-20106,
        'ERROR DE CONSISTENCIA: No existe el item: ' || pCodItem ||
        ' para el almacén: ' || pCodAlm ||
        ' en la tabla ITEMS_ALMACEN. ' || SQLERRM);
  END;
  --IF  (vExistencias < 0 ) THEN
    --RAISE_APPLICATION_ERROR (-20107,
      --'ERROR DE CONSISTENCIA: La existencia del item: ' || pCodItem ||
     --- ' para el almacén: ' || pCodAlm || ' es negativa.');
  ---END IF;
END ASEGURA_EXISTENCIA;

--------------------------------------------------------------------------------
-- ASEGURA_DISPONIBILIDAD: Verifica que el predespacho sea mayor que la existencia
PROCEDURE ASEGURA_DISPONIBILIDAD(pCodAlm NUMBER, pCodItem VARCHAR2) IS
  vDisponibilidad NUMBER;
BEGIN
  BEGIN
    SELECT NVL(Existencias,0) - NVL(CantPredespacho, 0)
    INTO   vDisponibilidad
    FROM   ITEMS_ALMACEN
    WHERE  CodAlmacen = pCodAlm
    AND    CodItem    = pCodItem;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR (-20106,
        'ERROR DE CONSISTENCIA: No existe el item: ' || pCodItem ||
        ' para el almacén: ' || pCodAlm ||
        ' en la tabla ITEMS_ALMACEN. ' || SQLERRM);
  END;
  IF  (vDisponibilidad < 0 ) THEN
    RAISE_APPLICATION_ERROR (-20107,
      'ERROR DE CONSISTENCIA: La cantidad en predespacho del item: ' || pCodItem ||
      ' para el almacén: ' || pCodAlm || ' es mayor que la existencia.');
  END IF;
END ASEGURA_DISPONIBILIDAD;

/********************************************************************************/
/* SALIDA_INT: Function para actualizar el item por movimiento de salida.          */
/********************************************************************************/
FUNCTION SALIDA_INT(pCodAlmacen     ITEMS_ALMACEN.CodAlmacen%TYPE,
                    pCodItem        ITEMS_ALMACEN.CodItem%TYPE,
                    pCantSalidas    ITEMS_ALMACEN.CantSalidas%TYPE,
                    pCantPreDespacho ITEMS_ALMACEN.CantPreDespacho%TYPE) RETURN NUMBER IS
--
-- IF 27/10/04: Inf. del item
  CURSOR C_ITM (cCodAlmacen ALMACENES.CodAlmacen%TYPE, 
                cCodItem ITEMS_ALMACEN.CodItem%TYPE) IS 

    SELECT NVL(Existencias,0) Disponible,
           ValorTot 
    FROM   ITEMS_ALMACEN
    WHERE  CodAlmacen = cCodAlmacen
    AND    CodItem    = cCodItem;                    
--
-- Variables de trabajo   
 R_ITM            C_ITM%ROWTYPE;
 vExistencias     ITEMS_ALMACEN.Existencias%TYPE;
 vCantPreDespacho ITEMS_ALMACEN.CantPreDespacho%TYPE;
 vValor           ITEMS_ALMACEN.ValorTot%TYPE;
BEGIN
--
-- IF 27/10/04: Inf. del item
   OPEN C_ITM(pCodAlmacen,pCodItem);
   FETCH C_ITM INTO R_ITM;
   IF C_ITM%NOTFOUND THEN
     CLOSE C_ITM;
     RAISE_APPLICATION_ERROR (-20106,
      'No existe el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
      ' para actualizar en la tabla ITEMS_ALMACEN.');     
   END IF; 
   CLOSE C_ITM; 
--
-- IF 27/10/04:Se verifica si la cantidad de salida es igual al disponible
   IF R_ITM.Disponible = pCantSalidas THEN
     vValor := R_ITM.ValorTot;
   ELSE  
   --
   -- Calculo del Valor del item segun su salida
     vValor := PROC_ALMACEN.VALOR_MOVIMIENTO(pCodAlmacen,pCodItem,pCantSalidas);
   END IF;  
--
-- Actualiza Cantidades en la Tabla ITEMS_ALMACEN
  BEGIN
    UPDATE ITEMS_ALMACEN
    SET    Existencias     = Existencias - NVL(pCantSalidas,0),
           CantSalidas     = CantSalidas + NVL(pCantSalidas,0),
           CantPreDespacho = NVL(CantPreDespacho,0) - NVL(pCantPreDespacho,0),
           ValorTot        = ValorTot - NVL(vValor,0)
    WHERE  CodAlmacen = pCodAlmacen
    AND    CodItem    = pCodItem;
  EXCEPTION
    WHEN OTHERS THEN
	  RAISE_APPLICATION_ERROR (-20100,
        'Problemas al actualizar el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
        ' en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR (-20101,
      'No existe el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
      ' para actualizar en la tabla ITEMS_ALMACEN.');
  END IF;
  --
  -- MV 17/04/02: Aseguramos existencia positiva y disponibilidad
  ASEGURA_EXISTENCIA(pCodAlmacen, pCodItem);
  ASEGURA_DISPONIBILIDAD(pCodAlmacen, pCodItem);

  RETURN(vValor);
END SALIDA_INT;
/********************************************************************************/
/* SALIDA: Function para realizar la salida interna generica.                  */
/********************************************************************************/
FUNCTION SALIDA(pCodAlmacen  ITEMS_ALMACEN.CodAlmacen%TYPE,
                pCodItem     ITEMS_ALMACEN.CodItem%TYPE,
                pCantSalidas ITEMS_ALMACEN.CantSalidas%TYPE)  RETURN NUMBER IS
vValor           ITEMS_ALMACEN.ValorTot%TYPE;
BEGIN
  --
  -- Se procesa la salida generica
  vValor:= SALIDA_INT(pCodAlmacen, pCodItem, pCantSalidas, 0);
  RETURN(vValor);
END SALIDA;
/********************************************************************************/
/* DESPACHO: Function para realizar la salida interna generica.                  */
/********************************************************************************/
FUNCTION DESPACHO(pCodAlmacen  ITEMS_ALMACEN.CodAlmacen%TYPE,
                  pCodItem     ITEMS_ALMACEN.CodItem%TYPE,
                  pCantDespacho ITEMS_ALMACEN.CantSalidas%TYPE,
                  pCantPreDespacho ITEMS_ALMACEN.CantPreDespacho%TYPE)  RETURN NUMBER IS
vValor           ITEMS_ALMACEN.ValorTot%TYPE;
BEGIN
  --
  -- Se procesa la salida por despacho
  vValor:= SALIDA_INT(pCodAlmacen, pCodItem, pCantDespacho, pCantPreDespacho);
  RETURN(vValor);
END DESPACHO;
/********************************************************************************/
/* ENTRADA: Procedure para actualizar el item por movimiento de entrada.        */
/********************************************************************************/
PROCEDURE ENTRADA(pCodAlmacen    ITEMS_ALMACEN.CodAlmacen%TYPE,
                  pCodItem       ITEMS_ALMACEN.CodItem%TYPE,
                  pCantEntrada   ITEMS_ALMACEN.CantEntradas%TYPE,
                  pValor         ITEMS_ALMACEN.ValorTot%TYPE) IS
 vExistencias     ITEMS_ALMACEN.Existencias%TYPE;
BEGIN
  --
  -- Actualiza Cantidades en la Tabla ITEMS_ALMACEN
  BEGIN  
    UPDATE ITEMS_ALMACEN
    SET   CantEntradas = CantEntradas + pCantEntrada,
          Existencias  = Existencias  + pCantEntrada,
          CostoProm    = NVL((ValorTot  + pValor)/(Existencias + pCantEntrada),0),
          ValorTot     = ValorTot     + pValor
    WHERE CodAlmacen   = pCodAlmacen
    AND   CodItem      = pCodItem;
     EXCEPTION
        WHEN ZERO_DIVIDE THEN -- handles ¿division by zero¿ error
           UPDATE ITEMS_ALMACEN
           SET   CantEntradas = CantEntradas + pCantEntrada,
                 Existencias  = Existencias  + pCantEntrada,
                 CostoProm    = 0,
                 ValorTot     = ValorTot     + pValor
           WHERE CodAlmacen   = pCodAlmacen
           AND   CodItem      = pCodItem;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR (-20104,
          'Problemas al actualizar el item: '||pCodItem||' para el almacen: '||pCodAlmacen||
          ' en la tabla ITEMS_ALMACEN. '||SQLERRM);
     END;
     IF SQL%NOTFOUND THEN
       RAISE_APPLICATION_ERROR (-20105,
        'No existe el item: '||pCodItem||' para el almacen: '||pCodAlmacen||
        ' para actualizar en la tabla ITEMS_ALMACEN. '||SQLERRM);
     END IF;
---
--- Se verifica que la existencia del item no sea negativa.
    BEGIN
      SELECT NVL(Existencias,0)
      INTO  vExistencias
      FROM ITEMS_ALMACEN
      WHERE CodAlmacen = pCodAlmacen
       AND  CodItem    = pCodItem;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR (-20106,
          'No existe el item: '||pCodItem||' para el almacen: '||pCodAlmacen||
          ' en la tabla ITEMS_ALMACEN. '||SQLERRM);
    END;
   --- IF  (vExistencias < 0 ) THEN
     --- RAISE_APPLICATION_ERROR (-20107,
     ---   'La existencia del item: '||pCodItem||' para el almacen: '||pCodAlmacen||
     ---   ' no puede ser negativa.');
    ---END IF;
END ENTRADA;
---
/*******************************************************************************/
/* PRE_DESPACHO: Procedure para actualizar el item del movimiento                */
/* pre-despacho .                                                               */
/*******************************************************************************/
PROCEDURE PRE_DESPACHO(pCodAlmacen      ITEMS_ALMACEN.CodAlmacen%TYPE,
                       pCodItem         ITEMS_ALMACEN.CodItem%TYPE,
                       pCantAprobada    ITEMS_ALMACEN.CantPreDespacho%TYPE) IS
BEGIN
  BEGIN
    UPDATE ITEMS_ALMACEN
    SET    CantPreDespacho = NVL(CantPreDespacho,0) + NVL(pCantAprobada,0)
    WHERE  CodAlmacen = pCodAlmacen
    AND    CodItem = pCodItem;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR (-20108,
        'Problemas al actualizar el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
        ' en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR (-20109,
      'No existe el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
      ' para actualizar en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END IF;
  --
  -- MV 17/04/02: Aseguramos que el predespacho sea menor o igual que la existencia
  ASEGURA_DISPONIBILIDAD(pCodAlmacen, pCodItem);

END PRE_DESPACHO;
---
---
/*******************************************************************************/
/* DEVOLVER_PDE: Procedure para actualizar el item del movimiento                */
/* en la devolucion del pre-despacho .                                                               */
/*******************************************************************************/
PROCEDURE DEVOLVER_PDE(pCodAlmacen      ITEMS_ALMACEN.CodAlmacen%TYPE,
                       pCodItem         ITEMS_ALMACEN.CodItem%TYPE,
                       pCantAprobada    ITEMS_ALMACEN.CantPreDespacho%TYPE) IS
BEGIN
  BEGIN
    UPDATE ITEMS_ALMACEN
    SET CantPreDespacho = NVL(CantPreDespacho,0) - NVL(pCantAprobada,0)
    WHERE CodAlmacen = pCodAlmacen
     AND  CodItem = pCodItem;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR (-20110,
        'Problemas al actualizar el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
        ' en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR (-20111,
      'No existe el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
      ' para actualizar en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END IF;
END DEVOLVER_PDE;
---
/*******************************************************************************/
/* CONFIRMA_PDE: Procedure para actualizar el item del movimiento segun la     */
/* confirmación del pre-despacho .                                                              */
/*******************************************************************************/
PROCEDURE CONFIRMA_PDE(pCodAlmacen      ITEMS_ALMACEN.CodAlmacen%TYPE,
                       pCodItem         ITEMS_ALMACEN.CodItem%TYPE,
                       pCantAprobada    ITEMS_ALMACEN.CantPreDespacho%TYPE,
                       pCantPreDespacho ITEMS_ALMACEN.CantPreDespacho%TYPE) IS
BEGIN
  BEGIN
     UPDATE ITEMS_ALMACEN
     SET CantPreDespacho = NVL(CantPreDespacho,0) - (NVL(pCantAprobada,0) - NVL(pCantPreDespacho,0)),
         IndPendRev = 'S'
     WHERE CodAlmacen = pCodAlmacen
     AND  CodItem = pCodItem;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR (-20112,
        'Problemas al actualizar el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
        ' en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR (-20113,
      'No existe el Item: '||pCodItem||' para el almacen: '||pCodAlmacen||
      ' para actualizar en la tabla ITEMS_ALMACEN. '||SQLERRM);
  END IF;
END CONFIRMA_PDE;

--------------------------------------------------------------------------------
-- CREA_ITEM_ALM: Crea el ITEM_ALMACEN indicado
-- MV 03/04/2002
PROCEDURE CREA_ITEM_ALM(pCodItem VARCHAR2, pCodAlmacen NUMBER) IS

  vUnidBasica ITEM_CAT.UnidBasica%TYPE;
BEGIN
--
-- Se obtiene la unidad de medida
  BEGIN
    SELECT UnidBasica
    INTO   vUnidBasica
    FROM   ITEM_CAT
    WHERE  CodItem = pCodItem;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20113,
       'Problema no se encontró el item: '||pCodItem||' en la tabla ITEM_CAT.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR (-20113,
       'Problema al obtener la unidad de medida del item: '||pCodItem||
       ' en la tabla ITEM_CAT, '||SQLERRM);
  END;
  --
  BEGIN
    INSERT INTO ITEMS_ALMACEN
           (CodAlmacen, CodItem, CodClase,
            CantReorden, CantInicial, CantEntradas,
            CantSalidas, Existencias, CostoProm,
            CostoFifo, CostoLifo, UndManejo,
            FecUltInv)
    VALUES (pCodAlmacen, pCodItem, 'C',
            0, 0, 0,
            0, 0, 0,
            0, 0, vUnidBasica,
            SYSDATE);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      NULL;  -- Si el item ya existe no hacemos nada
  END;

END CREA_ITEM_ALM;

--------------------------------------------------------------------------------
-- CREA_ITEM_ALMACENES: Crea el item en todos los almacenes del sistema
-- con los parámetros de inventario necesarios
-- MV 17/04/02
PROCEDURE CREA_ITEM_ALMACENES(pCodItem VARCHAR2, pCodClase VARCHAR2,
                              pCantReorden NUMBER, pCantMax NUMBER,
                              pCantMin NUMBER, pPlazoProm NUMBER) IS
  -- Almacenes de la instalación
  CURSOR C_ALM IS
  SELECT CodAlmacen
  FROM   ALMACENES
  ORDER BY CodAlmacen;
  
  CURSOR C_ALMGR (cCodGrupo GRUPOS_ALMS.CodGrupo%TYPE) IS
  SELECT CodAlmacen
  FROM GRUPOS_ALMS
  WHERE CodGrupo = cCodGrupo;
  
  CURSOR C_NUMALMGR (cCodGrupo GRUPOS_ALMS.CodGrupo%TYPE) IS
  SELECT COUNT(*) NumAlmacen
  FROM GRUPOS_ALMS
  WHERE CodGrupo = cCodGrupo;
  
  vGrupo  GRUPOS_ALMS.CodGrupo%TYPE;
  vNumAlmacen NUMBER;
BEGIN
  --VN 16/04/2007 Se verifica si el nombre normalizado tiene un grupo asociado a un almacen
  vGrupo :=  PROC_CATALOGO.GRUPO_ITEM(pCodItem);
  
  OPEN C_NUMALMGR(vGrupo);
  FETCH C_NUMALMGR INTO vNumAlmacen;
  CLOSE C_NUMALMGR;
 --   
  IF NVL(vGrupo,'X') <> 'X'  and vNumAlmacen > 0 THEN
    FOR R_ALM IN C_ALMGR(vGrupo) LOOP
     BEGIN
       INSERT INTO ITEMS_ALMACEN
              (CodAlmacen, CodItem, CodClase,
               CantReorden, CantInicial, CantEntradas,
               CantSalidas, Existencias, CostoProm,
               CostoFifo, CostoLifo, UndManejo,
               FecUltInv, CantMax, CantMin,
               PlazoPromEnt)
       SELECT R_ALM.CodAlmacen, pCodItem, pCodClase,
              pCantReorden, 0, 0,
              0, 0, 0,
              0, 0,  UnidBasica,
              SYSDATE, pCantMax, pCantMin,
              pPlazoProm
       FROM   ITEM_CAT
       WHERE  CodItem = pCodItem;
     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN -- Si ya existe en el Almacen, se deja asi
         NULL;
     END;
	END LOOP; 
  ELSE
   FOR R_ALM IN C_ALM LOOP
     BEGIN
       INSERT INTO ITEMS_ALMACEN
              (CodAlmacen, CodItem, CodClase,
               CantReorden, CantInicial, CantEntradas,
               CantSalidas, Existencias, CostoProm,
               CostoFifo, CostoLifo, UndManejo,
               FecUltInv, CantMax, CantMin,
               PlazoPromEnt)
       SELECT R_ALM.CodAlmacen, pCodItem, pCodClase,
              pCantReorden, 0, 0,
              0, 0, 0,
              0, 0,  UnidBasica,
              SYSDATE, pCantMax, pCantMin,
              pPlazoProm
       FROM   ITEM_CAT
       WHERE  CodItem = pCodItem;
     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN -- Si ya existe en el Almacen, se deja asi
         NULL;
     END;
	END LOOP; 
  END IF;	
END;

--------------------------------------------------------------------------------
-- Variante para manejar sólo el código de ítem y parámetros por omisión
PROCEDURE CREA_ITEM_ALMACENES(pCodItem VARCHAR2) IS
BEGIN
  CREA_ITEM_ALMACENES(pCodItem, 'C', 0, NULL, NULL, NULL);
END;

--------------------------------------------------------------------------------
-- DISPONIBILIDAD: Retorna la cantidad disponible de un item en el almacén, para
-- atender solicitudes
-- MV 03/04/2002
FUNCTION DISPONIBILIDAD(pCodAlmacen NUMBER, pCodItem VARCHAR2) RETURN NUMBER IS

  vExistencias ITEMS_ALMACEN.Existencias%TYPE;
BEGIN
  BEGIN
    SELECT NVL(Existencias, 0) - NVL(CantPredespacho, 0)
    INTO   vExistencias
    FROM   ITEMS_ALMACEN
    WHERE  CodAlmacen = pCodAlmacen
    AND    CodItem    = pCodItem;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vExistencias := 0;
  END;

  RETURN(vExistencias);

END DISPONIBILIDAD;
--------------------------------------------------------------------------------
-- VERIF_ITMALM: Verifica si existe el item para el almacen para realizar
-- la recepción por concepto de compra.
PROCEDURE VERIF_ITMALM(pCodAlmacen NUMBER, pCodItem VARCHAR2) IS
/*
 Cursor de item de almacen
*/
 CURSOR C_ITALM(pCodAlmacenC NUMBER, pCodItemC VARCHAR2) IS
 SELECT *
 FROM ITEMS_ALMACEN
 WHERE CodAlmacen = pCodAlmacenC
  AND  CodItem = pCodItemC;
--
R_ITALM   C_ITALM%ROWTYPE;
vClose   BOOLEAN := TRUE;
BEGIN
  OPEN C_ITALM(pCodAlmacen, pCodItem);
  FETCH C_ITALM INTO R_ITALM;
  IF C_ITALM%NOTFOUND THEN
    CLOSE C_ITALM;
    vClose := FALSE;
  --
  -- Se crea el item asociado al almacen
    CREA_ITEM_ALM(pCodItem, pCodAlmacen);
  END IF;
--
-- Se verifica si se debe cerrar el cursor
   IF vClose THEN
     CLOSE C_ITALM;
   END IF;
---
END VERIF_ITMALM;

--------------------------------------------------------------------------------
-- RECIBE_DEVMOV: Permite actualizar el item asociado al movimiento que se esta
-- reversando
PROCEDURE RECIBE_DEVMOV(R_ITEM      ITEMS_MOVIMIENTO%ROWTYPE, 
                        pTipoMovOrg  VARCHAR2,
                        pTipoMovRev  VARCHAR2) IS
                        
BEGIN
 BEGIN
  --
  -- Se verifica la naturaleza del movimiento a reversar
    IF pTipoMovRev IN ('ENT') 
      THEN -- Se actualiza el item como una entrada
    --
    -- Se actualiza el item 
      UPDATE ITEMS_ALMACEN
      SET   CantEntradas = CantEntradas + DECODE(pTipoMovOrg,'DEP',R_ITEM.CantDespacho,R_ITEM.CantItem),
            Existencias  = Existencias  + DECODE(pTipoMovOrg,'DEP',R_ITEM.CantDespacho,R_ITEM.CantItem),
            CostoProm    = NVL(
                               (
                                ValorTot  + R_ITEM.Valor
                               )
                                /(
                                  Existencias + DECODE(
                                                        pTipoMovOrg,
                                                        'DEP',R_ITEM.CantDespacho,
                                                        R_ITEM.CantItem
                                                       )
                                 )
                              ,0
                              ),
            ValorTot     = ValorTot     + R_ITEM.Valor
      WHERE CodAlmacen   = R_ITEM.CodAlmacen
      AND   CodItem      = R_ITEM.CodItem;
                                               
    ELSIF pTipoMovRev IN ('SAL') 
      THEN  -- Se actualiza el item como una salida
    --
    -- Se actualiza el item   
      UPDATE ITEMS_ALMACEN
      SET    Existencias     = Existencias - NVL(R_ITEM.CantItem,0),
             CantSalidas     = CantSalidas + NVL(R_ITEM.CantItem,0),
             CantPreDespacho = NVL(CantPreDespacho,0) - NVL(R_ITEM.CantItem,0),
             ValorTot        = ValorTot - NVL(R_ITEM.Valor,0)
      WHERE  CodAlmacen = R_ITEM.CodAlmacen
       AND    CodItem   = R_ITEM.CodItem;
    --
    -- Se recalcula el costo promedio    
      BEGIN
        UPDATE ITEMS_ALMACEN
        SET    CostoProm = ValorTot / Existencias  
        WHERE  CodAlmacen = R_ITEM.CodAlmacen
         AND    CodItem   = R_ITEM.CodItem;
      EXCEPTION 
      WHEN ZERO_DIVIDE THEN -- handles ¿division by zero¿ error
        UPDATE ITEMS_ALMACEN
        SET    CostoProm = 0  
        WHERE  CodAlmacen = R_ITEM.CodAlmacen
         AND    CodItem   = R_ITEM.CodItem;     
      END;   
    END IF; 
  EXCEPTION
    WHEN ZERO_DIVIDE THEN -- handles ¿division by zero¿ error
      UPDATE ITEMS_ALMACEN
      SET   CantEntradas = CantEntradas + R_ITEM.CantDespacho,
            Existencias  = Existencias  + R_ITEM.CantDespacho,
            CostoProm    = 0,
            ValorTot     = ValorTot     + R_ITEM.Valor
      WHERE CodAlmacen   = R_ITEM.CodAlmacen
      AND   CodItem      = R_ITEM.CodItem;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR (-20104,'ERROR INTERNO: '||
        'Al actualizar el item: '||R_ITEM.CodItem||' para el almacén: '||R_ITEM.CodAlmacen||
        ' en la tabla ITEMS_ALMACEN. '||SQLERRM);        
  END;
  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR (-20105,'ERROR DE DATOS: '||
        'No existe el item: '||R_ITEM.CodItem||' para el almacén: '||R_ITEM.CodAlmacen||
        ' para actualizar en la tabla ITEMS_ALMACEN, '||SQLERRM);
  END IF;       
END;
--
---------------------------------------------------------------------------------
END PROC_ITMALM;
/
