* @ValidationCode : MjotMTEyMDI2MzUzNDpjcDEyNTI6MTU3MDU5ODA2NTQ2NDpzcmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4xOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Oct 2019 10:44:25
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>141</Rating>
*-----------------------------------------------------------------------------
* Version 4 18/05/01  GLOBUS Release No. 200508 29/07/05
*
*************************************************************************
*
$PACKAGE IC.ModelBank
SUBROUTINE E.BUILD.INFO.ACCT.PREMIUM
*
*************************************************************************
*
* 28/10/96 - GB9601260
*
*            New sub-routine to initiate the PREMIUM.PROCESSING routine
*            in an ENQUIRY mode in order to create the premium details
*            into the INFO.ACCT.PREMIUM records which can then be viewed
*            by the users.
*
* 30/04/97 - GB9700339
*            SAVINGS.COND has become obsolete. Reference to it
*            must be changed to ACCT.GROUP.CONDITION
*
* 16/04/98 - GB9800251
*            Need to exclude converted files where the account is a
*            wash through account, ie not the REAL savings account.
*            Ie. After EURO conversion the ACCOUNTS with AUTO.PAY.ACCT
*                set will need to be ignored from a savings condition
*                group.
*
* 05/12/03 - EN_10002090
*            The READ statement has been replaced with EB.READ.PARAMETER
*            for the Multi-Book Enchancement.
*
* 08/10/19 - Task 3375978
*            Removal ST references which has been moved to AC
*
*************************************************************************
*

    $USING AC.AccountOpening
    $USING AC.Config
    $USING IC.OtherInterest
    $USING ST.CompanyCreation
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.Reports
    $USING IC.ModelBank

*
    GOSUB INITIALISATION
*
    GOSUB CALL.PREMIUM.PROCESSING
*
RETURN

*
*------------------------------------------------------------------
*
INITIALISATION:
*-------------
*
    CAP.DATE = ""
*
    ACCOUNT.ID = EB.Reports.getOData()
    LOCATE "CAP.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING CAP.POS THEN
        CAP.DATE = EB.Reports.getEnqSelection()<4,CAP.POS>
    END
*
    R.ACCOUNT = EB.Reports.getRRecord()
*
    EB.Reports.setOData("PR>0.00")

RETURN
*
*-----------------------------------------------------------------
*
CALL.PREMIUM.PROCESSING:
*----------------------
*
* GB9800251s
*
    IF R.ACCOUNT<AC.AccountOpening.Account.AutoPayAcct> THEN RETURN
*
* GB9800251e
*
    R.ACCT.GROUP.CONDITION = AC.Config.AcctGroupCondition.Read(R.ACCOUNT<AC.AccountOpening.Account.ConditionGroup>:R.ACCOUNT<AC.AccountOpening.Account.Currency>, READ.ERR)

    IF READ.ERR = "" THEN              ; * This is savings account

        MULTI.R.SAVINGS.PREMIUM = ""
        PREMIUMS.TO.PROCESS = ""

        GOSUB CREATE.PREMIUM.LIST

        DO.UPDATES = "N"
        PROCESS.MODE = "ENQUIRY"
        TOTAL.PREMIUM = ""
        ACC.PROCESSED = ""
        ERR.CODE = ""

        IC.OtherInterest.PremiumProcessing(MULTI.R.SAVINGS.PREMIUM,PREMIUMS.TO.PROCESS,"","",R.ACCOUNT,ACCOUNT.ID,DO.UPDATES,PROCESS.MODE,CAP.DATE,TOTAL.PREMIUM,ACC.PROCESSED,ERR.CODE)

        IF ERR.CODE = "" THEN
            IF TOTAL.PREMIUM THEN
                EB.Reports.setOData("PR>":TOTAL.PREMIUM)
            END
        END


    END

RETURN
*
*-----------------------------------------------------------------
*
CREATE.PREMIUM.LIST:
*------------------

    CNT = 1
    LOOP
    WHILE R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpPremiumType,CNT>

        READ.ERR = ""

* EN_10002090 /S
        COMP.CODE = R.ACCOUNT<AC.AccountOpening.Account.CoCode>
        SAV.PRE.ID = R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpPremiumType,CNT>
        PARAM.ID = SAV.PRE.ID:'*':COMP.CODE
        ST.CompanyCreation.EbReadParameter("F.SAVINGS.PREMIUM",'N','',R.SAVINGS.PREMIUM,PARAM.ID,F.SAVINGS.PREMIUM,READ.ERR)
* EN_10002090 /E

        IF READ.ERR THEN
            EB.SystemTables.setText("CANNOT READ SAVINGS.PREMIUM RECORD &":@FM:R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpPremiumType,CNT>)
            GOTO PROGRAM.ABORT
        END

        R.SAVINGS.PREMIUM = LOWER(R.SAVINGS.PREMIUM)
        MULTI.R.SAVINGS.PREMIUM<-1> = R.SAVINGS.PREMIUM
        R.SAVINGS.PREMIUM = RAISE(R.SAVINGS.PREMIUM)
        PREMIUMS.TO.PROCESS<-1> = R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpPremiumType,CNT>

        CNT +=1

    REPEAT

RETURN
*
*------------------------------------------------------------------
*
PROGRAM.ABORT:
*------------

    EB.ErrorProcessing.FatalError("E.BUILD.INFO.ACCT.PREMIUM")

RETURN
*
*------------------------------------------------------------------
*
END
