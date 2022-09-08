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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE RE.ConBalanceUpdates
      SUBROUTINE CONV.ACCOUNT.EXP.DATE.G152(ACCOUNT.ID,R.ACCOUNT,FN.ACCOUNT)
*
* 21/10/04 - EN_10002375
*            Update NEXT.EXP.DATE field


$INSERT I_COMMON
$INSERT I_EQUATE


***   Main processing   ***
*     ---------------     *

      IF R.ACCOUNT<168,1> THEN    ;* AC.EXPOSURE.DATES
         R.ACCOUNT<165> = R.ACCOUNT<168,1>  ;* AC.NEXT.EXP.DATE = AC.EXPOSURE.DATES,1
      END
      

      RETURN

END
