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
    $PACKAGE MG.Contract
    SUBROUTINE CONV.MG.MORTGAGE.G15.1(MG.ID,MG.REC,F.MG.MORTGAGE)
* This conversion routine will check the deal category in
* mg.txn.type.condition file, and if so, will populate value to
* FWD.BWD field in MG, from FWD.BWD field value of
* MG.TXN.TYPE.CONDITION file.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    EQU MG.FWD.BWD TO 133
    EQU MG.CATEGORY TO 8
    EQU MG.TXN.FWD.BWD TO 20
    Y.CATEGORY = MG.REC<MG.CATEGORY>
    CALL CACHE.READ("F.MG.TXN.TYPE.CONDITION",Y.CATEGORY,MG.TXN.REC,MG.TXN.ERR)
    IF NOT(MG.TXN.ERR) THEN
        IF MG.TXN.REC<MG.TXN.FWD.BWD> NE '' THEN
            MG.REC<MG.FWD.BWD> = MG.TXN.REC<MG.TXN.FWD.BWD>
        END ELSE
            MG.REC<MG.FWD.BWD> = 'CAL'
        END
    END ELSE
        MG.REC<MG.FWD.BWD> = 'CAL'
    END
*
    RETURN
END
