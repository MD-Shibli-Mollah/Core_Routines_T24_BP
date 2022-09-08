* @ValidationCode : Mjo0NDE4OTA2ODE6Q3AxMjUyOjE1MzczNTg2NTIyODg6bmlsb2ZhcnBhcnZlZW46NDowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDguMjAxODA3MjEtMTAyNjo4MTo3OQ==
* @ValidationInfo : Timestamp         : 19 Sep 2018 17:34:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nilofarparveen
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 79/81 (97.5%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.20180721-1026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.Channels
    SUBROUTINE E.NOFILE.TC.PRODUCTS.BALANCE(ProductsBalance)
*--------------------------------------------------------------------------------------------------------------
* Description :
*--------------
* This Enquiry(Nofile) routine is to provide the balance summary of the different product lines like Accounts, Deposits & Loans
*--------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.PRODUCTS.BALANCE using the Standard selection NOFILE.TC.PRODUCTS.BALANCE
* IN Parameters      : NA
* Out Parameters     : Accounts balance, Deposits balance, Loans balance
*--------------------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*---------------------
* 17/11/2016 - Enhancement 1836391 / Task 1931062
*              Profile card - Retail
*
* 18/09/2018 - Defect 2766148 / Task 2774139
*              Products Deposits and Loans Balance miscalculated in TC.NOF.PRODUCTS.BALANCE enquiry
*--------------------------------------------------------------------------------------------------------------
*** <region name = Inserts>
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING AC.BalanceUpdates
    $USING ST.ExchangeRate
    $USING EB.SystemTables
    $USING ST.CompanyCreation
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main process>
    GOSUB INITIALISE                                    ;* Initialise variables
    GOSUB BALANCE.CALCULATION                           ;* Calculate the balances for the respective product lines
    GOSUB BUILD.BALANCE.SUMMARY                         ;* Build final balance summary details
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialise variables>
INITIALISE:
*----------
    DEFFUN System.getVariable()
    ProductsBalance = '';
    BaseCurrency   = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCurrency) ;* To get the Logged in company currency from R.COMPANY common Variable.
    LocalCurrency = ''; LocalAmount = ''; ConvertedAmount = ''; ExChangeRate = ''; FinalAmount = ''
    ExtSmsAccountsSee = ''; TotNoOfAccts = ''; CurrentAccountPosition = ''; AcctNo = ''; RAccount = ''; AccountsBalance = ''
    ExtSmsDepositsSee = ''; TotNoOfDeposits = ''; CurrentDepositPosition = ''; DepositArrangementId = ''; RArrangement = ''; ArrAcctNo = ''; DepositsBalance = ''
    ExtSmsLoansSee = ''; TotNoOfLoans = ''; CurrentLoanPosition = ''; LoanArrangementId = ''; Onlineactualbal = ''
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Balance calculation>
BALANCE.CALCULATION:
*-------------------
*Accounts balance calculation
    ExtSmsAccountsSee = System.getVariable('EXT.SMS.ACCOUNTS.SEE')                ;* List of allowed account contracts defined in permission
    IF ExtSmsAccountsSee NE 'EXT.SMS.ACCOUNTS.SEE' THEN
        AccountsBalance = ''; Balance = '0'
        TotNoOfAccts      = DCOUNT(ExtSmsAccountsSee,@SM)
        FOR CurrentAccountPosition = 1 TO TotNoOfAccts
            AcctNo        = ExtSmsAccountsSee<1,1,CurrentAccountPosition>         ;* Processing account number
            RAccount      = AC.AccountOpening.Account.Read(AcctNo, ErrAcct)       ;* Read the account application
            LocalCurrency = RAccount<AC.AccountOpening.Account.Currency>          ;* Get the account currency
            AC.BalanceUpdates.AccountserviceGetonlineactualbalance(AcctNo, Onlineactualbal, ErrActBal)
            LocalAmount   = Onlineactualbal                                       ;* Get the account online actual balance
            GOSUB CHECK.FOR.BASE.CURRENCY
        NEXT CurrentAccountPosition
        AccountsBalance = Balance
    END ELSE
        AccountsBalance = '0'
    END
*Deposits balance calculation
    ExtSmsDepositsSee = System.getVariable('EXT.SMS.DEPOSITS.SEE')                  ;* List of allowed deposit contracts defined in permission
    IF ExtSmsDepositsSee NE 'EXT.SMS.DEPOSITS.SEE' THEN
        DepositsBalance = ''; Balance = '0'
        TotNoOfDeposits      = DCOUNT(ExtSmsDepositsSee,@SM)
        FOR CurrentDepositPosition = 1 TO TotNoOfDeposits
            DepositArrangementId = ExtSmsDepositsSee<1,1,CurrentDepositPosition>                    ;* Processing deposit arrangement
            RArrangement         = AA.Framework.Arrangement.Read(DepositArrangementId,ErrDeposit)   ;*Read the arragement details
            ArrAcctNo            = RArrangement<AA.Framework.Arrangement.ArrLinkedApplId>           ;*Get the account number of the deposit
            RAccount             = AC.AccountOpening.Account.Read(ArrAcctNo, ErrAcct)               ;* Read the account application
            LocalCurrency        = RAccount<AC.AccountOpening.Account.Currency>                     ;* Get the account currency
            AC.BalanceUpdates.AccountserviceGetonlineactualbalance(ArrAcctNo, Onlineactualbal, ErrActBal) ;*Get online actual balance
            LocalAmount          = Onlineactualbal                                                  ;* Get the account online actual balance
            GOSUB CHECK.FOR.BASE.CURRENCY
        NEXT CurrentDepositPosition
        DepositsBalance = Balance
    END ELSE
        DepositsBalance = '0'
    END
*Loans balance calculation
    ExtSmsLoansSee = System.getVariable('EXT.SMS.LOANS.SEE')                                        ;* List of allowed Loan contracts defined in permission
    IF ExtSmsLoansSee NE 'EXT.SMS.LOANS.SEE' THEN
        LoansBalance = ''; Balance = '0'
        TotNoOfLoans      = DCOUNT(ExtSmsLoansSee,@SM)
        FOR CurrentLoanPosition = 1 TO TotNoOfLoans
            LoanArrangementId    = ExtSmsLoansSee<1,1,CurrentLoanPosition>                       ;* Processing deposit arrangement
            RArrangement         = AA.Framework.Arrangement.Read(LoanArrangementId,ErrDeposit)      ;*Read the arragement details
            ArrAcctNo            = RArrangement<AA.Framework.Arrangement.ArrLinkedApplId>           ;*Get the account number of the deposit
            RAccount             = AC.AccountOpening.Account.Read(ArrAcctNo, ErrAcct)               ;* Read the account application
            LocalCurrency        = RAccount<AC.AccountOpening.Account.Currency>                     ;* Get the account currency
            AC.BalanceUpdates.AccountserviceGetonlineactualbalance(ArrAcctNo, Onlineactualbal, ErrActBal) ;*Get online actual balance
            LocalAmount          = Onlineactualbal                                                  ;* Get the account online actual balance
            GOSUB CHECK.FOR.BASE.CURRENCY
        NEXT CurrentLoanPosition
        LoansBalance = ABS(Balance)
    END ELSE
        LoansBalance = '0'
    END
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Check for base currency to calculate the exchange rate>
CHECK.FOR.BASE.CURRENCY:
*-----------------------
    IF BaseCurrency NE LocalCurrency THEN       ;*Check for base currency
        GOSUB EXCHANGE.RATE.CALCULATION         ;* Calculate exchange rate value
        FinalAmount = ConvertedAmount
        GOSUB BALANCE.SUMMARY                   ;* Calculate total balance for the product line
    END ELSE
        FinalAmount = LocalAmount
        GOSUB BALANCE.SUMMARY
    END
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Balance summary>
BALANCE.SUMMARY:
*---------------
    Balance = Balance + FinalAmount             ;* Calculate total balance for the product line
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Exchange rate calculation>
EXCHANGE.RATE.CALCULATION:
*-----------------------------
    ConvertedAmount = "" 
    ST.ExchangeRate.Exchrate('1',LocalCurrency,LocalAmount,BaseCurrency,ConvertedAmount,'','','','','')  ;* Get the exchange rate value
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Final array>
BUILD.BALANCE.SUMMARY:
*---------------------
    ProductsBalance<-1> = AccountsBalance:"*":DepositsBalance:"*":LoansBalance:"*":BaseCurrency       ;* Build final balance array for the respective product line
    RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
    END
