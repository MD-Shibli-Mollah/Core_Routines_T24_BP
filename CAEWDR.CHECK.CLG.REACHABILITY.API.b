* @ValidationCode : MjotMjAxNTExNjUxNjpDcDEyNTI6MTYwMjc1Mjc3OTg1Mzpza2F5YWx2aXpoaTo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTE5LTA0NTk6MTI5OjEyMw==
* @ValidationInfo : Timestamp         : 15 Oct 2020 14:36:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 123/129 (95.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE CAEWDR.Foundation
SUBROUTINE CAEWDR.CHECK.CLG.REACHABILITY.API(iClearingDetails, oReachabilityDetails)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*31/08/2020 - Enhancement Id-3831793/Task-3910568 - Clearing Directory upload and reachability Coding
*26/09/2020 - Task 3991338 - Added Preferred logic for reachability check
*15/10/2020 - Enhancement 3831888/Task 4000154 - Payments- NN bank - Equens DD � Cancellation and R-messages
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING CA.ClearingReachability
    $USING CA.Contract

*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------
initialise:
* initialise local variables
    oReachabilityDetails = ''
    bicValue = ''
    assignedbic = ''
    paymentChannel = ''
    scheme = ''
    alternateKeyVal = ''
    paymentInstrType = ''
    intCount = 1
    count = ''
    recordFound = ''
    bicLength = ''
    repeatCount = ''
    clrIdVal = ''
    clrRec = ''
    secondPosVal = ''
    Error = ''
    R.CLEARING.DIRECTORY = ''
    bicValue = iClearingDetails<CA.ClearingReachability.ClearingDetails.bic>
    bicLength = LEN(bicValue)
    paymentDate = iClearingDetails<CA.ClearingReachability.ClearingDetails.paymentDate>
    paymentChannel = 'EWSEPA'
    paymentInstrType = iClearingDetails<CA.ClearingReachability.ClearingDetails.paymentInstrumentType>
    localInstrumentCode= iClearingDetails<CA.ClearingReachability.ClearingDetails.localInstrument>
    oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.returnCode> = 'No'
    
RETURN
*-----------------------------------------------------------------------------
process:
* if the transaction type equals RD or RT or RF the reachability type needs to be skipped
    IF paymentInstrType EQ 'RD' OR paymentInstrType EQ 'RT' OR paymentInstrType EQ 'RF' OR paymentInstrType EQ 'RV' THEN
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.returnCode> = 'Yes'
        RETURN
    END
*  Scheme values are set according to transaction type and local instrument code value
    BEGIN CASE
        CASE paymentInstrType EQ 'CT'
            scheme = 'SCT'
           
        CASE paymentInstrType EQ 'DD' AND localInstrumentCode EQ 'CORE'
            scheme = 'SDDCORE'
           
        CASE paymentInstrType EQ 'DD' AND localInstrumentCode EQ 'B2B'
            scheme = 'SDDB2B'
    END CASE
    GOSUB checkReachability
    
RETURN
*-----------------------------------------------------------------------------
checkReachability:
* gosub to form the alternate key and check the clearing record
* until the record founds the loop will get execute
    LOOP
    WHILE recordFound NE '1'
        repeatCount = repeatCount + 1
        GOSUB formBIC
* form the alternate key value by concatinating the bic value, scheme and channel
        alternateKeyVal = assignedbic:'-':scheme:'-':paymentChannel
        GOSUB findClrRecordID ;* Gosub to find the clearing directory record
    REPEAT

RETURN
*-----------------------------------------------------------------------------
formBIC:
* GOSUB to form the bic value to check the reachability.
* Below are the combinations possible to be available in the clearing directory
    BEGIN CASE
* if the count is 1 then assign the 8 bic value and check for the record
        CASE repeatCount EQ '1'
            IF bicLength GT '8' THEN
                assignedbic = bicValue[1,8]
            END ELSE
                assignedbic = bicValue
            END
* if the record  not found for the 8 bic value then assign the entire 11 bic value(if the bic is greater than 8) and check for the record
* suppose if the bic length is 8 then assign XXX at the end of the bic value and check for the record.
        CASE repeatCount EQ '2'
            IF bicLength GT '8' THEN
                assignedbic = bicValue
            END ELSE
                assignedbic = bicValue[1,8]:'XXX'
            END
* if the record not found for the above combination then assign the variable recordFound to 1 to return back to the calling routine
        CASE 1
            recordFound = '1'
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
findClrRecordID:
*   Read the  F.CA.CLEARING.DIRECORY.LIST with the supplied alternate key value.
    Error = ''
    clrRec = CA.Contract.ClearingDirectoryList.Read(alternateKeyVal, Error)
    
    IF clrRec NE '' THEN ;* If there is no entry for the supplied alternate key then return back the control else process the retrieved records.
        count = DCOUNT(clrRec,@FM)
        IF count EQ '1' THEN
            secondPosVal = FIELD(clrRec<1>,'-',2)
            IF secondPosVal EQ 'P' THEN
                GOSUB processPreferredRecord ;* if it is a preferred record then process accordingly.
            END ELSE
                GOSUB processNonPreferredRecord ;* if it is a non preferred record then process the records based on the effective date.
            END
        END ELSE
            GOSUB processNonPreferredRecord ;* if it is a non preferred record then process the records based on the effective date.
        END
    END

RETURN
*-----------------------------------------------------------------------------
processPreferredRecord:
    
    clrIdVal = FIELD(clrRec<1>,'-',1) ;* fetch the clearing id value form the list.
    GOSUB readClrRecord ;* Gosub to read the clearing directory record
    
RETURN
*-----------------------------------------------------------------------------
processNonPreferredRecord:
*   if there is no preferred record then loop the record entries until the effective date less than payment date is found.
    intCount = 1
    ClearRecordArr=''
*find all records whose effective date is less than payment date
    LOOP
    WHILE intCount LE count
        secondPosVal = FIELD(clrRec<intCount>,'-',2)
        IF secondPosVal LE paymentDate THEN ;*
            effectiveDateArr<-1> = secondPosVal
            ClearRecordArr<-1>= clrRec<intCount> ;* find latest clearing recod from the clearing record array list.
        END
        intCount = intCount + 1
    REPEAT
*find latest effective date from the effective array list.
    MOSTEFFECTIVE=MAXIMUM(effectiveDateArr)
* find the first record from the list having latest effective date.
    FOR I=1 TO count
        IF effectiveDateArr<I> EQ MOSTEFFECTIVE THEN
            ClrID = ClearRecordArr<I>
            clrIdVal = FIELD(ClearRecordArr<I>,'-',1)
            I = count
        END
    NEXT I
    
*read the record and check reachability validations
    GOSUB readClrRecord
    
RETURN
*------------------------------------------------------------------------------
readClrRecord:
*   Read the clearing directory record with the clearing id determined.
    ErrorRec=''
    R.CLEARING.DIRECTORY = CA.Contract.ClearingDirectory.Read(clrIdVal, ErrorRec)
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
    endDate = R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrEndDate>
*   The payment date should be within the limit of start and end date of the record. If so then check for the reachability
    IF (paymentDate GE startDate) AND (paymentDate LE endDate) AND (status EQ 'ENABLED')THEN
        GOSUB CheckReachabilityType
    END
    
RETURN
*-----------------------------------------------------------------------------
CheckReachabilityType:
*   if the reachability type is configured as D(means directly reachable) then validate
    IF R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrReachabilityType> EQ 'D' THEN
        recordFound = 1
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.aosList> = R.CLEARING.DIRECTORY<CA.Contract.ClearingDirectory.CacdrAos>
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.clearingDirRec> = LOWER(R.CLEARING.DIRECTORY)
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.reachabilityType> = 'D'
        oReachabilityDetails<CA.ClearingReachability.ReachabilityDetails.returnCode> = 'Yes'
    END
    
RETURN
*-----------------------------------------------------------------------------
END
