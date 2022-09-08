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
*SUBROUTINE TO CHECK THE SCORE CARD PRODUCT IN SA.SCORE.TXN
    $PACKAGE OP.ModelBank
    SUBROUTINE CHECK.SCORE.CARD1

* 04-03-16 - 1653120
*            Incorporation of components

    $USING ST.Customer
    $USING OP.ModelBank
    $USING SA.Foundation
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:

    R.SA.TXN = ''
    R.CUST = ''
    RETURN

PROCESS:
    Y.APP.ID = EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StLocalRef)

    IF EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StLocalRef) THEN
        FORM.ERR = ''
        R.CUST = OP.ModelBank.EbMortgageFormOne.Read(Y.APP.ID,FORM.ERR)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,1>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrDateOfBirth>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,2>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrResidentialStatus>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,3>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrYearsAtRes>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,4>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrMaritalStatus>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,5>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrDependents>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,6>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpType>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,7>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurEmpYears>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
        tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,8>=R.CUST<OP.ModelBank.EbMortgageFormOne.EbMorFivThrCurJobTitle>; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
    END
    RETURN

    END
