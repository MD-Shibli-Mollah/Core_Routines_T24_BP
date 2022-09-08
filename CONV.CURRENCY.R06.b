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

************************************
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.CurrencyConfig
    SUBROUTINE CONV.CURRENCY.R06
************************************
* Modification log:
* ----------------
*
* 16/02/2007 - GLOBUS_BG_100013014
*              Changes done to call JOURNAL.UPDATE
*
* 07/04/08 - CI_10054650
*            CCY.HISTORY is not updated for all companies after conversion.
*********************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CURRENCY
    $INSERT I_F.CCY.HISTORY
    $INSERT I_F.COMPANY.CHECK
**********************************************************************************************
* Conversion routine to update the CCY.HISTORY file for the currencies which undergone change,
* on the day of conversion, from the release lower than R06 to R06 or higher release.
* This is because from R06 CCY.HISTORY is update online.
**********************************************************************************************
*
    SAVE.ID.COMPANY = ID.COMPANY

    F.COMPANY.CHECK = ''
    CALL OPF("F.COMPANY.CHECK", F.COMPANY.CHECK)

    CALL F.READ("F.COMPANY.CHECK", "CURRENCY", COMP.CHECK.REC, F.COMPANY.CHECK, "")
    COMP.LIST = DCOUNT(COMP.CHECK.REC<EB.COC.COMPANY.CODE>,VM)

    FOR I = 1 TO COMP.LIST

        IF COMP.CHECK.REC<EB.COC.COMPANY.CODE,I> <> ID.COMPANY THEN
            CALL LOAD.COMPANY(COMP.CHECK.REC<EB.COC.COMPANY.CODE,I>)
        END
        GOSUB INITIALISE
        GOSUB PROCESS.RECORDS

    NEXT I

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN
*
*-------------------------------------------------------------------------------------
INITIALISE:
*---------
* Initialise variables

    SEL.POS = ''
    SEL.ERR = '' ; SEL.LIST = '' ; NO.REC.SEL = ''

    GOSUB INTER.INIT
    HIS.DATE = TODAY

    FN.CURRENCY = "F.CURRENCY"
    F.CURRENCY = ''
    CALL OPF(FN.CURRENCY,F.CURRENCY)

    RETURN
*---------------------------------------------------------------------------------------
INTER.INIT:
*----------
    READ.ERR = ''
    RETURN.CODE = ''
    R.CURRENCY = ''
    CCY.DATE.REC = ''
    RETURN
*----------------------------------------------------------------------------------------
PROCESS.RECORDS:
*-----------------
    SEL.CMD = "SELECT ":FN.CURRENCY
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC.SEL, SEL.ERR)

    IF NOT(NO.REC.SEL) THEN
        RETURN
    END

    MATBUILD R.NEW.SAVE FROM R.NEW
    ID.NEW.SAVE = ID.NEW
    APPLICATION.SAVE = APPLICATION

    LOOP REMOVE CCY.ID FROM SEL.LIST SETTING SEL.POS
    WHILE CCY.ID:SEL.POS

        GOSUB INTER.INIT

        READ R.CURRENCY FROM F.CURRENCY,CCY.ID ELSE
            READ.ERR = "RECORD NOT FOUND"
        END

        IF NOT(READ.ERR) THEN
            CALL GET.CCY.HISTORY(HIS.DATE,CCY.ID,CCY.DATE.REC,RETURN.CODE)
            IF (CCY.DATE.REC<EB.CUR.CURR.NO> <> R.CURRENCY<EB.CUR.CURR.NO>) OR (CCY.DATE.REC<EB.CUR.CURR.NO> = R.CURRENCY<EB.CUR.CURR.NO> AND RETURN.CODE = '2') THEN
                MATPARSE R.NEW FROM R.CURRENCY
                ID.NEW = CCY.ID
                APPLICATION = "CURRENCY"
                CALL CCY.HISTORY.UPDATE
            END
            CALL JOURNAL.UPDATE(ID.NEW)
        END

    REPEAT


    MATPARSE R.NEW FROM R.NEW.SAVE
    ID.NEW = ID.NEW.SAVE
    APPLICATION = APPLICATION.SAVE

    RETURN
*-----------------------------------------------------------------------------------------
END
