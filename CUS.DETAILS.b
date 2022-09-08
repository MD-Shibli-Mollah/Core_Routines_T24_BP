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
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE TO VALIDATE VERSION VER.CU.ELIGIBILITY
    $PACKAGE OP.ModelBank
    SUBROUTINE CUS.DETAILS

* 04-03-16 - 1653120
*            Incorporation of components

    $USING ST.Customer
    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

PROCESS:
    IF EB.SystemTables.getComi() NE '' THEN
        Y.CUS.ID = EB.SystemTables.getComi()
        R.CUS = ST.Customer.Customer.Read(Y.CUS.ID, '')         ;*Retriving customer information
        * Before incorporation : CALL F.READ('FBNK.CUSTOMER',Y.CUS.ID,R.CUS,'','')         ;*Retriving customer information
        Y.DOB = R.CUS<ST.Customer.Customer.EbCusDateOfBirth>
        Y.NATION = R.CUS<ST.Customer.Customer.EbCusNationality>
        Y.RESIDENCE = R.CUS<ST.Customer.Customer.EbCusResidence>
        IF R.CUS<ST.Customer.Customer.EbCusEmploymentStatus><1,1> NE '' THEN  ;*getting the customer employee status if any specified in the customer record
            Y.EMP.STATUS = R.CUS<ST.Customer.Customer.EbCusEmploymentStatus><1,1>
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType, Y.EMP.STATUS); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType, tmp)
        END
        *getting the date of birth details and if it is exist making it as noinput field
        IF Y.DOB NE '' THEN
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth, Y.DOB); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth, tmp)
        END
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNationality, Y.NATION); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNationality); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrNationality, tmp)
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidence, Y.RESIDENCE); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidence); tmp<3>=INPUT.MODE; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidence, tmp)
    END
    RETURN
INITIALISE:

    Y.CUS.ID = ''
    R.CUS = ''
    INPUT.MODE = "NOINPUT"
    RETURN

    END
