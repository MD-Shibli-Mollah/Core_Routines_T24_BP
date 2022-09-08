* @ValidationCode : MjoxNDY3NDY3NjAyOkNwMTI1MjoxNTgwMjEwMTIzMTU1OnJhbXlhcGV0ZXRpOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNTo1NDo1Mg==
* @ValidationInfo : Timestamp         : 28 Jan 2020 16:45:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ramyapeteti
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/54 (96.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



*---------------------------------------------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.BULK.FILE.REF.NUM.GEN(iCompanyDetails,iClearingDetails,oNACHABulkFileRef)
*-------------------------------------------------------------------------------------------------------------
*
* This API returns the Unique Batch Number using which a Batch in a file can be uniquely identified.
* This number is mapped to the BulkReferenceOutgoing of POR.TRANSACTION. This API will be attached in
* BulkFileRefAPI field in the PP.CLEARING.
*
* Parameters
*
* IN - iCompanyDetails - Company Details
* IN - iClearingDetails - Clearing details
* OUT - oNACHABulkRef - Unique reference generated
*-------------------------------------------------------------------------------------------------------------
* Modification History :
*--------------------------------------------------------------------------------------------------------------
*
* 13/05/2019 - Enhancement 2959657 / Task 2959618
*              API to return the Unique Batch Number using which a Batch in a file can be uniquely identified
*              in a NACHA payment
* 17/06/2019 - Enhancement 2959615/Task 3183022 - Payments-Openbank-DD Mandates
*            - If the fileReference is already generated, skips new fileReference generation
* 20/06/2019 - Task 3179465 - If fileRefIndicator is present, then assigns fileRefIndicator to the fileReference
* 27/01/2020 - Defect 3408269/Task 3556339 
*             - Coding Added for removing EB.DataAccess.FWrite by replacing update routines of the respective component.

*-------------------------------------------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
    
    GOSUB Initialise ; *Initialise the variables used
    GOSUB Process ; *Generate a unique reference number

RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables used </desc>
    
    oNACHABulkFileRef = ''
    oNACHAFileRef = ''
    oNACHABulkRef = ''
    iLockingId = ''
    iAgentDigits = ''
    iRandomDigitsLen = ''
    fileRefIndicator = FIELD(iClearingDetails,'*',14)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc>Generate 7 digit unique reference number </desc>
    
    GOSUB GenerateFileReference ; *Generate a single digit file reference to be updated in POR.TRANSACTION and also in Outgoing message
    GOSUB GenerateBulkReference ; *Generate a 7 digit unique reference to be updated in BulkReferenceOutgoing of POR.TRANSACTION and also in the Outgoing message
    
    oNACHABulkFileRef = oNACHAFileRef:':@VM:':oNACHABulkRef
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GenerateFileReference>
GenerateFileReference:
*** <desc>Generate a single digit file reference to be updated in POR.TRANSACTION and also in Outgoing message </desc>
    IF fileRefIndicator NE '' THEN
        oNACHAFileRef = fileRefIndicator ;* returns the fileReference which is already generated.
        RETURN
    END
 
    FnLocking = 'F.LOCKING'
    FLocking = ''
    
    LockingId = 'GENFILEREF'  ;* The locking id for generating file reference
    rLocking = ''
    RecEr = ''
    Suffix=''
    CurrentDate = EB.SystemTables.getToday() ;* get TODAY date
    
    EB.DataAccess.FRead(FnLocking, LockingId,rLocking, FLocking, RecEr)  ;* read the Locking table with the id formed
 
;* The ASCII value of A is 065 and that of Z is 090. sequential increase from A to Z
;* The ASCII value of 0 is 048 and that of 9 is 057. sequential increase from 0 to 9

;* When there is no Locking record, create a record and update the value as 'A' . If there is an existing Locking record but it wasnt created on the current date, delete the exisitng
;* and create a new record and the update the value as 'A'.

;* When there is an existing Locking record and if its created on the current date, check if the value if within A to Z, if so increment the ASCII value such that the record is updated
;* with the next alphabet. If the existing value is not between A to Z, check if it is between 0-9, if so then increment the ASCII value such that the record is updated with the next number.
;* If the existing record has 'Z' whose ASCII value is 090, the record will be updated with '0' and incremented henceforth.

    IF rLocking EQ '' THEN  ;* if there is no record, write a new one with the sequence number and today date
        SeqNo = 'A' ;* sequence begins with A
        rLocking<2> = CurrentDate ;* today date
    END ELSE
        IF rLocking<2> LT CurrentDate THEN  ;* if there is a locking record present, but it is not created today, clear the record and create a new record.
            EB.DataAccess.FDelete(FnLocking,LockingId) ;* delete the exisitng old record
            SeqNo = 'A' ;* sequence begins with A
            rLocking<2> = CurrentDate ;* today date
        END ELSE
            IF rLocking<1> GE 'A' AND rLocking<1> LT 'Z' THEN ;* The ASCII values of characters will be compared
                SeqNo = SEQ(rLocking<1>) + 1 ;* if the record is present and is created today , and the existing value is between A-Z, then update the existing record with next alphabet
                SeqNo = CHAR(SeqNo)  ;* Converts the ASCII to CHAR
            END ELSE
                SeqNo = 'A' ;* sequence begins with A
            END
* As part of handling DD Mandates, 0-9  characters are not carried to generate unique reference (Only from A-Z is taken care)
        END
    END
    
    rLocking<1> = SeqNo ;* A-Z ; 0-9
   
     EB.SystemTables.LockingWrite(LockingId, rLocking, Suffix)
    
    oNACHAFileRef = rLocking<1>  ;* file reference
    
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------------------------------------
*** <region name= GenerateBulkReference>
GenerateBulkReference:
*** <desc>Generate a 7 digit unique reference to be updated in BulkReferenceOutgoing of POR.TRANSACTION and also in the Outgoing message </desc>

    iLockingId = 'BATCH' ;* locking file record id
    iAgentDigits = '2'  ;* length of the seq no from agent's relative position
    iRandomDigitsLen = '5' ;* length of the unique reference number  from locking record
    oReserved = ''
* this api returns a 7 digit unqiue reference number, using which a Batch in a file can be uniquely identified. This reference is mapped
* to the Bulk Reference Outgoing of POR.TRANSACTION

    PPAACH.ClearingFramework.PPAACHGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen,'', oNACHABulkRef,oReserved)
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------

