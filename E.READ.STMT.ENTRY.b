* @ValidationCode : MjotMTkzMzEwMDY2NTpDcDEyNTI6MTU2ODExNDE4NDY4NjpzdGFudXNocmVlOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4yMDE5MDcyMy0wMjUxOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Sep 2019 16:46:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 02/06/00  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-53</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.READ.STMT.ENTRY
*-----------------------------------------------------------------------------
*
** This subroutine is used by the enquiry STMT.ENT.BOOK to read the
** STMT.ENTRY record, or build a dummy record where required. It replaces
** E.STMT.ENQ2 which will remain for existing user defined enquiries.
** This routine will return the entire entry record, rather than selected
** highlights
*
** In - O.DATA  format Ac no * Entry Id or just entry id
** Out - R.RECORD the STMT ENTRY record or currency of account
*
*-----------------------------------------------------------------------------
* 11/03/98 - GB9800234
*            Set VM.COUNT when narrative from the entry is used
*
** 30/11/98 - GB9801498
**            - The drill downs to CUSTOMER.POSITION ENQ have
**              incorrect currency records
**
*
* 28/04/2003 - CI_10008655
*
*             Incorrect fee charge period description in the enquiry
*             STMT.ENT.BOOK
*
* 23/03/04 - CI_10018113
*          - Drill-down in ENQ>STMT.ENT.BOOK for charges throw an error
*          - 'INVALID YEAR.MONTH LENGTH'.Bcoz for charges, TRANS.REF field
*          - in STMT.ENTRY is updated in the format 'ACCT.ID-YYYYMMDD',
*          - but the id of STMT.ACCT.CH is 'ACCT.ID-YYYYMM'. Modified
*          - R.RECORD<AC.EntryCreation.StmtEntry.SteTransReference> to hold the id of STMT.ACCT.CH
*
* 25/09/04 - BG_100007305
*            Changes to I_OPF to always call OPF to open the files.
* 07/07/05 - CI_10032024
*            Overwrite the display of narrative defined on STMT.ENTRY for fees also when
*            STMT.NARR.FORMAT has some thing else to display
*
* 02/05/10 - Defect 51272 / Task 52248
*            If entry is not in STMT.ENTRY file then try to read in STMT.ENTRY.DETAIL and
*            to get the TXN.ID for netted entries.
*
* 29/07/10 - Defect 70530 / CI_10070980
*            Amount of IC.CHARGE transaction is not shown if TRANS.REF contains '*'
*            Modified to take the TRANS.REF from STMT.ENTRY for normal entries &
*            STMT.ENTRY.DETAIL for netted entries.
*
* 04/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING AC.AccountStatement

    tmp.O.DATA = EB.Reports.getOData()
    IF INDEX(tmp.O.DATA,"*",1) THEN
        ENTRY.ID = EB.Reports.getOData()["*",2,1]
        ACCOUNT.NO = EB.Reports.getOData()["*",1,1]
    END ELSE
        ENTRY.ID = EB.Reports.getOData() ; ACCOUNT.NO = ""
    END
*
    DETAIL.ENTRY = 0
    Y.ENTRY.CHECK = COUNT(ENTRY.ID,'!')

*To take STMT.ENTRY.DETAIL.XREF ID from 7th position for netted entries.
    IF Y.ENTRY.CHECK AND EB.Reports.getOData()["*",7,1] THEN
        ENTRY.ID = EB.Reports.getOData()["*",7,1]
        DETAIL.ENTRY = 1 ;* Flag to say read the entry from detail file
    END
*
** Read the entry into R.RECORD. If it is not present then add the
** account currency into field 3 of a dummy R.RECORD
*
    ENTRY.ERR = ''
    IF DETAIL.ENTRY = 0 THEN
        R.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(ENTRY.ID, ENTRY.ERR)
        EB.Reports.setRRecord(R.STMT.ENTRY )
    END ELSE
        R.STMT.ENTRY = AC.EntryCreation.tableStmtEntryDetail(ENTRY.ID, ENTRY.ERR)
        EB.Reports.setRRecord(R.STMT.ENTRY)
    END

    IF NOT(ENTRY.ERR) THEN ;* Entry record present
        GOSUB GET.RECORD.VALUES
    END ELSE
        YR.ACCOUNT = AC.AccountOpening.tableAccount(ACCOUNT.NO, AC.ERR)
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteCurrency>=YR.ACCOUNT<AC.AccountOpening.Account.Currency>; EB.Reports.setRRecord(tmp)
    END

* CI_10018113s
    IF EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteSystemId> = 'IC1' THEN
        YLEN.REF = LEN(EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteTransReference>)
        YTRANS.REF = EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteTransReference>[1,YLEN.REF-2]
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteTransReference>=YTRANS.REF; EB.Reports.setRRecord(tmp)
    END
* CI_10018113e

RETURN
*-----------------------------------------------------------------------------
GET.RECORD.VALUES:
*=================
** Return the calculated narrative if requested into the narrative field
** This can be switched off if the item SHOW.NARRATIVE is set to NO
*
    LOCATE "SHOW.NARRATIVE" IN EB.Reports.getDFields()<1> SETTING SHOW.NARR THEN
        IF EB.Reports.getDRangeAndValue()<SHOW.NARR> = "NO" THEN
            SHOW.NARR = ""
        END
    END ELSE
        SHOW.NARR = 1         ;* Default is calculate
    END

    IF SHOW.NARR THEN
        ENTRY.REC = EB.Reports.getRRecord() ; CALC.NARR = ""
        AC.AccountStatement.GetNarrative(ENTRY.ID, ENTRY.REC, CALC.NARR)
        IF CALC.NARR THEN
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteNarrative>=CALC.NARR; EB.Reports.setRRecord(tmp)
        END
        NARR.CNT = DCOUNT(EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteNarrative>,@VM)
        EB.Reports.setVmCount(NARR.CNT)
    END
*
** Ensure that currency is populated
** And put the amount in the foreign field even if local
*
** GB9801498S

    IF EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteCurrency> = "" THEN
        ACCOUNT.NO = EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteAccountNumber>
        YR.ACCOUNT = AC.AccountOpening.tableAccount(ACCOUNT.NO, AC.ERR)
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteCurrency>=YR.ACCOUNT<AC.AccountOpening.Account.Currency>; EB.Reports.setRRecord(tmp)
    END
** GB9801498E

    IF EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteAmountFcy> = "" THEN
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountFcy>=EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteAmountLcy>; EB.Reports.setRRecord(tmp)
    END
*
RETURN
*---------------------------------------------------------------------------
END
