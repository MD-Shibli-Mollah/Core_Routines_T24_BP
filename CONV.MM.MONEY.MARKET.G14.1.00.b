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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
      SUBROUTINE CONV.MM.MONEY.MARKET.G14.1.00(MM.ID, MM.REC, MM.FILE)

*********************************************************************

* 25/09/03 - EN_10001997
*             REPO Margin Call Enhancement.
*            New field SEND.PAYMENT is included and its value 
*            depends on the presence of PRIN.BEN.BANK.1 field.
*
***********************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
***********************************************************************

      GOSUB INITIALISE

      GOSUB PROCESS.RECS

      RETURN

***********************************************************************
INITIALISE:
***********
	RP.SEND.PAYMENT = 128
	RP.PRIN.BEN.BANK.1 = 24

      RETURN

***********************************************************************
PROCESS.RECS:
*************

      IF MM.REC<RP.PRIN.BEN.BANK.1> THEN
         MM.REC<RP.SEND.PAYMENT> = 'YES'
      END ELSE
         MM.REC<RP.SEND.PAYMENT> = 'NO'
      END

      RETURN

************************************************************************

   END
