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

* Version n dd/mm/yy  GLOBUS Release No. 200710 25/07/07
*-------------------------------------------------------------------------
* <Rating>-21</Rating>
*-------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.LETTER.OF.CREDIT.200712(Y.LCID,Y.LCREC,YFILE)
*
* Modifications
*
* 25/09/07 - EN_10003508
*            Conversion routine to populate new field PREV.CONFIRM.INST
*            in existing LC contracts with the field from RE.CONTRACT.DETAIL.
*
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQUATE RE.CON.DET.CONFIRMED TO 13
    EQUATE TF.LC.PREV.CONFIRMED.INST TO 233

    GOSUB OPEN.AND.READ.FILE
    GOSUB PROCESS.PARA

    RETURN
*
*==========
OPEN.AND.READ.FILE:
*==========
* Open the files and Read RE.CONTRACT.DETAIL for the LC ID here...
    FN.RE.CONTRACT.DETAIL = 'F.RE.CONTRACT.DETAIL' ; FV.RE.CONTRACT.DETAIL = ''
    CALL OPF(FN.RE.CONTRACT.DETAIL,FV.RE.CONTRACT.DETAIL)

    READ R.RE.BAL FROM FV.RE.CONTRACT.DETAIL, Y.LCID ELSE
        R.RE.BAL = ''
    END

    RETURN
*
*============
PROCESS.PARA:
*============

    Y.LCREC<TF.LC.PREV.CONFIRMED.INST> = R.RE.BAL<RE.CON.DET.CONFIRMED>

    RETURN
END
