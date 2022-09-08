* @ValidationCode : MjoxODM3OTk4MDAyOkNwMTI1MjoxNjEwOTY0NTc0MDc5OnZpZ25lc2hyYW1lc2g6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Jan 2021 15:39:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vigneshramesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.CustomerIdentification
SUBROUTINE QI.CHECK.ADDRESS.CONFLICT(CUSTOMER.ID, QI.CUST.SUPP.INFO, RULE.ID, RES.IN1, US.ADDR.CONFLICT, CONFLICT.REASON, DOC.RECVD, RES.OUT3)
*-----------------------------------------------------------------------------
* Sample API to check Address Conflict in QI
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* QI.CUST.SUPP.INFO          (IN)    - Incoming QCSI Record
*
* RULE.ID                    (IN)    - US Address Conflict Rule Id defined in QI parameter recrd
*
* RES.IN1                    (IN)    - Incoming Reserved Argument
*
* US.ADDR.CONFLICT           (OUT)   - Y/N, US Address Conflict indicator result
*
* CONFLICT.REASON            (OUT)   - Reason for Conflict of Address, if Addr Conflict is Y
*
* DOC.RECVD                  (OUT)   - Document received (WDTT), in case when No Address conflict
*
* RES.OUT2,RES.OUT3          (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/12/20 - SI 3436249 / Task 4149519
*            Sample API to check Address Conflict in QI
*
* 18/01/21 - SI 3436249 / Task 4184032
*            Assigning one parameter for Doc.Received to be returned from rule
*
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING RT.Config
    $USING QI.Config
    $USING EB.SystemTables
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    RULE.RESULT = ''
    ERR.INFO1 = ''
    ERR.INFO2 = ''
    RESULT = ''
    US.ADDR.CONFLICT = ''
    CONFLICT.REASON = ''
    DOC.RECVD = ''

* Read QI Parameter to get the Rule ID
    IF NOT(RULE.ID) THEN
        PARAM.ID = EB.SystemTables.getIdCompany()
        R.QI.PARAMETER = ''
        PARAM.ER = ''
        QI.Config.QiReadParameter(PARAM.ID, R.QI.PARAMETER, PARAM.ER, '', '', '')
        LOCATE 'QI.ADDRESS.CONFLICT.INDICATOR' IN R.QI.PARAMETER<QI.Config.QiParameter.QiParRuleType,1> SETTING RULE.POS THEN
            RULE.ID = R.QI.PARAMETER<QI.Config.QiParameter.QiParRuleName,RULE.POS>
        END
    END
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:

* Return if Rule is not defined in parameter
    IF NOT(RULE.ID) THEN
        RETURN
    END

* Call the API to execute the rule
    RULE.TYPE = ''
    RNEW.INFO = 'QI.CUSTOMER.SUPPLEMENTARY.INFO*':QI.CUST.SUPP.INFO
    RT.Config.RtExecuteRegulatoryRules(CUSTOMER.ID, RULE.ID, RULE.TYPE, '', RNEW.INFO, RULE.RESULT, ERR.INFO1, ERR.INFO2, '', '')
        
    RULE.RESULT = TRIM(RULE.RESULT,"'",'R')     ;* trim all quotes
    ADDR.CONFLICT.RESULT = FIELD(RULE.RESULT,'*',1)       ;* Address Conflict

* Return the result (Y/N)
    BEGIN CASE
        CASE ADDR.CONFLICT.RESULT EQ 'YES'
            US.ADDR.CONFLICT = ADDR.CONFLICT.RESULT[1,1]          ;* Y
            CONFLICT.REASON = FIELD(RULE.RESULT,'*',2)            ;* Reason for conflict
        CASE ADDR.CONFLICT.RESULT EQ 'NO'
            US.ADDR.CONFLICT = ADDR.CONFLICT.RESULT[1,1]          ;* N
            DOC.RECVD = FIELD(RULE.RESULT,'*',2)                  ;* in case if WDTT doc received
        CASE 1
            CONFLICT.REASON = RULE.RESULT
    END CASE

RETURN
*-----------------------------------------------------------------------------
END


