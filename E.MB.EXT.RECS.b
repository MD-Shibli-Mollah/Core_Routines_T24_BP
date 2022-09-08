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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.EXT.RECS
*-----------------------------------------------------------------------------
*
* Subroutine Type : Subroutine
* Attached to     : Attached to enquiry EXT.PROCESS.DETAILS
* Attached as     : Conversiion Routine
* Primary Purpose : To format data
*
* ----------------------------------------------------------

    $USING EB.Reports

    EXT.ID = EB.Reports.getOData()
    EXT.DATA = EB.Reports.getPreviousData()
    LOCATE EXT.ID IN EXT.DATA SETTING POS THEN

    EB.Reports.setLine(EB.Reports.getLine() -1)

    END
*-----------------------------------------------------------------------------

    RETURN
