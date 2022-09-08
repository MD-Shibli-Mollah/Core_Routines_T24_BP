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

* Version 3 21/07/00  GLOBUS Release No. G11.0.01 27/07/00
*-----------------------------------------------------------------------------
* <Rating>-66</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.RateParameters
    SUBROUTINE SETTLEMENT.RATES.CHECK.FIELDS
************************************************************************
* GB0001758
* Statement CALL REFRESH.FIELD(AF) changed to CALL REFRESH.FIELD(AF,"")
* Also in internal subroutine CHECK.FIELDS statement CASE AF = YY
* changed to REM > CASE AF = NAME.OF.THE.REQUIRED.FIELD, this routine
* will now compile and has a more meaningful name than YY.
*
* 09/09/02 - EN_10001077
*            Conversion of error messages to error codes.
************************************************************************

    $USING ST.RateParameters
    $USING EB.Display
    $USING EB.SystemTables
*
************************************************************************
*
*
************************************************************************
*
    GOSUB INITIALISE
*
************************************************************************
*
* Default the current field if input is null and the field is null.
*
    AF.POS = EB.SystemTables.getAf()
    AV.POS = EB.SystemTables.getAv()
    AS.POS = EB.SystemTables.getAs()
    BEGIN CASE
        CASE AS.POS
            INTO.FIELD = EB.SystemTables.getRNew(AF.POS)<1,AV.POS,AS.POS>
        CASE AV.POS
            INTO.FIELD = EB.SystemTables.getRNew(AF.POS)<1,AV.POS>
        CASE 1
            INTO.FIELD = EB.SystemTables.getRNew(AF.POS)
    END CASE
*
    IF EB.SystemTables.getComi() = '' AND INTO.FIELD = '' THEN
        GOSUB DEFAULT.FIELDS
    END

*
* Real validation here.....
*
    GOSUB CHECK.FIELDS

*
* Now default other fields from this one if there is a value....
*
    IF EB.SystemTables.getComi() THEN
        COMI.ENRI.SAVE = EB.SystemTables.getComiEnri()
        EB.SystemTables.setComiEnri('')
        GOSUB DEFAULT.OTHER.FIELDS
        EB.SystemTables.setComiEnri(COMI.ENRI.SAVE)
    END

************************************************************************
*
* All done here.
*
    RETURN
*
************************************************************************
* Local subroutines....
************************************************************************
*
INITIALISE:
    EB.SystemTables.setE('')
    EB.SystemTables.setEtext('')
*
* Open files....
*
    RETURN
*
************************************************************************
*
DEFAULT.FIELDS:
*
*      BEGIN CASE
*         CASE AF = XX.FIELD.NUMBER
*            COMI = TODAY
*
*      END CASE
* GB0001758
    AF.POS = EB.SystemTables.getAf()
    EB.Display.RefreshField(AF.POS,"")

    RETURN
************************************************************************
DEFAULT.OTHER.FIELDS:

    DEFAULTED.FIELD = ''
    DEFAULTED.ENRI = ''
*      BEGIN CASE
*         CASE AF = XX.FIELD.NUMBER
*              DEFAULTED.FIELD = XX.FIELD.NUMBER
*              DEFAULTED.ENRI = ENRI
*      END CASE

    EB.Display.RefreshField(DEFAULTED.FIELD, DEFAULTED.ENRI)

    RETURN
*
************************************************************************
*
CHECK.FIELDS:
*
* Where an error occurs, set E
*
    BEGIN CASE
        CASE EB.SystemTables.getAf() = ST.RateParameters.SettlementRates.SrEvApplRate
            CHECK.EVENT.DATE = EB.SystemTables.getRNew(ST.RateParameters.SettlementRates.SrEventDate)<1,EB.SystemTables.getAv()>
            IF CHECK.EVENT.DATE AND CHECK.EVENT.DATE LT EB.SystemTables.getToday() THEN
                EB.SystemTables.setE('LD.RTN.CHANGE.NOT.ALLOWED.DATE.LT.THAN.TODAY')
            END
    END CASE
*
CHECK.FIELD.END:
*
    RETURN
*
************************************************************************
*
    END
