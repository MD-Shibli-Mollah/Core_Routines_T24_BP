* @ValidationCode : MjotMTA3MjM2NjMyODpjcDEyNTI6MTU5OTY1MjM5MjMwMzpzYWlrdW1hci5tYWtrZW5hOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MToyMToyMQ==
* @ValidationInfo : Timestamp         : 09 Sep 2020 17:23:12
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/21 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE RE.ConBalanceUpdates
SUBROUTINE AC.GET.ECB.INFO(AccountId,RequestType,RequestResult,Response)
*-----------------------------------------------------------------------------
*
* Method to return request information from EB.CONTRACT.BALANCE record.
* IN  : AccountId
* IN  : RequestType  - Currently only CcyList is a valid option.
* OUT : RequestResult
* OUT : Response = 1 if error
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/01/15 - Enhancement 2117750 / Task 2128037
*            Initial development
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------
    $USING AC.HighVolume
    $USING BF.ConBalanceUpdates
    
*-----------------------------------------------------------------------------

    GOSUB Initialise   ;* Initialise variables
    GOSUB GetEcbRecord ;* Read the ECB record
    IF NOT(Response) THEN
        GOSUB ProcessRequestType ;* * Return the requested ECB Info
    END
    
RETURN

*-----------------------------------------------------------------------------
Initialise:
*----------
* Initialise variables

    Response = ""
    RequestResult = ""
    
RETURN

*-----------------------------------------------------------------------------
GetEcbRecord:
*------------
* Read the ECB record
    AC.HighVolume.EbReadHvt("EB.CONTRACT.BALANCES", AccountId, R.EB.CONTRACT.BALANCES, ErrMsg)
    IF ErrMsg NE "" THEN
        Response = 1
    END
    
RETURN

*-----------------------------------------------------------------------------
ProcessRequestType:
*------------------
* Return the requested ECB Info

    BEGIN CASE
        CASE RequestType = "CcyList"
            RequestResult = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbCcyList>
        CASE 1
            RequestResult = ""
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
END
