* @ValidationCode : MjotOTIwMDk3MDY6Q3AxMjUyOjE1ODM5MzA4MzkyNTg6cnZhcmFkaGFyYWphbjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6MTA5OjEwNg==
* @ValidationInfo : Timestamp         : 11 Mar 2020 18:17:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 106/109 (97.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-75</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE EOD.CHEQUE.REORDER.LOAD
* Routine to load the common variables for use in the record routine for
* the batch job EOD.CHEQUE.REORDER. Called from EOD.CHEQUE.REORDER.CONTROL

*CHANGE CONTROL
***************
*
* 14/02/02 - GLOBUS_EN_10000353
*            Enhancement for stock control.
*            Initialising the variables used for the enhancement.
*
* 15/04/02 - GLOBUS_BG_100000887
*            Open file CHEQUES.PRESENTED for STOCK application.
*
* 10/01/03 - GLOBUS_BG_100003164
*            Read the EOD.CHQ.REORDER.LIST and store CT.ID.LIST and
*            CI.ID.LIST
*
* 01/07/09 - CI_10064156
*            Remove read on EOD.CHQ.LIST with CHEQUE.TYPE as its no longer
*            used.
*
* 30/06/10 - D-60989 / T-63037
*            Open CQ.PARAMETER
*
* 31/01/11 - 120329
*            Banker's Draft Management.
*            Opened CHEQUE.REGISTER.SUPPLEMENT file.
*
* 06/03/13 - Task 612475
*            Remove read on EOD.CHQ.LIST with CHEQUE.ISSUE as its no longer
*            used.
*
* 22/05/14 - Defect 983465/ Task 1005513
*            OPF done for CHEQUES.PRESENTED removed.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
*18/09/15 - Enhancement 1265068 / Task 1475953
*         - Routine Incorporated
*
* 1/5/2017 - Enhancement 1765879 / Task 2102715
*            Remove dependency of code in ST products
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Check CG module availability for charges
*
***********************************************************************
    $USING CQ.ChqSubmit
    $USING CQ.ChqIssue
    $USING CQ.ChqConfig
    $USING CQ.ChqFees
    $USING AC.AccountOpening
    $USING EB.API
    $USING ST.Customer
    $USING EB.Security
    $USING AC.EntryCreation
    $USING EB.DataAccess


    acInstalled = @FALSE
    EB.API.ProductIsInCompany('AC', acInstalled)
*     Initialise file variables

    FN.CT.LOC = 'F.CHEQUE.TYPE' ; FV.CT.LOC = ''
    FN.CR.LOC = 'F.CHEQUE.REGISTER' ; FV.CR.LOC =''
    FN.CI.LOC = 'F.CHEQUE.ISSUE' ; FV.CI.LOC = ''
    FN.CC.LOC = 'F.CHEQUE.CHARGE' ; FV.CC.LOC = ''
    FN.CS.LOC = 'F.CHEQUE.STATUS' ; FV.CS.LOC = ''
    FN.AC.LOC = 'F.ACCOUNT' ; FV.AC.LOC = ''
    FN.CIA.LOC = 'F.CHEQUE.ISSUE.ACCOUNT' ; FV.CIA.LOC = ''
    FN.CUR.LOC = 'F.CURRENCY' ; FV.CUR.LOC = ''

*   FN.CP = 'F.CHEQUES.PRESENTED' ; FV.CP = ''    ;* GLOBUS_BG_100000887
    FN.EOD.CHQ.LIST.LOC = 'F.EOD.CHQ.REORDER.LIST'    ;* ; * BG_10003164 S
    FV.EOD.CHQ.LIST.LOC = ''      ;* BG_10003164 E

    FN.CQP = 'F.CQ.PARAMETER' ;* parameter file for cheque processings
    F.CQP = ''

    DIM CHQ.REC(CQ.ChqIssue.ChequeIssue.ChequeIsAuditDateTime)
    MAT CHQ.REC = ''          ;* Cheque.Issue record (Matparsed)
*     Open Files

    EB.DataAccess.Opf(FN.CT.LOC, FV.CT.LOC)
    CQ.ChqSubmit.setFnCt(FN.CT.LOC)
    CQ.ChqSubmit.setFvCt(FV.CT.LOC)

    EB.DataAccess.Opf(FN.CR.LOC, FV.CR.LOC)
    CQ.ChqSubmit.setFnCr(FN.CR.LOC)
    CQ.ChqSubmit.setFvCr(FV.CR.LOC)

    EB.DataAccess.Opf(FN.CI.LOC, FV.CI.LOC)
    CQ.ChqSubmit.setFnCi(FN.CI.LOC)
    CQ.ChqSubmit.setFvCi(FV.CI.LOC)

    EB.DataAccess.Opf(FN.CC.LOC, FV.CC.LOC)
    CQ.ChqSubmit.setFnCc(FN.CC.LOC)
    CQ.ChqSubmit.setFvCc(FV.CC.LOC)

    EB.DataAccess.Opf(FN.CS.LOC, FV.CS.LOC)
    CQ.ChqSubmit.setFnCs(FN.CS.LOC)
    CQ.ChqSubmit.setFvCs(FV.CS.LOC)

    IF acInstalled THEN
        EB.DataAccess.Opf(FN.AC.LOC, FV.AC.LOC)
        CQ.ChqSubmit.setFnAc(FN.AC.LOC)
        CQ.ChqSubmit.setFvAc(FV.AC.LOC)
    END

    EB.DataAccess.Opf(FN.CIA.LOC, FV.CIA.LOC)
    CQ.ChqSubmit.setFnCia(FN.CIA.LOC)
    CQ.ChqSubmit.setFvCia(FV.CIA.LOC)

    EB.DataAccess.Opf(FN.CUR.LOC, FV.CUR.LOC)
    CQ.ChqSubmit.setFnCur(FN.CUR.LOC)
    CQ.ChqSubmit.setFvCur(FV.CUR.LOC)

*   CALL OPF(FN.CP,FV.CP)     ;* GLOBUS_BG_100000887

    EB.DataAccess.Opf(FN.EOD.CHQ.LIST.LOC,FV.EOD.CHQ.LIST.LOC)     ;* BG_100003164 S/E
    CQ.ChqSubmit.setFnEodChqList(FN.EOD.CHQ.LIST.LOC)
    CQ.ChqSubmit.setFvEodChqList(FV.EOD.CHQ.LIST.LOC)

    FN.CHEQ.REG.SUPP.LOC = "F.CHEQUE.REGISTER.SUPPLEMENT"
    F.CHEQ.REG.SUPP.LOC = ""
    EB.DataAccess.Opf(FN.CHEQ.REG.SUPP.LOC,F.CHEQ.REG.SUPP.LOC)
    CQ.ChqSubmit.setFnCheqRegSupp(FN.CHEQ.REG.SUPP.LOC)
    CQ.ChqSubmit.setFCheqRegSupp(F.CHEQ.REG.SUPP.LOC)

*     Variable used in this routine

    CQ.ChqSubmit.setSelCtCmd('');* Select statement to fetch record from Cheque.Type
    CQ.ChqSubmit.setCtIdList('');* List of Cheque.Type IDs obtained after executing Sel.Ct.Cmd in Eb.Readlist
    CQ.ChqSubmit.setCtIdDesc('');* Description of Cheque.Type for Ct.Id.List
    CQ.ChqSubmit.setNoOfCtRec(0);* Total number of Cheque.Type records fetched from executing Sel.Ct.Cmd
    CQ.ChqSubmit.setCtErr('');* Error message captured on executing Sel.Ct.Cmd, if any
    CQ.ChqSubmit.setCtMinHolding('');* Min.Holding value from Cheque.Type
    CQ.ChqSubmit.setChqTypId('');* Cheque.Type record ID
    CQ.ChqSubmit.setChqTypRec('');* Cheque.Type record

    CQ.ChqSubmit.setSelCrCmd('');* Select statement to fetch record from Cheque.Register
    CQ.ChqSubmit.setCrIdList('');* List of Cheque.Register IDs obtained after executing Sel.Cr.Cmd in Eb.Readlist
    CQ.ChqSubmit.setNoOfCrRec(0);* Total number of records fetched from executing Sel.Cr.Cmd
    CQ.ChqSubmit.setCrErr('');* Error message captured on executing Sel.Cr.Cmd, if any
    CHQ.REG.ID = '' ;* Cheque.Register ID
    CQ.ChqSubmit.setChqRegRec('');* Cheque.Register Record

    CQ.ChqSubmit.setSelCiCmd('');* Select statement to fetch record ids from Cheque.Issue
    CQ.ChqSubmit.setCiIdList('');* List of Cheque.Issue IDs obtained after executing Sel.Ci.Cmd in Eb.Readlist
    CQ.ChqSubmit.setNoOfCiRec(0);* Total number of Cheque.Type records fetched from executing Sel.Ci.Cmd
    CQ.ChqSubmit.setCiErr('');* Error message captured on executing Sel.Ci.Cmd, if any


    CQ.ChqSubmit.setCcIdList('');* Cheque.Charge ID
    CQ.ChqSubmit.setCcIdDesc('');* Cheque.Charge Charges for Cc.Id.List
    CQ.ChqSubmit.setChqChgRec('');* Cheque.Charge record
    CQ.ChqSubmit.setCcErr('');* Cheque.Charge Read Err

    CQ.ChqSubmit.setChqIsAcRec('');* Cheque.Issue.Account Record

    CQ.ChqSubmit.setChqStsRec('');* Cheque.Status record
    CQ.ChqSubmit.setCsErr('');* Cheque.Status read error

    CQ.ChqSubmit.setChargeArray('');* Charge details needed for delivery

    CQ.ChqSubmit.setYrTwoAccount('');* Account Record
    CQ.ChqSubmit.setYrAccount('');* Charge Account Record
    CQ.ChqSubmit.setCurRec('');* Currency Record
    CQ.ChqSubmit.setCurErr('');* Currency Record read error
    CQ.ChqSubmit.setCcyCurMkt('');* Currency Record Ccy Mkt list
    CQ.ChqSubmit.setCcyMkt('');* Value of currency market in Cheque.Charge
    CQ.ChqSubmit.setRateType('');* Value of Rate.Type in Cheque.Charge

** GLOBUS_EN_10000353  -S

    CQ.ChqSubmit.setAutoReorderTyp('')
    CQ.ChqSubmit.setChqRegRec('')
    AUTO.CHQ.NO = ''
    NO.HELD = ''
    FOUND.FLAG = 0
    CNT = ''
    CHQ.PRE.REC = ''
    CHQ.TYPE = ''
    MIN.HOLD = ''
    CHQ.IS.REC = ''
    STS.ID = ''

    AUTO.CHQ.CNT = ''         ;* GLOBUS_BG_100000887
    I.CNT = ''      ;* GLOBUS_BG_100000887

** GLOBUS_EN_10000353 -E



*     Other temporary variables          -------------------------------------------------------------------------------
    CQ.ChqSubmit.setJCnt(0);* counter used to build Cheque.Issue select cmd
    CQ.ChqSubmit.setJsCnt(0);* Counter to loop thru'Cheque.Type
    CQ.ChqSubmit.setChequeAccId('');* Account # of Cheque.Issue ID, to write in Cheque.Issue.Account
    CQ.ChqSubmit.setNewId('');* New record id (Cheque.Issue)
    CQ.ChqSubmit.setNewSeq('');* Next sequence # for building New.ID
    CQ.ChqSubmit.setDt(''); CQ.ChqSubmit.setJX('');* used for date/time conversion
    CQ.ChqSubmit.setIssue('');* to issue or not to issue cheque customer.chq.is.restrict

    CQ.ChqSubmit.setCqParam('')
    C.ERR = ''
    CQ.PARAM.REC = ''
    CQ.PARAM.REC = CQ.ChqConfig.CqParameter.CacheRead('SYSTEM', C.ERR)         ;* Cache read to have IGNOR.CHQ.REG.UPD value
    CQ.ChqSubmit.setCqParam(CQ.PARAM.REC)

RETURN

END

