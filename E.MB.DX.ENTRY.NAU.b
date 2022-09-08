* @ValidationCode : MjotNzA1OTM3NjA2OmNwMTI1MjoxNTQyNzc4NDUzNjAzOmthcnRoaWtleWFua2FuZGFzYW15Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Nov 2018 11:04:13
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : karthikeyankandasamy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 02/06/00  GLOBUS Release No. G10.2.02 29/03/00
*-----------------------------------------------------------------------------
* <Rating>-68</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DX.ModelBank
SUBROUTINE E.MB.DX.ENTRY.NAU(RETURN.ARR)
*
*** <region name= Modification History>
*** <desc> </desc>
*-----------------------------------------------------------------------------
*
* 01/11/18 -  Enhancement:2822501 Task: 2829280
*             Componentization - II - Private Wealth
*----------------------------------------------------------------------------------
    $USING DX.Accounting
    $USING DX.Trade
    $USING AC.EntryCreation
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING AC.API
    $USING AC.AccountOpening
    $USING EB.DataAccess
    $USING EB.Reports
    $INSERT I_DAS.EB.CONTRACT.BALANCES
*
** This routine will turn DX.ACCT.ENTRIES records from being
** one field per entry, to multi valued fields per entry
*-----------------------------------------------------------------------------
* Maintenance History:
* --------------------
* 28/07/14 - Defect-1068274 / Task-1071411
*            The enquiry DX.ENTRY.NAU to list unauthorised entries on reversed trade is
*            displaying amounts with wrong sign.
*
* 11/12/14 - Defect 1189996 / Task 1196360
*            Enquiry for unauthorised entries DX.ENTRY.NAU does not list all entries for reversal
*
* 06/05/15 - Defect 1331776 / Task 1335882
*            Enquiry DX.ENTRY.NAU displays incorrect data.
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
* 21/7/15 - 1411404
*           Account number not displayed in enquiry,
*
* 21/7/15  1415231
*          CASE OTHERWISE changed to CASE 1
*
*---------------------------------------------------------------------------------------------------------------
INITIALISE:
* Open files

    FN.DX.ACCT.ENTRY = 'F.DX.ACCT.ENTRIES'
    F.DX.ACCT.ENTRY = ''
    EB.DataAccess.Opf(FN.DX.ACCT.ENTRY,F.DX.ACCT.ENTRY)

    FN.RE.ENT.DTL = 'F.RE.SPEC.ENTRY.DETAIL'
    F.RE.ENT.DTL = ''
    EB.DataAccess.Opf(FN.RE.ENT.DTL,F.RE.ENT.DTL)

* Initialisation of variables
    NEW.LIST = ''
    SEL.LIST = ''
    IN.RECORD = ''
    FORM.LIST = ''
    REC.CNT = 0
    SUB.DIV.CODE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSubDivisionCode) ; * Sub division code for company
    START.DATE = ''
    SPEC.ENT.IDS = ''
* Amount fields for which the entries had to be displayed in opposite sign
    AMT.LIST = AC.EntryCreation.StmtEntry.SteAmountLcy:@VM:AC.EntryCreation.StmtEntry.SteAmountFcy:@VM:AC.EntryCreation.StmtEntry.SteOriginalAmount:@VM:AC.EntryCreation.StmtEntry.SteOrigAmountLcy
    AMT.LIST := @VM:AC.EntryCreation.StmtEntry.SteAmountDealCcy:@VM:AC.EntryCreation.StmtEntry.SteRepaymentAmt:@VM:AC.EntryCreation.StmtEntry.SteOutstandingBal:@VM:AC.EntryCreation.StmtEntry.SteExpSplitAmt
* Select DX.ACCT.ENTRIES record
    LOCATE 'TRANS.REF' IN EB.Reports.getDFields()<1> SETTING POS1 THEN
        SEL.ID = EB.Reports.getDRangeAndValue()<POS1>
    END
    SEL.CMD = 'SELECT ':FN.DX.ACCT.ENTRY:' WITH @ID LIKE ':SEL.ID:'...'
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.RECS,SEL.ERR)
    GOSUB CHECK.TRADE.IN.RNAU ;* check whether the record selected is in RANU status in DX.TRADE

* Build an array with all the entries from both primary and secondary side
    IF REC.CNT THEN ; * When there are any records to process for the given transaction then go ahead else return
        FOR I = 1 TO REC.CNT
            R.DX.ACCT.REC = ''
            R.DX.ACCT.REC = DX.Accounting.AcctEntries.Read(NEW.LIST<I>, DX.ACCT.ERR)
* Before incorporation : CALL F.READ(FN.DX.ACCT.ENTRIES,NEW.LIST<I>,R.DX.ACCT.REC,F.DX.ACCT.ENTRIES,DX.ACCT.ERR)
            FORM.LIST = R.DX.ACCT.REC<DX.Accounting.AcctEntries.ActEntries>
            MV.COUNT = DCOUNT(FORM.LIST,@VM) ; * Get the number of entries stores under each DX.ACCT.ENTRIES
            FOR J = 1 TO MV.COUNT
                ACC.NO = FORM.LIST<1,J,1> ; * Get the account number
                AC.AccountOpening.IntAcc(ACC.NO,INT.FLG) ;* Check the account is internal or customer account
                IF INT.FLG THEN ; * If internal account then
                    FORM.LIST<1,J,1> = ACC.NO:SUB.DIV.CODE ; * Add sub division code
                END
            NEXT J
* array is to be build such that the each entries are delimited by field marker
            CONVERT @VM TO @FM IN FORM.LIST
            CONVERT @SM TO @VM IN FORM.LIST
            IN.RECORD<-1> = FORM.LIST
        NEXT I

        GOSUB PROCESS.SPEC.ENTRIES ;* process for picking spec entries

        GOSUB PROCESS
    END

RETURN
*---------------------------------------------------------------------------------------------------------------
CHECK.TRADE.IN.RNAU:
* Check whether the record selected is in RANU status in DX.TRADE
* if not then the processing should be skipped
    FOR J=1 TO NO.OF.RECS
        TRD.ID = FIELDS(SEL.LIST<J>,'*',1,1)
        TRD.ERR= ''
        R.DX.TRD.REC = ''
        R.DX.TRD.REC = DX.Trade.Trade.ReadNau(TRD.ID, TRD.ERR)
* Before incorporation : CALL F.READ(FN.DX.TRADE$NAU,TRD.ID,R.DX.TRD.REC,F.DX.TRADE$NAU,TRD.ERR)
        IF R.DX.TRD.REC<DX.Trade.Trade.TraRecordStatus>[1,3] = 'RNA' THEN
            NEW.LIST<-1> = SEL.LIST<J>
        END
    NEXT J
    REC.CNT = DCOUNT(NEW.LIST,@FM)

RETURN
*---------------------------------------------------------------------------------------------------------------
PROCESS:
* Build an final array whether the same field values of mutiple entries are delimited by value marker
* and different fields by field marker

    EB.Reports.setSmCount(1);* Reinitialised to 1 to avoid unwanted lines.
    FMC = DCOUNT(IN.RECORD,@FM)
    OUT.RECORD = ""
* the array is to be build with values found in DX.ACCT.ENTRIES build on the STMT.ENTRY format
* hence the values are positioned accordingly
    FOR YI = 1 TO FMC
        FOR FLD.ID = AC.EntryCreation.StmtEntry.SteAccountNumber TO AC.EntryCreation.StmtEntry.SteAaItemRef
            BEGIN CASE
                CASE (FLD.ID MATCHES AMT.LIST)
* As the enquiry is to list the RNAU entries the sign is to be changed
* for the amount read from DX.ACCT.ENTRIES
                    OUT.RECORD<FLD.ID,YI> = NEG(IN.RECORD<YI,FLD.ID>)
                CASE 1
                    OUT.RECORD<FLD.ID,YI> = IN.RECORD<YI,FLD.ID>
            END CASE
        NEXT FLD.ID
    NEXT YI
* Final array holding the entries
    RETURN.ARR<-1> = OUT.RECORD
    CONVERT @FM TO "#" IN RETURN.ARR

RETURN
*---------------------------------------------------------------------------------------------------------------
PROCESS.SPEC.ENTRIES:

    ID.LIST = ""
    THE.LIST = dasEbContractBalancesIdLk          ;* Select ECB records with DX.TRADE id
    THE.ARGS = TRD.ID:EB.DataAccess.dasWildcard       ;* Append ... for TXN.REF

    EB.DataAccess.Das("EB.CONTRACT.BALANCES",THE.LIST,THE.ARGS,'')   ;* Execute select
    ID.LIST = THE.LIST        ;* SELECTED LIST OF IDS

    GOSUB GET.SPECIAL.ENTRIES
RETURN
*--------------------------------------------------------------------------------------
GET.SPECIAL.ENTRIES:
*---------------------------------------------------------------------------------------
    ID.CNT = DCOUNT(ID.LIST,@FM)
    FOR I.CNT = 1 TO ID.CNT
        CONTRACT.ID = ID.LIST<I.CNT>
        ENTRY.LIST = '';ENTRY.TYPE = 'R'
        AC.API.EbGetContractEntries(CONTRACT.ID,ENTRY.TYPE,START.DATE,END.DATE,ENTRY.LIST)
        IF ENTRY.LIST THEN
            SPEC.ENT.IDS = LOWER(ENTRY.LIST)
        END
    NEXT I.CNT
* entry id's returned will have company mnemonic, so fetch the entry id alone amd read the entry record.
    IF SPEC.ENT.IDS THEN
        NO.OF.SPECS = DCOUNT(SPEC.ENT.IDS,@VM)
        FOR SPEC.CNT = 1 TO NO.OF.SPECS
            SPEC.ID  = FIELD(SPEC.ENT.IDS<1,SPEC.CNT>,'/',1)
            CO.MNE   =   FIELD(SPEC.ENT.IDS<1,SPEC.CNT>,'/',2)
            GOSUB GET.CONSOL.SPEC.ENTRY
        NEXT SPEC.CNT
    END
RETURN
*-------------------------------------------------------------------------------------
GET.CONSOL.SPEC.ENTRY:
*-------------------------------------------------------------------------------------
*Read the accounting entry
    R.RE.DTL.ERR = ''
    R.SPEC.REC = ''

    R.SPEC.REC = AC.EntryCreation.ReConsolSpecEntry.Read(SPEC.ID, R.RE.ERR)
* Before incorporation : CALL F.READ(tmp.FN.RE.CONSOL.SPEC.ENTRY,SPEC.ID,R.SPEC.REC,tmp.F.RE.CONSOL.SPEC.ENTRY,R.RE.ERR)

    IF R.RE.ERR THEN
        EB.DataAccess.FRead(FN.RE.ENT.DTL,SPEC.ID,R.SPEC.REC,F.RE.ENT.DTL,R.RE.DTL.ERR)
    END
    TXN.CODE = 'REV'
    GOSUB GET.TXN.CODE.DESC
    IN.RECORD<-1>=LOWER(R.SPEC.REC)

RETURN

*-------------------------------------------------------------------
GET.TXN.CODE.DESC:
*--------------------------------------------------------------------
* Get the discription from RE.TXN.CODES

    ENT.TXN.REC = ""
    ENT.TXN.REC = AC.EntryCreation.ReTxnCode.Read(TXN.CODE, TXN.ER)
* Before incorporation : CALL F.READ(FN.RE.TXN.CODE,TXN.CODE,ENT.TXN.REC,F.RE.TXN.CODE,TXN.ER)
    R.SPEC.REC<1> = ENT.TXN.REC<AC.EntryCreation.ReTxnCode.ReTxnShortDesc>

RETURN
*--------------------------------------------------------------------
END
