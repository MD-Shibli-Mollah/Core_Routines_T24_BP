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
    $PACKAGE OP.ModelBank
    SUBROUTINE DOC.ID.UPD
* 04-03-16 - 1653120
*            Incorporation of components

    $USING DM.Foundation
    $USING OP.ModelBank
    $USING EB.Display
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN


INITIALISE:


    RETURN
PROCESS:

    Y.DOC.ID = EB.SystemTables.getComi()
    tmp.AV = EB.SystemTables.getAv()
    tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocumentType); tmp<1,tmp.AV>=FIELD(Y.DOC.ID,'*',2); EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocumentType, tmp)

    R.CUST.DOCUMENT = ''; CUST.DOC.ERR = ''

    R.CUST.DOCUMENT = DM.Foundation.CustDocument.Read(Y.DOC.ID, CUST.DOC.ERR)
* Before incorporation : CALL F.READ(FN.CUST.DOCUMENT,Y.DOC.ID,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOC.ERR)
    IF CUST.DOC.ERR EQ '' THEN
        tmp.AV = EB.SystemTables.getAv()
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocReference); tmp<1,tmp.AV>=R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocReferenceNo>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocReference, tmp)
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocStatus); tmp<1,tmp.AV>=R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocStatus>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocStatus, tmp)
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocIssueDate); tmp<1,tmp.AV>=R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocBeginDate>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocIssueDate, tmp)
        tmp=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocEndDate); tmp<1,tmp.AV>=R.CUST.DOCUMENT<DM.Foundation.CustDocument.CusDocEndDate>; EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocEndDate, tmp)

        REFRESH.FIELDS = OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocumentType:@FM:OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocReference:@FM:OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocStatus:@FM:OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocIssueDate:@FM:OP.ModelBank.EbMortgageFormOne.EbMorFivThrDocEndDate
        EB.Display.RefreshField(REFRESH.FIELDS,'')
    END
    RETURN
