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

*------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>-81</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.PERIODIC.INT.CONDS(RET.ARR)
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION :
* ------------
* This routine is attached to the NOFILE enquiry PERIODIC.INTEREST.CONDS.
* The enquiry displays all the conditions set in the application PERIODIC.INTEREST based in the KEY
* or CURRENCY given in the selection criteria of the enquiry.
*
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
*
* MODIFICATION HISTORY :
* --------------------
*
*  VERSION : 1.0               DATE : 28 JUL 2009          CD  : EN_10004268
*                                                          SAR : SAR-2009-01-14-0003
*
*  VERSION : 1.1               DATE : 10 AUG 2009          CD  : BG_100024451
*                                                          TTS : TTS0908934
*
*  VERSION : 1.2               DATE : 03 NOV 2009          CD  : BG_100025714
*                                                          TTS : TTS0909226
*
*           DESCRIPTION :  Fixed Selction for the field KEY was not available. The changes include
*                          following. The list of values available for the field KEY are stored in a variable
*                          KEY.VAL.ID from FIXED SELCTION and Enquiry Selection.
*                          For each value of KEY given either in Enquiry Selection or
*                          FIXED SELECTION the corresponding DAS is called on the application BASIC.INTEREST
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*------------------------------------------------------------------------------------------

    $INSERT I_DAS.PERIODIC.INTEREST

    $USING ST.RateParameters
    $USING EB.DataAccess
    $USING EB.Reports

    GOSUB INITIALISE
    GOSUB LOCATE.FIELDS

    RETURN


*---------
INITIALISE:
*---------

    DAS.LIST = ''
    KEY.VAL  = ''
    CURR.VAL = ''
    ID.VAL   = ''

    Y.FIELDS.CNT = ''
    Y.OPERAND = ''
    Y.RANGE.AND.VALUE = ''

    RETURN

*------------
LOCATE.FIELDS:
*------------


    LOCATE 'CURRENCY' IN EB.Reports.getDFields() SETTING CURR.POS THEN     ;* Locate the CURRENCY in enquiry selection
    CURR.VAL = EB.Reports.getDRangeAndValue()<CURR.POS>
    END

    LOCATE 'DATE' IN EB.Reports.getDFields() SETTING DATE.POS THEN         ;*Locate the DATE in enquiry selection
    DATE.VAL = EB.Reports.getDRangeAndValue()<DATE.POS>
    END


    tmp.D.FIELDS = EB.Reports.getDFields()
    Y.FIELDS.CNT = DCOUNT(tmp.D.FIELDS,@FM)

    FOR Y.COUNT = 1 TO Y.FIELDS.CNT

        IF EB.Reports.getDFields()<Y.COUNT> EQ 'KEY' THEN        ;* Locate the values of KEY in enquiry selction as well as

            Y.OPERAND = EB.Reports.getDLogicalOperands()<Y.COUNT>         ;* the fixed selection of the enquiry.

            Y.RANGE.AND.VALUE = EB.Reports.getDRangeAndValue()<Y.COUNT>

            Y.SEL.OPERAND = EB.Reports.getOperandList()<Y.OPERAND>

            IF Y.SEL.OPERAND EQ 'LK' THEN
                Y.SEL.OPERAND = 'LIKE'
            END

            Y.STR1 = @SM
            Y.STR2 = @FM

            CHANGE Y.STR1 TO Y.STR2 IN Y.RANGE.AND.VALUE    ;* Convert the VM to FM in the variable Y.RANGE.AND.VALUE

            KEY.VAL.ID<-1> = Y.RANGE.AND.VALUE    ;* Appends the list of values for the field KEY either in

        END         ;* Enquiry Selection or Fixed Selection of the Enquiry

    NEXT Y.COUNT

    IF KEY.VAL.ID NE '' THEN

        LOOP

            REMOVE KEY.VAL FROM KEY.VAL.ID SETTING KEY.VAL.POS

        WHILE KEY.VAL:KEY.VAL.POS       ;* For each value of KEY the sub block LOCATE.SUB.PROCESS is called and the

            KEY.VAL.LEN = LEN(KEY.VAL)  ;* values are populated in the return variable RET.ARR

            IF KEY.VAL.LEN EQ '1' THEN
                KEY.VAL = "0":KEY.VAL
            END

            GOSUB LOCATE.SUB.PROCESS

        REPEAT

    END ELSE

        GOSUB LOCATE.SUB.PROCESS                            ;*E/BG_100025714

    END

    RETURN

*-----------------
LOCATE.SUB.PROCESS:
*-----------------


    BEGIN CASE      ;* Here based on the values given in enquiry selection and fixed selection the
            ;* ID.VAL variable is formed to CALL DAS on BASIC.INTEREST application.

        CASE  KEY.VAL EQ '' AND CURR.VAL EQ '' AND DATE.VAL EQ ''    ;*S/BG_100025714

            ID.VAL = ''

        CASE KEY.VAL EQ '' AND CURR.VAL NE '' AND DATE.VAL NE ''

            ID.VAL = "...":CURR.VAL:DATE.VAL

        CASE KEY.VAL NE '' AND CURR.VAL NE '' AND DATE.VAL NE ''

            ID.VAL = KEY.VAL:CURR.VAL:DATE.VAL

        CASE KEY.VAL NE '' AND CURR.VAL EQ '' AND DATE.VAL EQ ''

            ID.VAL = KEY.VAL:"..."

        CASE KEY.VAL NE '' AND CURR.VAL EQ '' AND DATE.VAL NE ''

            ID.VAL = KEY.VAL:"...":DATE.VAL

        CASE KEY.VAL NE '' AND CURR.VAL NE '' AND DATE.VAL EQ ''

            ID.VAL = KEY.VAL:CURR.VAL:"..."

        CASE KEY.VAL EQ '' AND CURR.VAL EQ '' AND DATE.VAL NE ''

            ID.VAL = "...":DATE.VAL

        CASE KEY.VAL EQ '' AND CURR.VAL NE '' AND DATE.VAL EQ ''         ;*S/BG_100025714

            ID.VAL = "...":CURR.VAL:"..."

    END CASE

    GOSUB CALL.DAS.PERIODIC.INT

    RETURN

*--------------------
CALL.DAS.PERIODIC.INT:
*--------------------


    IF ID.VAL NE '' THEN

        DAS.LIST     = dasPeriodicInterestIDLikeKeyCurrByDsndId
        TABLE.NAME    = "PERIODIC.INTEREST"
        ARGUMENTS    = ID.VAL
        TABLE.SUFFIX = ''

        EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    END ELSE

        DAS.LIST     = dasPeriodicInterestIDLikeKeyCurrByDsndId1
        TABLE.NAME    = "PERIODIC.INTEREST"
        ARGUMENTS    = ''
        TABLE.SUFFIX = ''

        EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    END

    GOSUB RETURN.ARRAY


    RETURN


*-----------
RETURN.ARRAY:
*-----------

    IF DAS.LIST NE '' THEN

        LOOP

            REMOVE P.INT.ID FROM DAS.LIST SETTING P.INT.ID.POS

        WHILE P.INT.ID:P.INT.ID.POS
            R.PERIODIC.INT = ST.RateParameters.tablePeriodicInterest(P.INT.ID, ERR.PERIODIC.INT)

            P.KEY             = P.INT.ID[1, LEN(P.INT.ID)-11]

            P.DATE            = P.INT.ID[LEN(P.INT.ID)-7, LEN(P.INT.ID)-5]

            P.DESC            = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiDescription>

            CURR.TEMP         = RIGHT(P.INT.ID, 11)

            P.CURR            = LEFT(CURR.TEMP, 3)

            P.REST.PERIOD     = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiRestPeriod>

            P.REST.DATE       = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiRestDate>

            P.DAYS.SINCE.SPOT = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiDaysSinceSpot>

            P.BID.RATE        = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiBidRate>

            P.OFFER.RATE      = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiOfferRate>

            P.AMOUNT          = R.PERIODIC.INT<ST.RateParameters.PeriodicInterest.PiAmt>

            P.DRILL           = P.INT.ID

            RET.ARR<-1>  = P.KEY:"*":P.DATE:"*":P.DESC:"*":P.CURR:"*":P.REST.PERIOD:"*":P.REST.DATE:"*":P.DAYS.SINCE.SPOT:"*":P.BID.RATE:"*":P.OFFER.RATE:"*":P.AMOUNT:"*":P.DRILL


        REPEAT

    END

    RETURN
