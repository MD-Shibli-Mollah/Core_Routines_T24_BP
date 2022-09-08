* @ValidationCode : MjotNzg3NDAzNjE3OkNwMTI1MjoxNTY0NTcyMzY0Mjc3OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:56:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqPaymentStop
    SUBROUTINE CONV.PAY.STOP.REVOKE.DATE.R07(PAY.STOP.ID,PAY.STOP.REC,YFILE.REC)

* 06/05/06 - CI_10040976
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_PaymentStop as ST_ChqPaymentStop and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* A New field Revoke Auth date has been introduced in Payment Stop which will get updated
* during authorisation of a Payment Stop record inputted for revoking Payment stop of already
* stopped cheques. This conversion should update that field for existence of MOD.PS.CHQ.NO.

* In addition if there exist any Payment stop with Cheque no instructed for Stop, then the field
* STOP.ACTIVE should get updated with "YES".



    $INSERT I_COMMON
    $INSERT I_EQUATE

    RECORD.TYPE = FIELD(YFILE.REC,"$",2,3)

    IF RECORD.TYPE NE "NAU" THEN

        PAY.STOP.TYPE = PAY.STOP.REC<2>
        STOP.TYPE.CNT = DCOUNT(PAY.STOP.TYPE,VM)

        FIRST.CHQ.NO = PAY.STOP.REC<3>

        MOD.PS.DATE = PAY.STOP.REC<45>
        MOD.PS.CNT = DCOUNT(MOD.PS.DATE,VM)

        PS.NO = 0
        LOOP
            REMOVE PS.STP.TYPE FROM PAY.STOP.TYPE SETTING PS.1
            PS.NO+=1
        UNTIL PS.NO GT STOP.TYPE.CNT
            IF PAY.STOP.REC<2,PS.NO> AND PAY.STOP.REC<3,PS.NO> THEN
                PAY.STOP.REC<10,PS.NO> = "YES"
            END

        REPEAT

        MOD.NO = 0
        LOOP
            REMOVE MOD.DATE FROM MOD.PS.DATE SETTING MOD.1
            MOD.NO +=1
        UNTIL MOD.NO GT MOD.PS.CNT
            IF PAY.STOP.REC<45,MOD.NO> NE '' THEN
                AUTH.DATE = PAY.STOP.REC<62>[1,6]
                REV.DATE = OCONV((ICONV(AUTH.DATE,"D4/E")),"D4/E")
                REV.AUTH.DATE = REV.DATE[7,4]:REV.DATE[4,2]:REV.DATE[1,2]
                PAY.STOP.REC<46,MOD.NO> = REV.AUTH.DATE
            END
        REPEAT
    END
    RETURN
END
