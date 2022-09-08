* @ValidationCode : MjotMTg4MDI0NDA0NzpDcDEyNTI6MTU5NzIyMDA0NjY2MDpzYXNpa3VtYXJ2OjEwOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MTAwOjEwMA==
* @ValidationInfo : Timestamp         : 12 Aug 2020 13:44:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sasikumarv
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 100/100 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-84</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.TXN.ENTRY.BUILD
*-----------------------------------------------------------------------------
* Subroutine type : Subroutine
* Attached to     : Enquiry MB.TXN.ENTRIES
* Attached as     : Conversion routine
* Purposes        : Returns the STMT, SPEC and CATEG Entry records for the Lead
*                   Company in which the enquiry is executed.
* @author         : prabha@temenos.com/madhusudananp@temenos.com

*-----------------------------------------------------------------------------
* @author         : rgayathri@temenos.com
**---------------------------------------------------------------------------------------
*Modification History
* 26/09/08 - BG_100020158
*            Problem in displaying categ entries.
*
* 27/07/11 - Defect 247831/ Task 251312
*            Cannot drilldown the enquiry TXN.ENTRY.MB if the Entry's account belongs
*            to another company. O.DATA value is suffixed with company mnemonic.
*
* 10/04/13 - DEFECT  631995 / TASK 646155
*			 Company mnemonic displayed is of Lead Company, respective company's mnemonics
*            have to be displayed. O.DATA value is now suffixed with only respective company
*            mnemonic instead of lead company.
*
* 10/07/20 - Enh 3847739 / Task 3847751
*            Update the Balance Types & Trans Reference for enquiry display
*            RE.TXN.CODE to be displayed only for Contract based Spec Entries
*
*----------------------------------------------------------------------------------------

    $USING AC.EntryCreation
    $USING ST.Config
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.SystemTables

*
*--------------------------------------
*
    STMT.ID = EB.Reports.getOData()['*',1,1]
    CO.MNE =  EB.Reports.getOData()['*',2,1]
    SAVE.ID.COMPANY = EB.SystemTables.getIdCompany()
    IF CO.MNE THEN
        LEAD.MNE = ''
        LEAD.COMP.ID = ''
        ST.CompanyCreation.GetCompany(CO.MNE,"",LEAD.COMP.ID,LEAD.MNE)
        IF LEAD.COMP.ID NE EB.SystemTables.getIdCompany() THEN
            ST.CompanyCreation.LoadCompany(LEAD.COMP.ID)
        END
    END
* BG_100020158 S
    TXN.ID = STMT.ID[2,99]

    BEGIN CASE
        CASE STMT.ID[1,1] = 'S'
            GOSUB READ.STMT.ENTRY

        CASE STMT.ID[1,1] = 'R'  OR STMT.ID[1,1] = 'E'
            GOSUB READ.SPEC.ENTRY

        CASE STMT.ID[1,1] = 'C'
            GOSUB READ.CATEG.ENTRY


    END CASE
* BG_100020158 E

    IF SAVE.ID.COMPANY NE EB.SystemTables.getIdCompany() THEN
        ST.CompanyCreation.LoadCompany(SAVE.ID.COMPANY)
    END

RETURN
*
*-------------------------------------------
*
READ.STMT.ENTRY:

    R.STMT.ENTRY = AC.EntryCreation.StmtEntry.Read(TXN.ID, R.STMT.ERR)
    IF R.STMT.ERR THEN
        R.STMT.ENTRY.DTL = AC.EntryCreation.StmtEntryDetail.Read(TXN.ID, R.STMT.ERR.DTL)
        EB.Reports.setRRecord(R.STMT.ENTRY.DTL)
        EB.Reports.setOData('T':TXN.ID:'*':CO.MNE)
    END ELSE
        EB.Reports.setRRecord(R.STMT.ENTRY)
    END

RETURN
*
*----------------------------------------------
*
READ.CATEG.ENTRY:

    R.CAT.ENT = AC.EntryCreation.CategEntry.Read(TXN.ID, R.CAT.ENT.ERR)
    IF R.CAT.ENT.ERR THEN
        R.CAT.ENT = AC.EntryCreation.CategEntryDetail.Read(TXN.ID, R.CAT.DTL.ERR)
        EB.Reports.setOData('N':TXN.ID:'*':CO.MNE)
    END
    EB.Reports.setRRecord(R.CAT.ENT)

RETURN
*
*-----------------------------------------------
*
READ.SPEC.ENTRY:

    R.SPEC.REC = AC.EntryCreation.ReConsolSpecEntry.Read(TXN.ID, R.RE.ERR)
    IF R.RE.ERR THEN
        R.SPEC.REC = AC.EntryCreation.ReSpecEntryDetail.Read(TXN.ID, R.RE.DTL.ERR)
        IF R.RE.DTL.ERR THEN
            R.SPEC.REC = AC.EntryCreation.ConsolEntToday.Read(TXN.ID, R.CON.ERR)
            EB.Reports.setOData('E':TXN.ID:'*':CO.MNE)
            GOSUB FILL.CET
        END ELSE
            EB.Reports.setOData('R':TXN.ID:'*':CO.MNE)
            GOSUB SET.SPEC.ENTRY
        END
    END ELSE
        EB.Reports.setOData('D':TXN.ID:'*':CO.MNE)
        GOSUB SET.SPEC.ENTRY
    END

RETURN
*-----------------------------------------------
SET.SPEC.ENTRY:

    EB.Reports.setRRecord(R.SPEC.REC)
    RecConsolkey = R.SPEC.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseConsolKeyType>
    BalanceType = FIELD(RecConsolkey, '.', DCOUNT(RecConsolkey, '.'))
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteBalanceType>=BalanceType; EB.Reports.setRRecord(tmp)
    
    IF NUM(R.SPEC.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseDealNumber>) ELSE
        TXN.CODE = R.SPEC.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseTransactionCode>
        GOSUB GET.TXN.CODE.DESC
    END
    
RETURN
*-----------------------------------------------
*BG_100020158
*-----------------------------------------------
FILL.CET:

* the fields of the enquiry are designed for STMT,CATEG and SPEC
* it cannot display for CET so send the values in the position of
* other entries
* VDATE -----> 11th position : customer -----> 8th position
* ACCOUNT -----> 1ST position : Booking date -----> 25th position
* Fcy  amt  -----> 13th position : Lcy amount -----> 3rd position
* Get these position from STMT than hard coding them
    EB.Reports.setRRecord(R.SPEC.REC)
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteValueDate>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetValueDate>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteCustomerId>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetCustomer>; EB.Reports.setRRecord(tmp)
* For account display the transaction code
    TXN.CODE = R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetTxnCode>
    GOSUB GET.TXN.CODE.DESC
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteBookingDate>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetBookingDate>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteCurrency>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetCurrency>; EB.Reports.setRRecord(tmp)
    THIS.AMT = 0
    BEGIN CASE
        CASE R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalCr> NE ""
            THIS.AMT = R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalCr>
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountLcy>=THIS.AMT; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountFcy>=0; EB.Reports.setRRecord(tmp)
        CASE R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalDr> NE ""
            THIS.AMT = R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalDr>
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountLcy>=THIS.AMT; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountFcy>=0; EB.Reports.setRRecord(tmp)
        CASE R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignCr> NE ""
            THIS.AMT = R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignCr>
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountLcy>=0; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountFcy>=THIS.AMT; EB.Reports.setRRecord(tmp)
        CASE R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignDr> NE ""
            THIS.AMT = R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignDr>
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountLcy>=0; EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteAmountFcy>=THIS.AMT; EB.Reports.setRRecord(tmp)
    END CASE
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteCompanyCode>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetCoCode>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteTransReference>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetTxnRef>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.StmtEntry.SteBalanceType>=R.SPEC.REC<AC.EntryCreation.ConsolEntToday.ReCetType>; EB.Reports.setRRecord(tmp)
RETURN
*-------------------------------------------------------------------
GET.TXN.CODE.DESC:
    
    ENT.TXN.REC = ""
    TXN.ER = ''
    ENT.TXN.REC = AC.EntryCreation.ReTxnCode.CacheRead(TXN.CODE, TXN.ER)
    tmp=EB.Reports.getRRecord(); tmp<1>=ENT.TXN.REC<AC.EntryCreation.ReTxnCode.ReTxnShortDesc>; EB.Reports.setRRecord(tmp)

RETURN
*--------------------------------------------------------------------
*BG_100020158
END
