* @ValidationCode : MjoxOTE5NTg5OTQ6Q3AxMjUyOjE1OTczMTM3NzQ1Njc6bXIuc3VyeWFpbmFtZGFyOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToxMTQ6MTE0
* @ValidationInfo : Timestamp         : 13 Aug 2020 15:46:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 114/114 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE CATNCL.Foundation
SUBROUTINE CATNCL.CHECK.CLG.REACHABITY.API(iClearingDetails, oReachabilityDetails)
*-----------------------------------------------------------------------------
* This reachability API would be invoked to check the Reachability of receiving bank for Tunisia Transfer.
*-----------------------------------------------------------------------------
* Modification History :
*17/06/2020 : Enhancement -3783859 / Task -3797792
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    $USING PP.CreditPartyDeterminationService
    $USING PP.DebitPartyDeterminationService
    $USING CA.ClearingReachability
    $USING CA.Contract
*-----------------------------------------------------------------------------
    GOSUB initialise ; *
    GOSUB process ; *
     
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
***Initialise Local variables

    R.CLEARING.DIRECTORY = ''
    nccValue = ''
    paymentChannel = iClearingDetails<CA.ClearingReachability.ClearingDetails.paymentChannel>
    paymentDate = iClearingDetails<CA.ClearingReachability.ClearingDetails.paymentDate>
    paymentInstrumentType = iClearingDetails<CA.ClearingReachability.ClearingDetails.paymentInstrumentType>
    requestorSource=iClearingDetails<CA.ClearingReachability.ClearingDetails.requestorSource>
    requestorSourceTxn = iClearingDetails<CA.ClearingReachability.ClearingDetails.requestorSourceTxn>
    directoryFldMatch = iClearingDetails<CA.ClearingReachability.ClearingDetails.directoryFldChk>
    oReachabilityDetails = ''
    oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.returnCode> = 'No'
    startDate=''
    effectiveDate=''
    status=''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
* Fetching the Ncc value
    GOSUB fetchNcc
*Form the alternate key value by concatenating  ncc Value and channel
    alternateKeyVal = nccValue : '-' : paymentChannel
    GOSUB findClrRecordID
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
fetchNcc:
* Fetching the Ncc value
    BEGIN CASE
        CASE requestorSource EQ 'PH'
            GOSUB fetchnccforph
        
        CASE requestorSource EQ 'PI'
            GOSUB fetchnccforpo
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
fetchnccforph:
* Fetching the Ncc value through TPH
    BEGIN CASE
        CASE paymentInstrumentType EQ 'CT' OR paymentInstrumentType EQ 'RT'
            oGetCreditErr=''
            iCreditPartyRole = ''
            iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.companyID> = requestorSourceTxn[1,3]
            iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.ftNumber> = requestorSourceTxn
            iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.crPartyRole> = 'BENFCY'
            iCreditPartyRole<PP.CreditPartyDeterminationService.CreditPartyKey.crPartyRoleIndic> = 'R'
            PP.CreditPartyDeterminationService.getPartyCreditDetails(iCreditPartyRole, oCreditPartyDet, oGetCreditErr)
*       To get creditaccountline value for BENFCY role
            IF oGetCreditErr EQ '' THEN
                accountLine = oCreditPartyDet<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine>
            END
       
        CASE paymentInstrumentType EQ 'DD' OR paymentInstrumentType EQ 'RF'
            oGetPrtyDbtError = ''
            iDebitPartyRole = ''
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.companyID> = requestorSourceTxn[1,3]
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.ftNumber> = requestorSourceTxn
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.dbtPartyRole> = 'DEBTOR'
            iDebitPartyRole<PP.DebitPartyDeterminationService.DebitPartyRole.dbtPartyRoleIndic> = 'R'
*       To get debitaccountline value for DEBTOR role
            PP.DebitPartyDeterminationService.getPartyDebitDetails(iDebitPartyRole, oPrtyDbtDetails, oGetPrtyDbtError)
            IF oGetPrtyDbtError EQ '' THEN
                accountLine = oPrtyDbtDetails<PP.DebitPartyDeterminationService.PartyDebitDetails.debitPartyAccountLine>
            END
    END CASE
    nccValue=accountLine[1,5]
    
RETURN
*-----------------------------------------------------------------------------
fetchnccforpo:
* Fetching the Ncc value in payment order
    IF directoryFldMatch NE '' THEN                     ;*logic to retrieve directoryFldMatch details
        CHANGE @VM TO @FM IN directoryFldMatch
        pos = ''
        loopcount = DCOUNT(directoryFldMatch,@FM)
        FOR pos = 1 TO loopcount
            directoryField<pos> = FIELD(directoryFldMatch<pos>,'==',1)
            matchValue<pos> = FIELD(directoryFldMatch<pos>,'==',2)
        NEXT pos
    END
      
    benAcct = FIELD(matchValue,@FM,1)    ;*BEN.ACCOUNT.NUMBER
    nccValue = benAcct[1,5]
                
RETURN
*-----------------------------------------------------------------------------
findClrRecordID:
* Read the  F.CA.CLEARING.DIRECORY.LIST with the supplied alternate key value.
    Error = ''
    clrRec = CA.Contract.ClearingDirectoryList.Read(alternateKeyVal, Error)
    IF clrRec NE '' THEN ;* If there is no entry for the supplied alternate key then return back the control else process the retrieved records.
        count = DCOUNT(clrRec,@FM)
        GOSUB checkreachability ;* if it is a non preferred record then process the records based on the effective date.
    END
    
RETURN
*-----------------------------------------------------------------------------
checkreachability:
*   if there is no preferred record then loop the record entries until the effective date less than payment date is found.
    intCount = 1
    ClearRecordArr=''
*   find all records whose effective date is less than payment date
    LOOP
    WHILE intCount LE count
        secondPosVal = FIELD(clrRec<intCount>,'-',2)
        IF secondPosVal LE paymentDate THEN ;*
            effectiveDateArr<-1> = secondPosVal
            ClearRecordArr<-1>= clrRec<intCount> ;* find latest clearing recod from the clearing record array list.
        END
        intCount = intCount + 1
    REPEAT
*   find latest effective date from the effective array list.
    MOSTEFFECTIVE=MAXIMUM(effectiveDateArr)
*   find the first record from the list having latest effective date.
    FOR I=1 TO count
        IF effectiveDateArr<I> EQ MOSTEFFECTIVE THEN
            ClrID = ClearRecordArr<I>
            clrIdVal = FIELD(ClearRecordArr<I>,'-',1)
            I = count
        END
    NEXT I
*   read the record and check reachability validations
    GOSUB readClrRecord
    
RETURN
*------------------------------------------------------------------------------
readClrRecord:
*   Read the clearing directory record with the clearing id determined.
    Error=''
    R.CLEARING.DIRECTORY = CA.Contract.ClearingDirectory.Read(clrIdVal, Error)
    IF Error EQ '' THEN ;* if record found then validate the record.
        GOSUB validateRecord
    END
    
RETURN
*-----------------------------------------------------------------------------
validateRecord:
*   Assign the reachability as sucess only if it matches the below condition.
    startDate = R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStartDate>
    effectiveDate = R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEffectiveDate>
    status = R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrStatus>
*   The payment date should be within the limit of start and end date of the record, status is ENABLED. If so then check for the reachability
    IF (paymentDate GE startDate) AND (paymentDate GE effectiveDate) AND (status EQ 'ENABLED') THEN
        GOSUB CheckReachabilityType
    END
    
RETURN
*--------------------------------------------------------------------
CheckReachabilityType:
*   if the reachability type is configured as D(means directly reachable) then validate
    IF R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrReachabilityType> EQ 'D' THEN
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.aosList> = R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAos>
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.clearingDirRec> = LOWER(R.CLEARING.DIRECTORY)
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.reachabilityType> = 'D'
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.returnCode> = 'Yes'
    END
    
RETURN
*-----------------------------------------------------------------------------
END
