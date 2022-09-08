* @ValidationCode : MjoxNzQ3NjA0MTg6Q3AxMjUyOjE1NjQ1NzgwMzE0MjM6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUE.TYPE.G12.2(CHQ.TYP.ID,R.CHQ.TYP,FV.CHQ.TYP)

** Conversion routine to populate the field AUTO.REORDER.TYPE with
** NO.HELD when AUTO.REQUEST is "YES" and AUTO.REORDER.TYPE EQ "".
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE


    IF R.CHQ.TYP<8> = "YES" THEN
        R.CHQ.TYP<10> = "NO.HELD"
    END

RETURN
END
