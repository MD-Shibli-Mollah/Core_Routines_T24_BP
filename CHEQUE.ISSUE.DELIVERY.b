* @ValidationCode : Mjo1MTE0MTgyOTM6Q3AxMjUyOjE1NjQ1NzE0NTYyMDk6c3JhdmlrdW1hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:40:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>125</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.DELIVERY(YCHARGE.ARRAY)
*------------------------------------------------------------------------------
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*------------------------------------------------------------------------------
    $USING ST.CompanyCreation
    $USING AC.AccountOpening
    $USING CQ.ChqConfig
    $USING EB.Delivery
    $USING EB.SystemTables
    $USING CQ.ChqIssue

    GOSUB INITIALISE
    GOSUB HANDOFF.PROCESS
    GOSUB CALL.HANDOFF
    GOSUB UPDATE.DE.REF

RETURN

INITIALISE:
*==========
*
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    CQ$CHEQUE.ACC.ID  = FIELD(ID.NEW.VAL,'.',2)

    R.ACCOUNT = ''
    ACC.ERR = ''
    CHEQ.ACC.ID = CQ$CHEQUE.ACC.ID
    R.ACCOUNT = AC.AccountOpening.Account.Read(CHEQ.ACC.ID, ACC.ERR)

    ACTIVITY.LIST = ''
    ADVICE.TYPE = ''
    ACTIVITY.DATE.INFO = ''
    SEND.NOTICE = ''
    PREVIEW.MODE = EB.SystemTables.getMessage()
    DELIVERY.REF = ''
    ERROR.MESSAGE = ''
    DE.REFERENCES = ''

    IF EB.SystemTables.getMessage() NE 'PREVIEW' THEN EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsActivity, '')

RETURN

HANDOFF.PROCESS:
*===============
    GOSUB ACTIVITY.INFO
    GOSUB HANDOFF.INFO

RETURN

ACTIVITY.INFO:
*=============
    ACTIVITY.LIST<1> = 'CQ-0900'
    IF EB.SystemTables.getMessage() NE 'PREVIEW' THEN EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsActivity, ACTIVITY.LIST<1>)

    ACTIVITY.LIST<4> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass)

    CHQ.STS = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
    CHEQ.STS.REC = ''
    STS.ERR = ''
    CHEQ.STS.REC = CQ.ChqConfig.ChequeStatus.Read(CHQ.STS, CHQ.STS.ERR)

    ACTIVITY.LIST<9> = CHEQ.STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsAppFormat>

RETURN

HANDOFF.INFO:
*============
    DIM HANDOFF(9)
    MAT HANDOFF = ''
    YNEW.REC = ''
    YOLD.REC = ''

    YNEW.REC = EB.SystemTables.getDynArrayFromRNew()
    YOLD.REC = EB.SystemTables.getDynArrayFromROld()
    HANDOFF(1) = YNEW.REC
    HANDOFF(2) = YOLD.REC
    HANDOFF(7) = YCHARGE.ARRAY

    GOSUB HEADER.INFO
    HANDOFF(8) = HEADER.REC

RETURN

HEADER.INFO:
*===========
    HEADER.REC = ''
    HEADER.REC<1> = EB.SystemTables.getIdCompany()
    HEADER.REC<2> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    HEADER.REC<5> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCurrency)    ; * check if available in "S" function
    HEADER.REC<6> = R.ACCOUNT<AC.AccountOpening.Account.DeptCode>
    HEADER.REC<7> = EB.SystemTables.getIdNew()
    THIS.CUSTOMER = R.ACCOUNT<AC.AccountOpening.Account.Customer>
    HEADER.REC<8> = THIS.CUSTOMER
    HEADER.REC<9> = EB.SystemTables.getTLanguage()<1>
    HEADER.REC<11> = EB.SystemTables.getToday()
    HEADER.REC<12> = ''

RETURN

CALL.HANDOFF:
*============
    EB.Delivery.Handoff(ACTIVITY.LIST, ADVICE.TYPE, ACTIVITY.DATE.INFO, SEND.NOTICE,MAT HANDOFF, PREVIEW.MODE, DELIVERY.REF, ERROR.MESSAGE)
    EB.SystemTables.setE(ERROR.MESSAGE)

RETURN

UPDATE.DE.REF:
*=============
    IF PREVIEW.MODE # 'PREVIEW' THEN
        DE.REF.LIST = DELIVERY.REF<1>
        DE.MAP.LIST = DELIVERY.REF<2>
        LOOP
            REF.ID = ''
            MAP.ID = ''
            REMOVE REF.ID FROM DE.REF.LIST SETTING FLG1
            REMOVE MAP.ID FROM DE.MAP.LIST SETTING FLG2
        WHILE REF.ID:MAP.ID:FLG1:FLG2 DO
            DE.REFERENCES<1,-1> = REF.ID:"-":MAP.ID
        REPEAT
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef, DE.REFERENCES)
    END

RETURN


END
