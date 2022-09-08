* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.CUST.ACCTS(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* Subroutine Type : Subroutine
* Attached to     : Called From enquiry SCV.ACCOUNT.LIST
* Attached as     : Build Routine
* Primary Purpose : To Overcome the performance Issue
*
* Incoming        :
* ------------------------------------------------------------------------
* Outgoing        : ENQ.DATA - which contains the account ids of the
*                   respective external user
* ------------------------------------------------------------------------
* MODIFICATION
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------

    $USING AC.AccountOpening

*
    LOCATE "CUSTOMER" IN ENQ.DATA<2,1> SETTING POS THEN
    CUST.ID = ENQ.DATA<4,POS>
    END

* ------------------------------------------------------------------------
*  Open the files needed

* ------------------------------------------------------------------------
    SEL.CMD = ''
    ACCT.ARR = ''
    R.CUS.ACCT = AC.AccountOpening.tableCustomerAccount(CUST.ID,ERR)
    IF NOT(ERR) THEN
        ACCT.ARR = R.CUS.ACCT
    END

    CONVERT @FM TO ' ' IN ACCT.ARR
    ENQ.DATA<2> = '@ID'
    ENQ.DATA<3> = 'EQ'
    ENQ.DATA<4> = ACCT.ARR

    RETURN
