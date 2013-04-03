CREATE OR REPLACE PACKAGE PROC_BIEN IS
   FUNCTION CONTADOR(pTipoMov CONTADORES_BIEN.TIPOMOV%TYPE,
                     pAno CONTADORES_BIEN.ANO%TYPE,
                     pMes CONTADORES_BIEN.MES%TYPE) RETURN NUMBER;
   PROCEDURE ACT_CODDEPENADM(pIdBien BIENES.IdBien%TYPE,
                             pCodDepenAdm BIENES.CodDepenAdm%TYPE,
                             pCodUbica   BIENES.CodUbica%TYPE);
   PROCEDURE VALIDA_STSRENG(pIdMov   DETS_RENG_MOV.IdMov%TYPE,
                            pNumReng DETS_RENG_MOV.NumReng%TYPE,
                            pIdBien  DETS_RENG_MOV.IdBien%TYPE,
                            pStsReng VARCHAR2);
--
-- IF 16/06/04: Incorporó campos faltantes para manejo de depreciación                            
   PROCEDURE GRABA_BIEN(pIdBien       BIENES.IdBien%TYPE,
                        pCodPlaca     BIENES.CodPlaca%TYPE,
                        pTipoBien     BIENES.TipoBien%TYPE,
   					    pDescBien     BIENES.DescBien%TYPE DEFAULT NULL,
                        pCodItem      BIENES.CodItem%TYPE,
                        pSerial       BIENES.Serial%TYPE DEFAULT NULL,
                        pMarca        BIENES.Marca%TYPE DEFAULT NULL,
   					    pModelo       BIENES.Modelo%TYPE DEFAULT NULL,
                        pCodUbica     BIENES.CodUbica%TYPE,
                        pNumResp      BIENES.NumResp%TYPE DEFAULT NULL,
                        pNumProp      BIENES.NumProp%TYPE DEFAULT NULL,
   					    pCostOrig     BIENES.CostOrig%TYPE,
                        pCCosto       BIENES.CCosto%TYPE DEFAULT NULL,
   					    pCodDepenAdm  BIENES.CodDepenAdm%TYPE DEFAULT NULL,
                        pNumProv      BIENES.NumProv%TYPE,
   					    pCostoAjust   BIENES.CostoAjust%TYPE,
                        pFecUltAjust  BIENES.FecUltAjust%TYPE DEFAULT NULL,
   					    pCantDeprec   BIENES.CantDeprec%TYPE,
                        pCostodeprec  BIENES.CostoDeprec%TYPE,
   					    pVidaUtil     BIENES.VidaUtil%TYPE DEFAULT 0,
                        pIdOrdCmp     BIENES.IdOrdCmp%TYPE DEFAULT NULL,
   					    pFecUltRev    BIENES.FecUltRev%TYPE DEFAULT NULL,
   	                    pNumCatas     BIENES.NumCatas%TYPE DEFAULT NULL,
   					    pIndPropio    BIENES.IndPropio%TYPE DEFAULT 'N',
   					    pObsBien      BIENES.ObsBien%TYPE DEFAULT NULL,
                        pFecAdquis    BIENES.FecAdquis%TYPE DEFAULT NULL,
   					    pLinderos     BIENES.Linderos%TYPE DEFAULT NULL,
                        pEstLegal     BIENES.EstLegal%TYPE DEFAULT NULL,
   					    pIndPlanos    BIENES.IndPlanos%TYPE DEFAULT NULL,
                        pFecReg       BIENES.FecReg%TYPE DEFAULT NULL,
   					    pTomoReg      BIENES.TomoReg%TYPE DEFAULT NULL,
                        pFolioReg     BIENES.FolioReg%TYPE DEFAULT NULL,
   					    pNumReg       BIENES.NumReg%TYPE DEFAULT NULL,
                        pOficReg      BIENES.OficReg%TYPE DEFAULT NULL,
   					    pValorProp    BIENES.ValorProp%TYPE DEFAULT NULL,
                        pAreaTerreno  BIENES.AreaTerreno%TYPE DEFAULT NULL,
   					    pAreaCubierta BIENES.AreaCubierta%TYPE DEFAULT NULL,
                        pOtrasAreas   BIENES.OtrasAreas%TYPE DEFAULT NULL,
   					    pAreaConst    BIENES.AreaConst%TYPE DEFAULT NULL,
                        pTotArea      BIENES.TotArea%TYPE DEFAULT NULL,
   					    pCaract       BIENES.Caract%TYPE DEFAULT NULL,
                        pAreaInmueble BIENES.AreaInmueble%TYPE DEFAULT NULL,
   					    pNumFact      BIENES.NumFact%TYPE DEFAULT NULL,
                        pCodItemRef   BIENES.CodItemRef%TYPE DEFAULT NULL,
   					    pStsBien      BIENES.StsBien%TYPE,
   					    pStsInc       BIENES.StsInc%TYPE,
   					    pAnoInc       BIENES.AnoInc%TYPE,
   					    pMesInc       BIENES.MesInc%TYPE,
                        pTipoMov      VARCHAR2,
                        pFecMov       DATE,
                        pVidaUtilMes  BIENES.VidaUtilMes%TYPE DEFAULT 0,    -- IF 16/06/04: Nuevo parametro
                        pCostoRescate BIENES.CostoRescate %TYPE DEFAULT 0,  -- IF 16/06/04: Nuevo parametro
                        pFecIncorp    BIENES.FecIncorp%TYPE DEFAULT NULL,   -- IF 16/06/04: Nuevo parametro
                        pIndInfDeprec BIENES.IndInfDeprec%TYPE DEFAULT 'N', -- IF 16/06/04: Nuevo parametro
						pStsRev       BIENES.StsRev%TYPE DEFAULT 'SIS',      -- IF 30/06/05: Nuevo parametro                    
                        pFecOC        BIENES.FecOdc%TYPE DEFAULT NULL,
						pRefOC       BIENES.REFODC%TYPE  DEFAULT NULL);
--
-- IF 16/06/04: Ahora se recibe la fecha de aquisicion                                                   
      PROCEDURE CREA_BIEN(pIdMov       RENGS_MOV.IdMov%TYPE,
                          pNumReng     RENGS_MOV.NumReng%TYPE,
                          pTipoBien    BIENES.TipoBien%TYPE,
                          pCodUbicAlm  BIENES.CodUbica%TYPE,
                          pCostoUni    BIENES.CostOrig%TYPE,
                          pProveedor   BIENES.NumProv%TYPE,
                          pFactura     BIENES.NumFact%TYPE,
                          pOrdCmp      BIENES.IdOrdCmp%TYPE,
                          pCodItem     BIENES.CodItem%TYPE,
                          pDescItem    BIENES.DescBien%TYPE,
                          pAInc        BIENES.AnoInc%TYPE,
                          pMInc        BIENES.MesInc%TYPE,
                          pCentCosto   BIENES.Ccosto%TYPE,
                          pDependencia BIENES.CodDepenAdm%TYPE,
						  pTipoMov     VARCHAR2,
						  pFecMov      DATE,
                          pMtoTotalDet OUT DETS_RENG_MOV.MtoDetMov%TYPE,
                          pFecAdquis   BIENES.FecAdquis%TYPE,
						  pStsRevMov   BIENES.StsRev%TYPE,
						  pFecOC       BIENES.FecOdc%TYPE  DEFAULT NULL,
						  pRefOC       BIENES.REFODC%TYPE  DEFAULT NULL);
      PROCEDURE ACT_STSBIEN(pIdBien BIENES.IdBien%TYPE,
                            pStsBien BIENES.StsBien%TYPE);
	  FUNCTION CREA_SOL_SUM_BIEN RETURN NUMBER;

      PROCEDURE ACT_STS_MOV(pIdMov   DETS_RENG_MOV.IdMov%TYPE,
                            pSts     MOVS_BIEN.STSMOV%TYPE);

   PROCEDURE REVISAR_BIEN(pIdBien BIENES.IdBien%TYPE);

   PROCEDURE MODIFICAR_BIEN(pIdBien BIENES.IdBien%TYPE);
   
 /**********************************************************************************/
 /* LLENA_CARACTS_TIPO_BIEN -- agrega las características de las clasificaciones */
 /* de los bienes que no se encuentren previamente cargados                        */ 
 /**********************************************************************************/  
PROCEDURE LLENA_CARACTS_TIPO_BIEN(pSUBTIPO BIENES.SUBTIPOBIEN%TYPE,
                                    pTIPO    BIENES.TIPOBIEN%TYPE);
   
 /**********************************************************************************/
 /* LLENA_CARACTSBIEN -- agrega las características de los bienes                  */
 /* de los bienes que no se encuentren previamente cargad                          */ 
 /**********************************************************************************/
   PROCEDURE LLENA_CARACTSBIEN(pIDBIEN CARACTS_BIEN.IDBIEN%TYPE,
                               pSUBTIPO BIENES.SUBTIPOBIEN%TYPE,
                               pTIPO    BIENES.TIPOBIEN%TYPE);
							   
							   
						--
-- IF 01/07/05 : Info del bien
  CURSOR C_BREV (cIdBien BIENES.IdBien%TYPE) IS
    SELECT codplaca, coditem, stsrev, coddepenadm, codubica, numresp
    FROM BIENES
    WHERE idbien = cidbien;   

------------------------------------------------------------------------------------- 
-- LLENA_TEXTS_BIEN --  Asociar los textos a un bien                  
-- que no se encuentren previamente cargados                         
   PROCEDURE LLENA_TEXTS_BIEN(pIDBIEN CARACTS_BIEN.IDBIEN%TYPE,
                               pSUBTIPO BIENES.SUBTIPOBIEN%TYPE,
                               pTIPO    BIENES.TIPOBIEN%TYPE);

------------------------------------------------------------------------------------- 
-- LLENA_TEXTO_TIPO_BIEN -- Asociar los textos a los tipos de bienes
--  que no se encuentren previamente cargadas                       
  
PROCEDURE LLENA_TEXTOS_TIPO_BIEN(pSUBTIPO BIENES.SUBTIPOBIEN%TYPE,
                                 pTIPO    BIENES.TIPOBIEN%TYPE);                              							   
--
-- Versión del package (Siempre debe ser la ultima función en el package)
      FUNCTION VERPKG RETURN VARCHAR2;
      PRAGMA RESTRICT_REFERENCES(VERPKG, WNDS);
END;

/
