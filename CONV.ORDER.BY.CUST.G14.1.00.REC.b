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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctModelling
      SUBROUTINE CONV.ORDER.BY.CUST.G14.1.00.REC(ORDER.BY.CUST.ID,R.RECORD,FILENAME)
*-----------------------------------------------------------------------------
* Record routine for conversion of ORDER.BY.CUST
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/09/03 - GLOBUS_CI_10012334
*            New routine
* 29/09/03 - GLOBUS_EN_10002037
*            Changed for US WHT field.
*            68 to 69 and 69 to 70.
* 07/02/08 - Error while running conversion as service
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE 
*-----------------------------------------------------------------------------

      IF R.RECORD<69> = '' THEN ; * TRADE.CCY is null so populate
         IF R.RECORD<1> = 'PURCHASE' THEN
            K.SECURITY = R.RECORD<10>
         END ELSE
            K.SECURITY = R.RECORD<6>
         END
         F.SECURITY.MASTER = ''
         R.SECURITY.MASTER = ''
         CALL F.READ('F.SECURITY.MASTER',K.SECURITY,R.SECURITY.MASTER,F.SECURITY.MASTER,'')
         R.RECORD<69> = R.SECURITY.MASTER<7>    ; * populate from SECURITY.CURRENCY
      END

      IF R.RECORD<70> = '' THEN ; * TOTAL.NOMINAL is null so populate
         R.RECORD<70> = SUM(SUM(R.RECORD<40>))  ; * populate by summing up all the NOMINAL
      END

      RETURN
*
*-----------------------------------------------------------------------------
*
   END
