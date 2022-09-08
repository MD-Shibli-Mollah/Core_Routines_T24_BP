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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------

*SUBROUTINE FOR THE VALIDATION OF EMPLOYEE STATUS IN EB.MORTGAGE.FORM1,CU.ELIGIBILITY
    $PACKAGE OP.ModelBank
    SUBROUTINE EMPLOYEE.STATUS
 
    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN


INITIALISE:
    EMP.STATUS = ''
    RETURN
PROCESS:
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType, EB.SystemTables.getComi())
    IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType) NE '' THEN
        EMP.STATUS = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType)
        IF (EMP.STATUS EQ "RETIRED" OR EMP.STATUS EQ "UNEMPLOYED") THEN
            EB.SystemTables.setEtext('NOT ELIGIBLE FOR THE MENTIONED EMPLOYED STATUS')
        END
    END
    RETURN
    END
