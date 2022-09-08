* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>170</Rating>
*-----------------------------------------------------------------------------
* Version 5 16/05/01  GLOBUS Release No. G12.0.00 29/06/01
      $PACKAGE SC.ScoReports
      SUBROUTINE E.SC.HOLD.PARAM
*
************************************************************
*
*    SUBROUTINE TO EXTRACT MULT.FACTOR AND PERCENTAGE
*    SET TO LOCAL4 AND LOCAL5 FOR USE TO CALCULATE
*    AVG.COST PRICE IN SC.HOLD.SUM ENQUIRY VIA
*    E.SC.HOLD.COST.CALC
*
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
*
* 27/06/02 - GLOBUS_EN_10000784
*            Add processing to handle part-paid & grouped shares/bonds such as
*            Telekurs Price Types 10, 11, 20 & 51.
*
* 24/10/02 - GLOBUS_EN_10001460
*          Conversion Of all Error Messages to Error Codes
*
* 25/11/08 - GLOBUS_BG_100021004 - dadkinson@temenos.com
*            TTS0804595
*            Remove DBRs
* 23-07-2015 - 1415959
*             Incorporation of components
************************************************************
*
$USING SC.SctPriceTypeUpdateAndProcessing
$USING SC.ScoSecurityPositionUpdate
$USING SC.ScoSecurityMasterMaintenance
$USING EB.DataAccess
$USING EB.ErrorProcessing
$USING EB.SystemTables
$USING EB.Reports

*
*****************************************************************
*  ;* BG_100021004 E

tmp.ID = EB.Reports.getId()
      SEC.NO = FIELD(tmp.ID,'.',2)
EB.Reports.setId(tmp.ID)
      
      R.SECURITY.MASTER = '';* BG_100021004 S  DBRs replaced
      YERR = ''
      R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SEC.NO, YERR)
* Before incorporation : CALL F.READ('F.SECURITY.MASTER',SEC.NO,R.SECURITY.MASTER,F.SECURITY.MASTER,YERR)
      IF YERR NE '' THEN
         EB.SystemTables.setE(YERR)
         GOTO FATAL
      END                  
      PRICE.TYPE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceType>  
      SEC.CCY = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityCurrency>
      Y.NOMINAL.FACTOR = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmNominalFactor>
      Y.FACTOR.TYPE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmFactorType>

      R.PRICE.TYPE = ''
      YERR = ''
      R.PRICE.TYPE = SC.SctPriceTypeUpdateAndProcessing.PriceType.CacheRead(PRICE.TYPE, YERR)
* Before incorporation : CALL CACHE.READ('F.PRICE.TYPE',PRICE.TYPE,R.PRICE.TYPE,YERR)
      IF YERR NE '' THEN
         EB.SystemTables.setE('SC.RTN.REC.NOT.FOUND.ON.FILE.F.PRICE.TYPE':@FM:PRICE.TYPE:@VM:'F.PRICE.TYPE')
         GOTO FATAL
      END  ;* BG_100021004 E                
     
      IF NOT(Y.NOMINAL.FACTOR) THEN ;* EN_10000784 S
         MULT.FACTOR = R.PRICE.TYPE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtMultiplyFactor>
      END ELSE
         IF Y.FACTOR.TYPE = "DIVIDE" THEN
            MULT.FACTOR = 1 / Y.NOMINAL.FACTOR
         END ELSE
            MULT.FACTOR = Y.NOMINAL.FACTOR
         END
      END ;* EN_10000784 E

      PERC.CODE = R.PRICE.TYPE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtPercentage>

      EB.SystemTables.setLocalFou(MULT.FACTOR)
      EB.SystemTables.setLocalFiv(PERC.CODE)
      EB.SystemTables.setLocalSix(SEC.CCY)

      RETURN
      
*-----------------------------------------------------------------------------
FATAL:

      EB.ErrorProcessing.Err()
      EB.SystemTables.setEtext(EB.SystemTables.getE())
      EB.ErrorProcessing.FatalError('E.SC.HOLD.PARAM')
      
   END
