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

* Version 5 18/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-75</Rating>

    $PACKAGE FT.Clearing
    SUBROUTINE FT.SCC.BULK.CROSSVAL(LOCAL.CLEARING.REC, BC.PARAM.REC)

************************************************************************
* Description:                                                         *
* ============                                                         *
*                                                                      *
* This routine will cross-validate fields used in the BC transactions  *
* for bulk standing orders in the SCC (Slovak Clearing Centre) system. *
*                                                                      *
************************************************************************
* Modification Log:                                                    *
* =================                                                    *
*                                                                      *
* 31/03/98 - GB9800251                                                 *
*            Force check digit if valid account number.                *
*                                                                      *
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*                                                                      *
*
* 28/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE  
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*                                                                *
************************************************************************
*


    $USING AC.StandingOrders
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING FT.Clearing


    NO.OF.PAY.METHODS = DCOUNT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod), @VM)
    FOR I = 1 TO NO.OF.PAY.METHODS
    	EB.SystemTables.setAv(I)
        IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod)<1,EB.SystemTables.getAv()>[1,2] = 'BC' THEN
            *
            * SCC.TXN.CODE is taken from LOCAL.REFERENCE. It is a mandatory field and therefore must
            * be present. It's position is held in REQ.LOCREF.POS on FT.LOCAL.CLEARING for the
            * corresponding REQ.LOCREF.NAME field. This position number must be present in field
            * LOC.REF.NO on the bulk standing order record.
            *
            SCC.TXN.CODE.POS = ''
            LOCATE 'SCC.TXN.CODE' IN LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefName,1> SETTING NAME.POS ELSE
            NAME.POS = '' ;* BG_100013036 - S
        END     ;* BG_100013036 - E
        IF NAME.POS THEN
            SCC.TXN.CODE.POS = LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefPos,NAME.POS>
        END

        LOCATE SCC.TXN.CODE.POS IN EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstLocRefNo)<1,EB.SystemTables.getAv(),1> SETTING TXN.POS ELSE
        TXN.POS = ''  ;* BG_100013036 - S
    END     ;* BG_100013036 - E
    IF TXN.POS = '' THEN
        EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstLocRefNo)
        EB.SystemTables.setEtext('FT.FSBC.INCOMPLETE.LOCAL.REF.DETAILS')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
*
* SCC.CONSTANT is taken from LOCAL.REFERENCE. It is a mandatory field and therefore must
* be present. It's position is held in REQ.LOCREF.POS on FT.LOCAL.CLEARING for the
* corresponding REQ.LOCREF.NAME field. This position number must be present in field
* LOC.REF.NO on the bulk standing order record.
*
    GOSUB GET.SCC.CONSTANT
    IF EB.SystemTables.getEtext() THEN
        RETURN
    END

*
* Make sure BENEFIC.ACCTNO satisfies MOD 11 validation
*
    GOSUB VALIDATION.FOR.BENIFIC.ACCTNO   ;* BG_100013036 - S
    IF EB.SystemTables.getEtext() THEN
        RETURN
    END     ;* BG_100013036 - E
*
* If no input is made to the beneficiary field then force input
* if the payment is to the Czech Republic (defined in field PTT.SORT.CODE
* on the FT.LOCAL.CLEARING file).
*
    GOSUB VALIDATION.FOR.BST.BANK.SORT.CODE         ;* BG_100013036 - S
    IF EB.SystemTables.getEtext() THEN
        RETURN
    END     ;* BG_100013036 - E
*
    END
    NEXT I

    RETURN

************************************************************************

CHECK.ACCT.NO.VALIDATION:
*
* GB9800251s
    RETURN.ERROR = 1
* GB9800251e
*

    RETURN
************************************************************************

***
* BG_100013036 - S
*=============================
VALIDATION.FOR.BENIFIC.ACCTNO:
*=============================
    IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficAcctno)<1,EB.SystemTables.getAv()> MATCHES '1N0N' THEN
        EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
        SAVE.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>)
        GOSUB CHECK.ACCT.NO.VALIDATION
        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
        EB.SystemTables.setComi(SAVE.COMI)
    END
    RETURN
************************************************************************
*=================
GET.SCC.CONSTANT:
*================
    SCC.CONSTANT.POS = ''
    LOCATE 'SCC.CONSTANT' IN LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefName,1> SETTING CONS.POS ELSE
    CONS.POS = ''
    END
    IF CONS.POS THEN
        SCC.CONSTANT.POS = LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefPos,CONS.POS>
    END

    LOCATE SCC.CONSTANT.POS IN EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstLocRefNo)<1,EB.SystemTables.getAv(),1> SETTING CON.POS ELSE
    CON.POS = ''
    END
    IF CON.POS = '' THEN
        EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstLocRefNo)
        EB.SystemTables.setEtext('FT.FSBC.INCOMPLETE.LOCAL.REF.DETAILS')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    RETURN
************************************************************************
*=================================
VALIDATION.FOR.BST.BANK.SORT.CODE:
*=================================
    IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBankSortCode)<1,EB.SystemTables.getAv()> MATCHES LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcPttSortCode> THEN
        IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficiary)<1,EB.SystemTables.getAv()> = '' THEN
            EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficiary); EB.SystemTables.setAs(1)
            EB.SystemTables.setEtext('FT.FSBC.BENEFICIARY.PRESENT')
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END
    RETURN
************************************************************************
    END
