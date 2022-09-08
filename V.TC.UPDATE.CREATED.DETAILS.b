* @ValidationCode : MjotNTA0ODU3NTUyOkNwMTI1MjoxNTUzODUyNjc2Nzg3OmpleWFsYXZhbnlhajoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAzLjIwMTkwMjE5LTEyNDE6Mzg6Mjg=
* @ValidationInfo : Timestamp         : 29 Mar 2019 15:14:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jeyalavanyaj
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 28/38 (73.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190219-1241
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PA.Channels
SUBROUTINE V.TC.UPDATE.CREATED.DETAILS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 19/03/2019  - Enhancement - 2867757 / Task 3034702
*               Fetch createdAt and createdChannel field details for PA.CONNECTION.TRACKER record
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Interface
    $USING PA.Contract
    $USING EB.ErrorProcessing
    $USING EB.Template
    $USING EB.API
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>
*
    GOSUB Initialise
    GOSUB Process
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise variables used in this routine</desc>
Initialise:
*----------
*
    connectionId = EB.SystemTables.getIdNew() ;* Get current connection Id
    extUserId    = EB.ErrorProcessing.getExternalUserId()      ;*Get the external user id from selection
    TIME.STAMP = TIMEDATE()
    X = OCONV(DATE(),"D-")
    DATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2] ;* Get time stamp to update created At details
    TODAY.DATE = EB.SystemTables.getToday() ;* Get T24 System date
    consentTxnLookup = 'PA.CONSENT.TXN'
    provider = FIELDS(connectionId,'-',3)
    provider = OCONV(provider, "MCU")
    providerLookupId = consentTxnLookup:'*':provider
*
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Set created date, time , channel and user details</desc>
Process:
*------
    IF EB.SystemTables.getRNew(PA.Contract.PAConnectionTracker.ConnTrackerCreatedAt) EQ '' THEN ;* Update created At details
        EB.SystemTables.setRNew(PA.Contract.PAConnectionTracker.ConnTrackerCreatedAt, DATE.TIME)
    END
    IF EB.SystemTables.getRNew(PA.Contract.PAConnectionTracker.ConnTrackerCreatedChannel) EQ '' THEN ;* Update created channel details
        OFS.SOURCE.REC = EB.Interface.getOfsSourceRec()
        CHANNEL.ID = OFS.SOURCE.REC<EB.Interface.OfsSource.OfsSrcChannel>
        EB.SystemTables.setRNew(PA.Contract.PAConnectionTracker.ConnTrackerCreatedChannel,CHANNEL.ID)
    END
    IF EB.SystemTables.getRNew(PA.Contract.PAConnectionTracker.ConnTrackerCreatedBy) EQ '' THEN ;* Update created by user details
        EB.SystemTables.setRNew(PA.Contract.PAConnectionTracker.ConnTrackerCreatedBy,extUserId)
    END
    consents = EB.SystemTables.getRNew(PA.Contract.PAConnectionTracker.ConnTrackerOurConsentTypes)
    LOCATE 'TransactionInformation' IN consents<1,1> SETTING CON.POS THEN
        GOSUB GET.CONSENT.FROM.DATE
        tmp<1,CON.POS> = TODAY.DATE
        EB.SystemTables.setRNew(PA.Contract.PAConnectionTracker.ConnTrackerOurConsentFromDate, tmp)
    END
*
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= get consent from date>
GET.CONSENT.FROM.DATE:
*-------------------
* Set From date for Transaction consent initiation by reading the days from lookup
    connectTxnRec =  EB.Template.Lookup.Read(providerLookupId,Error)
    LOCATE 'TXN.FROM.DATE' IN connectTxnRec<EB.Template.Lookup.LuDataName,1> SETTING DATE.POS THEN
        noOfDays = connectTxnRec<EB.Template.Lookup.LuDataValue,DATE.POS>
        EB.API.Cdt("", TODAY.DATE, "-":noOfDays:"C") ;* Since off balance sheet should happen at the EOD, so decrease the date by no.of daysC
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
 
END
