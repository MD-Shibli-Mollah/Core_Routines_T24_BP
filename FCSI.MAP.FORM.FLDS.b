* @ValidationCode : Mjo0ODQzMzcyMDg6Y3AxMjUyOjE2MTg5NzY2NzgyMzY6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2021 09:14:38
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE FA.CustomerIdentification
SUBROUTINE FCSI.MAP.FORM.FLDS(CUSTOMER.ID, CUST.SUPP.REC, RES.IN.1, RES.IN.2, MAPPED.FCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the form related fields in FCSI record
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* CUST.SUPP.REC              (IN)    - Incoming FCSI record
*
* RES.IN.1, RES.IN.2         (IN)    - Incoming Reserved Arguments
*
* MAPPED.FCSI                (OUT)   - FCSI record after mapping
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/02/21 - Enhancement 3918498 / Task 4246633
*            Sample API to map the form related fields in FCSI record
*
* 30/03/21 - Enhancement 4246863 / Task 4310910
*            Proper expiry date populated on manual expiry
*
* 21/04/21 - Enhancement 3436143 / Task 4348174
*            Changes done to select FATCA forms in sorted order
*-----------------------------------------------------------------------------
    $USING FA.CustomerIdentification
    $USING DM.Foundation
    $USING EB.DataAccess
    $USING RT.IndiciaChecks
    $USING FA.Config
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.FCSI = CUST.SUPP.REC
    CUST.ID = ''
    HOLDER.REF = ''
    FORM.LIST = ''
    FORM.ERR = ''
    OWNER.CNT = 0
    
    EXISTING.FORM.OWNER = MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormOwner>
    EXISTING.FORM.TYPE = MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormType>
    EXISTNG.OWNER.CNT = DCOUNT(MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormOwner>,@VM)
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:

* Get the list of FATCA document names from the Form type table
    EB.DataAccess.CacheRead('F.FATCA.FORM.TYPE', 'SSelectIDs', FORM.LIST, FORM.ERR)

* For main customer
    CUST.ID = CUSTOMER.ID
    HOLDER.REF = ''
    GOSUB CHECK.FORMS.SUBMITTED

* For controlling persons
    TOT.CUS.CNT = DCOUNT(MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId>,@VM)
    FOR CUS.CNT = 1 TO TOT.CUS.CNT
        CUST.ID = MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCustomerId,CUS.CNT>
        HOLDER.REF = MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiHolderRef,CUS.CNT>
        IF CUST.ID NE 'NULL' THEN   ;* when a roletype customer is removed, it will be updated as NULL. So, this check is done to avoid considering NULL values
            GOSUB CHECK.FORMS.SUBMITTED
        END
    NEXT CUS.CNT

* When controlling person is removed, form details related to that customer needs to be removed
    OWNER.CNT = OWNER.CNT+1
    FOR CNT = OWNER.CNT TO EXISTNG.OWNER.CNT
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormOwner,CNT> = 'NULL'
        F.CNT = 0
        TOT.F.CNT = DCOUNT(MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormType,CNT>,@SM)
        LOOP
            F.CNT+=1
        UNTIL F.CNT GT TOT.F.CNT
            IF TOT.F.CNT EQ '1' THEN    ;* Append NULL for first mv position, else update '-' to delete entire mv set (for OFS processing)
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormType,CNT,F.CNT> = 'NULL'
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormId,CNT,F.CNT> = 'NULL'
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiReqDate,CNT,F.CNT> = 'NULL'
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRecvDate,CNT,F.CNT> = 'NULL'
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiExpDate,CNT,F.CNT> = 'NULL'
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCutOffDate,CNT,F.CNT> = 'NULL'
            END ELSE
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormType,CNT,F.CNT> = '-'
            END
        REPEAT
    NEXT CNT
    
RETURN
*-----------------------------------------------------------------------------
CHECK.FORMS.SUBMITTED:

* Form owner is either main customer id of holder reference, incase of controlling person
    FORM.OWNER = ''
    IF HOLDER.REF THEN
        FORM.OWNER = HOLDER.REF
    END ELSE
        FORM.OWNER = CUST.ID
    END

* Loop through the form list and read each document and check for its validity
    TOT.FORM.CNT = DCOUNT(FORM.LIST,@FM)
    FORM.CNT = 0
    CNT = 0
    LOOP
        CNT += 1
    UNTIL CNT GT TOT.FORM.CNT

        DOCUMENT.TYPE = FORM.LIST<CNT>
        VALIDITY = ''
        DOC.ID = CUST.ID:'*':DOCUMENT.TYPE
        R.CUST.DOCUMENT = ''
        DOC.ERR = ''
        R.CUST.DOCUMENT = DM.Foundation.CustDocument.CacheRead(DOC.ID, DOC.ERR)
        DOC.STATUS = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatus>
        NEXT.STATUS = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocNextStatus>
        IF R.CUST.DOCUMENT THEN
            RT.IndiciaChecks.RtCheckCusDocValidity(CUST.ID, DOCUMENT.TYPE, '', '', VALIDITY, '', '', '')
        END
        GOSUB UPDATE.FORM.DETS
        
    REPEAT

RETURN
*-----------------------------------------------------------------------------
UPDATE.FORM.DETS:

* Check if the form dets are already updated in the existing FCSI
    EXIST.FLAG = @FALSE
    LOCATE FORM.OWNER IN EXISTING.FORM.OWNER<1,1> SETTING OWN.POS THEN
        LOCATE DOCUMENT.TYPE IN EXISTING.FORM.TYPE<1,OWN.POS,1> SETTING DOC.POS THEN
            EXIST.FLAG = @TRUE
        END
    END

* Add the form details only when it already existed or when it is valid now.
* Expiry of docs should not remove the details from FCSI
    IF EXIST.FLAG OR (VALIDITY EQ 'VALID') THEN
        FORM.CNT += 1   ;* increment form cnt
        IF FORM.CNT EQ 1 THEN   ;* update form owner if it is the first form
            OWNER.CNT +=1   ;* increment owner cnt
            MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormOwner,OWNER.CNT> = FORM.OWNER
        END
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormType,OWNER.CNT,FORM.CNT> = DOCUMENT.TYPE
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFormId,OWNER.CNT,FORM.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocReferenceNo>
        
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiReqDate,OWNER.CNT,FORM.CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRecvDate,OWNER.CNT,FORM.CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiExpDate,OWNER.CNT,FORM.CNT> = 'NULL'
        MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCutOffDate,OWNER.CNT,FORM.CNT> = 'NULL'
        
        BEGIN CASE
            CASE DOC.STATUS EQ '1'  ;* update received date and end date if status is received
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiReqDate,OWNER.CNT,FORM.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocBeginDate>
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRecvDate,OWNER.CNT,FORM.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatusDate>
                IF R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocEndDate> THEN   ;* check done to avoid overwriting NULL
                    MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiExpDate,OWNER.CNT,FORM.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocEndDate>
                END
            CASE DOC.STATUS EQ '2'  ;* update req date alone if status is not received
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiReqDate,OWNER.CNT,FORM.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatusDate>
            CASE DOC.STATUS EQ '3'  ;* in case if status moves to expired, retain the existing details
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiReqDate,OWNER.CNT,FORM.CNT> = CUST.SUPP.REC<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiReqDate,OWN.POS,DOC.POS>
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRecvDate,OWNER.CNT,FORM.CNT> = CUST.SUPP.REC<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiRecvDate,OWN.POS,DOC.POS>
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiExpDate,OWNER.CNT,FORM.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatusDate>       ;* update the doc expired date in order to calculate FATCA status
                MAPPED.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCutOffDate,OWNER.CNT,FORM.CNT> = CUST.SUPP.REC<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiCutOffDate,OWN.POS,DOC.POS>
        END CASE

    END

RETURN
*-----------------------------------------------------------------------------
END

