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
* <Rating>838</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE CUST.INFO

* Input subroutine

* 04-03-16 - 1653120
*            Incorporation of components

    $USING ST.Customer
    $USING AC.AccountOpening
    $USING OP.ModelBank
    $USING EB.Display
    $USING EB.SystemTables
    $USING EB.ErrorProcessing

*
*** check if the customer is in the file and then load the details
*

    INPUT.MODE = ""
    R.CUSTOMER = ""
*
    CUST.CODE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId)
    RTN.ERROR = ""
    R.CUSTOMER = ST.Customer.Customer.Read(CUST.CODE, RTN.ERROR)
* Before incorporation : CALL F.READ(FN.CUSTOMER,CUST.CODE,R.CUSTOMER,F.CUSTOMER,RTN.ERROR)
    IF R.CUSTOMER <> "" THEN
        INPUT.MODE = "NOINPUT"
    END
*
    IF NOT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId) = "" ) THEN
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTitle, R.CUSTOMER<ST.Customer.Customer.EbCusTitle>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTitle); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTitle, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFirstName, R.CUSTOMER<ST.Customer.Customer.EbCusNameOne>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFirstName); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFirstName, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMiddleName, R.CUSTOMER<ST.Customer.Customer.EbCusGivenNames>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMiddleName); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMiddleName, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFamilyName, R.CUSTOMER<ST.Customer.Customer.EbCusFamilyName>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFamilyName); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFamilyName, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrStreetName, R.CUSTOMER<ST.Customer.Customer.EbCusStreet,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrStreetName); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrStreetName, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAddress, R.CUSTOMER<ST.Customer.Customer.EbCusAddress,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAddress); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAddress, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCity, R.CUSTOMER<ST.Customer.Customer.EbCusTownCountry,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCity); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCity, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPostalCode, R.CUSTOMER<ST.Customer.Customer.EbCusPostCode,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPostalCode); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPostalCode, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidence, R.CUSTOMER<ST.Customer.Customer.EbCusResidence>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidence); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidence, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNationality, R.CUSTOMER<ST.Customer.Customer.EbCusNationality>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNationality); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNationality, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidentialStatus, R.CUSTOMER<ST.Customer.Customer.EbCusResidenceStatus,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidentialStatus); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidentialStatus, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth, R.CUSTOMER<ST.Customer.Customer.EbCusDateOfBirth>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth, tmp)
        RES.COUNT = DCOUNT(R.CUSTOMER<ST.Customer.Customer.EbCusResidenceSince>,@VM)
        *--------------------------------------------------------------------------------------------------------------
        * Calculate the no of years stayed at the current residence from customer record
        IF R.CUSTOMER<ST.Customer.Customer.EbCusResidenceSince,1> EQ "" THEN
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes, ""); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes, tmp)
        END ELSE
            tmp.TODAY = EB.SystemTables.getToday()
            OP.ModelBank.ApplCalcAge(YEARS.AT.RES,tmp.TODAY,R.CUSTOMER<ST.Customer.Customer.EbCusResidenceSince,1>)
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes, YEARS.AT.RES); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes, tmp)
            NO.OF.YEARS = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes)
        END
        *--------------------------------------------------------------------------------------------------------------
        *--------------------------------------------------------------------------------------------------------------
        *Calculate the no of years stayed at the previous residence from the customer record and reading customer record
        IF RES.COUNT GE '2' THEN
            FOR PREV.RES.COUNT = 2 TO RES.COUNT
                IF NO.OF.YEARS LT '2' THEN
                    IF R.CUSTOMER<ST.Customer.Customer.EbCusResidenceSince,PREV.RES.COUNT> = "" THEN
                        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears); tmp<1,PREV.RES.COUNT-1>=""; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears, tmp)
                    END ELSE
                        OP.ModelBank.ApplCalcAge(PREV.NO.YEARS,R.CUSTOMER<ST.Customer.Customer.EbCusResidenceSince,PREV.RES.COUNT-1>,R.CUSTOMER<ST.Customer.Customer.EbCusResidenceSince,PREV.RES.COUNT>)
                        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears); tmp<1,PREV.RES.COUNT-1>=PREV.NO.YEARS; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevNoYears, tmp);*T(EB.MOR53.PREV.NO.YEARS)<3> = INPUT.MODE
                    END
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName); tmp<1,PREV.RES.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusStreet,PREV.RES.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevStrName, tmp);*T(EB.MOR53.PREV.STR.NAME)<3> = INPUT.MODE
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevAddress); tmp<1,PREV.RES.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusAddress,PREV.RES.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevAddress, tmp);*T(EB.MOR53.PREV.ADDRESS)<3> = INPUT.MODE
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevCity); tmp<1,PREV.RES.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusTownCountry,PREV.RES.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevCity, tmp);*T(EB.MOR53.PREV.CITY)<3> = INPUT.MODE
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevPostCode); tmp<1,PREV.RES.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusPostCode,PREV.RES.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevPostCode, tmp);*T(EB.MOR53.PREV.POST.CODE)<3> = INPUT.MODE
                END
                NO.OF.YEARS = NO.OF.YEARS + PREV.NO.YEARS
            NEXT PREV.RES.COUNT
        END
        *--------------------------------------------------------------------------------------------------------------
***employee details
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType, R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStatus,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpName, R.CUSTOMER<ST.Customer.Customer.EbCusEmployersName,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpName); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpName, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurOccupation, R.CUSTOMER<ST.Customer.Customer.EbCusOccupation,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurOccupation); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurOccupation, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurJobTitle, R.CUSTOMER<ST.Customer.Customer.EbCusJobTitle,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurJobTitle); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurJobTitle, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpAddr, R.CUSTOMER<ST.Customer.Customer.EbCusEmployersAdd,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpAddr); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpAddr, tmp)
        EMP.COUNT = DCOUNT(R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStart>,@VM)
        *---------------------------------------------------------------------------------------------------------------
        *Calculate the no.of.years worked in the current job for an employee
        IF R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStart,1> EQ "" THEN
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears, ""); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears, tmp)
        END ELSE
            tmp.TODAY = EB.SystemTables.getToday()
            OP.ModelBank.ApplCalcAge(YEARS.AT.EMP,tmp.TODAY,R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStart,1>)
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears, YEARS.AT.EMP); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears, tmp)
            NO.OF.YEARS.EMP = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears)
        END
        *-------------------------------------------------------------------------------------------------------------
        *Calculate the no.of.years worked in the previous job for an employee from customer record
        IF EMP.COUNT GE '2' THEN
            FOR PREV.EMP.COUNT = 2 TO EMP.COUNT
                IF NO.OF.YEARS.EMP LT '2' THEN
                    IF R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStart,PREV.EMP.COUNT> = "" THEN
                        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears); tmp<1,PREV.EMP.COUNT-1>=""; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears, tmp)
                    END ELSE
                        OP.ModelBank.ApplCalcAge(PREV.EMP.YEARS,R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStart,PREV.EMP.COUNT-1>,R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStart,PREV.EMP.COUNT>)
                        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears); tmp<1,PREV.EMP.COUNT-1>=PREV.EMP.YEARS; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpYears, tmp);*T(EB.MOR53.PREV.EMP.YEARS)<3> = INPUT.MODE
                    END
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpType); tmp<1,PREV.EMP.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusEmploymentStatus,PREV.EMP.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpType, tmp);*T(EB.MOR53.PREV.EMP.TYPE)<3> = INPUT.MODE
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevOccupation); tmp<1,PREV.EMP.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusOccupation,PREV.EMP.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevOccupation, tmp);*T(EB.MOR53.PREV.OCCUPATION)<3> = INPUT.MODE
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevJobTitle); tmp<1,PREV.EMP.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusJobTitle,PREV.EMP.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevJobTitle, tmp);*T(EB.MOR53.PREV.JOB.TITLE)<3> = INPUT.MODE
                    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpAddr); tmp<1,PREV.EMP.COUNT-1>=R.CUSTOMER<ST.Customer.Customer.EbCusEmployersAdd,PREV.EMP.COUNT>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPrevEmpAddr, tmp);*T(EB.MOR53.PREV.EMP.ADDR)<3> = INPUT.MODE
                END
                NO.OF.YEARS.EMP = NO.OF.YEARS.EMP + PREV.EMP.YEARS
            NEXT PREV.EMP.COUNT
        END
        *--------------------------------------------------------------------------------------------------------------
        *--------------------------------------------------------------------------------------------------------------
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrGender, R.CUSTOMER<ST.Customer.Customer.EbCusGender>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrGender); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrGender, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaritalStatus, R.CUSTOMER<ST.Customer.Customer.EbCusMaritalStatus>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaritalStatus); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaritalStatus, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPhone, R.CUSTOMER<ST.Customer.Customer.EbCusPhoneOne,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPhone); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrPhone, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDependents, R.CUSTOMER<ST.Customer.Customer.EbCusNoOfDependents>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDependents); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDependents, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIdType, R.CUSTOMER<ST.Customer.Customer.EbCusLegalDocName>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIdType); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIdType, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIdDetails, R.CUSTOMER<ST.Customer.Customer.EbCusLegalId>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIdDetails); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIdDetails, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTaxId, R.CUSTOMER<ST.Customer.Customer.EbCusTaxId>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTaxId); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTaxId, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrEmail, R.CUSTOMER<ST.Customer.Customer.EbCusEmailOne,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrEmail); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrEmail, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFax, R.CUSTOMER<ST.Customer.Customer.EbCusFaxOne,1>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFax); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFax, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCoRelationship, R.CUSTOMER<ST.Customer.Customer.EbCusRelationCode>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCoRelationship); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCoRelationship, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCoRelId, R.CUSTOMER<ST.Customer.Customer.EbCusRelCustomer>); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCoRelId); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCoRelId, tmp)
    END
    EB.Display.RebuildScreen()
    RETURN
    END
