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
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*This conversion Routine changes the old id FORMATS in FT.FWD.DATES and
*FT.NORATE
    $PACKAGE FT.Contract
    SUBROUTINE CONV.FT.BUILD.NORATES(YID,YREC,YFILE)
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY
*--------------------
* 05/10/07 - BG_100015237
*            Conversion routine to change the file structure of FT.NORATE and
*            FT.FWD.DATE. Read the records and create balnk record with id
*            FT status * FT id.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
*
    FT.STAT = YREC<FT.STATUS>
    BEGIN CASE
    CASE FT.STAT MATCHES "INORATE":VM:"ANORATE"
        FN.FT.WORK.FILE = "F.FT.NORATE"
    CASE FT.STAT MATCHES "IFWD":VM:"AFWD"
        FN.FT.WORK.FILE = "F.FT.FWD.DATE"
    CASE 1
        RETURN
    END CASE
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*------------------------------------------------------------------------------
INITIALISE:
    FV.FT.WORK.FILE = ''
    CALL OPF(FN.FT.WORK.FILE,FV.FT.WORK.FILE)
    RETURN
*------------------------------------------------------------------------------
PROCESS:
*-------
    WORK.ID = FT.STAT:"*":YID
    DUMMY = ''
    WRITE DUMMY ON FV.FT.WORK.FILE,WORK.ID
    RETURN
*-----------------------------------------------------------------------------
END

