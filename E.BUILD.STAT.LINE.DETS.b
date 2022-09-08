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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>964</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.BUILD.STAT.LINE.DETS
*-------------------------------------------------------------------------
*
** This enquiry subroutine will return details of:
** Consol Key
** Asset Type / currency
** Mat split / Debit or credit
*

* Data In O.DATA line number
* Data out R.RECORD
*-------------------------------------------------------------------------
******                     MODIFICATION DETAILS                     ******
*-------------------------------------------------------------------------
*
* 26/09/12 - Defect 486388 / Task 488895
*            Changes done to check the INCLUDE.GAAP.TYPE setup from RE.STAT.REOPRT.HEAD
*            and skip the consol keys with position type other than setup.
*
*-------------------------------------------------------------------------
    $USING RE.Consolidation
    $USING RE.Config
    $USING EB.SystemTables
    $USING EB.Reports

    GOSUB INITIALISE ; *
    GOSUB PROCESS.SLC ; *Read RE.STAT.LINT.CONT record and process each key

* Set the enquiry common variable
    EB.Reports.setVmCount(DCOUNT(LINE.DETAILS<1>,@VM))
*
    RETURN
*
*-------------------------------------------------------------------------
INITIALISE:
* Open the required files
* Store the GAAP type setup from RE.STAT.REPORT.HEAD record.
    tmp.O.DATA = EB.Reports.getOData()
    REPORT.NAME = FIELD(tmp.O.DATA,'.',1)
    R.HEAD.REC = RE.Config.StatReportHead.Read(REPORT.NAME, YERR)
    INCLUDE.GAAP.TYPES = R.HEAD.REC<RE.Config.StatReportHead.SrhInclGaapType>

*--The routine GET.PL.GAAP.TYPE will return the list of all Position types and its
*--PL.PREFIX respectively, from which the key in process position type can be retrieved.
*
    IF INCLUDE.GAAP.TYPES THEN
        RE.Config.GetPlGaapType(POS.TYPE.LIST,"")
    END

    MAX.SMC = '' ; KEYPOS = ''

    RETURN
*-----------------------------------------------------------------------------
PROCESS.SLC:
*-----------
* Read RE.STAT.LINT.CONT record and process each key

    LINE.DETAILS = ''
    tmp.O.DATA = EB.Reports.getOData()
    R.CONT.REC = RE.Consolidation.StatLineCont.Read(tmp.O.DATA, YERR)

    IF R.CONT.REC THEN
        AL.PL = 'AL' ;* Process CAL keys
        KEYS = R.CONT.REC<RE.Consolidation.StatLineCont.SlcAsstConsolKey>
        CCY.TYPES = R.CONT.REC<RE.Consolidation.StatLineCont.SlcAssetType>
        GOSUB BUILD.DATA
        *
        AL.PL = 'PL' ;* Process CPL keys
        KEYS = R.CONT.REC<RE.Consolidation.StatLineCont.SlcPrftConsolKey>
        CCY.TYPES = R.CONT.REC<RE.Consolidation.StatLineCont.SlcProfitCcy>
        SIGN.LIST = R.CONT.REC<RE.Consolidation.StatLineCont.SlcProfitSign>
        GOSUB BUILD.DATA
    END
*
    FOR YI = 1 TO 5
        tmp=EB.Reports.getRRecord(); tmp<24+YI>=LINE.DETAILS<YI>; EB.Reports.setRRecord(tmp)
    NEXT YI

    RETURN
*-----------------------------------------------------------------------------
BUILD.DATA:
*----------

** Process each key and type ccy calculate the balance and return if not
** zero in LINE.DETAILS structure
**   LINE.DETAILS<1,x> = key
**   LINE.DETAILS<2,x,y> = type/ccy
**   LINE.DETAILS<3,x,y> = Balance in ccy
**   LINE.DETAILS<4,x,y> = Local balance
**   LINE.DETAILS<5,x,y> = ccy
*
    KEY.DET.CNT = ''
    LOOP
        REMOVE CON.KEY FROM KEYS SETTING YD
    WHILE CON.KEY:YD
        KEY.DET.CNT += 1
        SMC = ''                        ; * Largest no of SM
        IF AL.PL = 'AL' THEN
            GOSUB PROCESS.CAL.KEY ; *Process the CAL key
        END ELSE
            GOSUB PROCESS.CPL.KEY ; *Process the CPL key
        END
    REPEAT
*
    RETURN

*-----------------------------------------------------------------------------
PROCESS.CAL.KEY:
*---------------
* Process the CAL key

* If the POS.TYPE of the key is not same as the GAAP type given in header record
* then dont include it.
    Y.POS.TYPE = FIELD(CON.KEY,".",3)
    IF INCLUDE.GAAP.TYPES AND NOT(Y.POS.TYPE MATCHES INCLUDE.GAAP.TYPES) THEN
        RETURN        ;* Donot process get next AL.KEY
    END

    AL.REC = RE.Consolidation.ConsolidateAsstLiab.Read(CON.KEY, YERR)
    IF AL.REC THEN
        TYPES = CCY.TYPES<1,KEY.DET.CNT>
        LOOP
            REMOVE CHK.TYPE FROM TYPES SETTING YD2
        WHILE CHK.TYPE:YD2
            LOCATE CHK.TYPE IN AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslType,1> SETTING TYPE.POS THEN
            CCY = AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslCurrency>
            BAL = AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslBalance,TYPE.POS> + AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslDebitMovement,TYPE.POS> + AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslCreditMovement,TYPE.POS>
            IF CCY = EB.SystemTables.getLccy() THEN
                LOCAL.BAL = BAL
            END ELSE
                LOCAL.BAL = AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslLocalBalance,TYPE.POS> + AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslLocalDebitMve,TYPE.POS> + AL.REC<RE.Consolidation.ConsolidateAsstLiab.AslLocalCredtMve,TYPE.POS>
            END
            IF LOCAL.BAL THEN
                KEYPOS += 1      ; * Add in next position
                LINE.DETAILS<1,KEYPOS> = CON.KEY
                LINE.DETAILS<2,KEYPOS> = CHK.TYPE
                LINE.DETAILS<5,KEYPOS> = CCY
                LINE.DETAILS<4,KEYPOS> = LOCAL.BAL
                LINE.DETAILS<3,KEYPOS> = BAL
            END
        END
    REPEAT
    END

    RETURN
*-----------------------------------------------------------------------------
PROCESS.CPL.KEY:
*---------------
* Process the CPL key

* If the POS.TYPE of the key is not same as the GAAP type given in header record
* then dont include it.
    IF INCLUDE.GAAP.TYPES THEN
        Y.PREFIX = FIELD(CON.KEY,".",1)
        GAAP.TYPE = ""
        LOCATE Y.PREFIX IN POS.TYPE.LIST<2,1> SETTING PREF.POS THEN
        GAAP.TYPE = POS.TYPE.LIST<1,PREF.POS>
    END
    IF NOT(GAAP.TYPE MATCHES INCLUDE.GAAP.TYPES) THEN
        RETURN  ;* Donot process get next PL.KEY
    END
    END

    PL.REC = RE.Consolidation.ConsolidatePrftLoss.Read(CON.KEY, YERR)
    IF PL.REC THEN
        TYPES = CCY.TYPES<1,KEY.DET.CNT>
        *100000467se
        PROFIT.SIGN = SIGN.LIST<1,KEY.DET.CNT>
        LOOP
            REMOVE CCY FROM TYPES SETTING YD2
        WHILE CCY:YD2
            LOCATE CCY IN PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCurrency,1> SETTING CCYP THEN
            BEGIN CASE
                CASE R.CONT.REC<RE.Consolidation.StatLineCont.SlcProfitPeriod> = 'CM'
                    LOCAL.BAL = PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlBalance,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlDebitMovement,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCreditMovement,CCYP>
                    IF CCY NE EB.SystemTables.getLccy() THEN
                        BAL = PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyBalance,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyDebitMve,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyCredtMve,CCYP>
                    END ELSE
                        BAL = LOCAL.BAL
                    END
                CASE R.CONT.REC<RE.Consolidation.StatLineCont.SlcProfitPeriod> = 'YTD'
                    LOCAL.BAL = PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlBalanceYtd,CCYP>
                    IF CCY NE EB.SystemTables.getLccy() THEN
                        BAL = PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyBalanceYtd,CCYP>
                    END ELSE
                        BAL = LOCAL.BAL
                    END
                CASE 1
                    LOCAL.BAL = PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlBalance,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlDebitMovement,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCreditMovement,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlBalanceYtd,CCYP>
                    IF CCY NE EB.SystemTables.getLccy() THEN
                        BAL = PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyBalance,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyDebitMve,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyCredtMve,CCYP> + PL.REC<RE.Consolidation.ConsolidatePrftLoss.PtlCcyBalanceYtd,CCYP>
                    END ELSE
                        BAL = LOCAL.BAL
                    END
            END CASE
            IF LOCAL.BAL THEN
                *BG_100000467
                IF LOCAL.BAL GE 0 AND BAL GE 0 AND PROFIT.SIGN EQ 'DEBIT' THEN CONTINUE
                IF LOCAL.BAL LT 0 AND BAL LT 0 AND PROFIT.SIGN EQ 'CREDIT' THEN CONTINUE
                *BG_100000467
                KEYPOS += 1
                LINE.DETAILS<1,KEYPOS> = CON.KEY
                LINE.DETAILS<2,KEYPOS> = CCY
                LINE.DETAILS<5,KEYPOS> = CCY
                LINE.DETAILS<4,KEYPOS> = LOCAL.BAL
                LINE.DETAILS<3,KEYPOS> = BAL
            END
        END
    REPEAT
    END

    RETURN
*-----------------------------------------------------------------------------
    END
