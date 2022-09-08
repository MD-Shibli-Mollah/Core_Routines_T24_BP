* @ValidationCode : MjoxOTY3OTEzNzk5OkNwMTI1MjoxNTY0NTcyMzg0MDA4OnNyYXZpa3VtYXI6NzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOjc3Ojc3
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:56:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 77/77 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CQ.ChqPaymentStop
SUBROUTINE INITIATE.PAYMENT.STOP(ofsVersion, paymentStopRec, accountId, errText)
*-----------------------------------------------------------------------------
*   API routine to initiate PAYMENT.STOP
*   The Inputs to the API routine are:
*   1. ofsVersion : The Model Version of PAYMENT.STOP to be invoked for processing.
*   2. accountId: A Valid Account Id in core T24, for which Payment Stop needs to be initiated. The ID of PAYMENT.STOP record will be the Account Id.
*   3. paymentStopRec : The payment stop input rec for which PAYMENT.STOP needs to be initiated.
*                       The fields in the input record are @FM separated and order of fields, based on PAYMENT.STOP application, is as below:
*
*   CURRENCY(FldNo.:1):@FM:PAYM.STOP.TYPE(FldNo.:2):@FM:FIRST.CHEQUE.NO(FldNo.:3):@FM:LAST.CHEQUE.NO(FldNo.:4):@FM:CHEQUE.TYPE(FldNo.:6):@FM:
*   STOP.DATE(FldNo.:7):@FM:AMOUNT.FROM(FldNo.:8):@FM:AMOUNT.TO(FldNo.:9):@FM:WAIVE.CHARGE:(FldNo.:11)@FM:BENEFICIARY(FldNo.:12):@FM:
*   STOP.END.FLAG(FldNo.:13):@FM:APPLY.DATE(FldNo.:14):@FM:REMARKS(FldNo.:15):@FM:RAISE.ACTIVITY(FldNo.:16):@FM:CHARGE.CODE(FldNo.:17):@FM:
*   CHG.ACCOUNT(FldNo.:18):@FM:CHG.AMOUNT(FldNo.:20):@FM:CUSTOMER.NO(FldNo.:28):@FM:DATE.OF.ISSUE(FldNo.:29):@FM:ACTION.DATE(FldNo.:30):@FM:
*   OUR.REFERENCE(FldNo.:31):@FM:PAYEE(FldNo.:33):@FM:ANSWERS(FldNo.:34):@FM:SEND.NOTICE(FldNo.35):@FM:MOD.PS.CHQ.NO(FldNo.:43):@FM:MOD.CHQ.TYPE(FldNo.:44):@FM:
*   MOD.PS.DATE((FldNo.:45):@FM:IN.DRAWER.BK.ACCT(FldNo.:47):@FM:IN.DRAWER.BANK(FldNo.:48):@FM:IN.DELIVERY.REF(FldNo.:49):@FM:INWARD.MSG.TYPE(FldNo.:50):@FM:
*   IN.SWIFT.MSG(FldNo.:51):@FM:IN.PROCESS.ERR(FldNo.:52):@FM:DD.BC.SORT.CODE(FldNo.:53):@FM:DD.MANDATE.REF(FldNo.:54):@FM:DD.STOP.TYPE(FldNo.:55)
*
*   Note: The fields above are multi-value fields and associated with each Payment Stop Type (PAYM.STOP.TYPE)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 05/11/18 - Enhancement 2789882 / Task 2789894
*            New Template for STOP.REQUEST.STATUS as part of introducing functionality
*            for inward MT112 advice message and include CHQ.TYPE in outward MT111 stop payment message.
*            1. Introduce inward routine to define functionality for inward MT112 message.
*
** 01/01/2018 - SI 2680108/ Task 2937310
*             - Change Reserved3 to TransReference
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Interface
    $USING EB.Foundation
    $USING EB.Display
*** </region>
*-----------------------------------------------------------------------------
    GOSUB initialize
    
    GOSUB checkPayStopExists ;* Check if Payment Stop INAU/IHLD Record exists for the account id.
    IF errText NE '' THEN
        EB.SystemTables.setApplication(saveApplication)
        RETURN
    END
    
    GOSUB buildOfsData ;* Prepare Ofs Data from Payment Stop input record.
    GOSUB callOfsPostMessage ;*Call OFS Post Message to initiate PAYMENT.STOP
    EB.SystemTables.setApplication(saveApplication) ;* Revert the application from PAYMENT.STOP to original invoking application.
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
*** <desc>Initialise variables, opfs etc</desc>
initialize:
    errText = ''
    
*   Set the Application as PAYMENT.STOP and revert while returning to invoking application.
    saveApplication = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication(ofsVersion)
    
*   Return if Payment Stop Record is not populated.
    IF paymentStopRec EQ '' THEN
        errInfo = 'DE-INP.MISS'
        EB.ErrorProcessing.GetErrorMessage(errInfo)
        errText = 'PAYMENT.STOP RECORD - ':errInfo<1>
        EB.SystemTables.setApplication(saveApplication)
        RETURN
    END

*   Return if Account Number is not provided, on which Payment Stop needs to be initiated.
    IF accountId EQ '' THEN
        errInfo = 'AC-ACCOUNT.NUMBER.MISS'
        EB.ErrorProcessing.GetErrorMessage(errInfo)
        errText = errInfo<1>:" FOR PAYMENT.STOP"
        EB.SystemTables.setApplication(saveApplication)
        RETURN
    END
    
*   Return if the ofsVersion provided is not valid for Payment.stop
    IF ofsVersion EQ '' THEN
        errInfo = 'DE-INP.VERSION.WITH.ROUTINE'
        EB.ErrorProcessing.GetErrorMessage(errInfo)
        errText = errInfo<1>:" PAYMENT.STOP"
    END ELSE
        payStopAppln = FIELD(ofsVersion,',',1)
        IF payStopAppln NE 'PAYMENT.STOP' THEN
            errInfo = 'EB-INVALID.VERSION'
            EB.ErrorProcessing.GetErrorMessage(errInfo)
            errText = errInfo<1>:" ":ofsVersion:" FOR PAYMENT.STOP"
        END
    END
    IF errText NE '' THEN
        EB.SystemTables.setApplication(saveApplication)
        RETURN
    END
    
*   Determine Company
    txnCompany = EB.SystemTables.getIdCompany()
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= checkPayStopExists>
*** <desc>Check if existing Payment Stop Record exists in INAU/IHLD status.</desc>
*** <desc>In such case, new Payment Stop should not be initiated </desc>
checkPayStopExists:
    readErr = ''
    payStopRec = ''
    payStopRec = CQ.ChqPaymentStop.PaymentStop.ReadNau(accountId, readErr) ;* Read PAYMENT.STOP
    IF payStopRec NE '' THEN
        errInfo = 'ST-PAYMENT.STOP.INAU.REC.EXISTS.AUTH.NOT.ALLOWED'
        errInfo = errInfo<1>:@FM:accountId
        errText<-1> = errInfo
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= buildOfsData>
*** <desc>Build Ofs Data to process application PAYMENT.STOP. The Ofs Data is generated based on SS for PAYMENT.STOP</desc>
buildOfsData:
   
*   Invoke OFS.BUILD.RECORD to prepare OFS data for initiating PAYMENT.STOP
    appName = FIELD(EB.SystemTables.getApplication(),',',1) ;* PAYMENT.STOP
    ofsFunc = 'I'
    process = ''
    gtsMode = ''
    noOfAuth = ''
    transactionId = accountId   ;* Define Payment Stop for Account Id provided as Input
    record = paymentStopRec     ;* Payment Stop Input Record for initiating Payment Stop
    payStpAuthRec = ''
    ofsRecord = ''
    
*   Read Authorized record from Payment Stop, if available
    payStpAuthRec = CQ.ChqPaymentStop.PaymentStop.Read(accountId, readErr) ;* Read PAYMENT.STOP
        
*   Append the input Payment Stop Record with existing Authorized Record, for Account Id, before doing OFS Build Record.
*   This is required to avoid the functionality defined in PAYMENT.STOP, to clear fields, when an authorized record
*   is opened for re-inputting Payment Stop Details.
    FOR index1 = CQ.ChqPaymentStop.PaymentStop.AcPayPaymStopType TO CQ.ChqPaymentStop.PaymentStop.AcPayTransReference ;*Excluding the Audit Fields and Override Field.
        IF record<index1> NE '' THEN
            payStpAuthRec<index1,-1> = record<index1>
            record<index1> = payStpAuthRec<index1>
        END
    NEXT index1
   
*   Invoke OFS BUILD RECORD to build ofs Data, based on input record.
    EB.Foundation.OfsBuildRecord(appName, ofsFunc, process, ofsVersion, gtsMode, noOfAuth, transactionId, record, ofsRecord)
RETURN
*-----------------------------------------------------------------------------
*** <region name= callOfsPostMessage>
*** <desc>Call Ofs Post Message to invoke application</desc>
callOfsPostMessage:
    ofsSrc = 'PAYSTOP' ;* OFS SOURCE is set for PAYMENT.STOP
    
*   Invoke OFS Post Message to initiate PAYMENT.STOP.
    IF ofsRecord NE '' THEN
        EB.Interface.OfsPostMessage(ofsRecord,'', ofsSrc, '')
    END
RETURN
*-----------------------------------------------------------------------------
END
