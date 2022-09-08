* @ValidationCode : MjoxMTc1MTE5NTU2OkNwMTI1MjoxNTgyMDk1NDMyMjI0OnN0YW51c2hyZWU6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4yMDIwMDIxMi0wNjQ2Ojc2Ojcx
* @ValidationInfo : Timestamp         : 19 Feb 2020 12:27:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 71/76 (93.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-79</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Reports
SUBROUTINE E.MB.FETCH.DE.DESTINATION
*
* Subroutine Type       :   ENQUIRY API
* Attached to           :       ENQUIRY DE.CUSTOMER.PREFERENCES.SCV
* Attached as           :       Conversion Routine
* Primary Purpose       :       Fetch the correct destination from DE.ADDRESS
*
* Incoming:
* ---------
* O.DATA
*
* Outgoing:
* ---------
* O.DATA
*
* Error Variables:
* ----------------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 27 OCT 2010 - Sathish PS
*               New Development for SI RMB1 Refresh Retail Model Bank
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 31/07/19 - Enhancement 3257432 / Task 3257434
*            Direct access to DE.ADDRESS removed
*
* 17/09/19 - Enhancement 3357571 / Task 3357573
*            Changes done for Movement of contact preferences to a separate Master Data Module from Delivery
*
*-----------------------------------------------------------------------------------
    $USING ST.CompanyCreation
    $USING DE.Config
    $USING DE.Reports
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CustomerService
    $USING PF.Config
 
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    E.CARRIER = EB.Reports.getRRecord()<PF.Config.CustomerPreferences.CusprCarrier,EB.Reports.getVc(),EB.Reports.getS()>
    ID.DE.ADDRESS = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    ID.DE.ADDRESS := '.' : 'C-' : EB.Reports.getId()
    ID.DE.ADDRESS := '.' : E.CARRIER
    ID.DE.ADDRESS := '.' : EB.Reports.getRRecord()<PF.Config.CustomerPreferences.CusprAddress,EB.Reports.getVc(),EB.Reports.getS()>

    GOSUB LOAD.ADDRESS.RECORD
    DESTINATION = ''
    IF address THEN
        GOSUB FETCH.DE.DESTINATION
    END
    EB.Reports.setOData(DESTINATION)

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
FETCH.DE.DESTINATION:

    BEGIN CASE
        CASE E.CARRIER EQ 'PRINT'
            DESTINATION = address<ST.CustomerService.Address.streetAddress>
            IF address<ST.CustomerService.Address.townCounty> THEN
                DESTINATION := ',' : address<ST.CustomerService.Address.townCounty>
            END
            IF address<ST.CustomerService.Address.postCode> THEN
                DESTINATION := ',' : address<ST.CustomerService.Address.postCode>
            END
            IF address<ST.CustomerService.Address.country> THEN
                DESTINATION := ',' : address<ST.CustomerService.Address.country>
            END

        CASE E.CARRIER EQ 'EMAIL'
            DESTINATION = address<ST.CustomerService.EmailDetails.email>

        CASE E.CARRIER EQ 'SMS'
            DESTINATION = address<ST.CustomerService.SMSDetails.sms>

        CASE E.CARRIER EQ 'SWIFT'
            DESTINATION = address<ST.CustomerService.SWIFTDetails.code>

        CASE E.CARRIER EQ 'SECUREMSG'
            DESTINATION = ''

    END CASE

RETURN
*-----------------------------------------------------------------------------------*
LOAD.ADDRESS.RECORD:

    keyDetails = ''
    keyDetails<ST.CustomerService.AddressIDDetails.customerKey> = EB.Reports.getId()
    keyDetails<ST.CustomerService.AddressIDDetails.preferredLang> = ''
    keyDetails<ST.CustomerService.AddressIDDetails.companyCode> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    keyDetails<ST.CustomerService.AddressIDDetails.addressNumber> = EB.Reports.getRRecord()<PF.Config.CustomerPreferences.CusprAddress,EB.Reports.getVc(),EB.Reports.getS()>
            
    address = ''
    BEGIN CASE
        CASE E.CARRIER EQ 'PRINT'
            keyDetails<ST.CustomerService.AddressIDDetails.getDefault> = 'NO'
            ST.CustomerService.getPhysicalAddress(keyDetails,address)
            
        CASE E.CARRIER EQ 'SWIFT'
            keyDetails<ST.CustomerService.AddressIDDetails.getDefault> = 'NO'
            ST.CustomerService.getSWIFTAddress(keyDetails,address)
            
        CASE E.CARRIER EQ 'SMS'
            ST.CustomerService.getSMSDetails(keyDetails,address)
            
        CASE E.CARRIER EQ 'EMAIL'
            ST.CustomerService.getEmailDetails(keyDetails,address)
        
    END CASE

RETURN
*-----------------------------------------------------------------------------------*
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:


RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 2
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1

            CASE LOOP.CNT EQ 2

        END CASE
        LOOP.CNT += 1
        
        IF EB.SystemTables.getE() THEN
            PROCESS.GOAHEAD = 0
        END

    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
END
