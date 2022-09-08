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

* Version 4 29/09/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>183</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EU.AccountEuroConversion
      SUBROUTINE CONV.AC.EU.CONV.G9.2(AC.NO, AC.REC, AC.FILE)
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.ACCOUNT
*
** This routine will ensure that INTEREST.CCY and CHARGE.CCY
** match the currency of the account for converted accounts
** if they don't it change the currency, it will also remove
** accounts of the wrong currency which are linked in INT.LIQ
** and CHARGE fields
*
      IF AC.FILE['$',2,1] NE 'HIS' THEN  ; * Not history
         IF AC.REC<AC.ORIGINAL.ACCT> THEN          ; * Only converted
            AC.REC<AC.INTEREST.CCY> = AC.REC<AC.CURRENCY>
            AC.REC<AC.CHARGE.CCY> = AC.REC<AC.CURRENCY>
            IF AC.REC<AC.CON.INTEREST.ACCR>['.',4,1] NE AC.REC<AC.CURRENCY> THEN
               AC.REC<AC.CON.INTEREST.ACCR> = ''
            END
            IF AC.REC<AC.CON.CHARGE.ACCR>['.',4,1] NE AC.REC<AC.CURRENCY> THEN
               AC.REC<AC.CON.CHARGE.ACCR> = ''
            END
*
            IF AC.REC<AC.INTEREST.LIQU.ACCT> THEN
               AC.FLD = AC.INTEREST.LIQU.ACCT
               GOSUB CHECK.ACCT.CCY
            END
            IF AC.REC<AC.CHARGE.ACCOUNT> THEN
               AC.FLD = AC.CHARGE.ACCOUNT
               GOSUB CHECK.ACCT.CCY
            END
         END ELSE
*
** If the account has been renumbered, there will be an auto pay
** account, check that the charge account is the same currency as
** the account itself
*
            IF AC.REC<AC.AUTO.PAY.ACCT> THEN
               IF AC.REC<AC.CHARGE.ACCOUNT> THEN
                  AC.FLD = AC.CHARGE.ACCOUNT
                  GOSUB CHECK.ACCT.CCY
                  IF AC.REC<AC.FLD> = '' THEN      ; * Different ccy so cleared
                     AC.REC<AC.FLD> = OTH.REC<AC.ORIGINAL.ACCT>        ; * Set to renumbered linked a/c
                  END
               END
            END
         END
*
      END
*
      RETURN
*
*-------------------------------------------------------------
CHECK.ACCT.CCY:
*==============
*
      F.ACCOUNT = ''
      CALL OPF('F.ACCOUNT', F.ACCOUNT)
      READ OTH.REC FROM F.ACCOUNT, AC.REC<AC.FLD> ELSE OTH.REC =''
      IF OTH.REC<AC.CURRENCY> NE AC.REC<AC.CURRENCY> THEN
         AC.REC<AC.FLD> = ''
      END
*
      RETURN
*
*
   END
