* @ValidationCode : MjotNzkyMDcwMzQ0OkNwMTI1MjoxNjExNzUyODM0ODM0OmRpdnlhc2FyYXZhbmFuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToxMzoxMw==
* @ValidationInfo : Timestamp         : 27 Jan 2021 18:37:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.ACCT.SHORT.NAME(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 07/01/21 - Enhancement  : 4138776
*            Task    : 3984627
*            To return the short name of incoming account
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING AA.Framework
    $USING AC.AccountOpening

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    GOSUB DoProcess             ;* Main processing
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    RArrangement = ""
    AccountRec = ""
    AccountId = ""
    ArrangementId = InValue
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:
    
    AA.Framework.GetArrangement(ArrangementId, RArrangement, '')
    AccountId = RArrangement<AA.Framework.Arrangement.ArrLinkedApplId>
    AccountRec = AC.AccountOpening.Account.Read(AccountId, "")
    OutValue = AccountRec<AC.AccountOpening.Account.ShortTitle,1>

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
