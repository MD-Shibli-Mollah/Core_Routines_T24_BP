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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.MNE.CONV.RTN(ENQ.DATA)
*-------------------------------------------------------------------------------
* This is a build routine attached to the enquiry 'ACCOUNT.STATEMENT.ONLINE'.
* This builds the customer number when the mnemonic of a customer is given.
* Similarly it builds the account number if mnemonic of a account is given.
*-------------------------------------------------------------------------------
*
* 14/09/10 - Task 76280
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*--------------------------------------------------------------------------------
    $INSERT I_CustomerService_Key

    $USING AC.AccountOpening
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

**********
INITIALISE:
**********

    CUST.ERR = ''
    ACCT.ERR=''

    RETURN

********
PROCESS:
********

    LOCATE "CUSTOMER.NO" IN ENQ.DATA<2,1> SETTING Y.POS THEN
    mnemonic = ENQ.DATA<4,Y.POS>
    customerKey = ''
    CALL CustomerService.getCustomerForMnemonic(mnemonic, customerKey)
    IF NOT(EB.SystemTables.getEtext()) THEN
        ENQ.DATA<4,Y.POS> = customerKey<Key.customerID>
    END ELSE
        EB.SystemTables.setEtext('')
    END
    END

    LOCATE "ACCOUNT.NO" IN ENQ.DATA<2,1> SETTING Y.POS THEN
    R.MNEMONIC.ACCOUNT = AC.AccountOpening.tableMnemonicAccount(ENQ.DATA<4,Y.POS>, ACCT.ERR)
    IF ACCT.ERR EQ '' THEN
        ENQ.DATA<4,Y.POS> = R.MNEMONIC.ACCOUNT<AC.AccountOpening.MnemonicAccount.MacAccount>
    END
    END
    RETURN
*-----------------------------------------------------------------------------
    END
