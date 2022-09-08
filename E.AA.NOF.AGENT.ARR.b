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
* <Rating>-17</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AG.ModelBank
    SUBROUTINE E.AA.NOF.AGENT.ARR(AR.ID)
**********************************
*MODIFICATION HISTORY
*
* 05/06/14 - Task Id 1016833
*            Nofile routine to display AA.AGENT.COMMISSION.DETAILS information
*
* 16/02/14 - Task : 1255763
*            Defect : 1254429
*            Payment date should be passed to the enquiry AA.AGENT.COMMISSION.DETAILS
*
***********************************************************************
    $USING AA.PaymentSchedule
    $USING AA.AgentCommission
    $USING EB.Reports


    GOSUB PROCESS

    RETURN

PROCESS:
*-------
    LOCATE "BILL.ID" IN EB.Reports.getDFields()<1,1> SETTING ID.POS THEN
    BILL.ID = EB.Reports.getDRangeAndValue()<1,ID.POS>
    END

    F.AG.COMMISION = ''

    R.AG.COMMISSION = AA.AgentCommission.AaAgentCommissionDetails.Read(BILL.ID, E.AG.COMMISION)

    IF E.AG.COMMISION THEN
        AR.ID = "No Record in Agent Commission Details"
        RETURN
    END

* Read AA.BILL.DETAILS to get a payment date
    F.AA.BILL.DETAILS = ""
    R.AA.BILL.DETAILS = AA.PaymentSchedule.BillDetails.Read(BILL.ID, BILL.ERR)

    IF R.AA.BILL.DETAILS THEN
        PAYMENT.DATE = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
    END ELSE
        * If bills archieved then read bill from .HIST file and get a payment date
        F.AA.BILL.DETAILS.HIS = ""
        R.AA.BILL.DETAILS.HIS = AA.PaymentSchedule.BillDetails.ReadHis(BILL.ID,BILL.HIS.ERR)
        IF R.AA.BILL.DETAILS.HIS THEN
            PAYMENT.DATE = R.AA.BILL.DETAILS.HIS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
        END
    END

    ARRANGE.ID = R.AG.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetArrangement>
    COM.AMOUNT = R.AG.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetAmount>
    MARGIN.AMOUNT = R.AG.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetMarginAmount>
    MARGIN.RATE =   R.AG.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetMarginRate>
    MARGIN.PERCENT =R.AG.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetMarginPercent>

    CHANGE '*' TO @VM IN ARRANGE.ID
    CHANGE '*' TO @VM IN COM.AMOUNT
    CHANGE '*' TO @VM IN MARGIN.AMOUNT
    CHANGE '*' TO @VM IN MARGIN.RATE
    CHANGE '*' TO @VM IN MARGIN.PERCENT  

    ARR.CNT = DCOUNT(ARRANGE.ID,@VM)
    ARR.INT = 1
    LOOP
    WHILE ARR.INT LE ARR.CNT
        AR.ID<-1> = ARRANGE.ID<1,ARR.INT>:'*':COM.AMOUNT<1,ARR.INT>:'*':MARGIN.AMOUNT<1,ARR.INT>:'*':MARGIN.RATE<1,ARR.INT>:'*':MARGIN.PERCENT<1,ARR.INT>:'*':PAYMENT.DATE
        ARR.INT++
    REPEAT
    RETURN
    END
