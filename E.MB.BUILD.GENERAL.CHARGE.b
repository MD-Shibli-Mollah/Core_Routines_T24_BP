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
* <Rating>-132</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.GENERAL.CHARGE(RET.ARR)

*-----------------------------------------------------------------------------------------
*
* DESCRIPTION :   This routine is attached to the NOFILE enquiry GENERAL.CHARGE.CONDITIONS
* -----------
* This routine will build the list of records for the given Key if the key is given in
* descending order based on the date in ID. If the key is not given the routine will sort
* all the records in descending order based on the date in ID.
*
*-----------------------------------------------------------------------------------------
* REVESION HISTORY :
* ----------------
*
* VERSION : 1.0         DATE : 20 JUL 09    SAR : SAR-2009-01-14-0003
*                                           CD  : EN_10004268
*
* 12/11/10 - Task - 107259
*            Replace the enterprise(customer service api)code where it reads MNEMONIC.CUSTOMER file.
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------------------


    $INSERT I_DAS.GENERAL.CHARGE
    $INSERT I_DAS.DEBIT.INT.ADDON
    $INSERT I_DAS.HIGHEST.DEBIT
    $INSERT I_DAS.GOVERNMENT.MARGIN
    $INSERT I_DAS.INTEREST.STATEMENT
    $INSERT I_DAS.BALANCE.REQUIREMENT
    $INSERT I_DAS.NUMBER.OF.CREDIT
    $INSERT I_DAS.NUMBER.OF.DEBIT
    $INSERT I_DAS.TURNOVER.DEBIT
    $INSERT I_DAS.TURNOVER.CREDIT
    $INSERT I_DAS.ACCT.STATEMENT.CHARGE
    $INSERT I_CustomerService_Key

    $USING AC.AccountOpening
    $USING IC.Config
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports

    GOSUB INIT
    GOSUB LOCATE.FIELDS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*---


    RETURN

*------------
LOCATE.FIELDS:
* -----------------------------------------------------------------------------------------------------------------------
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
*------------------------------------------------------------------------------------------------------------------------


    LOCATE "@ID" IN EB.Reports.getDFields() SETTING CUS.POS THEN

    Y.CUST = EB.Reports.getDRangeAndValue()<CUS.POS>
    Y.CUST.OPR = EB.Reports.getDLogicalOperands()<CUS.POS>

    mnemonic = Y.CUST
    customerKey = ''
    EB.SystemTables.setEtext('')
    CALL CustomerService.getCustomerForMnemonic(mnemonic, customerKey)

    IF NOT(EB.SystemTables.getEtext()) THEN
        SEL.CUST = customerKey<Key.customerID>
        R.CUST.ACCT  = AC.AccountOpening.tableCustomerAccount(SEL.CUST, ERR.CUST.ACCT)
        SEL.ACCT = R.CUST.ACCT

    END ELSE

        SEL.CUST = Y.CUST
        R.CUST.ACCT  = AC.AccountOpening.tableCustomerAccount(SEL.CUST, ERR.CUST.ACCT)
        SEL.ACCT = R.CUST.ACCT
    END


    CONVERT @FM TO @VM IN SEL.ACCT

    END

    LOCATE "DESCRIPTION" IN EB.Reports.getDFields() SETTING ACC.POS THEN

    Y.ACCT = EB.Reports.getDRangeAndValue()<ACC.POS>

    Y.ACCT.OPR = EB.Reports.getDLogicalOperands()<ACC.POS>
    R.MNE.ACCT = AC.AccountOpening.tableMnemonicAccount(Y.ACCT, ERR.MNE.ACCT)

    IF NOT(ERR.MNE.ACCT) THEN
        SEL.ACCT = R.MNE.ACCT<AC.AccountOpening.MnemonicAccount.MacAccount>
    END ELSE
        SEL.ACCT = Y.ACCT
    END

    END


    IF SEL.CUST NE '' AND SEL.ACCT NE '' THEN
        R.ACCOUNT = AC.AccountOpening.tableAccount(SEL.ACCT, ERR.ACCOUNT)

        IF NOT(ERR.ACCOUNT) THEN
            CUST.TEMP = R.ACCOUNT<AC.AccountOpening.Account.Customer>
        END
        IF SEL.CUST NE CUST.TEMP THEN
            SEL.ACCT = ''
        END
    END


    IF Y.ACCT EQ '' AND Y.CUST EQ '' THEN
        GOSUB READ.GENERAL.CHARGE
    END ELSE
        GOSUB READ.GC.FOR.ACCOUNTS
    END

    RETURN

********************
READ.GC.FOR.ACCOUNTS:
********************

    GC.ID.ARR = ''

    LOOP
        REMOVE CUS.ACCT FROM SEL.ACCT SETTING CUS.ACCT.POS
    WHILE CUS.ACCT:CUS.ACCT.POS
        R.ACCOUNT = AC.AccountOpening.tableAccount(CUS.ACCT, ERR.ACCOUNT)

        IF NOT(ERR.ACCOUNT) THEN

            CUS.ACCT.GRP.CON = R.ACCOUNT<AC.AccountOpening.Account.ConditionGroup>

            GEN.CHARGE.ID = CUS.ACCT.GRP.CON:'...'

            TABLE.NAME     = "GENERAL.CHARGE"
            DAS.LIST       = dasGeneralChargeIdByDateDsnd
            ARGUMENTS      = GEN.CHARGE.ID:'...'
            TABLE.SUFFIX   = ''

            EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

            IF DAS.LIST NE '' THEN

                REMOVE GC.ID FROM DAS.LIST SETTING GEN.ID.POS

                GOSUB RET.VALUES

                LOCATE GC.ID IN GC.ID.ARR SETTING GC.ID.POS ELSE

                GC.ID.ARR<-1> = GC.ID

                RET.ARR<-1> = GC.ID:"*":GC.DATE:"*":GC.DESC:"*":GC.DB.INT.ADDON:"*":GC.GOV.MAR:"*"

                RET.ARR : = GC.HIGH.DB:"*":GC.INT.STMT:"*":GC.BAL.REQ:"*":GC.NO.CREDIT:"*":GC.NO.DEBIT:"*"

                RET.ARR : = GC.TURNO.CREDIT:"*":GC.TURNO.DEBIT:"*":GC.STMT.CHARGE
            END

        END

    END

    ACCT.CNT = ACCT.CNT - 1

    REPEAT

    RETURN


*******************
READ.GENERAL.CHARGE:
*******************

    TABLE.NAME     = "GENERAL.CHARGE"
    DAS.LIST       = dasGeneralChargeIds
    TABLE.SUFFIX   = ''

    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    IF DAS.LIST NE '' THEN

        LOOP

            REMOVE GC.ID.TEMP FROM DAS.LIST SETTING GEN.ID.POS

        WHILE GC.ID.TEMP:GEN.ID.POS

            GC.ID.PREFIX = FIELD(GC.ID.TEMP, '.', 1)

            IF GC.ID.ADDED.PRE NE GC.ID.PREFIX THEN

                GC.ID.LIST<-1> = GC.ID.TEMP

                GC.ID.ADDED.PRE = GC.ID.PREFIX

            END

        REPEAT

        LOOP

            REMOVE GC.ID FROM GC.ID.LIST SETTING GC.ID.POS

        WHILE GC.ID:GC.ID.POS

            GOSUB RET.VALUES


            RET.ARR<-1> = GC.ID:"*":GC.DATE:"*":GC.DESC:"*":GC.DB.INT.ADDON:"*":GC.GOV.MAR:"*"

            RET.ARR : = GC.HIGH.DB:"*":GC.INT.STMT:"*":GC.BAL.REQ:"*":GC.NO.CREDIT:"*":GC.NO.DEBIT:"*"

            RET.ARR : = GC.TURNO.CREDIT:"*":GC.TURNO.DEBIT:"*":GC.STMT.CHARGE

        REPEAT

    END

    RETURN


*---------
RET.VALUES:
*---------

    R.GC = IC.Config.tableGeneralCharge(GC.ID, ERR.GC)

    GC.DATE = FIELD(GC.ID,'.',2,1)
    GC.DESC = R.GC<IC.Config.GeneralCharge.GchDescription>
    GC.DB.INT.ADDON  = R.GC<IC.Config.GeneralCharge.GchDebitIntAddon>

    IF GC.DB.INT.ADDON NE '' THEN

        GOSUB DEBIT.INT.ADDON

    END

    GC.GOV.MAR       = R.GC<IC.Config.GeneralCharge.GchGovernmentMargin>
    IF GC.GOV.MAR NE '' THEN
        GOSUB GOVERNMENT.MARGIN
    END

    GC.HIGH.DB       = R.GC<IC.Config.GeneralCharge.GchHighestDebit>
    IF GC.HIGH.DB NE '' THEN
        GOSUB HIGHEST.DEBIT
    END

    GC.INT.STMT      = R.GC<IC.Config.GeneralCharge.GchInterestStatement>
    IF GC.INT.STMT NE '' THEN
        GOSUB INTEREST.STATEMENT
    END

    GC.BAL.REQ       = R.GC<IC.Config.GeneralCharge.GchBalRequirement>
    IF GC.BAL.REQ NE '' THEN
        GOSUB BALANCE.REQUIREMENT
    END

    GC.NO.CREDIT     = R.GC<IC.Config.GeneralCharge.GchNumberOfCredit>
    IF GC.NO.CREDIT NE '' THEN
        GOSUB NUMBER.OF.CREDIT
    END

    GC.NO.DEBIT      = R.GC<IC.Config.GeneralCharge.GchNumberOfDebit>
    IF GC.NO.DEBIT NE '' THEN
        GOSUB NUMBER.OF.DEBIT
    END

    GC.TURNO.CREDIT  = R.GC<IC.Config.GeneralCharge.GchTurnoverCredit>
    IF GC.TURNO.CREDIT NE '' THEN
        GOSUB TURNOVER.CREDIT
    END

    GC.TURNO.DEBIT   = R.GC<IC.Config.GeneralCharge.GchTurnoverDebit>
    IF GC.TURNO.DEBIT NE '' THEN
        GOSUB TURNOVER.DEBIT
    END

    GC.STMT.CHARGE   = R.GC<IC.Config.GeneralCharge.GchStatementCharge>
    IF GC.STMT.CHARGE NE '' THEN
        GOSUB STATEMENT.CHARGE
    END

    RETURN


*--------------
DEBIT.INT.ADDON:
*--------------

    DAS.TABLE = "DEBIT.INT.ADDON"
    DAS.ARGUMENTS   = GC.DB.INT.ADDON:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST   = DAS.DEBIT.INT.ADDON.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE DB.INT.ADDON FROM DAS.TABLE.LIST SETTING DB.INT.ADDON.POS

    GC.DB.INT.ADDON = DB.INT.ADDON

    RETURN

*----------------
GOVERNMENT.MARGIN:
*----------------


    DAS.TABLE  = "GOVERNMENT.MARGIN"
    DAS.ARGUMENTS = GC.GOV.MAR:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.GOVERNMENT.MARGIN.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE GOV.MAR FROM DAS.TABLE.LIST SETTING GOV.MAR.POS

    GC.GOV.MAR = GOV.MAR

    RETURN

*------------
HIGHEST.DEBIT:
*------------

    DAS.TABLE = "HIGHEST.DEBIT"
    DAS.ARGUMENTS = GC.HIGH.DB:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.HIGHEST.DEBIT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE HIGH.DB FROM DAS.TABLE.LIST SETTING HIGH.DB.POS

    GC.HIGH.DB = HIGH.DB

    RETURN

*-----------------
INTEREST.STATEMENT:
*----------------


    DAS.TABLE  = "INTEREST.STATEMENT"
    DAS.ARGUMENTS = GC.INT.STMT:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.INTEREST.STATEMENT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE INT.STMT FROM DAS.TABLE.LIST SETTING INT.STMT.POS

    GC.INT.STMT = INT.STMT

    RETURN


*------------------
BALANCE.REQUIREMENT:
*------------------

    DAS.TABLE = "BALANCE.REQUIREMENT"
    DAS.ARGUMENTS = GC.BAL.REQ:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.BALANCE.REQUIREMENT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE BAL.REQ FROM DAS.TABLE.LIST SETTING BAL.REQ.POS

    GC.BAL.REQ = BAL.REQ

    RETURN

*---------------
NUMBER.OF.CREDIT:
*---------------

    DAS.TABLE  = "NUMBER.OF.CREDIT"
    DAS.ARGUMENTS = GC.NO.CREDIT:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.NUMBER.OF.CREDIT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE NO.CREDIT FROM DAS.TABLE.LIST SETTING NO.CREDIT.POS

    GC.NO.CREDIT = NO.CREDIT

    RETURN

*--------------
NUMBER.OF.DEBIT:
*--------------

    DAS.TABLE = "NUMBER.OF.DEBIT"
    DAS.ARGUMENTS = GC.NO.DEBIT:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.NUMBER.OF.DEBIT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE NO.DEBIT FROM DAS.TABLE.LIST SETTING NO.DEBIT.POS

    GC.NO.DEBIT = NO.DEBIT

    RETURN

*--------------
TURNOVER.CREDIT:
*-------------

    DAS.TABLE = "TURNOVER.CREDIT"
    DAS.ARGUMENTS = GC.TURNO.CREDIT:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.TURNOVER.CREDIT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE TURNO.CREDIT FROM DAS.TABLE.LIST SETTING TURNO.CREDIT.POS

    GC.TURNO.CREDIT = TURNO.CREDIT

    RETURN

*-------------
TURNOVER.DEBIT:
*------------

    DAS.TABLE = "TURNOVER.DEBIT"
    DAS.ARGUMENTS = GC.TURNO.DEBIT:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.TURNOVER.DEBIT.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE TURNO.DEBIT FROM DAS.TABLE.LIST SETTING TURNO.DEBIT.POS

    GC.TURNO.DEBIT = TURNO.DEBIT

    RETURN

*---------------
STATEMENT.CHARGE:
*---------------

    DAS.TABLE = "ACCT.STATEMENT.CHARGE"
    DAS.ARGUMENTS = GC.STMT.CHARGE:'...':@FM:LEFT(GC.DATE,6)
    DAS.TABLE.LIST = DAS.ACCT.STATEMENT.CHARGE.ID
    DAS.TABLE.SUFFIX = ''

    EB.DataAccess.Das(DAS.TABLE, DAS.TABLE.LIST, DAS.ARGUMENTS, DAS.TABLE.SUFFIX)

    REMOVE STMT.CHARGE FROM DAS.TABLE.LIST SETTING STMT.CHARGE.POS

    GC.STMT.CHARGE = STMT.CHARGE

    RETURN
