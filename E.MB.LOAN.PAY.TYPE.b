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

*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : ENQUIRY record AI.AA.DETAILS.LOAN.AMOUNT
* Attached as     : Conversion Routine
*---------------------------------------------------------------------------------------------------------------
*                      M O D I F I C A T I O N S
*---------------------------------------------------------------------------------------------------------------

    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.LOAN.PAY.TYPE

    $USING AA.PaymentSchedule
    $USING EB.Reports


    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS

    EB.Reports.setOData(PAY.TYPE.DES)

    RETURN

INITIALISE:

    Y.ID=EB.Reports.getOData()

    F.PAY.SCH=''

    F.PAY.TYPE=''

    PAY.TYPE=''

    PAY.TYPE.DES=''

    RETURN

OPENFILE:

    RETURN

PROCESS:

    REC.PAYMENT = AA.PaymentSchedule.ArrPaymentSchedule.Read(Y.ID,REC.ERROR)

    PAY.TYPE=REC.PAYMENT<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>

    LOOP

        REMOVE PAY.TYPE.ID FROM PAY.TYPE SETTING POS

    WHILE PAY.TYPE.ID:POS

        REC.PAY.TYPE = AA.PaymentSchedule.PaymentType.Read(PAY.TYPE.ID, R.ERROR)

        PAY.TYPE.DES<1,-1>=REC.PAY.TYPE<AA.PaymentSchedule.PaymentType.PtDescription>

    REPEAT

    CONVERT @VM TO "&" IN PAY.TYPE.DES

    RETURN
    END
