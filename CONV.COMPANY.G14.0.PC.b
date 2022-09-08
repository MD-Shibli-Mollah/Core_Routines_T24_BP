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
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PC.Contract
    SUBROUTINE CONV.COMPANY.G14.0.PC(Y.ID, R.PC.PERIOD, F.PC.PERIOD)
*-----------------------------------------------------------------------------
* This conversion will populate those fields OFFICIAL.HOLIDAY,
* EB.COM.BRANCH.HOLIDAY, and EB.COM.BATCH.HOLIDAY for COMPANY.PC<<pc.period>>
* records based on the set up in COMPANY records
*
* 31/07/08 - GLOBUS_CI_10057053
*            New conversion routine
*
* 27/08/08 - CI_10057478
*            For NAU & HIS files, process is not necessary
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    BEGIN CASE
    CASE NOT(Y.ID LT TODAY AND R.PC.PERIOD<1> EQ 'OPEN')
        RETURN
    CASE F.PC.PERIOD[4] EQ "$HIS"
        RETURN
    CASE F.PC.PERIOD[4] EQ "$NAU"
        RETURN
    END CASE

    C$PC.CLOSING.DATE = Y.ID

    FN.COMP = 'F.COMPANY' ; F.COMP = ''
    CALL OPF(FN.COMP, F.COMP)

    SEL.CMD = 'SELECT ':FN.COMP
    COMP.LIST = ''
    CALL EB.READLIST(SEL.CMD, COMP.LIST, '', '', '')
    LOOP
        REMOVE ID.COMP FROM COMP.LIST SETTING Y.POS
    WHILE ID.COMP:Y.POS
        READ R.COMP.PC FROM F.COMP, ID.COMP THEN
            GOSUB PROCESS.COMPANY.PC
        END
    REPEAT
    C$PC.CLOSING.DATE = ''

    RETURN
*---------------------------------------------------------------------
PROCESS.COMPANY.PC:
*-----------------

    IF R.COMP.PC<14> THEN
        IF R.COMP.PC<60> = "" THEN
            R.COMP.PC<60> = R.COMP.PC<14>:"00"
        END
        IF R.COMP.PC<61> = "" THEN
            R.COMP.PC<61> = R.COMP.PC<14>:"00"
        END
        IF R.COMP.PC<62> = "" THEN
            R.COMP.PC<62> = R.COMP.PC<14>:"00"
        END
    END ELSE
        IF R.COMP.PC<15> THEN
            IF R.COMP.PC<60> = "" THEN
                R.COMP.PC<60> = R.COMP.PC<15>
            END
            IF R.COMP.PC<61> = "" THEN
                R.COMP.PC<61> = R.COMP.PC<15>
            END
            IF R.COMP.PC<62> = "" THEN
                R.COMP.PC<62> = R.COMP.PC<15>
            END
        END
    END
    WRITE R.COMP.PC TO F.COMP,ID.COMP

    RETURN
END
