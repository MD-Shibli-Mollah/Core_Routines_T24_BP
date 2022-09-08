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
* <Rating>-75</Rating>
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------------------
*Description:
************
*The routine is used to capture the event while the transaction inputted and authorised using mandate
*-----------------------------------------------------------------------------------------------------------------
*Modification History:
**********************
* 02/08/13 - Task 668952/ Enhancement 644961
*            Email notification to the signatories for pending payments
*
* 01/11/13 - Task 825442 / Defect 825430
*            Parameter removed from the routine "EB.MANDATE.AUTH.UNAUTH.EVENT "
*
* 18/08/14 - Task 911253 / Enhancement 897278
*            Customer & Account mandates.
*
* 15/09/15 - Defect 1456020 / Task 1470492
*            Email is not triggered when the signatories are set with email notification.
*
* 06/04/16 - Enhancement 1474899
*          - Task 1486674
*          - Routine incorporated
*
*-----------------------------------------------------------------------------------------------------------------
    $PACKAGE EB.Mandate

    SUBROUTINE EB.MANDATE.AUTH.UNAUTH.EVENT (EXTERNAL.MANDATE.ID)

    $USING EB.Mandate
    $USING EB.Interface
    $USING EB.ARC
    $USING DD.Contract
    $USING AC.StandingOrders
    $USING FT.BulkProcessing
    $USING FT.Contract
    $USING ST.Customer
    $USING ST.CompanyCreation
    $USING EB.Security
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.AlertProcessing


    GOSUB INIT
    GOSUB PROCESS

    RETURN
*----------------------------------------------------------------------------------------------------------------------
*** <region name = INIT>
INIT:
****
    MANDATE.ID = EXTERNAL.MANDATE.ID    ;* To store Mandate Id
    NO.OF.PERSION=''          ;* To store count of remaining persion for authorisation
    NO.OF.GROUP.PERSION=' '
    SIGN.LIST=''    ;* To store signatory lists from transaction
    CUSTOMER.ALLOWED=''       ;* To store allowed customer
    CUSTOMER.NO=''  ;* To store signatory customer number
    CUSTOMER.LIST=''          ;* Allowed customer list
    MIN.SIGNATORIES=''        ;* Minimum signatories value from mandate
    CUST.ALLOWED='' ;*To store allowed customer
    CUSTOMER.ALLOWLIST=''     ;* Allowed customer list  from mandate
    UNSIGNED.CUST.LIST=''     ;*Allowed customer list

    RETURN

***</region>
*----------------------------------------------------------------------------------------------------------------------
PROCESS:
*** <desc> get the list of customers allowed to authorise the transaction</desc>
    EB.Mandate.GetSignatories(MANDATE.ID,'','',CUST.ALLOWED,MIN.SIGNATORIES)
    CUSTOMER.ALLOWED=CUST.ALLOWED
    CHANGE @SM TO @FM IN CUST.ALLOWED
    GOSUB GET.SIGN.LIST
    IF SIGN.LIST NE '' THEN   ;* Authorisation Process , Get the next level signatories from current signatory group.
        GOSUB NEXT.LEVEL.SIGNATORY.PROCESS
    END ELSE
        FOR SIGN.CNT = 1 TO DCOUNT(CUST.ALLOWED,@FM)
            CUSTOMER.NO = CUST.ALLOWED<SIGN.CNT>
            LOCATE CUSTOMER.NO IN CUSTOMER.LIST SETTING CUS.POS THEN ELSE       ;*Check whether the customer is already located(duplicate)
            GOSUB MANDATE.EVENT.DETECT        ;* To capture the event in input level
        END
        CUSTOMER.LIST<-1> = CUSTOMER.NO
    NEXT SIGN.CNT
    END

    RETURN
***</region>
*--------------------------------------------------------------------------------------------------------------------------------------
*** <region name = NEXT.LEVEL.SIGNATORY.PROCESS>
NEXT.LEVEL.SIGNATORY.PROCESS:
*** <desc>Check the duplicate signatories and already authorised sigantories</desc>
    FOR CUSTCOUNT= 1 TO DCOUNT(CUSTOMER.ALLOWED,@FM)
        SIGNED.CUST.LIST=''
        UNSIGNED.CUST.LIST=''
        IF MIN.SIGNATORIES<CUSTCOUNT> GT 1 THEN   ;* Minimum signatory is > 1 then create a delivery message for other signatories
            CUSTOMER.ALLOWLIST=CUSTOMER.ALLOWED<CUSTCOUNT>  ;*Allowed signatories list
            CONVERT @SM TO @VM IN CUSTOMER.ALLOWLIST
            GOSUB GET.SIGNATORY.CUSTOMER.GROUP    ;*Get the remaining signatories from the signatories group
        END
    NEXT CUSTCOUNT

    RETURN
***</region>
*--------------------------------------------------------------------------------------------------------------------------------------
*** <region name =GET.SIGNATORY.CUSTOMER.GROUP>
GET.SIGNATORY.CUSTOMER.GROUP:
***<desc>Find the current signatory group</desc>
    IF SIGN.LIST<1,1> MATCHES CUSTOMER.ALLOWLIST THEN       ;*Find the current signatory group
        GOSUB NEXT.LEVEL.SIGNATORY.LIST
    END

    RETURN
***</region>
*--------------------------------------------------------------------------------------------------------------------------------------
*** <region name = NEXT.LEVEL.SIGNATORY.LIST>
NEXT.LEVEL.SIGNATORY.LIST:
***<desc>Next level signatory list</desc>
    LOOP
        REMOVE CUS.ID FROM CUSTOMER.ALLOWLIST SETTING CU.POS
    WHILE CUS.ID:CU.POS
        IF CUS.ID MATCHES SIGN.LIST THEN
            SIGNED.CUST.LIST<-1>=CUS.ID ;* To store already signed customers for the current signatory group
        END ELSE
            LOCATE CUS.ID IN CUSTOMER.LIST SETTING C.POS THEN ELSE    ;*Check whether the customer is already located(duplicate)
            CUSTOMER.LIST<-1>=CUS.ID          ;* To store remaining signatory for the current signatory group
            UNSIGNED.CUST.LIST<-1>=CUS.ID     ;* To store remaining signatory for the current signatory group
        END
    END
    REPEAT
    GOSUB FORM.NEXT.SIGNATORY.MSG       ;* To get number of signatories for email notification.

    RETURN
***</region>
*--------------------------------------------------------------------------------------------------------------------------------------
*** <region name =FORM.NEXT.SIGNATORY.MSG>
FORM.NEXT.SIGNATORY.MSG:
***<desc>To capture the event in authorisation level</desc>
    NO.OF.PERSION = MIN.SIGNATORIES<CUSTCOUNT>-DCOUNT(SIGNED.CUST.LIST,@FM)
    NO.OF.GROUP.PERSION=' ':NO.OF.PERSION:' more '
    LOOP
        REMOVE UNSINGED.CUST.ID FROM UNSIGNED.CUST.LIST SETTING C.POS
    WHILE UNSINGED.CUST.ID:C.POS
        CUSTOMER.NO=UNSINGED.CUST.ID
        GOSUB MANDATE.EVENT.DETECT      ;* To capture the event in authorisation level
    REPEAT

    RETURN
***</region>
*--------------------------------------------------------------------------------------------------------------------------------------
*** <region name = GET.SIGN.LIST>
***<desc> Signatory customer list for the mandate application </desc>
GET.SIGN.LIST:
****

    ERR.MSG = ''
    DIM APPLICATION.RECORD(EB.SystemTables.SysDim)    ;* Dimensioned variable to hold R.NEW
    DATA.REQUIRED = 1
    APPL.FIELD.NAME = 'SIGNATORY'       ;* Field name to be fetched from the record
    APPLICATION.DETAILS<1> = EB.SystemTables.getApplication()          ;* Name of the application
    APPLICATION.DETAILS<2> = EB.SystemTables.getIdNew()     ;* ID of the transaction
    APPL.RECORD.DYN = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE APPLICATION.RECORD FROM APPL.RECORD.DYN
    APPL.FIELD.DATA = ''
    EB.Mandate.GetApplFieldData (APPLICATION.DETAILS, MAT APPLICATION.RECORD, MANDATE.DETAILS, DATA.REQUIRED, APPL.FIELD.NAME, '', APPL.FIELD.DATA, ERR.MSG, '', '')

    SIGN.LIST = APPL.FIELD.DATA         ;* Contains the SIGNATORY field value.

    RETURN
*** </region>
*-------------------------------------------------------------------------------------------------------------------------------------
*** <region name = MANDATE.EVENT.DETECT>
MANDATE.EVENT.DETECT:
*** <desc> call the TEC.RECORD.EVENT routine to capture the event </desc>
    R.NEW.REC = EB.SystemTables.getDynArrayFromRNew()
    R.OLD.REC = EB.SystemTables.getDynArrayFromROld()
    DIM LINKED.VALUE(9)
    MAT LINKED.VALUE = ''
    LINKED.VALUE(1) = R.NEW.REC
    LINKED.VALUE(2) = R.OLD.REC
    DE.O.MSG.DET = ''

    GOSUB DE.O.MSG.DET
    LINKED.VALUE(3) = DE.O.MSG.DET
    IF MANDATE.ACCOUNT THEN
        GOSUB READ.CUSTOMER
        DE.O.HEADER.DET = ''
        DE.O.HEADER.DET = EB.SystemTables.getIdCompany()    ;*Position 1 - COMPANY
        DE.O.HEADER.DET := @FM:EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)      ;*Position 2 - CUS.COMPANY
        DE.O.HEADER.DET := @FM:EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>          ;*Position 3 - DEPARTMENT
        DE.O.HEADER.DET := @FM:R.CUSTOMER<ST.Customer.Customer.EbCusLanguage>   ;*Position 4 - LANGUAGE
        DE.O.HEADER.DET := @FM:EB.SystemTables.getIdNew()    ;*Position 5 - TRANSACTION REF
        DE.O.HEADER.DET := @FM:CUSTOMER.NO         ;*Position 6 - CUSTOMER
        DE.O.HEADER.DET :=@FM:NO.OF.GROUP.PERSION  ;*Position 7 - Number of persion in one group
        LINKED.VALUE(8) = DE.O.HEADER.DET
        EB.AlertProcessing.TecRecordEvent('EB.MANDATE',MANDATE.ACCOUNT,'',R.NEW.REC,MAT LINKED.VALUE,'','','')
    END

    RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------
*** <region name = DE.O.MSG.DET>
DE.O.MSG.DET:
*** <desc>Get the value to be passed in delivery message</desc>
    R.MANDATE.PARAMETER = ''  ;* EB.MANDATE.PARAMETER record
    APPLICATION.DETAILS = ''
    APPLICATION.DETAILS<1> = EB.SystemTables.getApplication()          ;* better store the application name in another variable and use it
    APPLICATION.DETAILS<2> = EB.SystemTables.getIdNew()
   APPL.RECORD.DYN = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE APPLICATION.RECORD FROM APPL.RECORD.DYN
    MANDATE.DETAILS = ''      ;* MANDATE.DETAILS<4> is passed as blank to fetch the field names and values for all the identifiers defined in EB.MANDATE.PARAMETER.
    MANDATE.DATA = ''
    APPL.FIELD.NAME = ''
    APPL.FIELD.DATA = ''
    EB.Mandate.MandateParamFieldData(APPLICATION.DETAILS,MAT APPLICATION.RECORD,MANDATE.DETAILS,R.MANDATE.PARAMETER,MANDATE.DATA,APPL.FIELD.NAME,APPL.FIELD.DATA,RESERVED1,RESERVED2)

    MANDATE.ACCOUNT = ''
    MANDATE.CURRENCY = ''
    MANDATE.AMOUNT = ''
    MANDATE.VALUE.DATE = ''

    LOCATE 'ACCOUNT' IN MANDATE.DATA SETTING ACC.POS THEN
    MANDATE.ACCOUNT = APPL.FIELD.DATA<ACC.POS,1>
    END
    LOCATE 'CURRENCY' IN MANDATE.DATA SETTING CCY.POS THEN
    MANDATE.CURRENCY = APPL.FIELD.DATA<CCY.POS,1>
    END
    LOCATE 'AMOUNT' IN MANDATE.DATA SETTING AMT.POS THEN
    MANDATE.AMOUNT = APPL.FIELD.DATA<AMT.POS,1>
    END
    LOCATE 'VALUE.DATE' IN MANDATE.DATA SETTING VD.POS THEN
    MANDATE.VALUE.DATE = APPL.FIELD.DATA<VD.POS,1>
    END

    DE.O.MSG.DET = MANDATE.ACCOUNT      ;*Position 1 - Account No
    DE.O.MSG.DET := @FM:MANDATE.CURRENCY ;* Position 2 - Currency
    DE.O.MSG.DET := @FM:MANDATE.AMOUNT   ;* Position 3 - Amount
    DE.O.MSG.DET := @FM:MANDATE.VALUE.DATE         ;* Position 4 - Value Date
    AUDIT.FIELD.NO = 9        ;* Update the audit fields
    LOOP
    WHILE AUDIT.FIELD.NO
        tmp.V = EB.SystemTables.getV()
        DE.O.MSG.DET := @FM:EB.SystemTables.getRNew(tmp.V-AUDIT.FIELD.NO)
        AUDIT.FIELD.NO -= 1
    REPEAT
* Position 5 - Record Status
* Postion 6 - Curr No
* Position 7 - Inputter
* Position 8 - Date Time
* Position 9 - Authoriser
* Position 10 - Company Code
* Position 11 - Department Code
* Position 12 - Auditor Code
* Position 13 - Audit Date Time

    RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------
*** <region name = READ.CUSTOMER>
READ.CUSTOMER:
*** <desc>read the customer record</desc>
    customerKey = CUSTOMER.NO
    customerRecord = ''
    CALL CustomerService.getRecord(customerKey,customerRecord)
    EB.SystemTables.setEtext('')
    R.CUSTOMER = customerRecord

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------------
    END
