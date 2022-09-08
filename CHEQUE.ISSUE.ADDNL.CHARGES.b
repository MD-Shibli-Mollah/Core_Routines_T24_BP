* @ValidationCode : MjoxOTc4OTc3MTI0OkNwMTI1MjoxNTgzOTMwNjMwMzg2OnJ2YXJhZGhhcmFqYW46MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOjExMDo5Nw==
* @ValidationInfo : Timestamp         : 11 Mar 2020 18:13:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 97/110 (88.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.ADDNL.CHARGES(ACCOUNT.NUMBER,ACCOUNT,MAT CHEQUE.ISSUE, EXCH.RATE, NEW.ID, YR.MULTI.STMT)

*-----------------------------------------------------------------------------
*  Input Parameters
*     ACCOUNT.NUMBER   :  Account Number to debit charges
*     ACCOUNT          :  Account Record to debit charges
*     CHEQUE.ISS       :  Cheque.Issue Record
*     EXCH.RATE        :  Rate for conversion if not LCCY
*     NEW.ID           :  Cheque.Issue ID - reference
*
*  Output Parameters
*     YR.MULTI.STMT    :  Stmt.Entry array, This array is appended
*
*-----------------------------------------------------------------------------
* 06/08/07 - CI_10049750
*            For LCCY entries are updated with AMOUNT.FCY & EXCHANGE.RATE.
* 20/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 18/09/15 - Enhancement 1265068 / Task 1475953
*         - Routine Incorporated
*
* 08/11/11/17 - Task :2335617
*               System is not populating the TAX related information in NARRATIVE fields of the respective STMT.ENTRY record.
*               Defect : 2315457
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 07/01/2020 - Defect 3515833 / Task 3526388
*              Code changes done to retain commission/charge/tax code even its value is zero.
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG*-----------------------------------------------------------------------------
    $USING CQ.ChqIssue
    $USING AC.AccountOpening
    $USING AC.EntryCreation
    $USING EB.Security
    $USING EB.SystemTables
    $INSERT I_CustomerService_AccountOfficer
*-----------------------------------------------------------------------------------------

    STMT.ENTRY=''
    BUILD.ENTRY=1
    ACCT.CUST = ACCOUNT<AC.AccountOpening.Account.Customer>
    ACCT.CURR = ACCOUNT<AC.AccountOpening.Account.Currency>
    CNT.CHG.CODE = DCOUNT(CHEQUE.ISSUE(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode),@VM)
    CNT.TAX.CODE = DCOUNT(CHEQUE.ISSUE(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode),@VM)
    CNT.TAX.CHG.CODE = DCOUNT(CQ.ChqIssue.getCqChgData()<2>,@VM)
    CHG.DATA = CQ.ChqIssue.getCqChgData()
    INTERNAL.ACCT = ''

**** This is common part ****
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCompanyCode> = EB.SystemTables.getIdCompany()
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteDepartmentCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteSystemId> = 'CQ'
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteBookingDate> = EB.SystemTables.getToday()
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrencyMarket> = "1"
    ACCOUNT.OFFICER = ACCOUNT<AC.AccountOpening.Account.AccountOfficer>
    IF ACCOUNT.OFFICER EQ'' THEN
        customerId = ACCOUNT<AC.AccountOpening.Account.Customer>
        customerAccountOfficer = ''
        CALL CustomerService.getAccountOfficer(customerId, customerAccountOfficer)
        ACCOUNT.OFFICER = customerAccountOfficer<AccountOfficer.accountOfficer>
        EB.SystemTables.setEtext('')
    END
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountOfficer> = ACCOUNT.OFFICER
    REFERENCE = NEW.ID
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteOurReference> = REFERENCE
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteTransReference> = REFERENCE
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber> = ''
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteProductCategory> = ACCOUNT<AC.AccountOpening.Account.Category>
    STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = ACCOUNT<AC.AccountOpening.Account.Currency>

    FOR CNT = 1 TO CNT.TAX.CHG.CODE
*** For Debiting Charges
* Do not raise entries if the amount is 0 .
        IF CHG.DATA<2,CNT> NE 'TAX' AND ((CHG.DATA<4,CNT> AND CHG.DATA<4,CNT> NE 0) OR (CHG.DATA<5,CNT> AND CHG.DATA<5,CNT> NE 0)) THEN
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber> = ACCOUNT.NUMBER
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.StePlCategory> = ''
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = ACCOUNT<AC.AccountOpening.Account.Currency>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCustomerId> = ACCOUNT<AC.AccountOpening.Account.Customer>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteTransactionCode> = CHG.DATA<8,CNT>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteValueDate> = EB.SystemTables.getToday()
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountLcy> = CHG.DATA<4,CNT> * -1

            IF ACCOUNT<AC.AccountOpening.Account.Currency> EQ EB.SystemTables.getLccy() THEN
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = ''
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = ''
            END ELSE
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = CHG.DATA<5,CNT> * -1
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = CHG.DATA<6,CNT>
            END

            YR.MULTI.STMT<-1>=STMT.ENTRY

*** For crediting charges
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteTransactionCode> = CHG.DATA<7,CNT>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteValueDate> = ''

            INTERNAL.ACCT=''
            AC.AccountOpening.IntAcc(CHG.DATA<3,CNT>,INTERNAL.ACCT)
            IF INTERNAL.ACCT THEN
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber>= CHG.DATA<3,CNT>
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.StePlCategory> = ''
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = CHG.DATA<3,CNT>[1,3]
            END ELSE
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber>= ''     ;* Account Number
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.StePlCategory> = CHG.DATA<3,CNT>
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = ACCOUNT<AC.AccountOpening.Account.Currency>
            END
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountLcy> = CHG.DATA<4,CNT>

            IF STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> EQ EB.SystemTables.getLccy() THEN   ;* CI_10049750 S/E
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = ''
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = ''
            END ELSE
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = CHG.DATA<5,CNT>
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = CHG.DATA<6,CNT>
            END

            YR.MULTI.STMT<-1> = STMT.ENTRY
        END
    NEXT CNT

***** For  Debiting taxes
    FOR CNT = 1 TO CNT.TAX.CHG.CODE
* Do not raise entries if the amount is 0 .
        IF CHG.DATA<2,CNT> EQ 'TAX' AND ((CHG.DATA<4,CNT> AND CHG.DATA<4,CNT> NE 0) OR (CHG.DATA<5,CNT> AND CHG.DATA<5,CNT> NE 0)) THEN
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber> = ACCOUNT.NUMBER
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.StePlCategory> = ''
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCustomerId> = ACCOUNT<AC.AccountOpening.Account.Customer>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteTransactionCode> = CHG.DATA<8,CNT>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteValueDate> = EB.SystemTables.getToday()
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountLcy> = CHG.DATA<4,CNT> *-1

            IF ACCOUNT<AC.AccountOpening.Account.Currency> EQ EB.SystemTables.getLccy() THEN
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = EB.SystemTables.getLccy()
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = ''
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = ''
            END ELSE
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = CHG.DATA<5,CNT> * -1
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = ACCOUNT<AC.AccountOpening.Account.Currency>
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = CHG.DATA<6,CNT>
            END

            YR.MULTI.STMT<-1> = STMT.ENTRY

**** For crediting taxes
            IF CHG.DATA<12,CNT> NE '' THEN
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteNarrative> = CHG.DATA<12,CNT>    ;* add Narrative of Tax in Stmt Entry record
            END
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAccountNumber> = CHG.DATA<3,CNT>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.StePlCategory> = ''
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCustomerId> = ''
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteTransactionCode> = CHG.DATA<7,CNT>
            STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountLcy> = CHG.DATA<4,CNT>

            IF CHG.DATA<3,CNT>[1,3] EQ EB.SystemTables.getLccy() THEN
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = ''
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = EB.SystemTables.getLccy()
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = ''
            END ELSE
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteAmountFcy> = CHG.DATA<5,CNT>
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteCurrency> = CHG.DATA<3,CNT>[1,3]
                STMT.ENTRY<1,AC.EntryCreation.StmtEntry.SteExchangeRate> = CHG.DATA<6,CNT>
            END

            YR.MULTI.STMT<-1> = STMT.ENTRY
        END

    NEXT CNT


RETURN
*-----------(Main)



END
*-----(End of Cheque.Issue.Addnl.Charges)
