* @ValidationCode : MjotOTQ5MjE5NDc2OkNwMTI1MjoxNjA5NDg0NDAwNTExOnZpZ25lc2hyYW1lc2g6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkyOS0xMjEwOjMxOjMx
* @ValidationInfo : Timestamp         : 01 Jan 2021 12:30:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vigneshramesh
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/31 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.CustomerIdentification
SUBROUTINE QI.CUSTOMER.IDENTIFICATION(CUSTOMER.ID, QI.CUST.SUPP.INFO, RULE.ID, RES.IN2, CUS.QI.STATUS, CUS.DOC.TYPE, RES.OUT2, RES.OUT3)
* Sample API to get the CUS.QI.STATUS and Cus.Document type if applicable corresponding to the customer residence and sector.
*
* Arguments:
*-------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* QI.CUST.SUPP.INFO          (IN)    - Incoming QCSI Record Details
*
* RULE.ID                    (IN)    - Incoming Reserved Arguments
*
* RES.IN2                    (IN)    - Incoming Reserved Arguments
*
* CUS.QI.STATUS              (OUT)   - Outgoing QI STATUS TYPE
*
* CUS.DOC.TYPE               (OUT)   - Document type
*
* RES.OUT2,RES.OUT3          (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/12/20 - SI 3436252 / TASK 4143346
*            Sample API to SET CUS.QI.STATUS
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING RT.Config
    $USING QI.Config
    $USING EB.SystemTables
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    IF RULE.ID THEN
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    
    RULE.RESULT = ''
    ERR.INFO1 = ''
    ERR.INFO2 = ''
    CUS.QI.STATUS = ''
    CUS.DOC.TYPE = ''

    IF NOT(RULE.ID) THEN
* Read QI Parameter to get the Rule ID
        PARAM.ID = EB.SystemTables.getIdCompany()
        R.QI.PARAMETER = ''
        PARAM.ER = ''
        QI.Config.QiReadParameter(PARAM.ID, R.QI.PARAMETER, PARAM.ER, '', '', '')
* Return if Rule is not defined in parameter
        LOCATE 'QI.CUSTOMER.IDENTIFICATION' IN R.QI.PARAMETER<QI.Config.QiParameter.QiParRuleType,1> SETTING RULE.POS ELSE
            RETURN
        END
        RULE.ID = R.QI.PARAMETER<QI.Config.QiParameter.QiParRuleName,RULE.POS>
    END
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
* Call the API to execute the rule
    RULE.TYPE<1> = ''
    RECORD.INFO = 'QI.CUSTOMER.SUPPLEMENTARY.INFO*':QI.CUST.SUPP.INFO
    RT.Config.RtExecuteRegulatoryRules(CUSTOMER.ID, RULE.ID, RULE.TYPE,'', RECORD.INFO, RULE.RESULT, '', '', '', '')
    

* Return the result
    IF (RULE.RESULT) THEN
        CUS.QI.STATUS = FIELD(RULE.RESULT,'*',1)
        IF FIELD(RULE.RESULT,'*',2) THEN
            CUS.DOC.TYPE = FIELD(RULE.RESULT,'*',2)
        END
    END
   

RETURN
*-----------------------------------------------------------------------------
END
