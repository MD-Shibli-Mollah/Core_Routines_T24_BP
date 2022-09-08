* @ValidationCode : MjoxMDAyMzgxODY5OkNwMTI1MjoxNTc4NDkzNTcwMjQwOnJtYW5pc2hhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzo1NjoxMQ==
* @ValidationInfo : Timestamp         : 08 Jan 2020 19:56:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rmanisha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/56 (19.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>306</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.ACCOUNTING

*-----------------------------------------------------------------------------------------
*
* 21/04/97 - GB9700339
*            EB.ACCOUNTING must be called instead of ACCOUNTING &
*            ACCOUNTING.AUT
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
*  08/09/06 - CI_10043918
*             Exchange Rate not updated for cheque issue
*
*  27/02/09 - CI_10061114
*             Fatal error when CHEQUE.ISSUE in HLD with charges is committed.
*
*  18/09/12 - Task 477300
*            Entry HOLD record is not deleted even if the charges as been waived .
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 07/01/2020 - Defect 3515833 / Task 3526388
*              Code changes done to retain commission/charge/tax code even its value is zero.
*-----------------------------------------------------------------------------------------
*
    $USING AC.API
    $USING EB.SystemTables
    $USING CQ.ChqIssue
*-----------------------------------------------------------------------------------------


*EN_10000101      IF ID.OLD#'' THEN RETURN           ; * remainder 'nochange'
*EN_10000101 -s
    BEGIN CASE
        CASE EB.SystemTables.getVFunction() = 'D'
            IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo)='VAL' THEN
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo, '')
                AC.API.EbAccounting('CC','DEL','','')
            END
        CASE EB.SystemTables.getVFunction() = 'R'

        CASE 1
            DIM R.NEW.REC(EB.SystemTables.SysDim)
            MAT R.NEW.REC = ''
            IF CQ.ChqIssue.getCqCharges() OR CQ.ChqIssue.getCqJCharges() THEN
                YR.MULTI.STMT=''
*                 MATBUILD ACCOUNT FROM CQ$CI.ACCOUNT
                ACCOUNT = CQ.ChqIssue.getCqCiAccount()     ;*  changed to dynamic
*EN_10000101 -e

                IF CQ.ChqIssue.getCqCharges() THEN
                    ACC.ID = CQ.ChqIssue.getCqChequeAccId()
                    CHQ.EXCH.RATE = CQ.ChqIssue.getCqExchRate()
                    CHQ.CHARGE = CQ.ChqIssue.getCqChequeCharge()
                    CHARGES = CQ.ChqIssue.getCqCharges()
                    CHARGE.DATE = CQ.ChqIssue.getCqChargeDate()
                    LCY.AMT = CQ.ChqIssue.getCqLcyAmt()
                    CQ.ChqIssue.ChequeIssueCharges(ACC.ID,ACCOUNT,CHQ.EXCH.RATE,CHQ.CHARGE,CHARGES,CHARGE.DATE,YR.MULTI.STMT,LCY.AMT)  ;*CI_10043918S/E
                    CQ.ChqIssue.setCqLcyAmt(LCY.AMT)
                    CQ.ChqIssue.setCqChargeDate(CHARGE.DATE)
                    CQ.ChqIssue.setCqCharges(CHARGES)
                    CQ.ChqIssue.setCqChequeCharge(CHQ.CHARGE)
                    CQ.ChqIssue.setCqExchRate(CHQ.CHARGE)
                END     ;*(for cheque leaf related charges)

*EN_10000101 -s
*  Update Yr.Multi.Stmt for other charges linked with Ft.Charge.Type & Ft.Commission.Type
                IF CQ.ChqIssue.getCqJCharges() THEN
                    R.REC = EB.SystemTables.getDynArrayFromRNew()
                    MATPARSE R.NEW.REC FROM R.REC
                    ACC.ID = CQ.ChqIssue.getCqChequeAccId()
                    CHQ.EXCH.RATE = CQ.ChqIssue.getCqExchRate()
                    REC.ID = EB.SystemTables.getIdNew()
                    CQ.ChqIssue.ChequeIssueAddnlCharges(ACC.ID, ACCOUNT, MAT R.NEW.REC, CHQ.EXCH.RATE, REC.ID , YR.MULTI.STMT)
                    CQ.ChqIssue.setCqChequeAccId(ACC.ID)
                    CQ.ChqIssue.setCqExchRate(CHQ.EXCH.RATE)
                    MATBUILD R.REC FROM R.NEW.REC
                    EB.SystemTables.setDynArrayToRNew(R.REC)
                END
*EN_10000101 -e

                IF EB.SystemTables.getRNewLast(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[2,2] = 'NA' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo)='VAL' AND EB.SystemTables.getRNewLast(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) EQ 'NO' THEN
                    VAL.CHG='CHG'
                END ELSE
                    VAL.CHG='VAL'
                END
*
** GB9700339
*
* When cheque charge and charges linked with FT.COMMISSION.TYPE, FT COMMISSION.TYPE , TAX is all zero then
* no entries will be formed i.e,YR.MULTI.STMT will null and hence do not call EB.ACCOUNTING without entries.
                IF YR.MULTI.STMT THEN
                    AC.API.EbAccounting('CC',VAL.CHG,YR.MULTI.STMT,'')
                END
                IF EB.SystemTables.getText()='NO' THEN V$ERROR=1
            END ELSE
                IF(EB.SystemTables.getRNewLast(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) EQ 'NO') AND (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) EQ 'YES')  THEN
                    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo, '')
                    AC.API.EbAccounting('CC','DEL','','')
                END
            END
    END CASE

RETURN


END
*-----(End of routine Cheque.Issue.Accounting)
