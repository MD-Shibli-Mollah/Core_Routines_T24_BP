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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE FOR VALIDATION OF DATE.OF.BIRTH IN EB.MORTGAGE.FORM1,CU.ELIGIBILITY
    $PACKAGE OP.ModelBank
    SUBROUTINE DATE.OF.BIRTH
* 04-03-16 - 1653120
*            Incorporation of components

    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN


INITIALISE:
    AGE = ''
    DOB = ''
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth, EB.SystemTables.getComi())
    RETURN
PROCESS:
    IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth) NE '' THEN
        DOB = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth)
        tmp.R.NEW.OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth)
        tmp.TODAY = EB.SystemTables.getToday()
        OP.ModelBank.ApplCalcAge(AGE,tmp.TODAY,tmp.R.NEW.OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth)   ;*calculating age based on date of birth
        IF AGE LT "18" THEN
            EB.SystemTables.setEtext('NOT ELIGIBLE AS AGE IS LESSER THAN 18')
        END
        IF DOB GT EB.SystemTables.getToday() THEN
            EB.SystemTables.setEtext('DATE OF BIRTH CANNOT BE A FUTURE DATE');*throwing error if date of birth is a future date
        END

    END
    RETURN
    END
