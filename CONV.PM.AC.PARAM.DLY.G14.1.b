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
* <Rating>49</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Config
    SUBROUTINE CONV.PM.AC.PARAM.DLY.G14.1

**************************************************************************
* Modification History:
*
* 16/09/03 - EN_10001961
*            This is a Subroutine which will run after all the PM.AC.PARAM
*            records have been converted.
*
**************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PM.AC.PARAM

    FN.PM.AC.PARAM.DLY = "F.PM.AC.PARAM.DLY"
    F.PM.AC.PARAM.DLY = ''
    CALL OPF(FN.PM.AC.PARAM.DLY,F.PM.AC.PARAM.DLY)

    SEL.STMT = "SELECT ":FN.PM.AC.PARAM.DLY
    ID.LIST = ''
    NO.SEL = ''
    CALL EB.READLIST(SEL.STMT,ID.LIST,'',NO.SEL,RET.ERR)
    IF ID.LIST THEN
        LOOP
            REMOVE PM.AC.PARAM.ID FROM ID.LIST SETTING MORE.ID
        WHILE PM.AC.PARAM.ID:MORE.ID
            ERR = ''
            READ R.PM.AC.PARAM.DLY FROM F.PM.AC.PARAM.DLY,PM.AC.PARAM.ID THEN
                CLASS.OVERNIGHT = R.PM.AC.PARAM.DLY<PM.AP.CLASS.OVERNIGHT>
                FOR LINE.CNT = 34 TO 8 STEP -1
                    R.PM.AC.PARAM.DLY<LINE.CNT> = R.PM.AC.PARAM.DLY<LINE.CNT-1>
                NEXT LINE.CNT
                R.PM.AC.PARAM.DLY<PM.AP.LCY.FX.POSN> = CLASS.OVERNIGHT
                WRITE R.PM.AC.PARAM.DLY TO F.PM.AC.PARAM.DLY,PM.AC.PARAM.ID
            END
        REPEAT
    END
***************************************************************************
    RETURN
END
