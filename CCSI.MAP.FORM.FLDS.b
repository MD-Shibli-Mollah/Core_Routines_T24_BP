* @ValidationCode : MjotNzc3MDE1ODg1OmNwMTI1MjoxNjE3MDk3MDQwMzQ3OmtyYW1hc2hyaTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDEtMDU1NjotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2021 15:07:20
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE CD.CustomerIdentification
SUBROUTINE CCSI.MAP.FORM.FLDS(CUSTOMER.ID, CUST.SUPP.REC, RES.IN.1, RES.IN.2, MAPPED.CCSI, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to map the form related fields in CCSI record
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* CUST.SUPP.REC              (IN)    - Incoming CCSI record
*
* RES.IN.1, RES.IN.2         (IN)    - Incoming Reserved Arguments
*
* MAPPED.CCSI                (OUT)   - CCSI record after mapping
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/02/21 - Enhancement 3918498 / Task 4246641
*            Sample API to map the form related fields in CCSI record
*
* 30/03/21 - Enhancement 4246863 / Task 4310910
*            Removing SC details on document expiry
*-----------------------------------------------------------------------------
    $USING CD.CustomerIdentification
    $USING DM.Foundation
    $USING RT.IndiciaChecks
    $USING EB.DataAccess
    $USING CD.Config
    $USING EB.SystemTables
    $USING RT.BalanceAggregation
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    MAPPED.CCSI = CUST.SUPP.REC
    
* Update Self certification flag as NO. Once forms are added, it will be set to YES
    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiSelfCertification> = 'NO'
    
    CUST.ID = ''
    HOLDER.REF = ''
    R.CRS.PARAM = ''
    OWNER.CNT = 0
    
    EXISTING.CUST.REF = MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCustRef>
    EXISTNG.OWNER.CNT = DCOUNT(MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCustRef>,@VM)
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:

* Get the list of CRS document names from CRS parameter
    CD.ERR = ''
    ID.COMP = EB.SystemTables.getIdCompany()
    R.CRS.PARAM = CD.Config.CrsParameter.CacheRead(ID.COMP, CD.ERR)
    FORM.LIST = RAISE(R.CRS.PARAM<CD.Config.CrsParameter.CdCpReqdDocType>)
        
    IF NOT(FORM.LIST) THEN
        RETURN
    END
    
* For main customer
    CUST.ID = CUSTOMER.ID
    HOLDER.REF = ''
    GOSUB CHECK.FORMS.SUBMITTED

* For controlling persons
    TOT.CUS.CNT = DCOUNT(MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId>,@VM)
    FOR CUS.CNT = 1 TO TOT.CUS.CNT
        CUST.ID = MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId,CUS.CNT>
        HOLDER.REF = MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerReference,CUS.CNT>
        GOSUB CHECK.FORMS.SUBMITTED
    NEXT CUS.CNT
    
* When any controlling person is removed, form details related to that customer needs to be removed.
* Appending NULL for that particular set for OFS processing
    OWNER.CNT = OWNER.CNT+1
    FOR CNT = OWNER.CNT TO EXISTNG.OWNER.CNT
        IF CNT EQ '1' THEN      ;* first mv set should contain NULL for OFS processing
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCustRef,CNT> = 'NULL'
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScReqDate,CNT> = 'NULL'
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScRecvDate,CNT> = 'NULL'
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCutOffDate,CNT> = 'NULL'
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScDocStatus,CNT> = 'NULL'
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScDocStatusByRole,CNT> = 'NULL'
        END ELSE
            MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCustRef,CNT> = '-'
        END
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

* Check if the form dets are already updated in the existing CCSI
    EXIST.FLAG = @FALSE
    LOCATE FORM.OWNER IN EXISTING.CUST.REF<1,1> SETTING OWN.POS THEN
        EXIST.FLAG = @TRUE
    END

* Add the form details only when it already existed or when it is valid now.
* Donot update when doc is expired (status = 3) because we cant update request/received date in this case
    IF (EXIST.FLAG OR (VALIDITY EQ 'VALID')) AND (DOC.STATUS NE '3') THEN
        OWNER.CNT +=1   ;* increment mv cnt
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCustRef,OWNER.CNT> = FORM.OWNER

        BEGIN CASE
            CASE DOC.STATUS EQ '1'  ;* if status is received
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScReqDate,OWNER.CNT> = 'NULL'
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScRecvDate,OWNER.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatusDate>
                IF FORM.OWNER EQ CUSTOMER.ID THEN   ;* set self certification flag to YES when form owner is the main customer id
                    MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiSelfCertification> = 'YES'
                END
            CASE NEXT.STATUS EQ '2'     ;* next status takes precedence for updation of req date
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScReqDate,OWNER.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocNextStatusDate>
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScRecvDate,OWNER.CNT> = 'NULL'
            CASE DOC.STATUS EQ '2'
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScReqDate,OWNER.CNT> = R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatusDate>
                MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScRecvDate,OWNER.CNT> = 'NULL'
        END CASE
        
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScCutOffDate,OWNER.CNT> = 'NULL'  ;* cut off date will be calculated based on req date in .PROCESS rtn
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScDocStatus,OWNER.CNT> = 'NULL'
        MAPPED.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiScDocStatusByRole,OWNER.CNT> = 'NULL'
    END

RETURN
*-----------------------------------------------------------------------------
END

