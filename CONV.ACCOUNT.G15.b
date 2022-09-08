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
* <Rating>304</Rating>
*-----------------------------------------------------------------------------
* Version 46 25/10/00 GLOBUS Release No. G14.0.00 03/07/03
*
*************************************************************************
*
    $PACKAGE AC.AccountOpening
    SUBROUTINE CONV.ACCOUNT.G15(ACCT.ID,ACCT.REC,FILE)
*
*************************************************************************
* This routine is to populate the NEXT.AF.DATE field in the ACCOUNT record.
* It will get the date next forward date from ACCT.ENT.FWD that falls outside
* the window ladder.
* The window ladder is calculated from the CASH.FLOW.DAYS set in ACCOUNT.PARAMETER or
* the last available date from the available funds ladder, which ever is bigger.
***************************************************************************
* Modifications:
* =============
* 26/09/04 - EN_10002329
*            Improve performance of SOD.CASHFLOW.UPDATE
*            Clearing all cash flow fields.
* 21/01/05 - BG_100007905
*            To ensure record routine is processed correctly
*            in multi-company environment.
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT.PARAMETER
*************************************************************************

    GOSUB INITIALISE

    GOSUB SELECT.ACCOUNT

    RETURN
*
*************************************************************************
INITIALISE:
*      Open files

    FN.ACCT.ENT.FWD= FILE[".",1,1]:".ACCT.ENT.FWD" ; F.ACCT.ENT.FWD = ''  ; * BG_100007905
    CALL OPF(FN.ACCT.ENT.FWD,F.ACCT.ENT.FWD)
* Initialise variables
*
    CASH.FLOW.DAYS = R.ACCOUNT.PARAMETER<AC.PAR.CASH.FLOW.DAYS>

    IF NOT(CASH.FLOW.DAYS) THEN
        CASH.FLOW.DAYS = 10
    END

* Determine the window extension. Anything falling into the window
* extension must be added to the account's cash flow.
*
    WINDOW.END = TODAY
    WINDOW.BEG = R.DATES(EB.DAT.LAST.WORKING.DAY)
    CALL CDT('',WINDOW.END,'+':CASH.FLOW.DAYS:'C')          ;* End of new window
    CALL CDT('',WINDOW.BEG,'+':CASH.FLOW.DAYS:'C')          ;* End of old window

    WRITE.ACC =0
    NO.OF.RECS = 0

    RETURN

*************************************************************************
*
SELECT.ACCOUNT:
*
    ACCT.WINDOW.END = MAXIMUM(ACCT.REC<AC.AVAILABLE.DATE>)
    IF ACCT.WINDOW.END LT WINDOW.END THEN ACCT.WINDOW.END = WINDOW.END

    READ FWD.REC FROM F.ACCT.ENT.FWD, ACCT.ID ELSE FWD.REC = ''
    GOSUB GET.NEXT.AF.DATE


    RETURN
********************************************************************************
GET.NEXT.AF.DATE:
    IF FWD.REC THEN

        FWD.DATE  = ''
        LOOP REMOVE STMT.ID FROM FWD.REC SETTING DELIM WHILE STMT.ID:DELIM
            STMT.DATE = STMT.ID[2,8]

            IF STMT.DATE GT ACCT.WINDOW.END AND STMT.ID[1,1] EQ 'F' THEN
                IF FWD.DATE THEN
                    IF STMT.DATE LT FWD.DATE THEN
                        FWD.DATE = STMT.DATE
                    END
                END ELSE
                    FWD.DATE = STMT.DATE
                END
            END
        REPEAT

        IF FWD.DATE THEN
            ACCT.REC<163> = FWD.DATE
        END
    END

    RETURN
*******************************************************************************


END
