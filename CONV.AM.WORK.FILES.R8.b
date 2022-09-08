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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
    SUBROUTINE CONV.AM.WORK.FILES.R8(YID,R.AM.WORK.FILES,YFILE)
*-----------------------------------------------------------------------------
*This ic teh conversion routine for adding four more workfiles to AM.WORK.FILES.
*Those files added to AM.WORK.FILES. gets cleared after the job gets run
*The workfiles added are BV.PRICE.UPDATE.PRE.WRK,BV.PRICE.UPDATE.WRK,
*BV.PERF.PRICE.CHANGE.PRE.WRK,BV.PERF.PRICE.CHANGE.WRK
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    WRK.ID = "BV.PRICE.UPDATE.PRE.WRK"
    GOSUB UPDATE.WRK.FILE

    WRK.ID ="BV.PRICE.UPDATE.WRK"
    GOSUB UPDATE.WRK.FILE

    WRK.ID ="BV.PERF.PRICE.CHANGE.WRK"
    GOSUB UPDATE.WRK.FILE

    RETURN

UPDATE.WRK.FILE:
*---------------
    LOCATE WRK.ID IN R.AM.WORK.FILES<1,1> SETTING POS ELSE
        R.AM.WORK.FILES<1,POS> = WRK.ID
    END

    RETURN


END
