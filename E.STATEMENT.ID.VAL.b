* @ValidationCode : MjozNDc3MDAwMTpjcDEyNTI6MTU0MTA3MzQwODA2Mzprc211a2VzaDotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIwLTE3MjY6LTE6LTE=
* @ValidationInfo : Timestamp         : 01 Nov 2018 17:26:48
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : ksmukesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181020-1726
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.STATEMENT.ID.VAL
*
*-------------------------------------------------------------------------
*
* Subroutine to validate statement id. The format can be:
*
* account.date.frequency.carrier
*
* All but the account are optional.
*
*-------------------------------------------------------------------------
* 06/09/02 - GLOBUS_EN_10001086
*          Conversion Of all Error Messages to Error Codes
*
* 21/10/02 - GLOBUS_EN_10001477
*            Changes done to adapt additional frequencies in account
*            statement.
*
* 18/12/02 - GLOBUS_BG_100002917
*            Modification done to validate the CARRIER number should
*            be allowed upto 9.
*
* 27/11/08 - BG_100021032
*            Error messages not raised properly
*
* 06/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/10/18 - EN 2828914 / Task 2828966
*            Assign carrier from the Statement based on the length of the Statement id part
*
*************************************************************************
*
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Template
    $USING EB.Utility
*-------------------------------------------------------------------------
*
    STATEMENT.ID = EB.Reports.getOData()
    CONVERT "." TO @FM IN STATEMENT.ID  ;* Easier to process
    ACCOUNT = STATEMENT.ID<1>
    V$DATE = STATEMENT.ID<2>
    FREQUENCY = STATEMENT.ID<3>
    ID.LEN = DCOUNT(STATEMENT.ID,@FM)
        
    IF ID.LEN GE 4 THEN
        CARRIER = STATEMENT.ID<5>
    END ELSE
        CARRIER = STATEMENT.ID<4>
    END
*
    EB.SystemTables.setComi(ACCOUNT)
    EB.Template.In2ant("16.1","ANT")
    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        RETURN
    END
*
    STATEMENT.ID<1> = EB.SystemTables.getComi()    ;* Could have been a mnemonic
*
    IF V$DATE THEN
        EB.SystemTables.setComi(V$DATE)
        EB.Utility.InTwod("11.1","D")
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setE(EB.SystemTables.getEtext())
            RETURN
        END
        STATEMENT.ID<2> = EB.SystemTables.getComi()          ;* Real date format
    END
*
    IF FREQUENCY > 9 THEN     ;* EN_10001477 S/E
        EB.SystemTables.setEtext("AC.RTN.INVALID.FREQUENCY")
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        RETURN
    END
*
    IF CARRIER > 9 THEN       ;* CI_100002917  S/E
        EB.SystemTables.setEtext("AC.RTN.INVALID.CARRIER")
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        RETURN
    END
*
    CONVERT @FM TO "." IN STATEMENT.ID
    EB.Reports.setOData(STATEMENT.ID);* Return to sender
*
RETURN
*
*-------------------------------------------------------------------------
PROGRAM.ABORT:
    EB.SystemTables.setE(EB.SystemTables.getEtext())
RETURN
*
*-------------------------------------------------------------------------
PROGRAM.END:
RETURN
*
*-------------------------------------------------------------------------
END
