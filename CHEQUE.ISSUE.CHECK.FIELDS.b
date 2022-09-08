* @ValidationCode : MjotNDIwMTk2NDQ3OkNwMTI1MjoxNjEyOTQxNzMzMTE5OmluZGh1bWF0aGlzOjM6MDowOjE6dHJ1ZTpOL0E6REVWXzIwMjAxMi4yMDIwMTEyOC0wNjMwOjM1NjozMQ==
* @ValidationInfo : Timestamp         : 10 Feb 2021 12:52:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/356 (8.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>3989</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.CHECK.FIELDS
*----------------------------------------------------------------------------------------
*
* GB0001758
* Statement CALL REFRESH.FIELD(AF) changed to CALL REFRESH.FIELD(AF,"")
* Also in internal subroutine CHECK.FIELDS statement CASE AF = YY
* changed to REM > CASE AF = NAME.OF.THE.REQUIRED.FIELD, this routine
* will now compile and has a more meaningful name than YY.
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
*            - Changed Cheque.Issue to standard template
*            - Changed all values captured in ER to capture in E
*            - GoTo Check.Field.Err.Exit has been changed to GoTo Check.Field.Exit
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
* 22/10/01 - GLOBUS_CI_10000413
*            Value in cheque.status cannot be greater than 90 without
*            crossing the status 90.
*
* 14/02/02 - GLOBUS_EN_10000353
*            Validation related to STOCK application.
*
* 18/03/02 - GLOBUS_BG_100000738
*            Bug fixes related to STOCK application.
*
* 26/03/02 - GLOBUS_BG_100000778
*            Bug fixes related to Stock application.
*
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
* 09/06/02 - CI_10009769
*          - Fields CHEQUE.STATUS and CHQ.NO.START are  made to auto populate simultaneously,
*          - allowing to input, other fields like ISSUE.DATE, NUMBER.ISSUED.
* 17/05/05 - CI_10030290
*            Unable to amend local ref/ notes field while Cheque status is 90.
*
* 04/07/05 - EN_10002578
*            Browser issues in CC.
*            Unable to do CHEQUE.ISSUE in browser.
*
* 30/10/06 - CI_10045148
*            The error condition "cheques.already.issued" would not be thrown in check fields stage
*            when duplicated cheque numbers are given to the customer.
*
* 06/12/06 - BG_100012531
*            Problem with CHQ.NO.START field.
*
* 28/09/07 - CI_10051630
*            1)When cheque issue record is inputted with Same status,
*            then MESSAGE.CLASS & CLASS.TYPE are not allowed to be inputted for the second time.
*            2)T array handling is moved to field definitions.
*            3)Charges are allowed to default from CHEQUE.CHARGE only for status eq 90.
*            For other than 90, only waive charges are allowed.
*
* 26/09/07 - CI_10052305
*            If WAIVE.CHARGES is set to YES ,then for staus other than 90,charges are made as null.
*
* 25/02/09 - CI_10060948
*            Cheque charge default process should be done here when the field level
*            validation for CHEQUE.STATUS is invoked from CROSSVAL routine
*
* 25/10/11 - Task 298157
*            When cheque.status is 90 the issue date and number issued is not defaulted when we pass string through
*            ofs.
*
* 10/08/12 - Task 461899
*            Validation added to amend NOTES field in already authorized CHEQUE.ISSUE record.
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
* 14/06/17 - Defect 2146557 / Task 2160569
*            correction for CHQ.NO.START fileld not getting defaulted / re-calculated properly.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG*-----------------------------------------------------------------------------------------
*
* 14/01/21 - Enhancement 3784714 / Task 4154238
*            calculate Tax on the cheque issued charges
*
* 05/02/21 - Defect 4210897 / Task 4173321
*            Changes done to raise error only when the CHEQUE.STATUS is moved from 90 to a lower status.
*--------------------------------------------------------------------------------------------------------
    $USING CQ.ChqFees
    $USING CQ.ChqConfig
    $USING CQ.ChqSubmit
    $USING CG.ChargeConfig
    $USING CQ.ChqStockControl
    $USING EB.Display
    $USING EB.API
    $USING EB.SystemTables
    $USING CQ.ChqIssue

*-----------------------------------------------------------------------------------------

    GOSUB INITIALISE
*
************************************************************************
*
* Default the current field if input is null and the field is null.
*
    BEGIN CASE
        CASE EB.SystemTables.getAs()
            tmp.AF = EB.SystemTables.getAf()
            INTO.FIELD = EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
        CASE EB.SystemTables.getAv()
            tmp.AF = EB.SystemTables.getAf()
            INTO.FIELD = EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv()>
        CASE 1
            tmp.AF = EB.SystemTables.getAf()
            INTO.FIELD = EB.SystemTables.getRNew(tmp.AF)
    END CASE
*
    IF EB.SystemTables.getComi() = '' AND INTO.FIELD = '' THEN
        GOSUB DEFAULT.FIELDS
    END
*
* Real validation here.....
*
    GOSUB CHECK.FIELDS
*
* Now default other fields from this one if there is a value....
*
    IF EB.SystemTables.getComi() THEN
        COMI.ENRI.SAVE = EB.SystemTables.getComiEnri()
        EB.SystemTables.setComiEnri('')
        GOSUB DEFAULT.OTHER.FIELDS
        EB.SystemTables.setComiEnri(COMI.ENRI.SAVE)
    END
************************************************************************
*
* All done here.
*
RETURN
*-----------(Main)

************************************************************************
* Local subroutines....
************************************************************************
*
INITIALISE:
*----------
    EB.SystemTables.setE('')
    EB.SystemTables.setEtext('')
*
*-----------(Initialise)

*
*-----------------------------------------------------------------------------------------
DEFAULT.FIELDS:
*--------------

    tmp.AF = EB.SystemTables.getAf()
    EB.Display.RefreshField(tmp.AF,"")
*
RETURN
*-----------(Default.Fields)


*
*-----------------------------------------------------------------------------------------
DEFAULT.OTHER.FIELDS:
*--------------------
    DEFAULTED.FIELD = ''
    DEFAULTED.ENRI = ''
*
    EB.Display.RefreshField(DEFAULTED.FIELD, DEFAULTED.ENRI)
*
RETURN
*-----------(Default.Other.Fields)



*
*-----------------------------------------------------------------------------------------
CHECK.FIELDS:
*------------
* Where an error occurs, set E
*
    BEGIN CASE
* GB0001758
*
*EN_10000101 -s
*     Cheque Status
        CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus
*        -------------------------------
            CH.STS = EB.SystemTables.getComi()
            IF CQ.ChqIssue.getCqCheckingException() THEN   ;* Control comes from CROSSVAL routine
                GOSUB HANDLE.DEFAULTS
            END ELSE
                EB.SystemTables.setTEnri('')
                EB.SystemTables.setTEtext('')


* CI_10000413 -s
* value in cheque.status cannot be greater than 90 without crossing the status 90.
                IF EB.SystemTables.getComi() GT 90 THEN
                    IF EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) LT 90 THEN
                        EB.SystemTables.setE('ST.RTN.STATUS.90.MISS')
                        GOTO CHECK.FIELD.END
                    END
                END
* CI_10000413 -e

* Need to allow cheque status to remain same. Hence IF condition is
* changed to case structure.

                BEGIN CASE
                    CASE CH.STS GT EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
* CI_10030290 E
*              Locate for cheque.status in Cheque.Charge, if not found display error
                        LOCATE CH.STS IN CQ.ChqIssue.getCqStsIdListDesc()<1> SETTING CHN.POS THEN

                            IF EB.SystemTables.getComi() THEN
                                GOSUB REINIT.CHARGES
                                GOSUB HANDLE.DEFAULTS

*                    If cheque status GE to 90
                                IF CH.STS <>  90 THEN
*CI_10009769 E

                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate, '')
                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued, '')
                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart, '')
                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, '')
                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '')
** GLOBUS_BG_100000738 -S
                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg, '')
                                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsSeriesId, '')
** GLOBUS_BG_100000738 -E

                                    ISSUE.DATE = '' ; CQ.ChqIssue.setCqCharges(''); CQ.ChqIssue.setCqChargeDate('')
*
                                END
                            END       ;* if comi
                        END ELSE
                            EB.SystemTables.setE('ST.RTN.INVALID.CHEQUE.STATUS.ID')
                        END ;* Locate in Sts.Id.List.Desc
*Raise error only when the CHEQUE.STATUS is changed from 90(issued cheque) to a lower cheque status.
                    CASE EB.SystemTables.getComi() AND (EB.SystemTables.getComi() LT EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)) AND EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90)
                        EB.SystemTables.setE('ST.RTN.CHQ.STATUS.CHANGED.LOWER.')
                        EB.SystemTables.setComi(EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus))
                    CASE NOT(EB.SystemTables.getComi())
                        EB.SystemTables.setE('ST.RTN.CHQ.STATUS.CANT.BLANK')
                        EB.SystemTables.setComi(EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus))
                    END  CASE


                    IF EB.SystemTables.getE() THEN
                        GOTO CHECK.FIELD.END
                    END

                    EB.Display.RebuildScreen()
                END
*EN_10000101 -e

            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate
*        ----------------------------
*EN_10000101 -s
*           Do not accept any value if Cheque.Status is less than 90

                IF NOT(CQ.ChqIssue.getCqCheckingException()) THEN
                    IF EB.SystemTables.getComi() OR EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90 THEN

* EN_10000101 -e
                        ISSUE.DATE=EB.SystemTables.getComi()
                        GOSUB ISSUE.DATE.VAL
                        EB.SystemTables.setComi(ISSUE.DATE)
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, EB.SystemTables.getComi())
                        LOCATE CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate IN EB.SystemTables.getTFieldno()<1> SETTING POS ELSE
                            POS = 0
                        END
                        IF POS THEN
                            tmp=EB.SystemTables.getTSequ(); tmp<-1>='D':POS; EB.SystemTables.setTSequ(tmp)
                        END
                    END
                END

            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued
*        -------------------------------
* EN_10000101 -s
*           Do not accept any value if Cheque.Status is less than 90

                IF NOT(CQ.ChqIssue.getCqCheckingException()) THEN
                    IF (EB.SystemTables.getComi() OR EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90) AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) <> '90') THEN

* EN_10000101 -e
                        CQ.ChqIssue.setCqNumberIs(EB.SystemTables.getComi())
                        GOSUB NUMBER.ISSUED.VAL
                        CQ.ChqIssue.setCqCharges('')
                        CQ.ChqIssue.ChequeIssueChargesVal()     ;* EN_10000101 - changed GOSUB CHARGES.VAL to this CALL st
                        IF EB.SystemTables.getE() THEN
                            GOTO CHECK.FIELD.END
                        END
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, CQ.ChqIssue.getCqCharges())
                        LOCATE CQ.ChqIssue.ChequeIssue.ChequeIsCharges IN EB.SystemTables.getTFieldno()<1> SETTING POS ELSE
                            POS = 0
                        END
                        IF POS THEN
                            tmp=EB.SystemTables.getTSequ(); tmp<-1>='D':POS; EB.SystemTables.setTSequ(tmp)
                        END
                        EB.SystemTables.setComi(CQ.ChqIssue.getCqNumberIs())
                    END     ;* EN_10000101
                END         ;* EN_10000101
*

            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsCharges
*        -------------------------

                CQ.ChqIssue.setCqCharges(EB.SystemTables.getComi())
                CQ.ChqIssue.setCqNumberIs(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued))
                IF (EB.SystemTables.getComi() OR EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90) AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) <> '90')  THEN  ;* CI_10051630 S/E
                    CQ.ChqIssue.ChequeIssueChargesVal()         ;* EN_10000101 - changed GOSUB CHARGES.VAL to this CALL st
                END
*        -------------------------
                temp.TAX.DATA=CQ.ChqIssue.getCqChqTaxData()
                IF temp.TAX.DATA NE "" THEN
                    CNT.TAX.DATA = DCOUNT(temp.TAX.DATA<2>,@VM)
                    FOR CNT = 1 TO CNT.TAX.DATA
                        TAXCODEREC<-1>=temp.TAX.DATA<1,CNT>
                        TAXAMOUNTREC<-1>=temp.TAX.DATA<4,CNT>
                    NEXT CNT
                    CONVERT @FM TO @VM IN TAXCODEREC
                    CONVERT @FM TO @VM IN TAXAMOUNTREC
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxId,TAXCODEREC)
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmount,TAXAMOUNTREC)
                END
*        -------------------------
                IF EB.SystemTables.getE() THEN
                    GOTO CHECK.FIELD.END
                END
                EB.SystemTables.setComi(CQ.ChqIssue.getCqCharges())
                tmp.COMI = EB.SystemTables.getComi()
                IF NOT(tmp.COMI) AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate) THEN
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '');* No date required
                    LOCATE CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate IN EB.SystemTables.getTFieldno()<1> SETTING POS THEN
                        tmp=EB.SystemTables.getTSequ(); tmp<-1>='D':POS; EB.SystemTables.setTSequ(tmp)
                    END
                END
                IF CQ.ChqIssue.getCqIssueRollover() THEN
                    EB.SystemTables.setComiEnri('WARNING - OUTSIDE CHARGE PERIOD')
                END


            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate
*        -----------------------------
                CQ.ChqIssue.setCqCharges(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges))
                IF CQ.ChqIssue.getCqCharges() AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges)[1,1] NE 'Y' THEN
                    IF EB.SystemTables.getComi() = "" THEN
                        EB.SystemTables.setComi(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate))
                    END
                    IF EB.SystemTables.getComi() = "" THEN
                        EB.SystemTables.setComi(EB.SystemTables.getToday())
                    END
                END
                CQ.ChqIssue.setCqChargeDate(EB.SystemTables.getComi())
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, EB.SystemTables.getComi())
                EB.SystemTables.setComi(CQ.ChqIssue.getCqChargeDate())

** GLOBUS_BG_100000738 -S

            CASE EB.SystemTables.getAf() = CQ.ChqIssue.ChequeIssue.ChequeIsStockReg
*        --------------------------------

                IF EB.SystemTables.getComi() THEN
                    tmp.E = ''
                    CQ.ChqIssue.StkCtrlChkFieldVal(tmp.E)
                    EB.SystemTables.setE(tmp.E)
                    IF EB.SystemTables.getE() THEN
                        GOTO CHECK.FIELD.END
                    END
                END
*
** GLOBUS_BG_100000738 -E

*** GLOBUS_EN_10000353 - S

            CASE EB.SystemTables.getAf() = CQ.ChqIssue.ChequeIssue.ChequeIsSeriesId
*        ------------------------------
** GLOBUS_BG_100000738 -S

                IF EB.SystemTables.getComi() THEN
                    tmp.E = ''
                    CQ.ChqIssue.StkCtrlChkFieldVal(tmp.E)
                    EB.SystemTables.setE(tmp.E)
                    IF EB.SystemTables.getE() THEN
                        GOTO CHECK.FIELD.END
                    END
                END
                POS = ""
                IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart) EQ "" THEN

** GLOBUS_BG_100000738 -E

                    IF EB.SystemTables.getComi() NE '' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) NE '' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg) NE '' THEN

                        STOCK.REG.ID = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg)
                        STOCK.REC = CQ.ChqStockControl.StockRegister.Read(STOCK.REG.ID, ERR1)
                        LOCATE EB.SystemTables.getComi() IN STOCK.REC<1,1> SETTING POS THEN
                            IF STOCK.REC<CQ.ChqStockControl.StockRegister.StoRegSeriesBal,POS> GE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN

                                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart, FIELD(STOCK.REC<CQ.ChqStockControl.StockRegister.StoRegSeriesNo,POS,1>,"-",1))
                                EB.Display.RebuildScreen()       ;* GLOBUS_BG_100000778
                            END
                        END
                    END
                END
*** GLOBUS_EN_10000353 - E

* GB9900548 (Starts)
            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart
*        ------------------------------

                IF EB.SystemTables.getComi() THEN          ;* EN_10000101
                    CHQ.START.NO = EB.SystemTables.getComi()

                    tmp.ID.NEW = EB.SystemTables.getIdNew()
                    CHEQ.TYP.ID = FIELD(tmp.ID.NEW,".",1)
                    CHEQ.TYP.REC = CQ.ChqConfig.ChequeType.Read(CHEQ.TYP.ID, CHQ.TYP.ERR)

                    AutoReorderType = CHEQ.TYP.REC<CQ.ChqConfig.ChequeType.ChequeTypeAutoReorderType>

                    IF AutoReorderType = "CHEQUE.NUMBER" THEN
                        MIN.HOLD = CHEQ.TYP.REC<CQ.ChqConfig.ChequeType.ChequeTypeMinHolding>
                        IF MIN.HOLD < EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN
                            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsAutoChequeNumber, EB.SystemTables.getComi() + EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) - MIN.HOLD)

                        END
                    END

*** GLOBUS_EN_10000353 -E

* EN_10000101 -s
                END ELSE
                    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ '90' AND NOT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)) THEN
                        EB.SystemTables.setE('ST.RTN.CHQ.START.NO.CANT.0.')
                        GOTO CHECK.FIELD.END
                    END
                END
* EN_10000101 -e
* GB9900548 (Ends)

*
*EN_10000101 -s
* Charge Code
            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsChgCode
*        --------------------------

                CG.ChargeConfig.InTwochg('11','CHG':@VM:'COM')

                IF NOT(CQ.ChqIssue.getCqCheckingException()) THEN
                    IF EB.SystemTables.getComi() THEN
                        CHG.CODE = EB.SystemTables.getComi()
                        FLT.AMT = ''
                        CHG.DATA = ''
                        CHG.DATA<1,1> = EB.SystemTables.getComi()
                        CHG.DATA<2,1> = ''
                        R.FT.COM.TYPE = CG.ChargeConfig.FtCommissionType.Read(CHG.CODE, ER)
                        FLT.AMT = R.FT.COM.TYPE<CG.ChargeConfig.FtCommissionType.FtFouFlatAmt

                        IF NOT(ER) THEN
                            EB.SystemTables.setEtext(ER)
                            IF FLT.AMT EQ '' THEN
                                EB.SystemTables.setE('ST.RTN.FLAT.AMT.PRESENT':@FM:EB.SystemTables.getComi())
                                GOTO CHECK.FIELD.END
                            END
                        END ELSE
                            R.FT.CHG.TYPE = CG.ChargeConfig.FtChargeType.Read(CHG.CODE, ER)
                            FLT.AMT = R.FT.CHG.TYPE<CG.ChargeConfig.FtChargeType.FtFivFlatAmt>
                            IF ER THEN
                                EB.SystemTables.setE(ER)
                                GOTO CHECK.FIELD.END
                            END
                        END

                    END ELSE
                        NEW.CHRG.CODES = '' ; NEW.CHRG.AMOUNT = ''
                        NEW.TAX.CODE = '' ; NEW.TAX.AMT = ''
                        OLD.CHRG.CODES = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)
                        TTL.NULL = 0
                        TTL.NEW.CHRG.CODES = DCOUNT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode),@VM)
                        FOR CNT = 1 TO TTL.NEW.CHRG.CODES
                            IF EB.SystemTables.getAv() = CNT THEN
                                TTL.NULL += 1
                                CONTINUE
                            END
                            IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,CNT> NE '' THEN
                                NEW.CHRG.CODES<1,(CNT-TTL.NULL)> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,CNT>
                                NEW.CHRG.AMOUNT<1,(CNT-TTL.NULL)> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CNT>
                                NEW.TAX.CODE<1,(CNT-TTL.NULL)> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode)<1,CNT>
                                NEW.TAX.AMT<1, (CNT-TTL.NULL)> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt)<1,CNT>
                            END
                        NEXT CNT
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode, NEW.CHRG.CODES)
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount, NEW.CHRG.AMOUNT)
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, NEW.TAX.CODE)
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, NEW.TAX.AMT)
                        EB.SystemTables.setComi(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,EB.SystemTables.getAv()>)
                    END

                    EB.Display.RebuildScreen()
                END
*

*    Chrg.Amount
            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount
*        ----------------------------
                IF EB.SystemTables.getComi() THEN
                    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,EB.SystemTables.getAv()> EQ '' THEN
                        EB.SystemTables.setE('ST.RTN.CHRG.CODE.MISS')
                        GOTO CHECK.FIELD.END
                        ACCT.CURR = CQ.ChqIssue.getCqAcctCurr()
                        AMT = EB.SystemTables.getComi()
                        EB.API.RoundAmount(ACCT.CURR, AMT, '1', '')
                        EB.SystemTables.setComi(AMT)
                    END
                END


*
* Waive.Charges
            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges
*        -------------------------------
                IF EB.SystemTables.getComi()[1,1] = 'Y' THEN
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode, '')
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount, '')
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, '')
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, '')
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, '')
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '');* cheque leaf charges
                    CQ.ChqIssue.setCqCharges(''); CQ.ChqIssue.setCqJCharges('')
                END
                EB.Display.RebuildScreen()


            CASE EB.SystemTables.getAf()=CQ.ChqIssue.ChequeIssue.ChequeIsClassType
                AV1 = EB.SystemTables.getAv()
*        ----------------------------
                IF EB.SystemTables.getComi() EQ '' THEN
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass); tmp<1,AV1>=''; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass, tmp)
                    EB.Display.RebuildScreen()
                END

            CASE EB.SystemTables.getAf() = CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass
                AV1 = EB.SystemTables.getAv()
*        ---------------------------------
                IF EB.SystemTables.getComi() EQ '' THEN
                    tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType); tmp<1,AV1>=''; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType, tmp)
                    EB.Display.RebuildScreen()
                END
* EN_10000101 -e


        END CASE

CHECK.FIELD.END:
        RETURN
*-----------(Check.Field)

*
* EN_10000101 -s
*-----------------------------------------------------------------------------------------
REINIT.CHARGES:
*--------------
*  Reinitialise Charges and Charge Code to null
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxId, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmount, '')

        IF EB.SystemTables.getAf() NE CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus THEN
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, '')
            EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '')
        END

        RETURN
*-----------(Reinit.Charges)
* EN_10000101 -e

*
*-----ISSUE DATE---------------------------------------------------------
ISSUE.DATE.VAL:
*--------------
        IF ISSUE.DATE='' THEN
            ISSUE.DATE=EB.SystemTables.getToday()
        END

        RETURN
*-----------(Issue.Date.Val)


*-----NUMBER ISSUED------------------------------------------------------
NUMBER.ISSUED.VAL:
*-----------------
        IF CQ.ChqIssue.getCqNumberIs() = '' THEN
            CQ.ChqIssue.setCqNumberIs(CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeDefaultIssueNo>)
        END

        RETURN
*-----------(Number.Issued.Val)
*-----CHEQUE STATUS------------------------------------------------------
UPDATE.DEFAULT.CHARGES:
*---------------------

        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) NE 'YES' THEN
            ALL.CHG = CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgChargeCode><1,CH.POS>
            ALL.CHG = RAISE(ALL.CHG)
            NO.OF.CHRG = DCOUNT(ALL.CHG,@VM)
            FOR CNT = 1 TO NO.OF.CHRG
                tmp=EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode); tmp<1,CNT>=ALL.CHG<1,CNT>; EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode, tmp)
            NEXT CNT
        END

        RETURN
*------------------------------------------------------------------------

HANDLE.DEFAULTS:
* Default charges

        tmp.CQ$CHECKING.EXCEPTION = CQ.ChqIssue.getCqCheckingException()
        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus) EQ '' AND (EB.SystemTables.getComi() EQ EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus))  THEN
            NULL
        END ELSE

            IF NOT(tmp.CQ$CHECKING.EXCEPTION) OR (CQ.ChqIssue.getCqCheckingException() AND (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)=''))  THEN         ;* At check fields or default during crossval
                LOCATE CH.STS IN CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus,1> SETTING CH.POS THEN
                    GOSUB UPDATE.DEFAULT.CHARGES
                END ELSE
*   If COMI not found in Cheque.Charge for defaulting charges, then take default charges
                    LOCATE "" IN CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus,1> SETTING CH.POS THEN
                        GOSUB UPDATE.DEFAULT.CHARGES
                    END
                END         ;* locate in cheque.charges

            END
            CQ.ChqIssue.setCqChargeCodeArray(RAISE(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)))
            CQ.ChqIssue.setCqChargeAmountArray(RAISE(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)))

* Default the values in  NUMBER.ISSUED and ISSUE.DATE in CHEQUE.ISSUE, when CHQ.STATUS is 90, here CHQ.STATUS will be HOT.FIELD
* This is done specially for browser, as CHECK.FIELDS will not get triggered in browser.
*
            IF (CH.STS ='90') THEN       ;*EN_10002578 S
                IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate)= '' AND CQ.ChqIssue.getCqCheckingException()) OR  NOT(tmp.CQ$CHECKING.EXCEPTION) THEN
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate, EB.SystemTables.getToday())
                END
                IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)= ''  AND CQ.ChqIssue.getCqCheckingException()) OR NOT(tmp.CQ$CHECKING.EXCEPTION) THEN
                    IF CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeDefaultIssueNo> THEN
                        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued, CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeDefaultIssueNo>)
                    END
                END
            END   ;*EN_10002578 E
* Default delivery

            IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType)= '' AND CQ.ChqIssue.getCqCheckingException()) OR NOT(tmp.CQ$CHECKING.EXCEPTION) THEN
                CHEQ.STS.REC = '' ; STS.ERR = ''
                CHEQ.STS.REC = CQ.ChqConfig.ChequeStatus.Read(CH.STS, STS.ERR)
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType, CHEQ.STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsClassType>)
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass, CHEQ.STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsMessageClass>)
            END
        END

        RETURN
*------------------------------------------------------------------------

    END
*-----(End of routine Cheque.Issue.Check.Fields)




