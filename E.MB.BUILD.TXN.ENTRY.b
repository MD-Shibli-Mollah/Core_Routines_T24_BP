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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.TXN.ENTRY(ENQ.DATA)
*==============================================================================================*
* Subroutine Type : Subroutine

* Attached to     : NOFILE Enquiry TXN.ENTRY

* Attached as     : Build Routine in the BUILD.ROUTINE field

* Incoming        : Common Variable ENQ.DATA

* Outgoing        : Common Varaible ENQ.DATA

* Primary Purpose : Build Rtn for TXN.ENTRY to format the transaction
*                   ID for AZ contracts

* Change History  :

* Version         : First Version

* @Author         : madhusudananp@temenos.com

*==============================================================================================*
* MODIFICATION
*
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------


    $USING EB.SystemTables
    $USING AC.AccountOpening

    AZ.ID = ENQ.DATA<4,1>

    BEGIN CASE
        CASE EB.SystemTables.getApplication() EQ 'AZ.ACCOUNT'
            R.ACCOUNT = AC.AccountOpening.tableAccount(AZ.ID, AC.ERR)
            AZ.PROD = R.ACCOUNT<AC.AccountOpening.Account.AllInOneProduct>
            IF NOT(EB.SystemTables.getEtext()) AND AZ.PROD THEN
                ENQ.DATA<4,1> = "AZ-":AZ.ID
            END
        CASE 1
    END CASE

    RETURN
    END
