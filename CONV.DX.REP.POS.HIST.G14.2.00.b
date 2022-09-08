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
    $PACKAGE DX.Position
    SUBROUTINE CONV.DX.REP.POS.HIST.G14.2.00(YID,YREC,YFILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.REP.POS.HIST
**************************

    FN.DX.TRANSACTION = 'F.DX.TRANSACTION'
    CALL OPF(FN.DX.TRANSACTION,F.DX.TRANSACTION)

    GEN.POS.KEY = ''

    SAVE.YID = YID

    TXN.ID = YREC<DX.RPH.TRANSACTION.IDS,1>
    CALL F.READ('F.DX.TRANSACTION',TXN.ID,R.DX.TRANSACTION,F.DX.TRANSACTION,ER)
    IF R.DX.TRANSACTION THEN
        DELETE F.FILE,SAVE.YID
        CALL DX.GEN.POS.KEY(R.DX.TRANSACTION,GEN.POS.KEY)
        YID = GEN.POS.KEY:'*':FIELD(SAVE.YID,'*',2)
    END

    RETURN

END
