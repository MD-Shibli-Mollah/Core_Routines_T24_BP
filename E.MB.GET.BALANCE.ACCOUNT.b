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
* <Rating>-89</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.MB.GET.BALANCE.ACCOUNT(ENQ.DATA)
*-----------------------------------------------------------------------------
* Description:
*-------------
* This is a build routine for BALANCE.ACCOUNT.DETAILS enquiry file. This routine
* will get the account number based on the setup done in EB.FINANCIAL.SYSTEM.
* This will get the account number as follows.
*
* 1. If account number is given then no need to process
* 2. If Currency given then get the category from EB.FINANCIAL.SYSTEM and
*    read the CATEG.INT.ACCT file for that category and get account number for
*    the given currency
* 3. If branch id is given then get the category from EB.FINANCIAL.SYSTEM and
*    read the CATEG.INT.ACCT file for that category and get account number for
*    the given branch
* 4. If both Currency and branch id  is given then get the category from
*    EB.FINANCIAL.SYSTEM and read the CATEG.INT.ACCT file for that category and
*    get account number that matches both currency and company.
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 19/09/14 - Enhancement - 1068928 / Task - 1106681
*            New build routine.
*-----------------------------------------------------------------------------
    $USING ST.CompanyCreation
    $USING AC.EntryBalancing
    $USING AC.AccountOpening
*
*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*----------
*
    tmp.R.EB.FINANCIAL.SYSTEM.T24 = AC.EntryBalancing.getREbFinancialSystemTTwoFou()
    IF NOT(tmp.R.EB.FINANCIAL.SYSTEM.T24) THEN ;* If this is not in common variable then cache read the same
        R.EB.FINANCIAL.SYSTEM = ''
        Y.ERR = ''
        R.EB.FINANCIAL.SYSTEM = AC.EntryBalancing.EbFinancialSystem.CacheRead('T24', Y.ERR)
        AC.EntryBalancing.setREbFinancialSystemTTwoFou(R.EB.FINANCIAL.SYSTEM)
    END
*
    CURR.GIVEN = ''
    BRANCH.GIVEN = ''
*
    RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
*-------
*
    LOCATE 'ACCOUNT.NUMBER' IN ENQ.DATA<2,1> SETTING ENQ.FIELD.POS THEN ;* Account number given so no need to process furthur
    RETURN
    END
*
    ACCOUNT.NUMBERS = ''
*
    GOSUB GET.BALANCING.ACCOUNT.NUMBERS ;* Get the account number of balancing categories from CATEG.INT.ACCT
*
    CURR.POS = ''
    LOCATE 'CURRENCY' IN ENQ.DATA<2,1> SETTING CURR.POS THEN
    CURR.GIVEN = ENQ.DATA<4,CURR.POS> ;* Currency given in selection criteria
    END
*
    BRANCH.POS = ''
    LOCATE 'CO.CODE' IN ENQ.DATA<2,1> SETTING BRANCH.POS THEN
    BRANCH.GIVEN = ENQ.DATA<4,BRANCH.POS> ;* Company id given in selection criteria
    END
*
    BEGIN CASE
            *
        CASE CURR.GIVEN AND BRANCH.GIVEN ;* Need to filter based on both currency and company id
            GOSUB FILTER.BASED.ON.CURRENCY
            GOSUB FILTER.BASED.ON.BRANCH
            *
        CASE CURR.GIVEN ;* Need to filter based on currency
            GOSUB FILTER.BASED.ON.CURRENCY
            *
        CASE BRANCH.GIVEN ;* Need to filter based on company id
            GOSUB FILTER.BASED.ON.BRANCH
            *
    END CASE
*
    CONVERT @FM TO ' ' IN ACCOUNT.NUMBERS ;* Convert it to space so that core routine will change it to SM marker
*
    ENQ.DATA<2,ENQ.FIELD.POS> = 'ACCOUNT.NUMBER'
    ENQ.DATA<3,ENQ.FIELD.POS> = 'EQ'
    ENQ.DATA<4,ENQ.FIELD.POS> = ACCOUNT.NUMBERS
    ENQ.FIELD.POS += 1
*
    RETURN
*
*-----------------------------------------------------------------------------
GET.BALANCING.ACCOUNT.NUMBERS:
*-----------------------------
*
    LOCAL.BALANCING.CAT = AC.EntryBalancing.getREbFinancialSystemTTwoFou()<AC.EntryBalancing.EbFinancialSystem.EbFinBalancingCat>
    INT.CATEG.COUNT = DCOUNT(LOCAL.BALANCING.CAT,@VM) ;* Get the balancing category
    FOR INT.CATEG = 1 TO INT.CATEG.COUNT
        *
        INT.CATEG.ID = LOCAL.BALANCING.CAT<AC.EntryBalancing.EbFinancialSystem.EbFinBalancingCat,INT.CATEG>
        GOSUB GET.CATEG.INT.ACCT ;* Get the account number from CATG.INT.ACCT
        IF ACCOUNT.NUMBERS THEN
            ACCOUNT.NUMBERS<-1> = R.CATEG.INT.ACCT
        END ELSE
            ACCOUNT.NUMBERS = R.CATEG.INT.ACCT
        END
        *
    NEXT INT.CATEG
*
    RETURN
*
*-----------------------------------------------------------------------------
GET.CATEG.INT.ACCT:
*------------------
*
    R.CATEG.INT.ACCT = ''
    Y.ERR = ''
    R.CATEG.INT.ACCT = AC.AccountOpening.CategIntAcct.Read(INT.CATEG.ID, Y.ERR)
*
    RETURN
*
*-----------------------------------------------------------------------------
FILTER.BASED.ON.CURRENCY:
*------------------------
*
    ACCT.COUNT = DCOUNT(ACCOUNT.NUMBERS,@FM)
    FILTER.ACCTS = ''
    FOR ACCT.POS = 1 TO ACCT.COUNT
        IF ACCOUNT.NUMBERS<ACCT.POS>[1,3] EQ CURR.GIVEN THEN ;* If curreny is same then add the account
            IF NOT(FILTER.ACCTS) THEN
                FILTER.ACCTS = ACCOUNT.NUMBERS<ACCT.POS>
            END ELSE
                FILTER.ACCTS<-1> = ACCOUNT.NUMBERS<ACCT.POS>
            END
        END
    NEXT ACCT.POS
*
    ACCOUNT.NUMBERS = FILTER.ACCTS
*
    RETURN
*-----------------------------------------------------------------------------
FILTER.BASED.ON.BRANCH:
*----------------------
*
    R.COM = ''
    Y.ERR = ''
    R.COM = ST.CompanyCreation.Company.CacheRead(BRANCH.GIVEN, Y.ERR) ;* Get sub division code from company record
    SUB.DIV.CODE = R.COM<ST.CompanyCreation.Company.EbComSubDivisionCode>
*
    ACCT.COUNT = DCOUNT(ACCOUNT.NUMBERS,@FM)
    FILTER.ACCTS = ''
    FOR ACCT.POS = 1 TO ACCT.COUNT
        IF ACCOUNT.NUMBERS<ACCT.POS>[4] EQ SUB.DIV.CODE THEN
            IF NOT(FILTER.ACCTS) THEN
                FILTER.ACCTS = ACCOUNT.NUMBERS<ACCT.POS>
            END ELSE
                FILTER.ACCTS<-1> = ACCOUNT.NUMBERS<ACCT.POS>
            END
        END
    NEXT ACCT.POS
*
    RETURN
*
*-----------------------------------------------------------------------------
*
    END
