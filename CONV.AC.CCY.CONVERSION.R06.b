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
* <Rating>169</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EU.AccountEuroConversion
    SUBROUTINE CONV.AC.CCY.CONVERSION.R06
*****************************************
* Move the converted records to History file and delete from
* live file.
*****************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.CCY.CONVERSION
***************************************
* 07/04/06 - EN_10002887
*            New Routine
***************************************
    GOSUB INITIALISATION
    GOSUB SELECT.FILE
    IF AC.CCY.LIST THEN
        GOSUB MOVE.HIST
    END
    RETURN
**********************************
INITIALISATION:

    FN.AC.CCY.CONVERSION = 'F.AC.CCY.CONVERSION'
    FV.AC.CCY.CONVERSION = ''
    CALL OPF(FN.AC.CCY.CONVERSION,FV.AC.CCY.CONVERSION)
*
    FN.AC.CCY.CONVERSION.HIS = 'F.AC.CCY.CONVERSION$HIS'
    FV.AC.CCY.CONVERSION.HIS = ''
    CALL OPF(FN.AC.CCY.CONVERSION.HIS,FV.AC.CCY.CONVERSION.HIS)
*
    RETURN
**********************************
SELECT.FILE:
    SELECT.CMD = 'SELECT ':FN.AC.CCY.CONVERSION 'WITH CONVERTED.DATE NE ""'
    EXECUTE SELECT.CMD
    READLIST AC.CCY.LIST ELSE AC.CCY.LIST = ''
    RETURN
**********************************
MOVE.HIST:
    LOOP
        REMOVE AC.CCY.ID FROM AC.CCY.LIST SETTING ACCY.POS
    WHILE AC.CCY.ID:ACCY.POS
        READ R.AC.CCY.CONVERSION FROM FV.AC.CCY.CONVERSION,AC.CCY.ID ELSE R.AC.CCY.CONVERSION = ''
        IF R.AC.CCY.CONVERSION<AC.CCY.DATE.CONVERTED> THEN
            AC.CCY.ID.HIS = AC.CCY.ID:';':R.AC.CCY.CONVERSION<AC.CCY.CURR.NO>
            R.AC.CCY.CONVERSION<AC.CCY.RECORD.STATUS> = 'MAT'
            WRITE R.AC.CCY.CONVERSION TO FV.AC.CCY.CONVERSION.HIS , AC.CCY.ID.HIS
            DELETE FV.AC.CCY.CONVERSION,AC.CCY.ID
        END
    REPEAT
    RETURN
**********************************
END
