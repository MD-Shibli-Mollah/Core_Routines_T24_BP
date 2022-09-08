* @ValidationCode : MjoxMzc5OTQwMDAyOkNwMTI1MjoxNTY0NTcxMTY4OTg5OnNyYXZpa3VtYXI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:36:08
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

*-----------------------------------------------------------------------------
* <Rating>48</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqFees
    SUBROUTINE CHEQUE.CHARGE.BAL.UPDATE(CHQ.ID, MAT CHQ.IS.REC,CHARGE.ACCT,CHRG.CCY)
*-----------------------------------------------------------------------------
*     This routine is called to update Cheque.Charge.Bal record with
*     details of charges collected and status.
*
*     Input Parameters
*     ----------------
*     CHQ.ID       :  Cheque.Issue ID and Cheque.Charge.Bal record ID
*     CHQ.IS.REC   :  Cheque.Issue Record
*     CHARGE.ACCT  :  Account ID of charges collected (if null, chq.id))
*     CHRG.CCY     :  Currency in which the charges are collected
*-----------------------------------------------------------------------------
* 27/06/07 - CI_10051630
*            When cheque issue record is inputted ,CHEQUE.CHARGE BAL file is
*            made to update correctly.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*
*18/09/15 - Enhancement 1265068 / Task 1475953
*         - Routine Incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*------------------------------------------------------------------------------
    $USING CQ.ChqIssue
    $USING CQ.ChqFees
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS.CHARGES

    RETURN
*--------------------------------------------------------------------------------------

PROCESS.CHARGES:
*--------------
    BEGIN CASE
        CASE CQ.ChqIssue.getCqFunction() = 'AUT'
            BEGIN CASE
                CASE CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] = 'RNA'
                    *                   Delete From Cheque.Charge.Bal
                    *                   CALL F.DELETE(FN.CCB, CHQ.ID)
                CASE 1
                    CHEQUE.BAL.REC = CQ.ChqFees.ChequeChargeBalHold.Read(CHQ.ID, BAL.READ.ERR)
                    CQ.ChqFees.ChequeChargeBal.Write(CHQ.ID, CHEQUE.BAL.REC)
                    CQ.ChqFees.ChequeChargeBalHold.Delete(CHQ.ID)
            END CASE
        CASE CQ.ChqIssue.getCqFunction() = 'VAL'
            BEGIN CASE
                CASE EB.SystemTables.getVFunction() = 'I'
                    GOSUB UPDATE.CHARGES
                    CQ.ChqFees.ChequeChargeBalHold.Write(CHQ.ID, CHEQUE.BAL.REC)
                CASE EB.SystemTables.getVFunction() = 'D'
                    CQ.ChqFees.ChequeChargeBalHold.Delete(CHQ.ID)
            END CASE
        CASE CQ.ChqIssue.getCqFunction() = 'EOD'
            GOSUB UPDATE.CHARGES
            CQ.ChqFees.ChequeChargeBal.Write(CHQ.ID, CHEQUE.BAL.REC)
    END CASE

    RETURN

*----------------------------------------------------------------------------------------
UPDATE.CHARGES:
*--------------
    LOCATE CQ.STATUS IN SH.ARRAY<1> BY 'AR' SETTING UB.J.POS THEN
*     If Booking.date eq today set UB.CHRG... multivalue
* Add status
    UB.CHRG.CODE = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCode><1,UB.J.POS>)
    UB.CHRG.DATE = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgDate><1,UB.J.POS>)
    UB.LCY.AMOUNT = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgLcyAmt><1,UB.J.POS>)
    UB.FCY.AMOUNT = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgFcyAmt><1,UB.J.POS>)
    UB.TAX.CODE = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalTaxCode><1,UB.J.POS>)
    UB.TAX.LCY.AMT = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxLcyAmt><1,UB.J.POS>)
    UB.TAX.FCY.AMT = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxFcyAmt><1,UB.J.POS>)
    END ELSE
    INS CQ.STATUS BEFORE SH.ARRAY<UB.J.POS>
    INS CQ.STATUS BEFORE CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus,UB.J.POS>
    INS EB.SystemTables.getToday() BEFORE CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate,UB.J.POS>
    INS CHG.ACCT BEFORE CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChrgAccount,UB.J.POS>
    INS CHRG.CCY BEFORE CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChrgCcy,UB.J.POS>
    INS EXCH.RATE BEFORE CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalExchRate,UB.J.POS>
    END

*     If Charges are collected insert a charge with charge code 'OTHERS'
    IF CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsCharges) THEN
        LOCATE 'OTHERS' IN UB.CHRG.CODE<1,1> BY 'AR' SETTING UB.LOC ELSE
        INS 'OTHERS' BEFORE UB.CHRG.CODE<1,UB.LOC>
        IF CHRG.CCY EQ EB.SystemTables.getLccy() THEN
            INS CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsCharges) BEFORE UB.LCY.AMOUNT<1,UB.LOC>
        END ELSE
            INS CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsCharges) BEFORE UB.FCY.AMOUNT<1,UB.LOC>
            INS CQ.ChqIssue.getCqLcyAmt() BEFORE UB.LCY.AMOUNT<1,UB.LOC>
        END
        IF CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate) NE EB.SystemTables.getToday() THEN
            INS CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate) BEFORE UB.CHRG.DATE<1,UB.LOC>
        END
    END
    END

*     Locate for charge code and insert new set if not found,
*     else add amount and tax amount if charge.date is same,
*     else insert a new set for different charge date within a booking date.

    TTL.CHRGS = DCOUNT(CHG.DATA<2>,@VM)

    FOR J.CNT = 1 TO TTL.CHRGS
        BEGIN CASE
            CASE CHG.DATA<2,J.CNT> = 'TAX'
                LOCATE CHG.DATA<1,J.CNT> IN UB.TAX.CODE<1,1> BY 'AR' SETTING UB.LOC ELSE
                INS CHG.DATA<1,J.CNT> BEFORE UB.TAX.CODE<1,UB.LOC>
                INS CHG.DATA<4,J.CNT> BEFORE UB.TAX.LCY.AMT<1,UB.LOC>
                IF CHRG.CCY NE EB.SystemTables.getLccy() THEN
                    INS CHG.DATA<5,J.CNT> BEFORE UB.TAX.FCY.AMT<1,UB.LOC>
                END
            END

        CASE 1
            LOCATE CHG.DATA<1,J.CNT> IN UB.CHRG.CODE<1,1> BY 'AR' SETTING UB.LOC ELSE
            INS CHG.DATA<1,J.CNT> BEFORE UB.CHRG.CODE<1,UB.LOC>
            INS CHG.DATA<4,J.CNT> BEFORE UB.LCY.AMOUNT<1,UB.LOC>
            INS '' BEFORE UB.CHRG.DATE<1,UB.LOC>
            IF CHRG.CCY NE EB.SystemTables.getLccy() THEN
                INS CHG.DATA<5,J.CNT> BEFORE UB.FCY.AMOUNT<1,UB.LOC>
            END
        END
    END CASE
    NEXT J.CNT


    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCode,UB.J.POS> = LOWER(UB.CHRG.CODE)
    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgDate,UB.J.POS> = LOWER(UB.CHRG.DATE)
    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgLcyAmt,UB.J.POS> = LOWER(UB.LCY.AMOUNT)
    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgFcyAmt,UB.J.POS> = LOWER(UB.FCY.AMOUNT)
    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalTaxCode,UB.J.POS> = LOWER(UB.TAX.CODE)
    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxLcyAmt,UB.J.POS> = LOWER(UB.TAX.LCY.AMT)
    CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxFcyAmt,UB.J.POS> = LOWER(UB.TAX.FCY.AMT)


    RETURN
*-----------(Update.Charges)

*-----------------------------------------------------------------------------------------
INITIALISE:
*----------
*     Read Cheque.Charge.Bal File
    UB.CHRG.CODE = ''
    UB.CHRG.DATE = ''
    UB.LCY.AMOUNT = ''
    UB.FCY.AMOUNT = ''
    UB.TAX.CODE = ''
    UB.TAX.LCY.AMT = ''
    UB.TAX.FCY.AMT = ''

    CQ.STATUS = ''
    EXCH.RATE = ''
    CHG.DATA = ''

    IF CHARGE.ACCT EQ '' THEN
        CHG.ACCT = FIELD(CHQ.ID,'.',2)
    END ELSE
        CHG.ACCT = CHARGE.ACCT
    END

    CHEQUE.BAL.REC = CQ.ChqFees.ChequeChargeBal.Read(CHQ.ID, BAL.READ.ERR)

    CQ.STATUS = CHQ.IS.REC(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
    EXCH.RATE = CQ.ChqIssue.getCqExchRate()<1>
    CHG.DATA = CQ.ChqIssue.getCqChgData()

    SH.ARRAY = RAISE(CHEQUE.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus>)

    RETURN
*-----------(Initialise)


    END
*-----(End of routine)
