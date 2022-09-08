* @ValidationCode : MjozMDUyMjM3ODQ6Q3AxMjUyOjE1Njk3NzgwNTEyNDg6dnBkaWxpcGt1bWFyOjE6MDotNzoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6MTA6MTA=
* @ValidationInfo : Timestamp         : 29 Sep 2019 22:57:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vpdilipkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -7
* @ValidationInfo : Coverage          : 10/10 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.Channels
SUBROUTINE E.TC.CONV.DISPLAY.CARD.NO
*-----------------------------------------------------------------------------
* This routine gets card number from O.DATA and returns masked card number
*-----------------------------------------------------------------------------
* *** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
*
* Modification History:
*---------------------
* 22/05/17 - Enhancement 2004884 / Task 2110313
*            Masking card number
* 01/10/19 - Defect - 3367195 / Task - 3367524
*          - CQ product installation check.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.Reports
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    CARD.ID = EB.Reports.getOData()          ;* Pick the card number from the enquiry variable

    CARD.NO  =  FIELD(CARD.ID,".",2)    ;* get cardno in card.id(cardtype.cardno)
    CARD.NO.LAST4 = RIGHT(CARD.NO,4)    ;* get last 4 digits in cardno
    CARD.NO.FIRST4 = LEFT(CARD.NO,4)    ;* get first 4 digits in cardno
    CARD.LEN = LEN(CARD.NO)-4
    STR1 = "R*":CARD.LEN
    FMT.CARD.NO = FMT(CARD.NO.LAST4,STR1)
    CARD.NO = CARD.NO.FIRST4:FMT.CARD.NO
    EB.Reports.setOData(CARD.NO);* Return back the masked card number

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
