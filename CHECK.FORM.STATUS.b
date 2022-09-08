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
* <Rating>-61</Rating>
*-----------------------------------------------------------------------------
*Subroutine to check customer status of previous Loan application
*this routine will call in the process of MORTGAGE.FORM application

    $PACKAGE OP.ModelBank
    SUBROUTINE CHECK.FORM.STATUS

* 04-03-16 - 1653120
*            Incorporation of components

    $USING ST.Customer
    $USING OP.ModelBank
    $USING EB.OverrideProcessing
    $USING EB.DataAccess
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------------------
INITIALISE:
    CURR.NO = 0
    EB.OverrideProcessing.StoreOverride(CURR.NO)
    FN.MORTGAGE.FORM = 'F.EB.MORTGAGE.FORM1'
    F.MORTGAGE.FORM = ''
    EB.DataAccess.Opf(FN.MORTGAGE.FORM,F.MORTGAGE.FORM)
    RETURN
*-----------------------------------------------------------------------------------------
PROCESS:
    CUST.ID =  EB.SystemTables.getIdNew()
    GOSUB GET.CUST.DETAILS.FROM.R.NEW
    SEL.CMD = "SELECT ":FN.MORTGAGE.FORM
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.RECS,RET.CODE)
    LOOP
        REMOVE  FORM.ID FROM SEL.LIST SETTING ID.POS
    WHILE FORM.ID:ID.POS DO
        FORM.ERR = ''
        R.FORM = OP.ModelBank.EbMortgageFormOne.Read(FORM.ID,FORM.ERR)
        GOSUB GET.FORM.DETAILS
        GOSUB TEST.AGAINST.CUST.DETAILS
    REPEAT
    RETURN
*-----------------------------------------------------------------------------------------
GET.FORM.DETAILS:
    CUS.CODE = R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId>
    FORM.STATUS = R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrFormStatus>
    FORM.FIRST.NAME = R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrFirstName>
    FORM.MIDDLE.NAME = R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrMiddleName>
    FORM.FAM.NAME = R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrFamilyName>
    FORM.DOB.OF.CUS = R.FORM<OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth>
    RETURN
*-----------------------------------------------------------------------------------------
GET.CUST.DETAILS.FROM.R.NEW:
    SHORT.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)
    NAME.1 = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNameOne)
    NAME.2 = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNameTwo)
    GIV.NAME=EB.SystemTables.getRNew(ST.Customer.Customer.EbCusGivenNames)
    FAM.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusFamilyName)
    DOB.OF.CUS = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusDateOfBirth)
    RETURN
*-----------------------------------------------------------------------------------------
TEST.AGAINST.CUST.DETAILS:
    IF (SHORT.NAME EQ FORM.FIRST.NAME) OR (NAME.1 EQ FORM.FIRST.NAME) THEN
        GOSUB FORM.STATUS.CHECK
    END
    IF (NAME.1 EQ FORM.MIDDLE.NAME) OR (NAME.2 EQ FORM.MIDDLE.NAME) AND FORM.MIDDLE.NAME THEN
        GOSUB FORM.STATUS.CHECK
    END
    IF (FAM.NAME EQ FORM.FAM.NAME) AND FORM.FAM.NAME THEN
        GOSUB FORM.STATUS.CHECK
    END
    RETURN
*-----------------------------------------------------------------------------------------
FORM.STATUS.CHECK:

    IF FORM.STATUS EQ 'REJECTED' THEN
        EB.SystemTables.setText('PREVIOUS LOAN APPLICATION WAS REJECTED FOR GIVEN DETAILS OF THE CUSTOMER')
        EB.OverrideProcessing.StoreOverride(CURR.NO)
    END
    RETURN
    END
