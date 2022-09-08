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

*Sub routine to check the document type for given loan type
*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE CHECK.LOAN.DOCUMENT.TYPE

* 04-03-16 - 1653120
*            Incorporation of components


    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
INITIALISE:
    Y.APP.ID = ''
    R.FORM.REC =''
    RETURN
PROCESS:
    Y.APP.ID = EB.SystemTables.getIdNew()
    FORM.ERR = ''
    R.FORM.REC = OP.ModelBank.EbMortgageFormOne.Read(Y.APP.ID,FORM.ERR)
    LOAN.TYPE = R.FORM.REC<OP.ModelBank.EbMortgageFormOne.EbMorFivThrLoanType>
    IF LOAN.TYPE EQ 'MORTGAGE'  THEN
        EB.SystemTables.setRNew(OP.ModelBank.EbLoanAgreement.EbOpLoaFouThrDocumentType, 'MLNAGREE')
    END
    IF LOAN.TYPE EQ 'PERSONAL.LOAN' THEN
        EB.SystemTables.setRNew(OP.ModelBank.EbLoanAgreement.EbOpLoaFouThrDocumentType, 'PLNAGREE')
    END
    IF LOAN.TYPE EQ 'VEHICLE.LOAN' THEN
        EB.SystemTables.setRNew(OP.ModelBank.EbLoanAgreement.EbOpLoaFouThrDocumentType, 'ALNAGREE')
    END
    RETURN
    END
