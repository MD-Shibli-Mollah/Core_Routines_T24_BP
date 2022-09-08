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

* Version 5 25/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-44</Rating>

    $PACKAGE FT.Clearing
    SUBROUTINE FT.SCC.STO.CROSSVAL(LOCAL.CLEARING.REC, BC.PARAM.REC)
*
************************************************************************
* Description:                                                         *
* ============                                                         *
*                                                                      *
* This routine will cross-validate fields used in the BC transactions  *
* for standing orders in the SCC (Slovak Clearing Centre) system.      *
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
* 22/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE 
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*                                                                 *
************************************************************************
*$USING ST.CompanyCreation

    $USING AC.StandingOrders
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING FT.Clearing


*
* SCC.TXN.CODE is taken from LOCAL.REFERENCE. It is a mandatory field and therefore must
* be present. It's position is held in REQ.LOCREF.POS on FT.LOCAL.CLEARING for the
* corresponding REQ.LOCREF.NAME field. This position number must be present in field
* FT.LOC.REF.NO on the standing order record.
*
    SCC.TXN.CODE.POS = ''
    LOCATE 'SCC.TXN.CODE' IN LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefName,1> SETTING NAME.POS ELSE
    NAME.POS = ''         ;* BG_100013036 - S
    END   ;*  BG_100013036 - E
    IF NAME.POS THEN
        SCC.TXN.CODE.POS = LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefPos,NAME.POS>
    END

    LOCATE SCC.TXN.CODE.POS IN EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoFtLocRefNo)<1,1> SETTING TXN.POS ELSE
    TXN.POS = ''          ;* BG_100013036 - S
    END   ;*BG_100013036 - E
    IF TXN.POS = '' THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoFtLocRefNo)
        EB.SystemTables.setEtext('FT.FSSC.INCOMPLETE.LOCAL.REF.DETAILS')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
*
* SCC.CONSTANT is taken from LOCAL.REFERENCE. It is a mandatory field and therefore must
* be present. It's position is held in REQ.LOCREF.POS on FT.LOCAL.CLEARING for the
* corresponding REQ.LOCREF.NAME field. This position number must be present in field
* FT.LOC.REF.NO on the standing order record.
*
    SCC.CONSTANT.POS = ''
    LOCATE 'SCC.CONSTANT' IN LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefName,1> SETTING CONS.POS ELSE
    CONS.POS = ''         ;* BG_100013036 - S
    END   ;* BG_100013036 - E
    IF CONS.POS THEN
        SCC.CONSTANT.POS = LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcReqLocrefPos,CONS.POS>
    END

    LOCATE SCC.CONSTANT.POS IN EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoFtLocRefNo)<1,1> SETTING CON.POS ELSE
    CON.POS = ''          ;* BG_100013036 - S
    END   ;* BG_100013036 - E
    IF CON.POS = '' THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoFtLocRefNo)
        EB.SystemTables.setEtext('FT.FSSC.INCOMPLETE.LOCAL.REF.DETAILS')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
*
* Make sure BENEFICIARY.ACCTNO satisfies MOD 11 validation
*
    IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo) MATCHES '1N0N' THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
        SAVE.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf()))
        GOSUB CHECK.ACCT.NO.VALIDATION
        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END
    EB.SystemTables.setComi(SAVE.COMI)
*
* If no input is made to the beneficiary field then force input
* if the payment is to the Czech Republic (defined in field PTT.SORT.CODE
* on the FT.LOCAL.CLEARING file).
*
    IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBankSortCode) MATCHES LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcPttSortCode> THEN
        IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBeneficiary) = '' THEN
            EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBeneficiary); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext('FT.FSSC.BENEFICIARY.PRESENT')
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END

    RETURN

***************************************************************************

CHECK.ACCT.NO.VALIDATION:

*
* GB9800251s
    RETURN.ERROR = 1
* GB9800251e
*

    RETURN

***
    END
