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
* <Rating>200</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Position
    SUBROUTINE CONV.DX.REP.POS.G14.2.00(YID,YREC,YFILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.TRANSACTION
    $INSERT I_F.DX.REP.POS.LAST
    $INSERT I_F.DX.REP.POSITION

    FN.DX.TRANSACTION = 'F.DX.TRANSACTION'
    F.DX.TRANSACTION = ''
    CALL OPF(FN.DX.TRANSACTION,F.DX.TRANSACTION)
    FN.DX.REP.POS.LAST = 'F.DX.REP.POS.LAST'
    F.DX.REP.POS.LAST = ''
    CALL OPF(FN.DX.REP.POS.LAST,F.DX.REP.POS.LAST)

    GEN.POS.KEY = ''

    SAVE.YID = YID

    TXN.ID = YREC<DX.RP.TRANSACTION.IDS,1>
    READ R.DX.TRANSACTION FROM F.DX.TRANSACTION,TXN.ID ELSE R.DX.TRANSACTION = ''
    IF R.DX.TRANSACTION THEN
        DELETE F.FILE,SAVE.YID
        CALL DX.GEN.POS.KEY(R.DX.TRANSACTION,GEN.POS.KEY)
        YID = GEN.POS.KEY
    END

    READ R.DX.REP.POS.LAST FROM F.DX.REP.POS.LAST,SAVE.YID ELSE R.DX.REP.POS.LAST = ''
    IF R.DX.REP.POS.LAST THEN
        REP.POS.FIELD = FIELD(R.DX.REP.POS.LAST<DX.RPL.DX.REP.POS.HIST.ID>,'*',2)
        R.DX.REP.POS.LAST<DX.RPL.DX.REP.POS.HIST.ID> = YID:'*':REP.POS.FIELD
        SAVE.REP.POS.LAST = R.DX.REP.POS.LAST
        DELETE F.DX.REP.POS.LAST,SAVE.YID
        WRITE SAVE.REP.POS.LAST ON F.DX.REP.POS.LAST,YID
    END

    RETURN

END
