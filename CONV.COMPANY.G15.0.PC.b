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
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PC.Contract
    SUBROUTINE CONV.COMPANY.G15.0.PC(Y.ID, R.PC.PERIOD, F.PC.PERIOD)
*-----------------------------------------------------------------------------
* This conversion will populate those fields related multi book FINANCIAL.MNE,
* FINANCIAL.COM, and BOOK for COMPANY.PC<<pc.period>> records.
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

    FN.COMP = 'F.COMPANY' ; F.COMP = ''
    CALL OPF(FN.COMP, F.COMP)

    C$PC.CLOSING.DATE = Y.ID

    FN.COMP.PC = 'F.COMPANY' ; F.COMP.PC = ''
    CALL OPF(FN.COMP.PC, F.COMP.PC)

    SEL.CMD = 'SELECT ':FN.COMP.PC
    COMP.LIST = ''
    CALL EB.READLIST(SEL.CMD, COMP.LIST, '', '', '')
    LOOP
        REMOVE ID.COMP FROM COMP.LIST SETTING Y.POS
    WHILE ID.COMP:Y.POS
        READ R.COMP FROM F.COMP, ID.COMP ELSE
            NULL
        END
        READ R.COMP.PC FROM F.COMP.PC, ID.COMP THEN
            GOSUB PROCESS.COMPANY.PC
        END
    REPEAT
    C$PC.CLOSING.DATE = ''

    RETURN

*-----------------------------------------------------------------------------
PROCESS.COMPANY.PC:
*------------------

*   Populates those three fields FINANCIAL.MNE, FINANCIAL.COM, and BOOK
*   related to multibook in PC company records from actual company record.
    R.COMP.PC<64> = R.COMP<64>
    R.COMP.PC<65> = R.COMP<65>
    R.COMP.PC<55> = R.COMP<55>

    WRITE R.COMP.PC TO F.COMP.PC,ID.COMP

    RETURN
*-----------------------------------------------------------------------------
END
