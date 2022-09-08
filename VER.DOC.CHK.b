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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE FOR EB.MORTGAGE.FORM1,DOCUMENTS

    $PACKAGE OP.ModelBank
    SUBROUTINE VER.DOC.CHK

    $USING OP.ModelBank
    $USING DM.Foundation
    $USING EB.DataAccess
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

PROCESS:
    IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId) NE '' AND EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocumentType) NE '' THEN
        Y.CUS.ID = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCustomerId)
        Y.SYMBOL = '*'
        Y.DOC = CATS(Y.CUS.ID,Y.SYMBOL)
        Y.DOC.TYPE = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocumentType)
        R.DTYPE = DM.Foundation.DocumentType.Read(Y.DOC.TYPE, '')
        Y.DOC.CLASS = R.DTYPE<DM.Foundation.DocumentType.DocTypClass>
        SEL.CMD = "SELECT ":FN.DTYPE
        EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.RECS,RET.CODE)
        LOOP
            REMOVE Y.DOC.ID FROM SEL.LIST SETTING POS
        WHILE Y.DOC.ID EQ Y.DOC.TYPE
            Y.ID  = CATS(Y.DOC,Y.DOC.ID)
            R.CUS.DOC = DM.Foundation.CustDocument.Read(Y.ID, ERR)
            EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocIntId, Y.ID)
        REPEAT
    END
    RETURN
INITIALISE:

    FN.DTYPE= 'F.DOCUMENT.TYPE'
    F.DTYPE = ''
    EB.DataAccess.Opf(FN.DTYPE,F.DTYPE)

    Y.DOC.ID = ''
    R.CUS.DOC = ''
    RETURN
    END
