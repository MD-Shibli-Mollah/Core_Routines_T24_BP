* @ValidationCode : Mjo5NjA2NjkyNDI6Q3AxMjUyOjE1NjQ1Njk3NTQzMDQ6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:12:34
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
$PACKAGE CQ.Cards
SUBROUTINE CONV.CARD.ISSUE.G14(ID,YREC,FILE)
* Conversion routine for adding the filed CARD.STATUS in CARD.ISSUE for
* the existing live and $NAU records.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    YREC<1> = '90'
RETURN
END
