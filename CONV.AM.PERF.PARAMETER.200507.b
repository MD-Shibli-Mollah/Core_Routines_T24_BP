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
    $PACKAGE AM.Performance
    SUBROUTINE CONV.AM.PERF.PARAMETER.200507(AM.PERF.PARAMETER.ID,R.AM.PERF.PARAMETER,FN.AM.PERF.PARAMETER)
*
*----------------------------------------------------------------------------
* Program Discription:
* This program clearsdown the field INFLOW.TRD.TXN that has become REVALUE.FLOW
* as a part of change to Performance flow enhancement (EN_10002482)
*----------------------------------------------------------------------------

    GOSUB INITIALISE

    R.AM.PERF.PARAMETER<26> = ''

    RETURN

INITIALISE:

    RETURN

END
