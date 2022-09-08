* @ValidationCode : MjoxMDI5NzUyNzY1OkNwMTI1MjoxNTEyMzgyODIwNzU5OnNhdGhpc2hrdW1hcmo6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcxMi4yMDE3MTEwOS0xNDMxOjE3MToxMjE=
* @ValidationInfo : Timestamp         : 04 Dec 2017 15:50:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sathishkumarj
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 121/171 (70.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201712.20171109-1431
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE E.TC.CONV.GET.VARIABLES
*-----------------------------------------------------------------------------
* Description
*--------------------
* This conversion routine is used to find the trans rights for the account, deposits and loans of this external user
*-------------------
* Routine type       : Conversion Routine.
* IN Parameters      : Produt Id & Product Line
* Out Parameters     : Array - Trans Rights, Prefered Product, Prefered Product Label & Prefered Product Position
*
*-------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 23/11/2017 - SI - 2314993 / Enhancement - 2315131 / Task - 2315134
*              Client BOI: Favourites (User Preferences)
*-------------------------------------------------------------------------------------------------
    $USING EB.Reports
    $USING T2.ModelBank
*
    GOSUB Initialise
    GOSUB Process
    GOSUB Finalise
*
RETURN
*-------------------------------------------------------------------------------------------------
*** <region name = Initialise>
Initialise:
*----------
***Initialise****
    DEFFUN System.getVariable()
*
    RequestVariable = EB.Reports.getOData() ;*Input variable for this conversion routine
    ProductId = FIELD(RequestVariable,"-", 1) ;* Product id
    ProductLine = FIELD(RequestVariable,"-", 2) ;* Product line
*
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name = Process>
Process:
*----------
***Process****
    BEGIN CASE
        CASE ProductLine EQ 'ACCOUNTS' ;* Accounts ext varibales check
            GOSUB AccountVariables
        CASE ProductLine EQ 'DEPOSITS' ;* Deposits ext varibales check
            GOSUB DepositVariables
        CASE ProductLine EQ 'LENDING' ;* Loans ext varibales check
            GOSUB LoanVariables
        CASE ProductLine EQ '' ;* If product line is null then redirect to account parah as non aa product
            GOSUB AccountVariables
    END CASE
*
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name = Account Variables>
AccountVariables:
*----------
***Process****
    ExtSmsAccounts      = System.getVariable("EXT.SMS.ACCOUNTS") ;*getting the trans accounts
    ExtSmsAccountsSee   = System.getVariable("EXT.SMS.ACCOUNTS.SEE") ;*getting the see accounts
    ExtPrfAccounts      = System.getVariable("EXT.PRF.ACCOUNTS") ;*getting the prf accounts
    ExtPrfAccountsLabel = System.getVariable("EXT.PRF.ACCOUNTS.LABEL") ;*getting the prf account labels
    ExtPrfAccountsPos   = System.getVariable("EXT.PRF.ACCOUNTS.POS") ;*getting the prf accounts positions
    
;* Convert / set ext sms accounts
    IF ExtSmsAccounts NE 'EXT.SMS.ACCOUNTS' THEN
        ExtSmsAccounts = RAISE(ExtSmsAccounts)
    END ELSE
        ExtSmsAccounts = ''
    END
    
;* Convert / set ext sms accounts see
    IF ExtSmsAccountsSee NE 'EXT.SMS.ACCOUNTS.SEE' THEN
        ExtSmsAccountsSee = RAISE(ExtSmsAccountsSee)
    END ELSE
        ExtSmsAccountsSee = ''
    END
    
;* Convert / set ext prf accounts
    IF ExtPrfAccounts NE 'EXT.PRF.ACCOUNTS' THEN
        ExtPrfAccounts = RAISE(ExtPrfAccounts)
    END ELSE
        ExtPrfAccounts = ''
    END
    
;* Convert / set ext pref account label
    IF ExtPrfAccountsLabel NE 'EXT.PRF.ACCOUNTS.LABEL' THEN
        ExtPrfAccountsLabel = RAISE(ExtPrfAccountsLabel)
    END ELSE
        ExtPrfAccountsLabel = ''
    END
    
;* Convert / set ext pref account positions
    IF ExtPrfAccountsPos NE 'EXT.PRF.ACCOUNTS.POS' THEN
        ExtPrfAccountsPos = RAISE(ExtPrfAccountsPos)
    END ELSE
        ExtPrfAccountsPos = ''
    END
    
;* Locate current product in ext sms accounts to get trans rights
    LOCATE ProductId IN ExtSmsAccounts<1,1> SETTING SmsAccPos THEN
        AccTransRight = "YES"       ;*Setting trans variable as Yes
    END ELSE
        AccTransRight = "NO"        ;*Setting trasn variable as No for false scenario
    END
    
;* Locate current product in ext sms accounts see to get see rights
    LOCATE ProductId IN ExtSmsAccountsSee<1,1> SETTING SmsAccSeePos THEN
        AccSeeRight = "YES"       ;*Setting trans variable as Yes
    END ELSE
        AccSeeRight = "NO"        ;*Setting trasn variable as No for false scenario
    END
    
;* Locate current product in ext pref accounts to get to know pref account & related details
    LOCATE ProductId IN ExtPrfAccounts<1,1> SETTING PrfAccPos THEN
        PreferedAccount = "YES"       ;*Setting prf account variable as Yes
        PreferedAccountLabel = ExtPrfAccountsLabel<1,PrfAccPos> ;*Setting prf account lable
        PreferedAccountPos = ExtPrfAccountsPos<1,PrfAccPos> ;*Setting prf account position
    END ELSE
        PreferedAccount = "NO"        ;*Setting trasn variable as No for false scenario
    END
* Final Array
    ResultArray = AccTransRight:"*":PreferedAccount:"*":PreferedAccountLabel:"*":PreferedAccountPos:"*":AccSeeRight
*
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name = Deposit Variables>
DepositVariables:
*----------
***Process****
    ExtSmsDeposits      = System.getVariable("EXT.SMS.DEPOSITS") ;*getting the trans deposits
    ExtSmsDepositsSee   = System.getVariable("EXT.SMS.DEPOSITS.SEE") ;*getting the see deposits
    ExtPrfDeposits      = System.getVariable("EXT.PRF.DEPOSITS") ;*getting the prf  deposits
    ExtPrfDepositsLabel = System.getVariable("EXT.PRF.DEPOSITS.LABEL") ;*getting the prf deposit labels
    ExtPrfDepositsPos   = System.getVariable("EXT.PRF.DEPOSITS.POS") ;*getting the prf deposit positions
    
;* Convert / set ext sms deposits
    IF ExtSmsDeposits NE 'EXT.SMS.DEPOSITS' THEN
        ExtSmsDeposits = RAISE(ExtSmsDeposits)
    END ELSE
        ExtSmsDeposits = ''
    END
    
;* Convert / set ext sms deposits see
    IF ExtSmsDepositsSee NE 'EXT.SMS.DEPOSITS.SEE' THEN
        ExtSmsDepositsSee = RAISE(ExtSmsDepositsSee)
    END ELSE
        ExtSmsDepositsSee = ''
    END
    
;* Convert / set ext prf deposits
    IF ExtPrfDeposits NE 'EXT.PRF.DEPOSITS' THEN
        ExtPrfDeposits = RAISE(ExtPrfDeposits)
    END ELSE
        ExtPrfDeposits = ''
    END
    
;* Convert / set ext pref deposits label
    IF ExtPrfDepositsLabel NE 'EXT.PRF.DEPOSITS.LABEL' THEN
        ExtPrfDepositsLabel = RAISE(ExtPrfDepositsLabel)
    END ELSE
        ExtPrfDepositsLabel = ''
    END
    
;* Convert / set ext pref deposits positions
    IF ExtPrfDepositsPos NE 'EXT.PRF.DEPOSITS.POS' THEN
        ExtPrfDepositsPos = RAISE(ExtPrfDepositsPos)
    END ELSE
        ExtPrfDepositsPos = ''
    END
    
;* Locate current product in ext sms deposits see to get trans rights
    LOCATE ProductId IN ExtSmsDeposits<1,1> SETTING SmsDepPos THEN
        DepTransRight = "YES"       ;*Setting trans variable as Yes
    END ELSE
        DepTransRight = "NO"        ;*Setting trasn variable as No for false scenario
    END
    
;* Locate current product in ext sms deposits see to get see rights
    LOCATE ProductId IN ExtSmsDepositsSee<1,1> SETTING SmsDepSeePos THEN
        DepSeeRight = "YES"       ;*Setting trans variable as Yes
    END ELSE
        DepSeeRight = "NO"        ;*Setting trasn variable as No for false scenario
    END
    
;* Locate current product in ext pref deposits to get to know pref account & related details
    LOCATE ProductId IN ExtPrfDeposits<1,1> SETTING PrfDepPos THEN
        PreferedDeposit = "YES"       ;*Setting prf deposit variable as Yes
        PreferedDepositLabel = ExtPrfDepositsLabel<1,PrfDepPos> ;*Setting prf deposit label
        PreferedDepositPos = ExtPrfDepositsPos<1,PrfDepPos> ;*Setting prf deposit position
    END ELSE
        PreferedDeposit = "NO"        ;*Setting trasn variable as No for false scenario
    END
*Final Array
    ResultArray = DepTransRight:"*":PreferedDeposit:"*":PreferedDepositLabel:"*":PreferedDepositPos:"*":DepSeeRight
*
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name = Loan Variables>
LoanVariables:
*----------
***Process****
    ExtSmsLoans      = System.getVariable("EXT.SMS.LOANS") ;*getting the trans loans
    ExtSmsLoansSee   = System.getVariable("EXT.SMS.LOANS.SEE") ;*getting the trans loans
    ExtPrfLoans      = System.getVariable("EXT.PRF.LOANS") ;*getting the prf loans
    ExtPrfLoansLabel = System.getVariable("EXT.PRF.LOANS.LABEL") ;*getting the prf loan labels
    ExtPrfLoansPos   = System.getVariable("EXT.PRF.LOANS.POS") ;*getting the prf loan positions
    
;* Convert / set ext sms loan
    IF ExtSmsLoans NE 'EXT.SMS.LOANS' THEN
        ExtSmsLoans = RAISE(ExtSmsLoans)
    END ELSE
        ExtSmsLoans = ''
    END
    
;* Convert / set ext sms loan see
    IF ExtSmsLoansSee NE 'EXT.SMS.LOANS.SEE' THEN
        ExtSmsLoansSee = RAISE(ExtSmsLoansSee)
    END ELSE
        ExtSmsLoansSee = ''
    END
    
;* Convert / set ext prf loan
    IF ExtPrfLoans NE 'EXT.PRF.LOANS' THEN
        ExtPrfLoans = RAISE(ExtPrfLoans)
    END ELSE
        ExtPrfLoans = ''
    END
    
;* Convert / set ext pref loan label
    IF ExtPrfLoansLabel NE 'EXT.PRF.LOANS.LABEL' THEN
        ExtPrfLoansLabel = RAISE(ExtPrfLoansLabel)
    END ELSE
        ExtPrfLoansLabel = ''
    END
    
;* Convert / set ext pref loan positions
    IF ExtPrfLoansPos NE 'EXT.PRF.LOANS.POS' THEN
        ExtPrfLoansPos = RAISE(ExtPrfLoansPos)
    END ELSE
        ExtPrfLoansPos = ''
    END
;* Locate current product in ext pref loan trans to get see rights
    LOCATE ProductId IN ExtSmsLoans<1,1> SETTING SmsLonPos THEN
        LonTransRight = "YES"       ;*Setting trans variable as Yes
    END ELSE
        LonTransRight = "NO"        ;*Setting trasn variable as No for false scenario
    END
;* Locate current product in ext pref loan see to get see rights
    LOCATE ProductId IN ExtSmsLoansSee<1,1> SETTING SmsLonSeePos THEN
        LonSeeRight = "YES"       ;*Setting trans variable as Yes
    END ELSE
        LonSeeRight = "NO"        ;*Setting trasn variable as No for false scenario
    END
;* Locate current product in ext pref loans to get to know pref account & related details
    LOCATE ProductId IN ExtPrfLoans<1,1> SETTING PrfLonPos THEN
        PreferedLoan = "YES"       ;*Setting prf loan variable as Yes
        PreferedLoanLabel = ExtPrfLoansLabel<1,PrfLonPos> ;*Setting prf loan variable label
        PreferedLoanPos = ExtPrfLoansPos<1,PrfLonPos> ;*Setting prf loan variable position
    END ELSE
        PreferedLoan = "NO"        ;*Setting trasn variable as No for false scenario
    END
*
    ResultArray = LonTransRight:"*":PreferedLoan:"*":PreferedLoanLabel:"*":PreferedLoanPos:"*":LonSeeRight
*
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
*** <region name = Initialise>
Finalise:
*----------
***Finalise****
    IF ResultArray THEN
        EB.Reports.setOData(ResultArray) ;*Assigning the result variable to the enquiry output
    END
*
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
END
