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
    $PACKAGE AA.ModelBank
    SUBROUTINE AA.DE.CONV.INT.TIER(IN.VALUE,HEADER.REC,MV.NO,OUT.FREQ,ERROR.MSG)

****************************
*
* Modification History
*
* 05/02/15 - EN_1176071
*            New routine for interest tier
*            mapping process of AA
*            Used in DE.FORMAT.PRINT.
*
******************************

    IF IN.VALUE EQ "" THEN
        OUT.FREQ = "Remainder"
    END ELSE
        OUT.FREQ = IN.VALUE
    END

    RETURN
END
