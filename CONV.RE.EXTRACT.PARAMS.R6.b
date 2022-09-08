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
    $PACKAGE RE.ReportExtraction
    SUBROUTINE CONV.RE.EXTRACT.PARAMS.R6(ID, REC, CONV.FILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
** Conversion to populate automatically the extract params
** record so that existing records are consistent with the
** prior releases
** New Field PL.DETAILS - set to Y if CONTRACT.DETAIL = Y
** or set to NO if NO
** New Field OPTIONS - set to include values:
**  AL.NET.CONSOL.KEY
**  PL.NET.OPP.LINE
*
    REC<10> = REC<7>
    REC<11> = "AL.NET.CONSOL.KEY":VM:"PL.NET.OPP.LINE"
*
    RETURN
END
