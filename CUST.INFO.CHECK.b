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
* <Rating>69</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE TO VALIDATE ADDRESS DETAILS OF VERSION EB.MORTGAGE.FORM1,CUS.DETAILS
    $PACKAGE OP.ModelBank
    SUBROUTINE CUST.INFO.CHECK
*---------------------------------------------------------------
* 04-03-16 - 1653120
*            Incorporation of components

    $USING OP.ModelBank
    $USING EB.ErrorProcessing
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*---------------------------------------------------------------
INITIALISE:

    NO.OF.YEARS = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes)

    RETURN
*-----------------------------------------------------------------
PROCESS:
    IF NO.OF.YEARS LT '2' THEN
        Y.YEAR.COUNT1 = DCOUNT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName,@VM)
        FOR YEAR.COUNT1 = 1 TO Y.YEAR.COUNT1
            IF NO.OF.YEARS LT '2' THEN
                IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears)<1,YEAR.COUNT1> EQ '' THEN
                    EB.SystemTables.setAf(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName)
                    EB.SystemTables.setEtext('ENTER PREVIOUS ADDRESS AND YEARS STAYED')
                    EB.ErrorProcessing.StoreEndError()
                END ELSE
                    NO.OF.YEARS = NO.OF.YEARS+EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears)<1,YEAR.COUNT1>
                    GOSUB PROCESS.YEARS
                END
            END
        NEXT YEAR.COUNT1
    END ELSE
        IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName) NE '' THEN
            EB.SystemTables.setAf(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName)
            EB.SystemTables.setEtext('NO NEED OF PREV ADDRESS')
            EB.ErrorProcessing.StoreEndError()
        END
    END
    RETURN
*----------------------------------------------------------------
PROCESS.YEARS:

****IF STILL NO.YEARS AT RESIDENCE LESS THAN 2
    Y.YEAR.COUNT = DCOUNT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName,@VM)
    FOR YEAR.COUNT = 1 TO Y.YEAR.COUNT
        IF NO.OF.YEARS LT '2' THEN
            IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears)<1,YEAR.COUNT+1> EQ '' THEN
                EB.SystemTables.setAf(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName)
                EB.SystemTables.setEtext('ENTER ONE MORE PREVIOUS ADDRESS AND YEARS STAYED')
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                NO.OF.YEARS = NO.OF.YEARS+EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears)<1,YEAR.COUNT+1>
            END
        END ELSE
            IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName)<1,YEAR.COUNT+1> NE '' THEN
                EB.SystemTables.setAf(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName)
                EB.SystemTables.setEtext('ONLY ONE PREVIOUS ADDRESS ALLOWED')
                EB.ErrorProcessing.StoreEndError()
            END
        END
    NEXT YEAR.COUNT
    RETURN

    END
