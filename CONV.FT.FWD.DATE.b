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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*This conversion Routine changes the old id FORMATS in FT.FWD.DATES

    $PACKAGE FT.Contract
    SUBROUTINE CONV.FT.FWD.DATE(YID,YREC,YFILE)
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY
*--------------------
* 05/08/11 - CI_10073838
*            Conversion routine to change the file structure of FT.FWD.DATE.
*            Read the records and create balnk record with id
*            FT status * FT id * Processing Date
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
*
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*------------------------------------------------------------------------------
INITIALISE:

    FV.FUNDS.TRANSFER = ''
    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    CALL OPF(FN.FUNDS.TRANSFER, FV.FUNDS.TRANSFER)

    FN.FT.FWD.DATE = "F.FT.FWD.DATE"
    FV.FT.FWD.DATE = ''
    CALL OPF(FN.FT.FWD.DATE,FV.FT.FWD.DATE)

    RETURN
*------------------------------------------------------------------------------
PROCESS:
*-------

    FT.ID = FIELD(YID,"*",2)
    CALL F.READ(FN.FUNDS.TRANSFER, FT.ID, R.FT, FV.FUNDS.TRANSFER,READ.ERR)     ;* Read the record from FT

    PROC.DATE = R.FT<FT.PROCESSING.DATE>          ;* Get the processing date
    WORK.ID = YID:"*":PROC.DATE         ;* Append processign date to the existing id

    CALL F.DELETE(FN.FT.FWD.DATE, YID)  ;* Delete the old record

    YID = WORK.ID
    YREC = ''

    RETURN
*-----------------------------------------------------------------------------
END
