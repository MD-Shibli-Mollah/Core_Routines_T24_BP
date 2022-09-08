* @ValidationCode : Mjo2MjM3MTAxNjA6Q3AxMjUyOjE1NjQ1Njk3Njg3NDU6c3JhdmlrdW1hcjoyOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOjEwOjg=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:12:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/10 (80.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.Cards
SUBROUTINE CONV.CARD.TYPE(ID,YREC,FILE)

*Conversion routine for mapping the OVERRIDE
*and LOCAL.REF field values to correct field position
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 31/07/18 - Defect 2686665/ Task 2701648
*            Replace the 9th position (CARD.TYPE.LOCAL.REF) of records by 10th position (CARD.TYPE.OVERRIDE)value
*            of the card.type record only if 9th position field data is not present.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*----------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQUATE CARD.TYPE.LOCAL.REF TO 9
    EQUATE CARD.TYPE.OVERRIDE TO 10
     
    FILE.NAME = FIELD(FILE,'$',1)
    IF FILE.NAME = 'F.CARD.TYPE' AND YREC<CARD.TYPE.LOCAL.REF> EQ '' THEN
        YREC<CARD.TYPE.LOCAL.REF> = YREC<CARD.TYPE.OVERRIDE>
        YREC<CARD.TYPE.OVERRIDE> = ''
    END

    
RETURN
END
