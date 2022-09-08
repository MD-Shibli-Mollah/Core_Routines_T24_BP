* @ValidationCode : MjoxOTg0NjcyMzU5OkNwMTI1MjoxNjA0NTkzNzIyNjAxOnNpdmFjaGVsbGFwcGE6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkxOS0wNDU5Ojg3Ojgx
* @ValidationInfo : Timestamp         : 05 Nov 2020 21:58:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 81/87 (93.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CQ.Channels
SUBROUTINE V.CHK.REC.TC.STOCK.ENTRY
*-----------------------------------------------------------------------------
*Attched to PW.PROCESS to create stock entry for accounts for which cheques are issued
*for first time or stock balance has expired
*-----------------------------------------------------------------------------
* Modification History :
* 13/11/2018  - Enhancement 2293366 / Task 2868666
*               2293366: User Journey - Phase 3 - Cheques
*
* 01/10/19 - Defect - 3367195 / Task - 3387171
*          - CQ product installation check.
*-----------------------------------------------------------------------------
    $USING EB.Foundation
    $USING EB.SystemTables
    $USING EB.Interface
    $USING CQ.ChqStockControl
    $USING EB.DataAccess
    $USING PW.Foundation
    $USING EB.Security
    $USING ST.CompanyCreation
    $USING CQ.ChqConfig
    $USING CQ.ChqSubmit
    $USING EB.API

    GOSUB INITIALISE
    IF NOT(CQInstalled) THEN
        RETURN
    END
    GOSUB PROCESS
RETURN

INITIALISE:
* Initialise the required variables
    tmp.PW$ACTIVITY.TXN.ID = PW.Foundation.getActivityTxnId()                   ;* Get Activity trabsaction ID
    R.PAT = PW.Foundation.ActivityTxn.Read(tmp.PW$ACTIVITY.TXN.ID, PAT.ERR)
    PW.PROCESS.ID = R.PAT<PW.Foundation.ActivityTxn.ActTxnProcess>              ;* Get the current process id to map the details
    R.PW.PROCESS = PW.Foundation.Process.Read(PW.PROCESS.ID, Error)
    CHQ.BOOK.ID = R.PW.PROCESS<PW.Foundation.Process.ProcParentCtxId>           ;*Read ChequeIssue record ID from field ParentCtxId
    CHQ.TYPE = FIELDS(CHQ.BOOK.ID,'.',1)
    ACCOUNT=FIELDS(CHQ.BOOK.ID,'.',2)
    COMPANY.ID = EB.SystemTables.getIdCompany()                                 ;* Read Company ID
    R.COMPANY = ST.CompanyCreation.Company.Read(COMPANY.ID, Error)
    LOCAL.COUNTRY = R.COMPANY<ST.CompanyCreation.Company.EbComLocalCountry>     ;*Read Local country
    STOCK.PARAM.ID = 'CHQ'
    USER.ID = EB.SystemTables.getOperator()                                     ;* Read user
    R.USER.REC = EB.Security.User.Read(USER.ID, USER.ERR)
    DEPT.CODE = R.USER.REC<EB.Security.User.UseDepartmentCode>                  ;* Getting the dept code for the current user.
    START.NO = ''
    SERIES=''
    CHQ.SER.ID = ''
    
    CQInstalled = ''
    EB.API.ProductIsInCompany('CQ', CQInstalled)   ;* Checks if CQ product is installed
RETURN

PROCESS:
* Creation of the stock entry for the cheque type
* Get the the details of stock register to input
*    STK.PARAM.REC = CQ.ChqStockControl.StockParameter.CacheRead(STOCK.PARAM.ID,ERR)     ;* Read Stock Paramater record and extract stock reg ID
    ST.CompanyCreation.EbReadParameter('F.STOCK.PARAMETER', '', '', STK.PARAM.REC, STOCK.PARAM.ID,'', ERR) ;* Read Stock Paramater record and extract stock reg ID
    REG.ID = STK.PARAM.REC<CQ.ChqStockControl.StockParameter.SpStockRegId>
    FIRST.PRT.REG.ID  = FIELD(REG.ID,'-',1)
    SECOND.PRT.REG.ID = FIELD(REG.ID,'-',2)
    LOCAL.TABLE =  STK.PARAM.REC<CQ.ChqStockControl.StockParameter.SpLocalTableNo>
    CURR.APPL = FIRST.PRT.REG.ID
    GOSUB VALIDATE.REG.ID
    STOCK.REG.ID =STOCK.PARAM.ID:'.':TMP.STK.REG.ID
    IF SECOND.PRT.REG.ID THEN                      ;* Form Stock register ID
        CURR.APPL = SECOND.PRT.REG.ID
        GOSUB VALIDATE.REG.ID
        STOCK.REG.ID:='-':TMP.STK.REG.ID
    END
    GOSUB CHECK.STOCK.STARTNO
*Input details
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntToRegister, STOCK.REG.ID)
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntChequeType, CHQ.TYPE)
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntStockAcctNo, ACCOUNT)
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntStockSeries, LOCAL.COUNTRY)
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntStockStartNo, START.NO)
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntStockQuantity, '1000')
    EB.SystemTables.setRNew(CQ.ChqStockControl.StockEntry.StoEntNotes, 'New stock entry for this cheque type')
RETURN

VALIDATE.REG.ID:
    
    BEGIN CASE
        CASE ((CURR.APPL EQ 'COMPANY.CODE') OR (CURR.APPL EQ 'CO.CODE')) AND NOT(LOCAL.TABLE)
            TMP.STK.REG.ID = COMPANY.ID
        CASE ((CURR.APPL EQ 'DEPARTMENT.CODE') OR (CURR.APPL EQ 'DEPT.CODE')) AND NOT(LOCAL.TABLE)
            TMP.STK.REG.ID = DEPT.CODE
    END CASE

RETURN

CHECK.STOCK.STARTNO:
* Get the start series no. for the cheque type from the stock register
    R.STOCK.REG = CQ.ChqStockControl.StockRegister.Read(STOCK.REG.ID, Error)
    STOCK.BAL =  R.STOCK.REG<CQ.ChqStockControl.StockRegister.StoRegSeriesBal>
    SERIES.ID.LIST = R.STOCK.REG<CQ.ChqStockControl.StockRegister.StoRegSeriesId>
    SERIES.NO.LIST = R.STOCK.REG<CQ.ChqStockControl.StockRegister.StoRegSeriesNo>
    CONVERT @VM TO @FM IN SERIES.ID.LIST
    CONVERT @VM TO @FM IN SERIES.NO.LIST
    CONVERT @SM TO @VM IN SERIES.NO.LIST
    CONVERT @VM TO @FM IN STOCK.BAL
*Read default issue no of cheques from cheque type
    R.CHEQUE.TYPE = CQ.ChqConfig.ChequeType.CacheRead(CHQ.TYPE, Error)
    DEFAULT.ISSUE.NO = R.CHEQUE.TYPE<CQ.ChqConfig.ChequeType.ChequeTypeDefaultIssueNo>
* Get the series and starting number
    CHQ.SER.ID = CHQ.TYPE:"*":LOCAL.COUNTRY:"*":ACCOUNT
    LOCATE CHQ.SER.ID IN SERIES.ID.LIST SETTING SER.CNT THEN
        IF STOCK.BAL<SER.CNT,1> EQ 0 THEN
            GOSUB START.NO.FOR.EXPIRED.STOCK
            EXIT
        END
        ELSE
            IF STOCK.BAL<SER.CNT,1> LT DEFAULT.ISSUE.NO THEN
                START.NO = FIELDS(SERIES.NO.LIST<SER.CNT,1>,'-',2) + 1
                EXIT
            END
        END
    END
* IF CHQ.TYPE entry is not present in STOCK.REGISTER then default the starting scheque no. to 100
    IF START.NO EQ '' OR START.NO EQ 0 THEN
        START.NO = '100'
    END
RETURN
START.NO.FOR.EXPIRED.STOCK:
    CHQ.REG.ID= CHQ.TYPE:'.':ACCOUNT
    R.CHQ.REG = CQ.ChqSubmit.ChequeRegister.Read(CHQ.REG.ID, Error)
    CHQ.NO = R.CHQ.REG<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>
    LAST.CHQ= FIELDS(CHQ.NO,'-',2)
    START.NO=LAST.CHQ + 1
RETURN
END
