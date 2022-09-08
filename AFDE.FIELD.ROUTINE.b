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
    $PACKAGE CR.ModelBank
    SUBROUTINE AFDE.FIELD.ROUTINE

    $USING PW.ModelBank
    $USING EB.Browser
    $USING AC.AccountOpening
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN


INITIALISE:

    EB.Browser.SystemGetuservariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)
    LOCATE 'CURRENT.CUSTOMER' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
    YR.CUSTOMER.ID = YR.VARIABLE.VALUES<YR.POS.1>
    END

    RETURN


PROCESS:

    IF EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCustomer) = '' THEN
        EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCustomer, YR.CUSTOMER.ID)
    END
    AC.AccountOpening.GetAccountNumber('AC',YR.NEXT.ID)
    EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoAccountNumber, YR.NEXT.ID)

    RETURN

    END
