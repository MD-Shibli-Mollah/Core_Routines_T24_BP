* @ValidationCode : Mjo0NTQ1OTE1NTk6Q3AxMjUyOjE2MDQ1OTM3MjIyMTY6c2l2YWNoZWxsYXBwYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE5LTA0NTk6MTA2Ojgx
* @ValidationInfo : Timestamp         : 05 Nov 2020 21:58:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 81/106 (76.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CQ.Channels
SUBROUTINE V.VAL.TC.CHEQUE.ISSUE
*-----------------------------------------------------------------------------
* This routine used to trigger the cheque issue flow, to be attached to the
* CHEQUE.ISSUE,TC version as Check routine
*-----------------------------------------------------------------------------
* Modification History :
* 13/11/2018  - Enhancement 2293366 / Task 2868666
*               2293366: User Journey - Phase 3 - Cheques
*
* 01/10/19 - Defect - 3367195 / Task - 3387171
*          - CQ product installation check.
*-----------------------------------------------------------------------------
    $USING CQ.ChqIssue
    $USING EB.SystemTables
    $USING CQ.ChqStockControl
    $USING CQ.ChqSubmit
    $USING EB.DataAccess
    $USING EB.Security
    $USING CQ.ChqConfig
    $USING EB.API
    $USING ST.CompanyCreation
    $INSERT I_DAS.STOCK.REGISTER
    
    GOSUB INITIALISE
    IF NOT(CQInstalled) THEN
        RETURN
    END
    GOSUB PROCESS
RETURN

INITIALISE:
*---------
    STOCK.PARAMETER.ID = ''
    STOCK.ID = ''
    CHQ.ID = EB.SystemTables.getIdNew()
    ACCOUNT.ID = FIELDS(CHQ.ID,'.',2)
    CHQ.TYPE = FIELDS(CHQ.ID,'.',1)
    TODAY.DATE=EB.SystemTables.getToday()
    COMPANY.ID = ''
    DEPT.CODE = ''
    STOCK.ARG=''
    LOC.TAB.NO=''
    DEFAULT.ISSUE.NO=''
    SERIES.ID=''
    STOCK.BAL=''
    SERIES.ID.LIST= ''
    SERIES.NO.LIST= ''
    
    CQInstalled = ''
    EB.API.ProductIsInCompany('CQ', CQInstalled)   ;* Checks if CQ product is installed
    
RETURN

PROCESS:
*------
* Read Stock Parameter table to find the Stock register ID format.
    GOSUB READ.STOCK.PARAMETER
* Get the series for the cheque type from the stock register
    STOCK.REG.ID =  dasStockRegisterIdLike
    THE.ARGS = 'CHQ.':STOCK.ARG:'...'
    EB.DataAccess.Das("STOCK.REGISTER",STOCK.REG.ID,THE.ARGS,"")
    IF STOCK.REG.ID THEN
        R.STOCK.REG = CQ.ChqStockControl.StockRegister.Read(STOCK.REG.ID, Error)        ;*Read Stock Register record
        STOCK.BAL =  R.STOCK.REG<CQ.ChqStockControl.StockRegister.StoRegSeriesBal>      ;*Extract Stock Balance array
        SERIES.ID.LIST = R.STOCK.REG<CQ.ChqStockControl.StockRegister.StoRegSeriesId>   ;*Extract Series ID array
        SERIES.NO.LIST = R.STOCK.REG<CQ.ChqStockControl.StockRegister.StoRegSeriesNo>   ;*Extract Series NO. Array
        CONVERT @VM TO @FM IN SERIES.ID.LIST
        CONVERT @VM TO @FM IN SERIES.NO.LIST
        CONVERT @SM TO @VM IN SERIES.NO.LIST
        CONVERT @VM TO @FM IN STOCK.BAL
*Read default issue no of cheques from cheque type
        R.CHEQUE.TYPE = CQ.ChqConfig.ChequeType.CacheRead(CHQ.TYPE, Error)                  ;*Read Cheque Type to find default issue no.
        DEFAULT.ISSUE.NO = R.CHEQUE.TYPE<CQ.ChqConfig.ChequeType.ChequeTypeDefaultIssueNo>
* Get the series and starting number
        LOOP
            REMOVE SERIES FROM SERIES.ID.LIST SETTING SER.POS
        WHILE SERIES:SER.POS
            SER.CNT+=1
            SER.CHQ.TYPE = FIELDS(SERIES,'*',1)
            SER.CHQ.ACCNO = FIELDS(SERIES,'*',3)
            SER.BALANCE = STOCK.BAL<SER.CNT,1>
*; check for the cheque type, account and stock balance to avaoid any stock quantity errors
            IF CHQ.TYPE MATCHES SER.CHQ.TYPE AND ACCOUNT.ID MATCHES SER.CHQ.ACCNO AND SER.BALANCE GE DEFAULT.ISSUE.NO THEN
                SERIES.ID = SERIES
                SERIES.NO = SERIES.NO.LIST<SER.CNT,1>
                GOSUB GET.CHEQUE.START.NO
                EXIT
            END
        REPEAT
;* If series ID is found then default the Cheque Issue record fileds
        IF SERIES.ID THEN
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus,'90')
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued,DEFAULT.ISSUE.NO)
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg,STOCK.REG.ID)
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsSeriesId,SERIES.ID)
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart,START.NO)
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNotes,'Cheque book issued')
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate,TODAY.DATE)
        END ELSE
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNotes,'Request received')
        END
    END
RETURN
*------------------------------------------------------------------------------------------------
*** <region name= READ.STOCK.PARAMETER>
*** <desc> Read Stock paramaeter record and based on the stock Id, form Id of Stock register</desc>
READ.STOCK.PARAMETER:
    STOCK.PARAMETER.ID = "CHQ";
*R.STOCK.PARAMETER = CQ.ChqStockControl.StockParameter.CacheRead(STOCK.PARAMETER.ID, Error)
    ST.CompanyCreation.EbReadParameter('F.STOCK.PARAMETER', '', '', R.STOCK.PARAMETER, STOCK.PARAMETER.ID,'', ERR) ;* Read Stock Paramater record and extract stock reg ID
    STOCK.ID = R.STOCK.PARAMETER<CQ.ChqStockControl.StockParameter.SpStockRegId>
    BEGIN CASE
        CASE STOCK.ID EQ "COMPANY.CODE"
            GOSUB GET.COMPANY.CODE
            STOCK.ARG = COMPANY.ID
        CASE STOCK.ID EQ "DEPARTMENT.CODE"
            GOSUB GET.DEPT.CODE
            STOCK.ARG = DEPT.CODE
        CASE STOCK.ID EQ "LOCAL.TABLE"
            GOSUB GET.LOCAL.TABLE
            STOCK.ARG = LOC.TAB.NO
        CASE STOCK.ID EQ "CO.CODE-DEPT.CODE"
            GOSUB GET.COMPANY.CODE
            GOSUB GET.DEPT.CODE
            STOCK.ARG = COMPANY.ID:"-"DEPT.CODE
        CASE STOCK.ID EQ "DEPT.CODE-LOCAL.TAB"
            GOSUB GET.DEPT.CODE
            GOSUB GET.LOCAL.TABLE
            STOCK.ARG = DEPT.CODE:"-"LOC.TAB.NO
        CASE STOCK.ID EQ "CO.CODE-LOCAL.TAB"
            GOSUB GET.COMPANY.CODE
            GOSUB GET.LOCAL.TABLE
            STOCK.ARG = COMPANY.ID:"-"LOC.TAB.NO
    END CASE
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------
*** <region name= GET.COMPANY.CODE>
*** <desc>Extract company code </desc>
GET.COMPANY.CODE:
    COMPANY.ID = EB.SystemTables.getIdCompany()
RETURN
*** </region>
*----------------------------------------------------------------------------------------------------
*** <region name= GET.DEPT.CODE>
*** <desc>Extract department code</desc>
GET.DEPT.CODE:
    DEPT.CODE = EB.SystemTables.getRUser()<EB.Security.User.UseDeptCode>
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------
*** <region name= GET.LOCAL.TABLE>
*** <desc>Extract local table name </desc>
GET.LOCAL.TABLE:
    LOC.TAB.NO = R.STOCK.PARAMETER<CQ.ChqStockControl.StockParameter.SpLocalTableNo>
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------
*** <region name= GET.CHEQUE.START.NO>
*** <desc> default new cheque start number after reading the cheque register record.
*Also check if the total cheques issued is more than series balance, then default left over balance to total cheques isssud. </desc>
GET.CHEQUE.START.NO:
    CHQ.REG.ID= CHQ.TYPE:'.':ACCOUNT.ID
    R.CHQ.REG = CQ.ChqSubmit.ChequeRegister.Read(CHQ.REG.ID, Error)
    CHQ.NO = R.CHQ.REG<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>
    LAST.CHQ= FIELDS(CHQ.NO,'-',2)
    START.NO=LAST.CHQ + 1
RETURN
*** </region>

END
