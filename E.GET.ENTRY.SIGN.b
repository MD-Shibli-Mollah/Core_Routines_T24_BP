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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.ENTRY.SIGN
*-----------------------------------------------------------------------------

*** <region name= Modification log>
* 06/07/2010 - Enhancement 48658 / Task 53486
*              Conversion routine to return the entry sign based on the set up in ACCOUNT.PARAMETER
*              and reversal marker in entry.
*              The purpose is to change only the display i.e. reversal of debit will be displayed under debit column
*              and reversal of credit will be displayed under credit column if it is set in ACCOUNT.PARAMETER level.
***</region>
*-----------------------------------------------------------------------------

    $USING AC.Config
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB GET.ENTRY.SIGN

    RETURN

*** <region name= INITIALISE>
*** <desc>The region were the variables are initialised before using it </desc>
*----------
INITIALISE:
*----------

    ENTRY.AMT = EB.Reports.getOData()
    ENTRY.SIGN = ''
    EB.Reports.setOData('')

    RETURN
***</region>
*-------------------------------------------------------------------------------------
*** <region name= GET.ENTRY.SIGN>
*** <desc>Entry sign is returned based on the setup in ACCOUNT.PARAMETER for the field REVERSE.TURNOVER</desc>
*--------------
GET.ENTRY.SIGN:
*--------------

    IF ENTRY.AMT > 0 THEN
        ENTRY.SIGN = 'CREDIT'
    END ELSE
        ENTRY.SIGN = 'DEBIT'
    END

    IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParReverseTurnover> EQ 'YES' AND EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteReversalMarker> EQ 'R' THEN
        IF ENTRY.SIGN = 'CREDIT' THEN
            ENTRY.SIGN = 'DEBIT'
        END ELSE
            ENTRY.SIGN = 'CREDIT'
        END
    END
    EB.Reports.setOData(ENTRY.SIGN)

    RETURN
***</region>
*-----------------------------------------------------------------------------------------------------
