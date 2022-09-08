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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-50</Rating>

    $PACKAGE FT.Clearing
    SUBROUTINE FT.SIC.BULK.CROSSVAL(LOCAL.CLEARING.REC, BC.PARAM.REC)

***************************************************************************
*
* This routine will cross-validate fields used in the BC transactions for
* bulk standing orders in the SIC (Swiss Interbank Clearing) system.
*
***************************************************************************
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*
* 23/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
************************************************************************

    $USING AC.StandingOrders
    $USING EB.ErrorProcessing
    $USING FT.Contract
    $USING EB.SystemTables
    $USING FT.Clearing

    NO.OF.PAY.METHODS = DCOUNT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod), @VM)
    FOR I = 1 TO NO.OF.PAY.METHODS
    	EB.SystemTables.setAv(I)
        IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod)<1,EB.SystemTables.getAv()>[1,2] = 'BC' THEN
            *
            * Add validation for PTT account numbers and reference in SIC environment
            *
            IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBankSortCode)<1,EB.SystemTables.getAv()> MATCHES LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcPttSortCode> THEN ;* PTT payment
                GOSUB CHECK.ON.BEN.REFERENCE      ;* BG_100013036 - S / E
            END
        END
        IF EB.SystemTables.getEtext() THEN
            RETURN  ;* BG_100013036 - S
        END         ;* BG_100013036 - E
    NEXT I

    RETURN

***************************************************************************
* BG_100013036 - S
*======================
CHECK.ON.BEN.REFERENCE:
*=====================
    BEGIN CASE
        CASE EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBenReference)<1,EB.SystemTables.getAv()> = ''      ;* C10 length 9
            EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
            IF NOT (EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficAcctno)<1,EB.SystemTables.getAv()> MATCHES '':@VM:'9N') THEN
                EB.SystemTables.setEtext('FT.FTSBC.9.DIGITS.PTT.PAYMENT')
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                GOSUB MOD10.CHECK
            END
        CASE EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBenReference)<1,EB.SystemTables.getAv()> MATCHES '15N'       ;* C15 OLD
            EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
            IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficAcctno)<1,EB.SystemTables.getAv()> MATCHES '5N' THEN
                GOSUB MOD10.CHECK
            END ELSE
                EB.SystemTables.setEtext('FT.FTSBC.5.NUMERIC.WITH.15.DIGIT.REF')
                EB.ErrorProcessing.StoreEndError()
            END
        CASE EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBenReference)<1,EB.SystemTables.getAv()> MATCHES '16N':@VM:'27N'        ;* C15 NEW
            EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
            IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficAcctno)<1,EB.SystemTables.getAv()> MATCHES '9N' THEN
                GOSUB MOD10.CHECK
                EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBenReference)
                GOSUB MOD10.CHECK
            END ELSE
                EB.SystemTables.setEtext('FT.FTSBC.9.NUMERIC.VESR.PAYMENT')
                EB.ErrorProcessing.StoreEndError()
            END
        CASE 1
            EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBenReference)
            EB.SystemTables.setEtext('FT.FTSBC.15,16.OR.27.NUMERIC.VESR.PAYMENT')
            EB.ErrorProcessing.StoreEndError()
    END CASE
    RETURN          ;* BG_100013036 - E
***************************************************************************
MOD10.CHECK:

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()<1,EB.SystemTables.getAv()>) THEN
        YCHK = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>
        FT.Contract.Mod10Check(YCHK,"VAL","",EB.SystemTables.getEtext())
        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()        ;* BG_100013036 - S
        END         ;*BG_100013036 - E
    END

    RETURN
***************************************************************************
***
    END
