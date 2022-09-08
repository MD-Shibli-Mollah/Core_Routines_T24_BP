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

* Version n dd/mm/yy  GLOBUS Release No. G14.2.00 27/11/2003
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Config
    SUBROUTINE CONV.LC.PARAMETERS.G14.2(ID,R.REC,FILE)
*******************************************************
*
* This file routine populates the new fields,
* ASSN.TRAN.CODE.CR & ASSN.TRAN.CODE.DR, with the values
* in the fields, PAY.TRANS.CR & PAY.TRANS.DR, resp.
* in the file LC.PARAMETERS.
*
* Modifications
*
* 18/02/04 - BG_100006243
*            Bug fixes related to Multi book changes.
*            This conversion should run after the
*            CONV.MB.PARAM.G14.2. Hence this is changed as a
*            record routine.
*
*******************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    EQU PAY.TRANS.CR TO 7     ;* BG_6243 +
    EQU PAY.TRANS.DR TO 8
    EQU ASSN.TRAN.CODE.CR TO 81
    EQU ASSN.TRAN.CODE.DR TO 82
*
    R.REC<ASSN.TRAN.CODE.CR> = R.REC<PAY.TRANS.CR>
    R.REC<ASSN.TRAN.CODE.DR> = R.REC<PAY.TRANS.DR>          ;* BG_6243 -
*
    RETURN
END
