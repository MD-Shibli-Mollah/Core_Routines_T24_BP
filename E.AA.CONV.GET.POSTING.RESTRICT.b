* @ValidationCode : MjoxNTI0OTY4MjgyOkNwMTI1MjoxNjA5MjQ1MzIxODAyOm1qZWJhcmFqOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMTEtMTIxMDoxMzoxMw==
* @ValidationInfo : Timestamp         : 29 Dec 2020 18:05:21
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

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.GET.POSTING.RESTRICT
*-----------------------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Conversion routine to get the posting restrict of the contract
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
*            Conversion routine to get the posting restrict of the contract
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
    PostingRestricts = ""
    Err = ""
    
*** In Microservices, there is no account involved and arrangement id is used as primary key.
*** So get posting restrict from arrangement record in case of MS. Else get it from account record.
    IF AccountId[1,2] EQ "AA" THEN
        RArrangement = ""
        AA.Framework.GetArrangement(AccountId, RArrangement, Err)
        PostingRestricts = RArrangement<AA.Framework.Arrangement.ArrPostingRestrict>
    END ELSE
        RAccount = AC.AccountOpening.Account.Read(AccountId, Err)
        PostingRestricts = RAccount<AC.AccountOpening.Account.PostingRestrict>
    END
    EB.Reports.setOData(PostingRestricts)     ;* Set posting restrict

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
