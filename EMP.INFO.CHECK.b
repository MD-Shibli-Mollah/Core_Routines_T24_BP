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
*SUBROUTINE TO VALIDATE EMPLOYEE ADDRESS DETAILS OF VERSION EB.MORTGAGE.FORM1,CUS.DETAILS

    $PACKAGE OP.ModelBank
    SUBROUTINE EMP.INFO.CHECK
*---------------------------------------------------------------

    $USING OP.ModelBank
    $USING EB.SystemTables
     
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*---------------------------------------------------------------
INITIALISE:

    NO.OF.YEARS = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears)   ;*CALCULATING NO.OF.YEARS WORKING IN THE CURRENT JOB

    RETURN
*-----------------------------------------------------------------
PROCESS:
*******IF NO.OF.YEARS OF WORKED IN A CURRENT JOB IS LESS THAN 2 YEARS

    Y.YEAR.COUNT1 = DCOUNT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpType,@VM)
    FOR YEAR.COUNT1 = 1 TO Y.YEAR.COUNT1
        IF NO.OF.YEARS LT '2' THEN
            IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears)<1,YEAR.COUNT1> EQ '' THEN
                EB.SystemTables.setEtext('ENTER PREVIOUS JOB DETAILS')
            END ELSE
                NO.OF.YEARS = NO.OF.YEARS+EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears)<1,YEAR.COUNT1>
                GOSUB PROCESS.YEARS
            END
        END ELSE
            IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears) NE '' THEN
                EB.SystemTables.setEtext('NO NEED OF PREV JOB DETAILS')
            END
        END
    NEXT YEAR.COUNT1
    RETURN
*----------------------------------------------------------------
PROCESS.YEARS:
*******IF STILL NO.YEARS WORKED IN A JOB LESS THAN 2 AFTER INCLUDING ONE PREVIOUS JOB DETAILS

    Y.YEAR.COUNT = DCOUNT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpType,@VM)
    FOR YEAR.COUNT = 1 TO Y.YEAR.COUNT
        IF NO.OF.YEARS LT '2' THEN
            IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears)<1,YEAR.COUNT+1> EQ '' THEN
                EB.SystemTables.setEtext('ENTER ONE MORE JOB DETAILS')
            END ELSE
                NO.OF.YEARS = NO.OF.YEARS+EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears)<1,YEAR.COUNT+1>
            END
        END ELSE
            IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears)<1,YEAR.COUNT+1> NE '' THEN
                EB.SystemTables.setEtext('ONLY ONE PREVIOUS ADDRESS ALLOWED')
            END
        END
    NEXT YEAR.COUNT
    RETURN

END
