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
    $PACKAGE AC.Config
    SUBROUTINE CONV.ACCOUNT.PARAMETER.200708(ID,R.ACCT.PAR,FILE)
* Conversion to default field in acct.par . To decide entry updates i ECB.

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.PARAMETER

    GOSUB PROCESS

    RETURN

*----------------
PROCESS:
*----------

    IF R.ACCT.PAR<AC.PAR.UPDATE.ENTRIES> EQ '' THEN
        R.ACCT.PAR<AC.PAR.UPDATE.ENTRIES> = 'RECENT'
    END

    RETURN
*
END
