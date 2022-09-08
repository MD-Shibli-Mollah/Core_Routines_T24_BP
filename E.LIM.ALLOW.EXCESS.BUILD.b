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
* <Rating>60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.ModelBank

    SUBROUTINE E.LIM.ALLOW.EXCESS.BUILD
*-----------------------------------------------------------------------------
* Modification History:
*
* 28/12/01 - GLOBUS_EN_10000351
*            This is the display routine for displaying the excess over the allowed
*            amts defined in limits for different ccys.
*
* 12/08/07 - CI_10050862 / REF: HD0711933
*            Fatal error in OPF during drilldown of Enq LIAB at LIMIT.SUMMARY enquiry
*
* 23/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 01/01/13 - Enhancement - 450817 / Task 486148
*            Changes done to get the account utilisation details from new work file
*			 LI.LIMIT.GROUP.ALLOCATION for the account whose customer has group limit setup.
*
*-----------------------------------------------------------------------------

    $USING LI.Config
    $USING AC.AccountOpening
    $USING AC.Config
    $USING EB.DataAccess
    $USING AC.CashFlow
    $USING LI.GroupLimit
    $USING EB.Reports

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*******************

* Open files

    LIMIT.KEY.LIST = ''
    ALLOWED.AMT.LIST = ''
    LIMIT.REC = ''
    LIMIT.ERR = ''
    ACCOUNT.REC = ''
    ACCOUNT.CCY = ''
    ACCOUNT.CCYS = ''
    ACCOUNT.ERR = ''
    AC.FLAG = 0
    NET.FLAG = 0
    CCY.BALANCE = ''
    CCY.ALLOWED = ''
    CCY.EXCESS = ''
    CCY.BALANCE.LIST = ''
    ALLOWED.CCY = ''
    ALLOWED.AMT = ''

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*****************

    YKEY = EB.Reports.getOData()

    LIM.COUNT = DCOUNT(YKEY,@FM)
    FOR I = 1 TO LIM.COUNT
        LIMIT.ID = YKEY<I>
        GOSUB PROCESS.LIMIT.ACCOUNTS
        IF ALLOWED.AMT.LIST THEN
            IF LIMIT.KEY.LIST THEN
                LIMIT.KEY.LIST:= @SM:LIMIT.ID
            END ELSE
                LIMIT.KEY.LIST = LIMIT.ID
            END
            GOSUB FORM.DISPLAY.DETAILS
        END
    NEXT I

    RETURN

*-----------------------------------------------------------------------------
PROCESS.LIMIT.ACCOUNTS:
**************************

* The excess for limit accounts can be calculated as follows:
* If an allowed amt has been defined in the ccy of the account then the
* allow netting flag in both the limit and account should be verified. If
* the flag has been set to 'NO' in both or either then the debit balances
* in the accounts only need to be considered for calculation of excess
* over the allowed amt. If it has been set to 'YES' then both the credit
* and debit balances need to be netted and the resultant negative balance
* needs to be compared with the allowed amt.

    LIMIT.REC = LI.Config.Limit.Read(LIMIT.ID, LIMIT.ERR)

    LIABILITY.NUMBER = LIMIT.REC<LI.Config.Limit.LiabilityNumber>
    ALLOW.NETTING = LIMIT.REC<LI.Config.Limit.AllowNetting>

    ACC.COUNT = DCOUNT(LIMIT.REC<LI.Config.Limit.AccCompany>,@VM)
    IF ACC.COUNT THEN
        AC.FLAG = 0
    END ELSE
        AC.FLAG = 1
    END

    IF NOT(AC.FLAG) THEN
        FOR ACC = 1 TO ACC.COUNT

            ACCOUNT.COMPANY = LIMIT.REC<LI.Config.Limit.AccCompany,ACC>
            AC.AccountOpening.GetAccountCompany(ACCOUNT.COMPANY)
            FN.ACCOUNT = "F":ACCOUNT.COMPANY:".ACCOUNT"
            F.ACCOUNT = ''
            EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)

            ACCOUNT.ID = LIMIT.REC<LI.Config.Limit.Account,ACC>
            GOSUB ACCOUNT.PROCESS

        NEXT ACC
    END
    GOSUB CALCULATE.EXCESS.AMOUNT


    RETURN

*-----------------------------------------------------------------------------
ACCOUNT.PROCESS:
*********************

    EB.DataAccess.FRead(FN.ACCOUNT,ACCOUNT.ID,ACCOUNT.REC,F.ACCOUNT,ACCOUNT.ERR)
    IF NOT(ACCOUNT.ERR) THEN
        ACCOUNT.CCY = ACCOUNT.REC<AC.AccountOpening.Account.Currency>
        ACCT.ALLOW.NETTING = ACCOUNT.REC<AC.AccountOpening.Account.AllowNetting>
        *
        accountKey = ACCOUNT.ID
        response.Details = ''
        workingBal = ''
        AC.CashFlow.AccountserviceGetworkingbalance(accountKey, workingBal, response.Details)
        *
        ACCOUNT.BALANCE = workingBal<AC.CashFlow.BalanceWorkingbal>

        IF ACCOUNT.BALANCE < 0 THEN
            * For the customers with group setup account balance is shared between many group limits
            * so get the exact amount allocated to the passed limit instead of using the whole account balance
            GROUP.CUST = '' ;* Set this flag to return the utilisation of the passed account
            LIMIT.UTILISED = 0
            YLIMIT.ID = LIMIT.ID
            * Get the limit allocated amount for the account
            LI.GroupLimit.GetAccountUtilisation(ACCOUNT.ID, ACCOUNT.REC, YLIMIT.ID, LIMIT.REC, GROUP.CUST, LIMIT.UTILISED, '', ERR)

            * In case the account does not use the passed limit and the balance is allocated by some other limits
            * balance returned value will be 0 so checking the return flag insted of checking return balance
            IF GROUP.CUST = 'YES' THEN ;* This flag indicates the passed account customer is in sharing group so use the returned value
                ACCOUNT.BALANCE = LIMIT.UTILISED ;* Take the returned balance
            END
        END

        IF ACCOUNT.CCY THEN
            IF ALLOW.NETTING EQ 'YES' AND ACCT.ALLOW.NETTING EQ 'YES' THEN
                NET.FLAG = 1
            END

            IF ACCOUNT.BALANCE LT 0 OR NET.FLAG THEN
                ACCOUNT.BALANCE = ACCOUNT.BALANCE/1000
                BALANCE = ACCOUNT.BALANCE

                LOCATE ACCOUNT.CCY IN ACCOUNT.CCYS<1,1,1> SETTING ALLOW.POINTER ELSE
                ALLOW.POINTER = 0
            END
            IF ALLOW.POINTER THEN
                CCY.BALANCE<1,1,ALLOW.POINTER> = CCY.BALANCE<1,1,ALLOW.POINTER> + BALANCE
            END ELSE
                ACCOUNT.CCYS = INSERT(ACCOUNT.CCYS,1,1,-1,ACCOUNT.CCY)
                CCY.BALANCE = INSERT (CCY.BALANCE,1,1,-1,BALANCE)
            END
        END
    END
    END

    RETURN


*-----------------------------------------------------------------------------
CALCULATE.EXCESS.AMOUNT:
******************************

    ALLOW.COUNT = DCOUNT(LIMIT.REC<LI.Config.Limit.AllowedCcy>,@VM)

    FOR ALLOW = 1 TO ALLOW.COUNT
        EXCESS.AMT = 0
        BALANCE.AMT = 0
        ALLOWED.CCY = LIMIT.REC<LI.Config.Limit.AllowedCcy,ALLOW>
        ALLOWED.AMT = LIMIT.REC<LI.Config.Limit.AllowedAmt,ALLOW>
        ALLOWED.AMT = ALLOWED.AMT/1000

        IF NOT(AC.FLAG) THEN
            LOCATE ALLOWED.CCY IN ACCOUNT.CCYS<1,1,1> SETTING ALLOW.POS ELSE
            ALLOW.POS = 0
        END

        IF ALLOW.POS THEN
            BALANCE.AMT = CCY.BALANCE<1,1,ALLOW.POS>
            BALANCE.AMT = ABS(BALANCE.AMT)
        END
    END

* For contract limits the OS.CCY and OS.AMT fields need to be compared
* with the ALLOWED.CCY and ALLOWED.AMT and the excess needs to be
* calculated.

    LOCATE ALLOWED.CCY IN LIMIT.REC<LI.Config.Limit.OsCcy,1,1> SETTING OS.POS ELSE
    OS.POS = ''
    END
    IF OS.POS THEN
        BALANCE.AMT = ABS(LIMIT.REC<LI.Config.Limit.OsAmt,1,OS.POS>)/1000 + BALANCE.AMT
    END

    IF BALANCE.AMT GT ALLOWED.AMT THEN
        EXCESS.AMT = BALANCE.AMT - ALLOWED.AMT
    END

    IF ALLOWED.AMT.LIST THEN
        ALLOWED.AMT.LIST:= @SM:ALLOWED.AMT
        CCY.EXCESS:= @SM:EXCESS.AMT
        CCY.ALLOWED:= @SM:ALLOWED.CCY
        CCY.BALANCE.LIST:= @SM:BALANCE.AMT
    END ELSE
        ALLOWED.AMT.LIST = ALLOWED.AMT
        CCY.EXCESS = EXCESS.AMT
        CCY.ALLOWED = ALLOWED.CCY
        CCY.BALANCE.LIST = BALANCE.AMT
    END

    NEXT ALLOW

    RETURN

*-----------------------------------------------------------------------------
FORM.DISPLAY.DETAILS:
***************************

    R.RECORD.TMP<1> = LIABILITY.NUMBER
    R.RECORD.TMP<2> = LIMIT.KEY.LIST
    R.RECORD.TMP<3> = CCY.ALLOWED
    R.RECORD.TMP<4> = ALLOWED.AMT.LIST
    R.RECORD.TMP<5> = CCY.BALANCE.LIST
    R.RECORD.TMP<6> = CCY.EXCESS
    EB.Reports.setRRecord(R.RECORD.TMP)
    EB.Reports.setVmCount(DCOUNT(R.RECORD.TMP,@VM))
    EB.Reports.setSmCount(DCOUNT(R.RECORD.TMP,@SM))

    RETURN
*-----------------------------------------------------------------------------
    END
