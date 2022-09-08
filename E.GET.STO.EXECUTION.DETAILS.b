* @ValidationCode : MjotMjI2MjcwMzkzOkNwMTI1MjoxNTQ5NTIwNDg2Mjg4OnNhc2lrdW1hcnY6NzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4yMDE5MDIwMS0wODAwOjYyOjYx
* @ValidationInfo : Timestamp         : 07 Feb 2019 11:51:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sasikumarv
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 61/62 (98.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190201-0800
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
SUBROUTINE E.GET.STO.EXECUTION.DETAILS
*-----------------------------------------------------------------------------
* Conversion Routine to Fetch details of Execution of STO
*-----------------------------------------------------------------------------
* Modification History :
*
* 30/01/19 - Task 2966009
*            New Conversion Routine
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AC.StandingOrders
*-----------------------------------------------------------------------------
    
    EnqSelection = ''
    
    EnqSelection = EB.Reports.getEnqSelection()
    
    FieldData = EnqSelection<2>     ;*get selection fields
    OperandData = EnqSelection<3>   ;*get selection operands
    ValueData = EnqSelection<4>     ;*get selection values
    
    StoId = EB.Reports.getOData() ;*get STO id
    
    LOCATE 'ACTUAL.PROCESSING.DATE' IN FieldData<1,1> SETTING DatePos THEN
        ExecDate = ValueData<1,DatePos>
        Operand = OperandData<1,DatePos>
    END
    
    StoRecord = EB.Reports.getRRecord()
    
    IF StoRecord EQ '' THEN
        RETURN  ;*return if no record is found
    END

*get the Execution details
    PaymentReference = StoRecord<AC.StandingOrders.StandingOrder.StoPaymentReference>
    ActualProcessingDate =  StoRecord<AC.StandingOrders.StandingOrder.StoActualProcessingDate>
    ExecutionTime = StoRecord<AC.StandingOrders.StandingOrder.StoActualExecutionTime>
    
    DateCnt = DCOUNT(ActualProcessingDate,@VM)
    
    ReturnDataContent = ''
    
    IF ExecDate EQ '' THEN  ;*if no date is provided return all the Execution details
        ReturnDataContent = SPLICE(PaymentReference,'~',ActualProcessingDate)
        ReturnDataContent = SPLICE(ReturnDataContent,'~',ExecutionTime)
    END ELSE
        GOSUB GET.DATES ;*if date provided, return only the details that satisfies the condition
    END
    
    EB.Reports.setOData(ReturnDataContent<1,EB.Reports.getVc()>)    ;*set return data for display
    EB.Reports.setVmCount(DCOUNT(ReturnDataContent,@VM))            ;*set value to indicate the number of MV returned
    
RETURN
*-----------------------------------------------------------------------------
GET.DATES:
*Loop through each processing date and check if its matches the selection criteria date
    
    FOR DateLoop = 1 TO DateCnt
        
        DateToProcess = ActualProcessingDate<1,DateLoop>
        
        BEGIN CASE
            CASE Operand EQ 'EQ'
                IF DateToProcess EQ ExecDate THEN
                    GOSUB FETCH.DATA
                END
            CASE Operand EQ 'LE'
                IF DateToProcess LE ExecDate THEN
                    GOSUB FETCH.DATA
                END
            CASE Operand EQ 'LT'
                IF DateToProcess LT ExecDate THEN
                    GOSUB FETCH.DATA
                END
            CASE Operand EQ 'GE'
                IF DateToProcess GE ExecDate THEN
                    GOSUB FETCH.DATA
                END
            CASE Operand EQ 'GT'
                IF DateToProcess GT ExecDate THEN
                    GOSUB FETCH.DATA
                END
            CASE Operand EQ 'RG'
                ExecDateStart = FIELD(ExecDate,' ',1)
                ExecDateEnd = FIELD(ExecDate,' ',2)
                IF (DateToProcess GE ExecDateStart) OR (DateToProcess LE ExecDateEnd) THEN
                    GOSUB FETCH.DATA
                END
        END CASE
    
    NEXT DateLoop
    
RETURN
*-----------------------------------------------------------------------------
FETCH.DATA:
    
    ReturnDataContent<1,-1> = PaymentReference<1,DateLoop>:'~':ActualProcessingDate<1,DateLoop>:'~':ExecutionTime<1,DateLoop>

RETURN
*-----------------------------------------------------------------------------
END
