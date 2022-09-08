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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.CashManagement
    SUBROUTINE CONV.AM.CASH.MGMT.200712(ID, R.AM.PARAMETER, FILE)
* Conversion to default fields in AM.PARAMETER

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS

    RETURN

*----------------
PROCESS:
*----------


     R.AM.PARAMETER<69> = '2'; * AM.PAR.COUPON.DAYS
      R.AM.PARAMETER<70> = '2'; * AM.PAR.DIVIDEND.DAYS
      R.AM.PARAMETER<71> = '2'; * AM.PAR.INTEREST.DAYS
      R.AM.PARAMETER<72> = '2'; * AM.PAR.REDEMPTION.DAYS
      R.AM.PARAMETER<73> = '2'; * AM.PAR.MM.DAYS
      R.AM.PARAMETER<74> = '2'; * AM.PAR.FX.DAYS
      R.AM.PARAMETER<79> = ''; * AM.PAR.CON.RATE.RTN
      R.AM.PARAMETER<80> = 'NO'; * AM.PAR.AUTO.RECALC.CM

    RETURN
*
END
