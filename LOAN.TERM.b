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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
*Subroutine to validate loan period in EB.MORTGAGE.FORM1,PR.ELIGIBILITY

    $PACKAGE OP.ModelBank
    SUBROUTINE LOAN.TERM

    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN 


INITIALISE:
    PRODUCT.TERM = ''
    MIN.PROD.TERM = ''
    MAX.PROD.TERM = ''
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrProductTerm, EB.SystemTables.getComi())
    RETURN
PROCESS:
    IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrProductTerm) THEN
        MIN.PROD.TERM = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMinProdTerm)
        MAX.PROD.TERM = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaxProdTerm)
        PRODUCT.TERM = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrProductTerm)
        IF MIN.PROD.TERM[INDEX(MIN.PROD.TERM,'Y',1),1] EQ 'Y' THEN    ;*Converting the years into days
            MIN.TERM  = TRIM(MIN.PROD.TERM,'Y','T')
            MIN.PROD.TERM.IN.DAYS = MIN.TERM * 365
        END
        IF MAX.PROD.TERM[INDEX(MAX.PROD.TERM,'Y',1),1] EQ 'Y' THEN
            MAX.TERM = TRIM(MAX.PROD.TERM,'Y','T')
            MAX.PROD.TERM.IN.DAYS = MAX.TERM * 365
        END
        IF PRODUCT.TERM[INDEX(PRODUCT.TERM,'Y',1),1] EQ 'Y' THEN
            PROD.TERM = TRIM(PRODUCT.TERM,'Y','T')
            PRODUCT.TERM.IN.DAYS = PROD.TERM * 365
            GOSUB TERM.YEARS  ;*To check the term
        END ELSE
            EB.SystemTables.setEtext('TERM SHOULD BE ENTERED IN YEARS')
        END
    END
    RETURN
TERM.YEARS:

    IF PRODUCT.TERM.IN.DAYS LT MIN.PROD.TERM.IN.DAYS OR PRODUCT.TERM.IN.DAYS GT MAX.PROD.TERM.IN.DAYS THEN    ;*check for the loan term that it is in between the range specified
        EB.SystemTables.setEtext('PRODUCT TERM NOT WITHIN THE PRODUCTS PERMISSIBLE RANGE')
    END
    RETURN
    END
