* @ValidationCode : MjotMTExNDc1MTYzOTpDcDEyNTI6MTU2NDU3MTQ1NjA0ODpzcmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
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
* <Rating>-43</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISS.CHECK.NOT.ALREADY.ISSUED
*-----------------------------------------------------------------------------------------
*  This routine is the conversion of GOSUB CHECK.NOT.ALREADY.ISSUED
*  to CALL CHEQUE.ISS.CHECK.NOT.ALREADY.ISSUED
*-----------------------------------------------------------------------------------------
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

    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING EB.API
    $USING CQ.ChqIssue

    GOSUB CHECK.NOT.ALREADY.ISSUED

RETURN


* GB9900548 (Starts)
*
*
CHECK.NOT.ALREADY.ISSUED:
*-----------------------

    NO.OF.ISS = DCOUNT(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>,@VM)
    FOR ISS.NO = 1 TO NO.OF.ISS
        START.NO = FIELD(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos,ISS.NO>,"-",1)
        END.NO = FIELD(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos,ISS.NO>,"-",2)
        tmp.CQ$RANGE.FIELD = CQ.ChqIssue.getCqRangeField()
        EB.API.MaintainRanges(tmp.CQ$RANGE.FIELD, START.NO, END.NO, "ENQ", RESULT, CHQ.ERROR)
        CQ.ChqIssue.setCqRangeField(tmp.CQ$RANGE.FIELD)
        IF RESULT THEN
            EB.SystemTables.setE("ST.RTN.CHEQUE/S.ALRDY.ISSUED")
            EXIT
        END
    NEXT ISS.NO

RETURN
* GB9900548 (Ends)
*
*
END
