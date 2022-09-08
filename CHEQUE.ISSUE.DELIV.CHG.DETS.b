* @ValidationCode : Mjo3Mjc0MDI1NjE6Q3AxMjUyOjE1ODM5MjgyNDQwNzg6cnZhcmFkaGFyYWphbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Mar 2020 17:34:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>430</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.DELIV.CHG.DETS(YCHARGE.ARRAY,CHARGE.CODE,CHARGE.AMOUNT,TAX.AMOUNT,CHARGE.DATE)

* 23/10/01 - GLOBUS_BG_100000159
*            Charges are debited to cheque issue account and not to charge account
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 14/08/15 - Enhancement 1265068 / Task 1387491
*           - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG***********************************************************************

    $USING CQ.ChqConfig
    $USING AC.AccountOpening
    $USING CG.ChargeConfig
    $USING EB.ErrorProcessing
    $USING EB.API
    $USING EB.SystemTables
    $USING CQ.ChqIssue


    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

INITIALISE:
*==========

    tmp.ID.NEW = EB.SystemTables.getIdNew()
    CQ.ChqIssue.setCqChequeAccId(FIELD(tmp.ID.NEW,'.',2))
    YCHARGE.ARRAY = ''
    TOT.CHG.AMT = 0
    TOT.TAX.AMT = 0
RETURN

PROCESS:
*=======
    IF CHARGE.CODE EQ '' THEN

        CHG = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges)
        CHARGE.DATE = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate)

        CHARGE.COUNT = DCOUNT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode),@VM)
        FOR CT = 1 TO CHARGE.COUNT
            TOT.CHG.AMT += EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CT>
            TOT.TAX.AMT += EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt)<1,CT>
        NEXT CT

    END ELSE                           ; * being in PREVIEW mode and Function = "S"

        CHARGE.COUNT = DCOUNT(CHARGE.CODE,@VM)
        FOR CT = 1 TO CHARGE.COUNT
            IF CHARGE.CODE<1,CT> EQ 'OTHERS' THEN
                CHG = CHARGE.AMOUNT<1,CT>
            END ELSE
                TOT.CHG.AMT += CHARGE.AMOUNT<1,CT>
                TOT.TAX.AMT += TAX.AMOUNT<1,CT>
            END
        NEXT CT
    END

*if no charges then no delivery message produced

    IF CHG = '' THEN CHG = 0
    TOT.AMT = CHG + TOT.CHG.AMT + TOT.TAX.AMT
    IF TOT.AMT NE 0 THEN
        IF EB.SystemTables.getMessage() NE "PREVIEW" THEN EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef, '')
        GOSUB CHARGE.ACC
        GOSUB CHARGE.DESC
        GOSUB CHARGE.ARRAY
    END

RETURN

CHARGE.ACC:
*==========
* picking the a/c & ccy from CHARGE.ACCOUNT field if exists.

    ACC.REC = '' ; ACC.ERR = '' ; ACC.ID = CQ.ChqIssue.getCqChequeAccId()
    ACC.REC = AC.AccountOpening.Account.Read(ACC.ID, ACC.ERR)

    CHG.ACC.ID=CQ.ChqIssue.getCqChequeAccId()
    ACCOUNT.CCY = ACC.REC<AC.AccountOpening.Account.Currency>
    ACC.TITLE = ACC.REC<AC.AccountOpening.Account.ShortTitle>

    CHQ.STS = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
    R.CHEQUE.STATUS = CQ.ChqConfig.ChequeStatus.Read(CHQ.STS, CHQ.ERR)
    STS.DESC = R.CHEQUE.STATUS<CQ.ChqConfig.ChequeStatus.ChequeStsDescription>

RETURN

CHARGE.DESC:
*===========
* charge description from FT.CHARGE.TYPE or FT.COMMISSION.TYPE
    IF CHARGE.CODE EQ '' THEN

        FOR CT = 1 TO CHARGE.COUNT
            EB.SystemTables.setEtext('')
            R.FT.COMMISSION.TYPE = ''
            COM.CODE = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,CT>
            R.FT.COMMISSION.TYPE = CG.ChargeConfig.FtCommissionType.Read(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,CT>, COM.ER)
            EB.SystemTables.setEtext(COM.ER)
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setEtext('')
                R.FT.CHARGE.TYPE = ''
                R.FT.CHARGE.TYPE = CG.ChargeConfig.FtChargeType.Read(COM.CODE, CHG.ER)
                EB.SystemTables.setEtext(CHG.ER)
                IF EB.SystemTables.getEtext() THEN
                    GOSUB FATAL.ERROR
                END ELSE
                    YCHARGE.ARRAY<9,CT,-1> = R.FT.CHARGE.TYPE<CG.ChargeConfig.FtChargeType.FtFivDescription>
                END
            END ELSE
                YCHARGE.ARRAY<9,CT,-1> = R.FT.COMMISSION.TYPE<CG.ChargeConfig.FtCommissionType.FtFouDescription>
            END

            YCHARGE.ARRAY<6,CT,-1> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,CT>
            YCHARGE.ARRAY<7,CT,-1> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount)<1,CT>
            YCHARGE.ARRAY<8,CT,-1> = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt)<1,CT>
        NEXT CT


    END ELSE                           ; * being in PREVIEW mode and Function = "S"

        FOR CT = 1 TO CHARGE.COUNT
            IF CHARGE.CODE<1,CT> NE 'OTHERS' THEN
                EB.SystemTables.setEtext('')
                R.FT.COMMISSION.TYPE = ''
                R.FT.COMMISSION.TYPE = CG.ChargeConfig.FtCommissionType.Read(CHARGE.CODE<1,CT>, COM.ER)
                EB.SystemTables.setEtext(COM.ER)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setEtext('')
                    R.FT.CHARGE.TYPE = ''
                    R.FT.CHARGE.TYPE = CG.ChargeConfig.FtChargeType.Read(CHARGE.CODE<1,CT>, CHG.ER)
                    EB.SystemTables.setEtext(CHG.ER)
                    IF EB.SystemTables.getEtext() THEN
                        GOSUB FATAL.ERROR
                    END ELSE
                        YCHARGE.ARRAY<9,CT,-1> = R.FT.CHARGE.TYPE<CG.ChargeConfig.FtChargeType.FtFivDescription>
                    END
                END ELSE
                    YCHARGE.ARRAY<9,CT,-1> = R.FT.COMMISSION.TYPE<CG.ChargeConfig.FtCommissionType.FtFouDescription>
                END

                YCHARGE.ARRAY<6,CT,-1> = CHARGE.CODE<1,CT>
                YCHARGE.ARRAY<7,CT,-1> = CHARGE.AMOUNT<1,CT>
                YCHARGE.ARRAY<8,CT,-1> = TAX.AMOUNT<1,CT>
            END
        NEXT CT
    END

RETURN

FATAL.ERROR:
*===========
    EB.ErrorProcessing.FatalError('CHEQUE.ISSUE')
RETURN

CHARGE.ARRAY:
*============
* populating charge array

    EB.API.RoundAmount(ACCOUNT.CCY,CHG,'1','')
    EB.API.RoundAmount(ACCOUNT.CCY,TOT.CHG.AMT,'1','')
    EB.API.RoundAmount(ACCOUNT.CCY,TOT.TAX.AMT,'1','')
    EB.API.RoundAmount(ACCOUNT.CCY,TOT.AMT,'1','')

    YCHARGE.ARRAY<1,1> = EB.SystemTables.getToday()
    YCHARGE.ARRAY<2,1> = ACC.TITLE
    YCHARGE.ARRAY<3,1> = CHG.ACC.ID
    YCHARGE.ARRAY<4,1> = ACCOUNT.CCY
    YCHARGE.ARRAY<5,1> = STS.DESC
    YCHARGE.ARRAY<10,1> = CHG
    YCHARGE.ARRAY<11,1> = TOT.TAX.AMT
    YCHARGE.ARRAY<12,1> = TOT.AMT
    IF CHARGE.DATE NE EB.SystemTables.getToday() THEN
        YCHARGE.ARRAY<13,1> = CHARGE.DATE
        IF YCHARGE.ARRAY<6> AND YCHARGE.ARRAY<13> THEN
            YCHARGE.ARRAY<14,1> = EB.SystemTables.getToday()
        END
    END

RETURN


END
