* @ValidationCode : MjotMjg3MzIyODY3OkNwMTI1MjoxNjAwMjU0OTczMzk4Om1qZWJhcmFqOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNTo1Mzo1Mw==
* @ValidationInfo : Timestamp         : 16 Sep 2020 16:46:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/53 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Settlement
SUBROUTINE AA.LOCAL.RESTRICT.ACTIVITY(CallType, CallApplicationRecord, SettlementMethod, ArrangementAccount, SettlementAccount, SettlementAmount, SettlementType,Exceptions)
*-----------------------------------------------------------------------------
*** <region name= Routine Description>
*** <desc> </desc>
*
* This routine will check whether the Settlement Activity is restricted, if "YES" then exception is thrown.
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
* 03/09/20 - Enhancement : 3930369
*            Task        : 3941466
*            Microservices - Skip the read to account record if the contract is from it and get arrangement from account itself
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

    $USING AA.Framework
    $USING AA.ActivityRestriction
    $USING RC.TransactionCycler
    $USING FT.Config
    $USING AC.AccountOpening

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    GOSUB Initialise ;* Initialise the variables
    GOSUB Process ;* Main process

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise the variables </desc>
Initialise:

    Exceptions = ""
    SettlementRec = ""
    SettleActivity = ""
    RestrictActivity = ""
    SetMvPos = SettlementType<2> ;* Multi-value position of Settlement Array.

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc> Main process </desc>
Process:
*** If CallType "SETTLEMENT", then Settle Activity is fetched directly from the Payin/Payout Activity field.
*** If CallType "RC", then settle activity is fetched based on the transaction type used in RC.DETAIL.
    
    BEGIN CASE
        CASE CallType EQ 'SETTLEMENT'
            
            GOSUB GetArrId ;* Get the Arrangement Id

            IF SettlementMethod EQ "CREDIT" THEN
                SettleActivity = CallApplicationRecord<AA.Settlement.SettlePoAaAcActivity,SetMvPos> ;* Payout Activity
            END ELSE
                SettleActivity = CallApplicationRecord<AA.Settlement.SettlePiAaAcActivity,SetMvPos> ;* Payin Activity
            END
        
            IF ArrangementId THEN
                GOSUB CheckRestrictActivity ;* Check whether the activity is restricted
            END
        
        CASE CallType EQ 'RC'
        
            GOSUB GetArrId ;* Get the Arrangement Id
            
            IF ArrangementId THEN
                TxnType = CallApplicationRecord<RC.TransactionCycler.Detail.DetTxnType> ;* Transaction Type
                TxnSign = CallApplicationRecord<RC.TransactionCycler.Detail.DetTxnSign> ;* Transaction Sign
                TxnDate = CallApplicationRecord<RC.TransactionCycler.Detail.DetNextRetryDate> ;* Next Retry Date from RC.DETAIL
                FttcRec = FT.Config.TxnTypeCondition.CacheRead(TxnType, Error) ;* Get the FTTC record
                IF TxnSign EQ "CREDIT" THEN
                    TxnCode = FttcRec<FT.Config.TxnTypeCondition.FtSixTxnCodeCr> ;* Transaction Code
                END ELSE
                    TxnCode = FttcRec<FT.Config.TxnTypeCondition.FtSixTxnCodeDr> ;* Transaction Code
                END
                AA.Framework.GetTransactionActivity("FINANCIAL", ArrangementId, TxnDate, TxnCode, TxnSign, SettleActivity, TxnServiceGroup) ;* Get the Activity corresponding to the Transaction code.
        
                GOSUB CheckRestrictActivity ;* Check whether the activity is restricted
            END
              
    END CASE

    IF RestrictActivity EQ 'YES' THEN
        Exceptions = "AA-ACTIVITY.RESTRICTED" ;* Exception thrown
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetArrId>
*** <desc> Get the Arrangement Id </desc>
GetArrId:

*** In Microservices, there is no account table involved and arrangement id is used as primary key to refer anything for a contract.
*** So skip read to account record in case of MS. Instead get arrangement from account itself.
    AccountRec = ""
    ArrangementId = ""
    IF SettlementAccount[1,2] NE "AA" THEN
        AccountRec = AC.AccountOpening.Account.CacheRead(SettlementAccount, Error) ;* Get the Account Record
        ArrangementId = AccountRec<AC.AccountOpening.Account.ArrangementId> ;* Get the Corresponding Arrangement Id
    END ELSE
        ArrangementId = SettlementAccount
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckRestrictActivity>
*** <desc> </desc>
CheckRestrictActivity:
*** If Settle Activity, it returns whether the activity is restricted or not.

    IF SettleActivity THEN
        AA.ActivityRestriction.CheckRestrictActivity(ArrangementId, '', SettleActivity, RestrictActivity) ;* Check whether the activity is restricted.
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
