* @ValidationCode : Mjo4NjE3MzkwOTY6Q3AxMjUyOjE2MDkyNDUzMjIwOTY6bWplYmFyYWo6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4yMDIwMTExMS0xMjEwOjEzOjEz
* @ValidationInfo : Timestamp         : 29 Dec 2020 18:05:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.GET.ALT.ACCOUNT.ID
*------------------------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Conversion routine to get alternate account ids of the contract
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         : AA.Framework.GetArrangement,AC.AccountOpening.Account.Read
* @access       : private
* @stereotype   : subroutine
* @author       : gayathrik@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 11/12/20 - Enhancement : 3930802
*            Task        : 3930805
*            Conversion routine to get alternate account ids of the contract
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING EB.Reports
    $USING AA.Framework
    $USING AC.AccountOpening

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    AccountId = EB.Reports.getOData()    ;* Get account id
    AltAccountIds = ""
    Err = ""
    
*** In Microservices, there is no account involved and arrangement id is used as primary key.
*** So get alt account ids from arrangement record in case of MS. Else get it from account record.
    IF AccountId[1,2] EQ "AA" THEN
        RArrangement = ""
        AA.Framework.GetArrangement(AccountId, RArrangement, Err)
        AltAccountIds = RArrangement<AA.Framework.Arrangement.ArrAlternateId>
    END ELSE
        RAccount = AC.AccountOpening.Account.Read(AccountId, Err)
        AltAccountIds = RAccount<AC.AccountOpening.Account.AltAcctId>
    END

    EB.Reports.setOData(AltAccountIds)    ;* Set alternate account ids

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
