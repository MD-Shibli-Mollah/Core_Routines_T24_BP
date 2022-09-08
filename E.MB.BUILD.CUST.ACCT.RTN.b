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
* <Rating>-66</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.CUST.ACCT.RTN(ENQ.DATA)
*--------------------------------------------------------------------------------------------------------
* DESCRIPTION :
* -----------
* This routine is attched to a NOFILE enquiry GENERIC.CHARGES
* The Enquiry displays the list of generic charges set across the system for accounts belonging to a customer.
*---------------------------------------------------------------------------------------------------------

* REVESION HISTORY :
* ----------------
*
*  VERSION : 1.0        DATE : 16 JUL 09        CD  : EN_10004268
*                                               SAR : SAR-2009-01-14-0003
*
* 12/11/10 - Task - 107259
*            Replace the enterprise(customer service api)code where it reads MNEMONIC.CUSTOMER file.
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*----------------------------------------------------------------------------------------------------------

    $INSERT I_CustomerService_Key
    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING IC.Config

    GOSUB INITIALISE
    GOSUB LOCATE.FIELDS
    GOSUB READ.IC.CHARGE

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*---------


    RETURN
*-----------------------------------------------------------------------------
LOCATE.FIELDS:
*---------------------------------------------------------------------------------------------------------------------
*
* 1.
*
* This part of the routine is used to locate the CUSTOMER and ACCOUNT numbers that are input in the
* enquiry selection criteria. If CUSTOMER number is given in the selection then the ACCOUNT numbers of that customer
* are updated in the variable SEL.ACCT by reading the CUSTOMER.ACCOUNT application. If CUSTOMER mnemonic is given in the
* enquiry selection then the corresponding CUSTOMER number is updated in the variable SEL.CUST by reading the
* CUSTOMER.MNEMONIC application
*
* 2.
*
* If ACCOUNT number is given in the selction then it is used else if the ACCOUNT mnemonic is given in the selection
* then the corresponding ACCOUNT number is updated in the variable SEL.ACCT by reading the ACCOUNT.MNEMONIC application
*
*----------------------------------------------------------------------------------------------------------------------


    ENQ.DATA.FIELDS = ENQ.DATA<2>
    E.OPERAND = ENQ.DATA<3>
    E.DATA = ENQ.DATA<4>


    LOCATE "@ID" IN ENQ.DATA.FIELDS SETTING CUS.POS THEN

    Y.CUST = E.DATA<CUS.POS>
    mnemonic = Y.CUST
    customerKey = ''
    EB.SystemTables.setEtext('')
    CALL CustomerService.getCustomerForMnemonic(mnemonic, customerKey)

    IF NOT(EB.SystemTables.getEtext()) THEN
        SEL.CUST = customerKey<Key.customerID>
        R.CUST.ACCT = AC.AccountOpening.tableCustomerAccount(SEL.CUST, ERR.CUST.ACCT)
        SEL.ACCT = R.CUST.ACCT

    END ELSE

        SEL.CUST = Y.CUST
        R.CUST.ACCT = AC.AccountOpening.tableCustomerAccount(SEL.CUST, ERR.CUST.ACCT)
        SEL.ACCT = R.CUST.ACCT
    END

    CONVERT @FM TO @VM IN SEL.ACCT

    END


    LOCATE "IC.CHARGE.ID" IN ENQ.DATA.FIELDS SETTING ACC.POS THEN

    Y.ACCT = E.DATA<ACC.POS>
    SEL.ACCT = Y.ACCT
    R.MNE.ACCT = AC.AccountOpening.tableMnemonicAccount(Y.ACCT, ERR.MNE.ACCT)

    IF NOT(ERR.MNE.ACCT) THEN
        SEL.ACCT = R.MNE.ACCT
    END ELSE
        SEL.ACCT = Y.ACCT
    END

    END


    RETURN
*-----------------------------------------------------------------------------
READ.IC.CHARGE:
*---------------------------------------------------------------------------------------------------------------------
* For each account in the variable SEL.ACCT the application IC.CHARGE is read with id as 'A-':Accout Number.
* If the record exists then it is added to the returning array variable RET.SEL.
*
* If the record doesn't exist then the ACCOUNT application is read with the id as Account Number and the variables
* AC.COND.GRP, AC.CURR  are updated with the CONDITION.GROUP and CURRENCY details respectively.
*
* Now the application IC.CHARGE is read with  id as "G-":<<CONDITION.GROUP>>. If record exists the the return variable
* RET.SEL is updated with the value "G-":<<CONDITION.GROUP>>.
*
* If record doesn't exist then the application IC.CHARGE is read with the id G-<<CONDITION.GROUP>>-<<CURRENCY>>
* and if a value exists the the variable RET.SEL is updated with the value G-<<CONDITION.GROUP>>-<<CURRENCY>>.
*
*---------------------------------------------------------------------------------------------------------------------


    ACCT.CNT = DCOUNT(SEL.ACCT, @VM)

    LOOP
        REMOVE CUS.ACCT FROM SEL.ACCT SETTING CUS.ACCT.POS
    WHILE ACCT.CNT GE '1'

        IC.CHARGE.ID = "A-":CUS.ACCT
        R.IC.CHARGE = IC.Config.tableCharge(IC.CHARGE.ID, ERR.IC.CHARGE)

        IF NOT(ERR.IC.CHARGE) THEN
            RET.SEL<-1> = IC.CHARGE.ID
        END ELSE
            GOSUB READ.ACCOUNT
        END

        ACCT.CNT = ACCT.CNT -1
    REPEAT

    ENQ.DATA<2> = "@ID"

    ENQ.DATA<3> = "EQ"

    ENQ.DATA<4> = RET.SEL

    RETURN
*-----------------------------------------------------------------------------
READ.ACCOUNT:
*-----------
    R.ACCOUNT = AC.AccountOpening.tableAccount(CUST.ACCT, ERR.ACCOUNT)

    AC.COND.GRP = R.ACCOUNT<AC.AccountOpening.Account.ConditionGroup>

    AC.CURR     = R.ACCOUNT<AC.AccountOpening.Account.Currency>

    G.ID = "G-":AC.COND.GRP
    R.IC.CHARGE = IC.Config.tableCharge(G.ID, ERR.G.IC.CHARGE)

    IF NOT(ERR.G.IC.CHARGE) THEN
        RET.SEL<-1> = G.ID
    END ELSE
        G.CUR.ID = "G-":AC.COND.GRP:"-":AC.CURR
        R.IC.CHARGE = IC.Config.tableCharge(G.CUR.ID, ERR.GC.IC.CHARGE)

        IF NOT(ERR.GC.IC.CHARGE) THEN
            RET.SEL<-1> = G.CUR.ID
        END
    END

    RETURN
*-----------------------------------------------------------------------------
    END
