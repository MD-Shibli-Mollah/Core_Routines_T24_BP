* @ValidationCode : MjotMzQ4MTE3MzpDcDEyNTI6MTYxMjUyMjk2Nzc1MDppbmRodW1hdGhpczoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjIwMjAxMTI4LTA2MzA6NDIxOjEzNA==
* @ValidationInfo : Timestamp         : 05 Feb 2021 16:32:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 134/421 (31.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>3170</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.CROSSVAL
*----------------------------------------------------------------------------------------
*
* 30/03/99 - GB9900548
*            The application allows for issuing the same cheque numbers
*            to the same account again and again.
*            On reversal the cheque register record must not be removed
*            from the live file. Instead on every change performed
*            a history record must be written out always to maintain
*            a clear audit trail.
*
* 06/09/01 - GLOBUS_EN_10000101
*            Enhanced Cheque.Issue to collect charges at each Status
*            and link to Soft Delivery
*            Changed Cheque.Issue to standard template
*            Changed all values captured in ER to capture in E
*            - All the variables are set in I_CI.COMMON
*
*            New fields added to the template are
*            - Cheque.Status
*            - Chrg.Code
*            - Chrg.Amount
*            - Tax.Code
*            - Tax.Amt
*            - Waive.Charges
*            - Class.Type       : -   Link to Soft Delivery
*            - Message.Class    : -      -  do  -
*            - Activity         : -      -  do  -
*            - Delivery.Ref     : -      -  do  -
*
* 14/02/02 - GLOBUS_EN_10000353
*            Validation related to STOCK application.
*
* 18/03/02 - GLOBUS_BG_100000738
*            Bug fixes related to STOCK application
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 06/01/05 - BG_100007859
*            Performance improvement for payment stop.
*
* 17/05/05 - CI_10030290
*            Unable to amend local ref/ notes field while Cheque status is 90.
*
* 06/12/06 - BG_100012531
*            Problem with CHQ.NO.START field.
*
* 27/06/07 - CI_10051630
*            1)Error msg is thrown When CHG.CODE & CHG.AMOUNT field are inputted for the authorised record
*              of same status.
*            2)Error msg is thrown When any changes are made in some fields for Status 90 of the authorised record.
*            3)Error msg is thrown when some fields are inputted for Status other than 90.
*
* 30/11/07 - CI_10052699
*            CHEQUE.ISSUE takes more time to get committed due to some unnecessary processing.
*
* 25/02/09 - CI_10060948
*            Repeat field level validation should be done for CHEQUE.STATUS also
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 04/05/15 - Defect 1324389 / Task 1335104
*            Validation restricted to Charge Date is charge is waived.
*
* 14/08/15 - Enhancement 1265068 / Task 1387491
*           - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 21/12/19 - Defect 3501918 / Task 3502367
*          - Initialised variable tmp.AF to avoid Non-numeric value -- ZERO USED errors in TAFC.
*
* 07/01/2020 - Defect 3515833 / Task 3526388
*              Code changes done to retain commission/charge/tax code even its value is zero.
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG*-----------------------------------------------------------------------------------------
*
* 05/02/21 - Defect 4210897 / Task 4173321
*            Changes done to raise error only when the CHEQUE.STATUS is moved from 90 to a lower status.
*------------------------------------------------------------------------------------------------------------
    $USING CQ.ChqConfig
    $USING CQ.ChqStockControl
    $USING EB.ErrorProcessing
    $USING EB.API
    $USING EB.Template
    $USING CG.ChargeConfig
    $USING EB.Display
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING CQ.ChqIssue

    $INSERT I_DAS.CHEQUE.ISSUE          ;* CI_10056345

*-----------------------------------------------------------------------------------------
    GOSUB INITIALISE
*
    GOSUB REPEAT.CHECK.FIELDS
*
    GOSUB REAL.CROSSVAL
*
RETURN
*


*-----------------------------------------------------------------------------------------
REAL.CROSSVAL:
*-------------
* Real cross validation goes here....
*

* EN_10000101 -s
    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
*-----------------------------
*     Check if the value is changed
* CI_10030290 S
* CHEQUE.STATUS can be either blank / should be of higher status
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) = '' THEN
        EB.SystemTables.setEtext('ST.RTN.CHQ.STATUS.CANT.BLANK')
        EB.ErrorProcessing.StoreEndError()
    END ELSE
*Raise error only when the CHEQUE.STATUS is changed from 90(issued cheque) to a lower cheque status.
        IF (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)) AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90) AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) GT EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)) THEN
            EB.SystemTables.setEtext('ST.RTN.CHQ.STATUS.CHANGED.LOWER')
            EB.ErrorProcessing.StoreEndError()
        END
    END

    SAVE.AF = EB.SystemTables.getAf()
    C.COUNT = ''    ;* CI_10051630
    IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)) AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90) THEN         ;* CI_10051630
        FOR C.COUNT = CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus TO CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart
            IF EB.SystemTables.getRNew(C.COUNT) NE EB.SystemTables.getROld(C.COUNT) THEN
                EB.SystemTables.setAf(C.COUNT)
                EB.SystemTables.setEtext("ST-NO.CHANGE.ALLOWED")
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT C.COUNT
    END   ;* CI_10051630

    EB.SystemTables.setAf(SAVE.AF)

    SAVE.AF = EB.SystemTables.getAf()
    C.COUNT = ''    ;* CI_10051630
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) NE 90 THEN
        FOR C.COUNT = CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate TO CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart
            IF C.COUNT = CQ.ChqIssue.ChequeIssue.ChequeIsCurrency THEN
                CONTINUE
            END
            IF EB.SystemTables.getRNew(C.COUNT) NE '' THEN
                EB.SystemTables.setAf(C.COUNT)
                EB.SystemTables.setEtext("ST-INP.NOT.ALLOW.STATUS")
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT C.COUNT
    END
    EB.SystemTables.setAf(SAVE.AF);* CI_10051630

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges)
*----------------------------
*     If waive.charge field is null, default it with "NO"
    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF) EQ '' THEN
        EB.SystemTables.setAf(tmp.AF)
        EB.SystemTables.setRNew(EB.SystemTables.getAf(), 'NO')
    END
    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF) EQ 'YES' THEN
        EB.SystemTables.setAf(tmp.AF)
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '')
    END

* CI_10030290 E
    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate)
*-------------------------
*     If Cheque.Status is 90, then input is mandatory
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90 THEN
        tmp.AF = EB.SystemTables.getAf()
        IF NOT(EB.SystemTables.getRNew(tmp.AF)) THEN
            EB.SystemTables.setAf(tmp.AF)
            EB.SystemTables.setEtext('ST.RTN.INP.MISS.CHEQUE.STATUS.EQ.90')
            EB.ErrorProcessing.StoreEndError()
        END ELSE
*EN_10000101 -e
            ISSUE.DATE=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate)
            GOSUB ISSUE.DATE.VAL
            CQ.ChqIssue.setCqNumberIs(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued))
            GOSUB NUMBER.ISSUED.VAL
            IF EB.SystemTables.getIdOld()='' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) NE 'YES' THEN
                CQ.ChqIssue.setCqCharges(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges))
                CQ.ChqIssue.ChequeIssueChargesVal()     ;* EN_10000101 - changed GOSUB CHARGES.VAL to this CALL st
                IF EB.SystemTables.getE() THEN
                    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsCharges)
                    EB.SystemTables.setEtext(EB.SystemTables.getE())
                    EB.ErrorProcessing.StoreEndError()
                    EB.SystemTables.setE('')
                END
                CQ.ChqIssue.setCqChargeDate(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate))
                CQ.ChqIssue.ChequeIssueChargeDateVal() ;* EN_10000101 - changed GOSUB CHARGE.DATE.VAL to this CALL st
                IF EB.SystemTables.getE() THEN
                    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate)
                    EB.SystemTables.setEtext(EB.SystemTables.getE())
                    EB.ErrorProcessing.StoreEndError()
                    EB.SystemTables.setE('')
                END
            END
        END         ;*(#issue.date)
    END
* GB9900548 (Starts)

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)
*----------------------------
*EN_10000101 -s
*     If cheque.status is 90 then Number.Issued is required
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90 THEN
        tmp.AF = EB.SystemTables.getAf()
        IF NOT(EB.SystemTables.getRNew(tmp.AF)) THEN
            EB.SystemTables.setAf(tmp.AF)
            EB.SystemTables.setEtext('ST.RTN.INP.MISS.CHEQUE.STATUS.EQ.90.1')
            EB.ErrorProcessing.StoreEndError()
        END ELSE
*            IF R.NEW(AF) AND R.NEW(CHEQUE.IS.CHQ.NO.START) AND ID.OLD = "" THEN
*EN_10000101 -e
* CI_10030290 S

            tmp.AF = EB.SystemTables.getAf()
            tmp.AF = EB.SystemTables.getAf()
            tmp.AF = EB.SystemTables.getAf()
            tmp.AF = EB.SystemTables.getAf()
            IF (EB.SystemTables.getROld(tmp.AF) = '') OR (EB.SystemTables.getROld(tmp.AF) AND EB.SystemTables.getROld(tmp.AF) <> EB.SystemTables.getRNew(tmp.AF))  THEN
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setAf(tmp.AF)
* CI_10030290 E
                tmp.AF = EB.SystemTables.getAf()
                IF EB.SystemTables.getRNew(tmp.AF) AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart) THEN
                    EB.SystemTables.setAf(tmp.AF)
                    tmp.AF = EB.SystemTables.getAf()
                    CQ.ChqIssue.setCqRangeField(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart):"-":EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)+EB.SystemTables.getRNew(tmp.AF)-1)
                    EB.SystemTables.setAf(tmp.AF)
                    CQ.ChqIssue.ChequeIssCheckNotAlreadyIssued()          ;* EN_10000101 - changed GOSUB CHECK.NOT.ALREADY.ISSUED to this CALL st
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setEtext(EB.SystemTables.getE())
                        EB.ErrorProcessing.StoreEndError()
                    END
                END
            END     ;*EN_10000101 (#number.issued)
        END
    END   ;* CI_10030290 S/E

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
*---------------------------

    BEGIN CASE
* Cheque status is before issued, so cheque number start should not be present
        CASE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) < 90
            tmp.AF = EB.SystemTables.getAf()
            IF EB.SystemTables.getRNew(tmp.AF) # "" THEN
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setEtext("ST-CHQ.NO.START.MUST.BE.BLANK")
                EB.ErrorProcessing.StoreEndError()
            END
* Cheque status is issued, so cheque number start is required
        CASE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) = 90
            IF NOT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)) THEN
                EB.SystemTables.setEtext('ST.RTN.INP.MISS.CHEQUE.STATUS.EQ.90')
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                tmp.AF = EB.SystemTables.getAf()
                tmp.AF = EB.SystemTables.getAf()
                tmp.AF = EB.SystemTables.getAf()
                tmp.AF = EB.SystemTables.getAf()
                IF (EB.SystemTables.getROld(tmp.AF) = '') OR (EB.SystemTables.getROld(tmp.AF) AND EB.SystemTables.getROld(tmp.AF) <> EB.SystemTables.getRNew(tmp.AF) )  THEN
                    EB.SystemTables.setAf(tmp.AF)
                    EB.SystemTables.setAf(tmp.AF)
                    EB.SystemTables.setAf(tmp.AF)
                    EB.SystemTables.setAf(tmp.AF)
                    tmp.AF = EB.SystemTables.getAf()
                    IF EB.SystemTables.getRNew(tmp.AF) AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN
                        EB.SystemTables.setAf(tmp.AF)
                        tmp.AF = EB.SystemTables.getAf()
                        tmp.AF = EB.SystemTables.getAf()
                        CQ.ChqIssue.setCqRangeField(EB.SystemTables.getRNew(tmp.AF):"-":EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)+EB.SystemTables.getRNew(tmp.AF)-1)
                        EB.SystemTables.setAf(tmp.AF)
                        EB.SystemTables.setAf(tmp.AF)
                        CQ.ChqIssue.ChequeIssCheckNotAlreadyIssued()
                        IF EB.SystemTables.getE() THEN
                            EB.SystemTables.setEtext(EB.SystemTables.getE())
                            EB.ErrorProcessing.StoreEndError()
                        END ELSE  ;* CI_10056345 -S
                            tmp.ID.NEW = EB.SystemTables.getIdNew()
                            ACC.TYPE = FIELD(tmp.ID.NEW,'.',1,2)
                            EB.SystemTables.setIdNew(tmp.ID.NEW)
                            START.NO = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
                            END.NO = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart) + EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) - 1
                            LOC.POS = '' ; CHEQUE.ISSUE.ID = '' ; RESULT = '' ; RANGE.ERROR = ''; RANGE.FIELD = ''
                            DAS.ARGS = ACC.TYPE:'...' : @FM : EB.SystemTables.getIdNew() : @FM : '90'
                            THE.LIST = DAS.CHEQUE.ISSUE$NAU
                            FILE.SUFFIX = '$NAU'

                            EB.DataAccess.Das('CHEQUE.ISSUE', THE.LIST, DAS.ARGS, FILE.SUFFIX)

                            LOOP
                                REMOVE CHEQUE.ISSUE.ID FROM THE.LIST SETTING LOC.POS
                            WHILE CHEQUE.ISSUE.ID:LOC.POS
                                R.CHEQUE.ISSUE = CQ.ChqIssue.ChequeIssue.ReadNau(CHEQUE.ISSUE.ID, READ.ERR)
                                CHEQUE.NOS = R.CHEQUE.ISSUE<CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart>:'-':R.CHEQUE.ISSUE<CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart> + R.CHEQUE.ISSUE<CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued> - 1
                                IF RANGE.FIELD THEN
                                    RANGE.FIELD<1,-1> = CHEQUE.NOS
                                END ELSE
                                    RANGE.FIELD = CHEQUE.NOS
                                END
                            REPEAT
                            EB.API.MaintainRanges(RANGE.FIELD, START.NO, END.NO, 'ENQ', RESULT, RANGE.ERROR)
                            IF RESULT THEN
                                EB.SystemTables.setEtext("ST.RTN.CHEQUE/S.ALRDY.ISSUED")
                                EB.ErrorProcessing.StoreEndError()
                            END

                        END
                    END
                END
            END
* Cheque status is beyond issued, so cheque number start cannot change
        CASE EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) > 90
            tmp.AF = EB.SystemTables.getAf()
            tmp.AF = EB.SystemTables.getAf()
            IF EB.SystemTables.getROld(tmp.AF) # EB.SystemTables.getRNew(tmp.AF) THEN
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setEtext("ST-CHQ.NO.START.CANNOT.CHANGE")
                EB.ErrorProcessing.StoreEndError()
            END
    END CASE

    IF CQ.PARAM.REC<CQ.ChqConfig.CqParameter.CqParChequeNumLen> THEN
        tmp.AF = EB.SystemTables.getAf()
        IF LEN(EB.SystemTables.getRNew(tmp.AF)) GT CQ.PARAM.REC<CQ.ChqConfig.CqParameter.CqParChequeNumLen> THEN
            EB.SystemTables.setAf(tmp.AF)
            EB.SystemTables.setEtext('ST-LEN.GT.LEN.DEFINED.IN.CQ.PARAM')
            EB.ErrorProcessing.StoreEndError()
        END
    END


*EN_10000101 -s
    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsCharges)
*---------------------
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) NE 90 THEN
        CQ.ChqIssue.setCqCharges(''); CQ.ChqIssue.setCqChargeDate('')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, '')
    END

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate)
*--------------------------
    IF NOT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges)) THEN
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '')
    END ELSE
        CQ.ChqIssue.setCqChargeDate(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate))
        CQ.ChqIssue.ChequeIssueChargeDateVal()
        IF EB.SystemTables.getE() THEN
            EB.ErrorProcessing.StoreEndError()
        END
    END

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)
*-----------------------
    IF (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)) AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode) THEN  ;* CI_10051630 S
        EB.SystemTables.setEtext("ST-CHG.CODE.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
    END   ;* CI_10051630 E
    EB.Template.FtNullsChk()
    EB.Template.Dup()
    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) NE 'YES' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode) NE '' THEN
        EB.SystemTables.setEtext(tmp.ETEXT)
        CQ.ChqIssue.setCqJCharges(''); J.CHARGE.DATE = '' ; J.TTL.CHARGES = 0 ; J.TTL.TAX = 0
        CNT.CHRG = DCOUNT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode),@VM)
        BUILD.ENTRY = ''
        CHG.DATA= ''
        CQ.ChqIssue.setCqCustCond('')
        EXCH.RATE = ''
*  Initialise Tax details from R.NEW
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, '')

        FOR CNT = 1 TO CNT.CHRG
            CHG.DATA<1,CNT> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,CNT>
            CHG.DATA<2,CNT> = ''

            EXCH.RATE<1,CNT> = CQ.ChqIssue.getCqExchRate()<1>
            EXCH.RATE<4,CNT> = CQ.ChqIssue.getCqExchRate()<4>

            IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CNT> THEN
                tmp=CQ.ChqIssue.getCqCustCond(); tmp<2,CNT>=CQ.ChqIssue.getCqAcctCurr(); CQ.ChqIssue.setCqCustCond(tmp)
                tmp=CQ.ChqIssue.getCqCustCond(); tmp<3,CNT>=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CNT>; CQ.ChqIssue.setCqCustCond(tmp)
            END
        NEXT CNT
    
        CHG.DATA<68> = 'YES' ;* To Retrive Commission/charge/tax even its value is Zero

        ACCT.CUST = CQ.ChqIssue.getCqAcctCust()
        ACCT.CURR = CQ.ChqIssue.getCqAcctCurr()

* CALCULATE.CHARGE currently doesn't return the tax amt in LCY correctly when an
* userdefined EXCH rate is passed.  It is calculated with MID rate at present.
        CURR.MKT = CQ.ChqIssue.getCqCcyMkt()
        CUST.COND = CQ.ChqIssue.getCqCustCond()
        CG.ChargeConfig.CalculateCharge(ACCT.CUST , '', ACCT.CURR, CURR.MKT, EXCH.RATE, '', ACCT.CURR, CHG.DATA, CUST.COND, '', '')
        CQ.ChqIssue.setCqCustCond(CUST.COND)
        CQ.ChqIssue.setCqCcyMkt(CURR.MKR)
        CQ.ChqIssue.setCqChgData(CHG.DATA)

        TTL.CHRGS = DCOUNT(CHG.DATA<2>,@VM)
        T.CNT = 1
        C.CNT = 1
        FOR CNT = 1 TO TTL.CHRGS

            IF CQ.ChqIssue.getCqAcctCurr() EQ EB.SystemTables.getLccy() THEN
                IF CHG.DATA<2,CNT> EQ 'TAX' THEN
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt); tmp<1,T.CNT>=CHG.DATA<4,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, tmp)
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode); tmp<1,T.CNT>=CHG.DATA<1,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, tmp)
                    T.CNT += 1
                END ELSE
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount); tmp<1,C.CNT>=CHG.DATA<4,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount, tmp)
                    C.CNT += 1
                END
            END ELSE
                IF CHG.DATA<2,CNT> EQ 'TAX' THEN
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt); tmp<1,T.CNT>=CHG.DATA<5,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, tmp)
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode); tmp<1,T.CNT>=CHG.DATA<1,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, tmp)
                    T.CNT += 1
                END ELSE
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount); tmp<1,C.CNT>=CHG.DATA<5,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount, tmp)
                    C.CNT += 1
                END
            END

            tmp=CQ.ChqIssue.getCqJCharges(); tmp<CNT>=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CNT>; CQ.ChqIssue.setCqJCharges(tmp)
            J.TTL.CHARGES += EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CNT>
            J.TTL.TAX += EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt)<1,CNT>

        NEXT CNT
    END
    EB.Display.RebuildScreen()
*

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsClassType)
*     -----------------------
    tmp.AF = EB.SystemTables.getAf()
    AV1 = EB.SystemTables.getAv()
    IF EB.SystemTables.getRNew(tmp.AF) EQ '' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass) NE '' THEN
        tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass); tmp<1,AV1>=''; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass, tmp)
        tmp=EB.SystemTables.getTEnri(); tmp<CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass,AV1>=''; EB.SystemTables.setTEnri(tmp)
    END
    EB.Template.FtNullsChk()
    EB.Template.Dup()

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass)
*     ----------------------------
    tmp.AF = EB.SystemTables.getAf()
    AV1 = EB.SystemTables.getAv()
    IF EB.SystemTables.getRNew(tmp.AF) EQ '' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType) NE '' THEN
        tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType); tmp<1,AV1>=''; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType, tmp)
        tmp=EB.SystemTables.getTEnri(); tmp<CQ.ChqIssue.ChequeIssue.ChequeIsClassType,AV1>=''; EB.SystemTables.setTEnri(tmp)
    END
    EB.Template.FtNullsChk()
    EB.Template.Dup()

*EN_10000101 -e

*** GLOBUS_EN_10000353 - S

    EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsSeriesId)
* ------------------------
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) NE '' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg) NE '' THEN
        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart) EQ '' THEN
            tmp.AF = EB.SystemTables.getAf()
            STOCK.REG.ID = EB.SystemTables.getRNew(tmp.AF)
            EB.SystemTables.setAf(tmp.AF)
            STOCK.REC = CQ.ChqStockControl.StockRegister.Read(STOCK.REG.ID, ERR1)
            LOCATE EB.SystemTables.getComi() IN STOCK.REC<1,1> SETTING LOC.POS THEN  ;* GLOBUS_BG_100000738
                IF STOCK.REC<CQ.ChqStockControl.StockRegister.StoRegSeriesBal,LOC.POS> GE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN

                    START.NO = FIELD(STOCK.REC<CQ.ChqStockControl.StockRegister.StoRegSeriesNo,LOC.POS,1>,"-",1)

                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart, START.NO)
                END
            END     ;* GLOBUS_BG_100000738
        END
    END

*** GLOBUS_EN_10000353 - E

RETURN

*
*-----ISSUE DATE---------------------------------------------------------
ISSUE.DATE.VAL:
*--------------
    IF ISSUE.DATE='' THEN
        ISSUE.DATE=EB.SystemTables.getToday()
    END

RETURN
*-----------(Issued.Date.Val)


*-----NUMBER ISSUED------------------------------------------------------
NUMBER.ISSUED.VAL:
*-----------------
    IF CQ.ChqIssue.getCqNumberIs() = '' THEN
        CQ.ChqIssue.setCqNumberIs(CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeDefaultIssueNo>)
    END

RETURN
*-----------(Number.Issued.Val)

*-----------------------------------------------------------------------------------------
REPEAT.CHECK.FIELDS:
*-------------------
* Loop through each field and repeat the check field processing if there is any defined
*
    CQ.ChqIssue.setCqCheckingException(1)
    AF.CNT = EB.SystemTables.getAf()
    FOR AF.CNT = 1 TO CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef
        EB.SystemTables.setAf(AF.CNT)
        tmp.AF = EB.SystemTables.getAf()
        IF INDEX(EB.SystemTables.getN(AF.CNT), "C", 1) THEN
*
* Is it a sub value, a multi value or just a field
*
            BEGIN CASE
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[4,2] = 'XX'      ;* Sv
                    EB.SystemTables.setAf(EB.SystemTables.getAf())
                    tmp.AF = EB.SystemTables.getAf()
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(tmp.AF), @VM)
                    EB.SystemTables.setAf(tmp.AF)
                    IF NO.OF.AV = 0 THEN
                        NO.OF.AV = 1
                    END
                    AV.CNT = EB.SystemTables.getAv()
                    FOR AV.CNT = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(AV.CNT)
                        tmp.AF = EB.SystemTables.getAf()
                        NO.OF.SV = DCOUNT(EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv()>, @SM)
                        EB.SystemTables.setAf(tmp.AF)
                        IF NO.OF.SV = 0 THEN
                            NO.OF.SV = 1
                        END
                        AS.CNT = EB.SystemTables.getAs()
                        FOR AS.CNT = 1 TO NO.OF.SV
                            EB.SystemTables.setAs(AS.CNT)
                            GOSUB DO.CHECK.FIELD
                        NEXT AS.CNT
                    NEXT AV.CNT
                    tmp.AF = EB.SystemTables.getAf()
                CASE EB.SystemTables.getF(tmp.AF)[1,2] = 'XX'      ;* Mv
                    EB.SystemTables.setAf(tmp.AF)
                    EB.SystemTables.setAs('')
                    tmp.AF = EB.SystemTables.getAf()
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(tmp.AF), @VM)
                    EB.SystemTables.setAf(tmp.AF)
                    IF NO.OF.AV = 0 THEN
                        NO.OF.AV = 1
                    END
                    AV.NO = EB.SystemTables.getAv()
                    FOR AV.NO = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(AV.NO)
                        GOSUB DO.CHECK.FIELD
                    NEXT AV.NO
                CASE 1
                    EB.SystemTables.setAv(''); EB.SystemTables.setAs('')
                    GOSUB DO.CHECK.FIELD
            END CASE
        END
    NEXT AF.CNT
    CQ.ChqIssue.setCqCheckingException('')

RETURN
*-----------(Repeat.Check.Fields)


*-----------------------------------------------------------------------------------------
DO.CHECK.FIELD:
*--------------
** Repeat the check field validation - errors are returned in the variable E.
*
    AS1 = EB.SystemTables.getAs()
    AV1 = EB.SystemTables.getAv()
    AF1 = EB.SystemTables.getAf()
    EB.SystemTables.setComiEnri("")
    BEGIN CASE
        CASE AS1
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1)<1,AV1,AS1>)
        CASE AV1
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1)<1,AV1>)
        CASE AF1
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1))
    END CASE
*
    CQ.ChqIssue.ChequeIssueCheckFields()
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setEtext(EB.SystemTables.getE())
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        BEGIN CASE
            CASE AS1
                tmp=EB.SystemTables.getRNew(AF1); tmp<1,AV1,AS1>=EB.SystemTables.getComi(); EB.SystemTables.setRNew(AF1, tmp)
                YENRI.FLD = AF1:".":AV1:".":AS1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
            CASE AV1
                tmp=EB.SystemTables.getRNew(AF1); tmp<1,AV1>=EB.SystemTables.getComi(); EB.SystemTables.setRNew(AF1, tmp)
                YENRI.FLD = AF1:".":AV1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
            CASE AF1
                EB.SystemTables.setRNew(AF1, EB.SystemTables.getComi())
                YENRI.FLD = AF1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
        END CASE
    END

RETURN
*-----------(Do.Check.Field)



*-----------------------------------------------------------------------------------------
SET.UP.ENRI:
*-----------
    LOCATE YENRI.FLD IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
        tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=YENRI; EB.SystemTables.setTEnri(tmp)
    END

RETURN
*-----------(Set.Up.Enri)



*-----------------------------------------------------------------------------------------
INITIALISE:
*----------
    EB.SystemTables.setE('')
    ER = ''
    EB.SystemTables.setEtext('')
    EB.Display.RebuildScreen()

** GLOBUS_EN_10000353 -S

    CQ.PARAM.REC = CQ.ChqConfig.CqParameter.Read('SYSTEM', CQ.ERR)   ;* BG_100007859 - E

** GLOBUS_EN_10000353 -E
RETURN
*-----------(Initialise)

*-----------------------------------------------------------------------------------------




END
*-----(End of Cheque.Issue.CrossVal)




