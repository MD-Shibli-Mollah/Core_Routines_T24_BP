* @ValidationCode : MjotMTc1OTYxMTM3MDpDcDEyNTI6MTU2NDU3MTQ1NjE5NzpzcmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>57</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.DELIVERY.PREVIEW
*-----------------------------------------------------------------------------
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 14/08/15 - Enhancement 1265068 / Task 1387491
*           - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*------------------------------------------------------------------------------
    $USING CQ.ChqFees
    $USING EB.Display
    $USING EB.SystemTables
    $USING CQ.ChqIssue

    GOSUB INITIALISE
    GOSUB PREVIEW.PROCESS

RETURN

INITIALISE:
*==========

    BAL.ERR = ''
    BOOK.DATE = ''
    CNT.BK.STS = ''
    BK.CNT = 1
    BAL.CHG.CODE = ''
    BAL.CHG.AMT = ''
    BAL.TAX.AMT = ''
    CHG.DATE = ''

RETURN

PREVIEW.PROCESS:
*===============

    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] EQ 'RNA' OR EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus) EQ 'REVE' THEN
        RETURN                          ; * no preview during Reverse function
    END

    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] NE 'INA' AND EB.SystemTables.getVFunction() EQ "S" THEN
        GOSUB CHARGES.PROCESS
    END

    GOSUB CALL.DELIVERY

RETURN

CHARGES.PROCESS:
*===============

    CH.ID = EB.SystemTables.getIdNew()
    CH.STS = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
    CH.BAL.REC = '' ; BAL.ERR = ''
    CH.BAL.REC = CQ.ChqFees.ChequeChargeBal.Read(CH.ID, BAL.ERR)

    STS.CNT = DCOUNT(CH.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus>,@VM)
    FOR S.CNT = 1 TO STS.CNT
        IF CH.STS EQ CH.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus,S.CNT> THEN
            STS.POS = S.CNT
            CHRG.CODE.CNT = DCOUNT(CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCode,STS.POS>,@SM)
            TAX.CODE.CNT = DCOUNT(CH.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalTaxCode,STS.POS>,@SM)
        END
    NEXT S.CNT

    FOR CNT.CHG = 1 TO CHRG.CODE.CNT
        CHG.CODE = CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCode, STS.POS, CNT.CHG>
        IF CHG.CODE EQ 'OTHERS' THEN CHG.DATE = CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgDate,STS.POS>

        C.AMOUNT = CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgFcyAmt, STS.POS, CNT.CHG>
        IF NOT(C.AMOUNT) THEN
            C.AMOUNT = CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgLcyAmt, STS.POS, CNT.CHG>
        END
        BAL.CHG.AMT<-1> = C.AMOUNT
        BAL.CHG.CODE<-1> = CHG.CODE
    NEXT CNT.CHG

    FOR CNT.TAX = 1 TO TAX.CODE.CNT
        BAL.TAX.CODE<-1> = CH.BAL.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalTaxCode, STS.POS, CNT.TAX>
        T.AMOUNT = CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxFcyAmt, STS.POS, CNT.TAX>
        IF NOT(T.AMOUNT) THEN
            T.AMOUNT = CH.BAL.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxLcyAmt, STS.POS, CNT.TAX>
        END
        BAL.TAX.AMT<-1> = T.AMOUNT
    NEXT CNT.TAX

    CONVERT @FM TO @VM IN BAL.CHG.CODE
    CONVERT @FM TO @VM IN BAL.CHG.AMT
    CONVERT @FM TO @VM IN BAL.TAX.AMT

RETURN

CALL.DELIVERY:
*=============

    CQ.ChqIssue.ChequeIssueDelivChgDets(CHARGE.ARRAY,BAL.CHG.CODE,BAL.CHG.AMT,BAL.TAX.AMT,CHG.DATE)
    IF CHARGE.ARRAY THEN
        CQ.ChqIssue.ChequeIssueDelivery(CHARGE.ARRAY)
    END ELSE
        EB.SystemTables.setText("NO MESSAGE TO BE PREVIEWED")
        EB.Display.Rem()
    END

RETURN

END
