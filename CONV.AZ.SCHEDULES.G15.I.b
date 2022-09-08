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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
    SUBROUTINE CONV.AZ.SCHEDULES.G15.I(AZS.ID,AZS.REC,YFILE)
*-----------------------------------------------------------------------------------------------------------*
* Wrongly Input a possition in CONV.AZ.SCHEDULES.G14.2
* This routine used to move the Date value only from 30th(ADDITIONAL.SPREAD) field to 32nd Field (GRACE.END.DATE).
*-----------------------------------------------------------------------------------------------------------*
* Modification History:
*----------------------
* 09/12/04 - BG_100007738
*            New routine
*
*-----------------------------------------------------------------------------------------------------------*

    $INSERT I_COMMON
    $INSERT I_EQUATE

* Main Para

    GRACE.END.DATE = AZS.REC<30>        ;* Assign the Grace End Date value from the wrong field(Additional.Spread)

    IF GRACE.END.DATE THEN
        NO.OF.GRACE = DCOUNT(GRACE.END.DATE,VM)
        GRACE.NO = 0
        LOOP
            GRACE.NO += 1
        UNTIL GRACE.NO GT NO.OF.GRACE
            GRACE.DATE = GRACE.END.DATE<1,GRACE.NO>
            IF GRACE.DATE AND LEN(GRACE.DATE) EQ 8 AND NUM(GRACE.DATE) THEN     ;* Check This is a date value or Not
                AZS.REC<32,GRACE.NO> = GRACE.DATE ;* Assign the value in 32nd field
                AZS.REC<30,GRACE.NO> = ''         ;* Nullifying the value in 30th field
            END
        REPEAT
    END

* End of Routine
END
