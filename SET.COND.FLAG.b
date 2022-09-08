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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE SET.COND.FLAG(STR1,STR2,OPR1,COND1)

    BEGIN CASE
    CASE OPR1 EQ '1'

        IF STR1 EQ STR2 THEN
            COND1 = 'TRUE'
        END
    CASE OPR1 EQ '3'
        IF STR1 LT STR2 THEN
            COND1 = 'TRUE'
        END
    CASE OPR1 EQ 4
        IF STR1 GT STR2 THEN
            COND1 = 'TRUE'
        END
    CASE OPR1 EQ 8
        IF STR1 LE STR2 THEN

            COND1 = 'TRUE'
        END
    CASE OPR1 EQ 9
        IF STR1 GE STR2 THEN
            COND1 = 'TRUE'
        END
    END CASE

    RETURN
END
