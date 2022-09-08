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
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
* Version 3 25/05/01  GLOBUS Release No. G12.0.00 29/06/01

    $PACKAGE FT.Clearing
    SUBROUTINE FT.SIC.STO.CROSSVAL(LOCAL.CLEARING.REC, BC.PARAM.REC)

***************************************************************************
*
* This routine will cross-validate fields used in the BC transactions for
* standing orders in the SIC (Swiss Interbank Clearing) system.
*
***************************************************************************
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*
* 17/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*************************************************************************
    $USING AC.StandingOrders
    $USING EB.ErrorProcessing
    $USING FT.Contract
    $USING EB.SystemTables
    $USING FT.Clearing


*
* Add validation for PTT account numbers and reference in SIC environment
*
    IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBankSortCode) MATCHES LOCAL.CLEARING.REC<FT.Clearing.LocalClearing.LcPttSortCode> THEN     ;* Ptt payment
        BEGIN CASE
            CASE EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenReference) = ""        ;* C10 length 9
                EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
                IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo) MATCHES "":@VM:"9N") THEN
                    EB.SystemTables.setEtext("FT.FTSSC.9.DIGITS.PTT.PAYMENT")
                    EB.ErrorProcessing.StoreEndError()
                END ELSE
                    GOSUB MOD10.CHECK
                END
            CASE EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenReference) MATCHES "15N"         ;* C15 OLD
                EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
                IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo) MATCHES "5N" THEN
                    GOSUB MOD10.CHECK
                END ELSE
                    EB.SystemTables.setEtext("FT.FTSSC.5.NUMERIC.WITH.15.DIGIT.REF")
                    EB.ErrorProcessing.StoreEndError()
                END
            CASE EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenReference) MATCHES "16N":@VM:"27N"          ;* C15 NEW
                EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
                IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo) MATCHES "9N" THEN
                    GOSUB MOD10.CHECK
                    EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenReference)
                    GOSUB MOD10.CHECK
                END ELSE
                    EB.SystemTables.setEtext("FT.FTSSC.9.NUMERIC.VESR.PAYMENT")
                    EB.ErrorProcessing.StoreEndError()
                END
            CASE 1
                EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenReference)
                EB.SystemTables.setEtext("FT.FTSSC.15,16.OR.27.NUMERIC.VESR.PAYMENT")
                EB.ErrorProcessing.StoreEndError()
        END CASE
    END

    RETURN

***************************************************************************

MOD10.CHECK:

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) THEN
        YCHK = EB.SystemTables.getRNew(EB.SystemTables.getAf())
        FT.Contract.Mod10Check(YCHK,"VAL","",EB.SystemTables.getEtext())
        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()        ;* BG_100013036 - S
        END         ;* BG_100013036 - E
    END

    RETURN

***
    END
