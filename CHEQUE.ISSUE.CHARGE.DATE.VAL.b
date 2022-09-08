* @ValidationCode : MjoyMDk2OTcyMzg3OkNwMTI1MjoxNTY0NTcxNDU2MDg1OnNyYXZpa3VtYXI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
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
* <Rating>66</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.CHARGE.DATE.VAL

*     This routine is the conversion of GOSUB CHARGE.DATE.VAL
*-----------------------------------------------------------------------------------------
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
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
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
*-----------------------------------------------------------------------------------------

    $USING EB.Utility
    $USING EB.SystemTables
    $USING CQ.ChqIssue


    GOSUB CHARGE.DATE.VAL

RETURN
*-----------(Main)



CHARGE.DATE.VAL:
*===============
    IF CQ.ChqIssue.getCqChargeDate()#'' THEN
        IF CQ.ChqIssue.getCqCharges() THEN
            BEGIN CASE
                CASE CQ.ChqIssue.getCqChargeDate() GT EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum)
                    EB.SystemTables.setE('ST.RTN.DATE.EXCEEDS.FWD.VALUE.MAX')
                CASE CQ.ChqIssue.getCqChargeDate() LT EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum)
                    EB.SystemTables.setE('ST.RTN.DATE.EXCEEDS.BACK.VALUE.MAX')
            END CASE
        END ELSE
            EB.SystemTables.setE('ST.RTN.NO.INP.WITHOUT.CHRG')
        END
        IF EB.SystemTables.getE() THEN RETURN                ; * EN_10000101
        IF CQ.ChqIssue.getCqChargeDate() LT CQ.ChqIssue.getCqIssueStartDate() AND CQ.ChqIssue.getCqIssueStartDate() <> '' THEN
            EB.SystemTables.setE('ST.RTN.NEXT.ISSUE.PERIOD')
            RETURN                       ; * EN_10000101
        END
    END ELSE
        IF CQ.ChqIssue.getCqCharges() THEN
            CQ.ChqIssue.setCqChargeDate(EB.SystemTables.getToday())
        END
    END

RETURN
*-----------(Charge.Date.Val)

*
END
*-----(End of routine Cheque.Issue.Charge.Date.Val)
