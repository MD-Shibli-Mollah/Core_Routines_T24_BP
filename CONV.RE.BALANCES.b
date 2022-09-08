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
* <Rating>-55</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.RE.BALANCES(ACCOUNT.ID,R.ACCOUNT,FILE)
*--------------------------------------------------------------------
* Modification :
*
* 14/10/05 - EN_10002692
*            New routine
*
* 01/06/06 - CI_10041570
*            System throws CACHE.EXCEEDS error when CONVERSION.DETAILS is run
*
* 06/09/2006 - CI_10043849
*            Conversion processes all companies accounts and write them into
*            RE.CONTRACT.BALANCE file of the company in which the conversion
*            is run, instead of writing it to the respective company's
*            RE.CONTRACT.BALANCE file.
*
*06/11/2009 - CI_10067361
*
*              Incorrect updates to RE.CONTRACT.BALANCES for suspense accruals.
*
*---------------------------------------------------------------------
*
* New routine to build RE.CONTRACT.BALANCES for account to hold
* accrual figures.

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.RE.CONTRACT.BALANCES
    $INSERT I_F.DATES

*--- Main processing.

    IF FILE['$',2,1] = '' THEN          ;* Live record.
        IF NOT(NUM(ACCOUNT.ID))THEN RETURN
        GOSUB INITIALISE
        GOSUB UPDATE.BALANCE
    END

    RETURN

*----------
INITIALISE:
*----------

    COMP.MNE = FILE[2,3]
    FN.RE.CONTRACT.BALANCES = 'F':COMP.MNE:'.RE.CONTRACT.BALANCES'
    F.RE.CONTRACT.BALANCES = ''
    CALL OPF(FN.RE.CONTRACT.BALANCES,F.RE.CONTRACT.BALANCES)
    R.RE.CONTRACT.BALANCES = ''

    ACCOUNT.REC = R.ACCOUNT

    IF ACCOUNT.REC<AC.CONTINGENT.INT> = "O" THEN
        INT.SUFFIX = "OFFSP"
    END ELSE
        INT.SUFFIX = "SP"
    END
    BALANCE.DATE = R.DATES(EB.DAT.LAST.WORKING.DAY)

    RETURN

*--------------
UPDATE.BALANCE:
*--------------

    Y.LOC.FIELDS = AC.ACCR.CHG.CATEG:FM:AC.ACCR.CR.CATEG:FM:AC.ACCR.CR2.CATEG:FM:AC.ACCR.DR.CATEG:FM:AC.ACCR.DR2.CATEG
    Y.AMT.FIELDS = AC.ACCR.CHG.AMOUNT:FM:AC.ACCR.CR.AMOUNT:FM:AC.ACCR.CR2.AMOUNT:FM:AC.ACCR.DR.AMOUNT:FM:AC.ACCR.DR2.AMOUNT
    Y.SUSP.FIELDS = AC.ACCR.CHG.SUSP:FM:AC.ACCR.CR.SUSP:FM:AC.ACCR.CR2.SUSP:FM:AC.ACCR.DR.SUSP:FM:AC.ACCR.DR2.SUSP

    FOR Y.AF = 1 TO 5
        ACC.CAT.FLD = Y.LOC.FIELDS<Y.AF>
        ACC.AMT.FLD = Y.AMT.FIELDS<Y.AF>
        ACC.SUSP.FLD = Y.SUSP.FIELDS<Y.AF>

        GOSUB ACCUMULATE.BALANCES

    NEXT Y.AF

    IF R.RE.CONTRACT.BALANCES THEN      ;* If there is any accrual.
        R.RE.CONTRACT.BALANCES<RCB.CURRENCY> = ACCOUNT.REC<AC.CURRENCY>
        R.RE.CONTRACT.BALANCES<RCB.CONSOL.KEY> = ACCOUNT.REC<AC.CONSOL.KEY>
        R.RE.CONTRACT.BALANCES<RCB.CUSTOMER> = ACCOUNT.REC<AC.CUSTOMER>
        WRITE R.RE.CONTRACT.BALANCES TO F.RE.CONTRACT.BALANCES,ACCOUNT.ID
    END

    RETURN

*-------------------
ACCUMULATE.BALANCES:
*-------------------

    IF ACCOUNT.REC<ACC.CAT.FLD> THEN    ;* Check if there is any accrual for that type.
        ACCR.CNT = DCOUNT(ACCOUNT.REC<ACC.CAT.FLD>,VM)
        FOR Y.AC = 1 TO ACCR.CNT        ;* Loop thru all categories.
            ACCR.CATEGORY = ACCOUNT.REC<ACC.CAT.FLD,Y.AC>
            IF ACCOUNT.REC<ACC.AMT.FLD,Y.AC> THEN
                R.RE.CONTRACT.BALANCES<RCB.VALUE.DATE,-1> = BALANCE.DATE
                R.RE.CONTRACT.BALANCES<RCB.TYPE,-1> = ACCR.CATEGORY
                R.RE.CONTRACT.BALANCES<RCB.BALANCE,-1> = ACCOUNT.REC<ACC.AMT.FLD,Y.AC>
            END
            GOSUB CHECK.FOR.SUSPENSE
        NEXT Y.AC
    END
    RETURN

*-------------------
CHECK.FOR.SUSPENSE:
*------------------

*---This will insert NNNNNSP if interest suspended.
    IF ACCOUNT.REC<ACC.SUSP.FLD,Y.AC> THEN
        ACCR.CATEGORY := INT.SUFFIX
        R.RE.CONTRACT.BALANCES<RCB.VALUE.DATE,-1> = BALANCE.DATE
        R.RE.CONTRACT.BALANCES<RCB.TYPE,-1> = ACCR.CATEGORY
        R.RE.CONTRACT.BALANCES<RCB.BALANCE,-1> = ACCOUNT.REC<ACC.SUSP.FLD,Y.AC>

    END
    RETURN

*----------------------------------------------------------------------
END
