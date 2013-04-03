CREATE OR REPLACE PACKAGE Proc_Deprec IS
   FUNCTION MESES_INCORPORADO(pIdBien BIENES.IdBien%TYPE, pMes BIENES.MesInc%TYPE, pAno BIENES.AnoInc%TYPE) RETURN NUMBER;

   FUNCTION VALIDA_BIEN_DEPREC(pIdBien BIENES.IdBien%TYPE) RETURN BOOLEAN;

   PROCEDURE CALCULA_DEPREC(pMes BIENES.MesInc%TYPE,
                            pAno BIENES.AnoInc%TYPE,
						    pProceso VARCHAR2);

   PROCEDURE VALIDA_DEPRECIACION(pMes BIENES.MesInc%TYPE,
                                 pAno BIENES.AnoInc%TYPE,
						         pProceso VARCHAR2);

   PROCEDURE DEPRECIACION(pMes BIENES.MesInc%TYPE,
                          pAno BIENES.AnoInc%TYPE,
						  pProceso VARCHAR2);

   PROCEDURE VALIDA_STS_DET(pIdDoc DETS_VALOR_BIEN.IdDoc%TYPE,
                            pStsDet DETS_VALOR_BIEN.StsDet%TYPE);

   PROCEDURE ACT_STS_DET(pIdDoc DETS_VALOR_BIEN.IdDoc%TYPE,
                         pStsDet DETS_VALOR_BIEN.StsDet%TYPE);

   FUNCTION FRACCION_MES_SUM(pIdBien  BIENES.IdBien%TYPE,
                             pMesProc BIENES.MesInc%TYPE,
					         pAnoProc BIENES.AnoInc%TYPE,
							 pMejorInd BOOLEAN DEFAULT FALSE) RETURN NUMBER;
							 								
   FUNCTION FRACCION_MES_IND(pIdBien  BIENES.IdBien%TYPE,
                             pMesProc BIENES.MesInc%TYPE,
					         pAnoProc BIENES.AnoInc%TYPE) RETURN NUMBER;				 
							 
   FUNCTION FRACCION_MESMEJORAS_IND(pIdMov   MOVS_BIEN.IdMov%TYPE,
                                    pIdBien  DETS_RENG_MOV.IdBien%TYPE,
                                    pMesProc MOVS_BIEN.Mes%TYPE,
				                    pAnoProc MOVS_BIEN.Ano%TYPE) RETURN NUMBER;

   PROCEDURE ACT_STS_PROC(pIdDoc   DETS_VALOR_BIEN.IdDoc%TYPE,
                          pStsProc DETS_VALOR_BIEN.StsProc%TYPE);

   PROCEDURE CALCULA_MEJORAS_SUM(pMes BIENES.MesInc%TYPE,
                                 pAno BIENES.AnoInc%TYPE,
						         pProceso VARCHAR2,
								 pDocDepr VARCHAR2);

   PROCEDURE CALCULA_MEJORAS_IND(pMes BIENES.MesInc%TYPE,
                                 pAno BIENES.AnoInc%TYPE,
						         pProceso VARCHAR2,
								 pDocDepr VARCHAR2);

   PROCEDURE ELIMINAR_PERIODO_DEPREC(pPeriodo DETS_VALOR_BIEN.Periodo%TYPE,
                                     pAno     DETS_VALOR_BIEN.Ano%TYPE);

-- Versión del package (Siempre debe ser la ultima función en el package)
   FUNCTION VERPKG RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(VERPKG, WNDS);
   PRAGMA RESTRICT_REFERENCES(MESES_INCORPORADO, WNDS);
END;

/
