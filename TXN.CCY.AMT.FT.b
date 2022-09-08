* @ValidationCode : MjotMTcxNzY5Njg4OkNwMTI1MjoxNTA0Nzc1MTc4OTc4OnJkaGVwaWtoYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzA4LjIwMTcwNzAzLTIxNDc6MTI6MTI=
* @ValidationInfo : Timestamp         : 07 Sep 2017 14:36:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdhepikha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/12 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.20170703-2147
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-54</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PZ.ModelBank
SUBROUTINE TXN.CCY.AMT.FT(ApplicationId, ApplicationRecord, StmtEntryId, StmtEntryRec, OutText)
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* Hook routine attached to STMT.NARR.FORMAT - FT.TXHIS.
* This routine determines the Credit amount of an underlying FT transaction.
*-----------------------------------------------------------------------------
*
* @uses EB.API
* @uses FT.Contract
* @package PZ.ModelBank
* @class TXN.CCY.AMT.FT
* @stereotype subroutine
* @author rdhepikha@temenos.com
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* @param ApplicationId     -    Transaction Reference (FT id)
* @param ApplicationRecord -    Transaction Record (Record of an FT transaction)
* @param StmtEntryId       -    ID of STMT.ENTRY
* @param StmtEntryRec      -    STMT.ENTRY record
*
* Outgoing Arguments:
*
* @param OutText           -    Transaction amount (credit amount in an FT TXN)
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*-----------------------------------------------------------------------------
*
* 06/09/17 - Enhancement 2140052 / Task 2261830
*            Hook routine attached to STMT.NARR.FORMAT - FT.TXHIS, to determine
*            the Credit amount of an underlying FT transaction
*
*** </region>
*
*-----------------------------------------------------------------------------

*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING EB.API
    $USING FT.Contract

*** </region>

*-----------------------------------------------------------------------------

*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    GOSUB initialise ;* Initialise the required values
    GOSUB process ;* Main process

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initialise the required values </desc>

    ssRecord = ""
    fieldNo = ""
    ErrMsg = ""
    amountCredited = ""
    OutText = ""

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> Main process </desc>

    amountCredited = ApplicationRecord<FT.Contract.FundsTransfer.AmountCredited>

* AMOUNT.CREDITED will be of format CCY:CreditAmount. Only the credit amount has to be returned
    OutText = amountCredited[4,99]

RETURN
*** </region>

END

