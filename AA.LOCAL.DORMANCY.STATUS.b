* @ValidationCode : MjotNzkyMjY3MTIyOkNwMTI1MjoxNjAwMjU0OTU3NTA5Om1qZWJhcmFqOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToyNjoyNg==
* @ValidationInfo : Timestamp         : 16 Sep 2020 16:45:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Settlement
SUBROUTINE AA.LOCAL.DORMANCY.STATUS(CallType, CallApplicationRecord, SettlementMethod, ArrangementAccount, SettlementAccount, SettlementAmount, SettlementType,Exceptions)
*-----------------------------------------------------------------------------
*** <region name= Routine Description>
*** <desc> </desc>
*
* This routine will get the Dormancy status of the corresponding settlement arrangement and return exception if Dormancy status is set.
* This routine is attached in 'User rule routine' field in AA.SETTLEMENT.TYPE record.
*
*** </region>
*-----------------------------------------------------------------------------
*<region name= Arguments>
*<desc>Input and out arguments required for the sub-routine</desc>
*Arguments
*
* Input
*
* @param CallType               : Indicate the calling application. RC/Settlement Property
* @param CallApplicationRecord  : Contains the calling application Record. i.e. if the call type is RC then
*                                 RC.DETAIL record / Settlement then settlement record is passed.
* @param SettlementMethod       : Indicate the settlement request is DEBIT/CREDIT
* @param ArrangementAccount     : Arrangement Account Reference
* @param SettlementAccount      : Settlement Account Reference
* @param SettlementAmount       : Settlement Amount to be processed
* @param SettlementType         : Reference of AA.SETTLEMENT.TYPE
*
* Output
*
* @return Exceptions           : Error IDs for any exceptions raised. Multiple error IDs are separated by #
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*
* 16/07/19 - Enhancement : 3126449
*            Task        : 3222194
*            New API introduced.
*
* 01/09/20 - Enhancement : 3930369
*            Task        : 3941466
*            Microservices - Skip the read to account record if the contract is from it and get arrangement from account itself
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

    $USING AA.Dormancy
    $USING AC.AccountOpening

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    GOSUB Process ;* Main process

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc> </desc>
Process:
    
    Exceptions = ""
    SettlementRec = ""
    
    BEGIN CASE
        CASE CallType EQ 'SETTLEMENT'
            
            GOSUB CheckDormancy ;* Check Dormancy Status
            
        CASE CallType EQ 'RC'
       
            GOSUB CheckDormancy ;* Check Dormancy Status

    END CASE

    IF DormancyStatus THEN
        Exceptions = "AA-DORMANCY.STATUS.ERROR" ;* Exception thrown
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckDormancy>
*** <desc> Check Dormancy Status </desc>
CheckDormancy:
    
*** In Microservices, there is no account table involved and arrangement id is used as primary key to refer anything for a contract.
*** So skip read to account record in case of MS. Instead get arrangement from account itself.
    AccountRec = ""
    ArrangementId = ""
    IF SettlementAccount[1,2] NE "AA" THEN
        AccountRec = AC.AccountOpening.Account.CacheRead(SettlementAccount, Error)  ;* Get the Account Record
        ArrangementId = AccountRec<AC.AccountOpening.Account.ArrangementId> ;* Get the corresponding Arrangement Id
    END ELSE
        ArrangementId = SettlementAccount
    END
    
    IF ArrangementId THEN
        AA.Dormancy.DetermineDormancyStatus('', ArrangementId, '', DormancyStatus, DormancyDate, DormancyProcess) ;* Get the Dormancy Status
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
