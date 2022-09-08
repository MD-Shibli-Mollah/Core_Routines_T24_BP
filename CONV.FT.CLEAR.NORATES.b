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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Contract
    SUBROUTINE CONV.FT.CLEAR.NORATES
******************************************
* Conversion file routine to clear the old format FT.NORATE and
* FT.FWD.DATE records. New formate record in built in the
* conversion routine CONV.FT.BUILD.NORATES
*
********************************************
* 05/10/07 - BG_100015237
*            New version.
********************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
********************************************
    GOSUB INITIALISE
    GOSUB CLEAR.RECS
    RETURN
*********************************************
INITIALISE:
    FN.FT.NORATE = "F.FT.NORATE"
    FV.FT.NORATE = ""
    CALL OPF(FN.FT.NORATE,FV.FT.NORATE)
    FN.FT.FWD.DATE = "F.FT.FWD.DATE"
    FV.FT.FWD.DATE = ""
    CALL OPF(FN.FT.FWD.DATE,FV.FT.FWD.DATE)
    RETURN
*************************
CLEAR.RECS:
    DELETE FV.FT.NORATE,'INORATE'
    DELETE FV.FT.NORATE,'ANORATE'
    DELETE FV.FT.FWD.DATE,'IFWD'
    DELETE FV.FT.FWD.DATE,'AFWD'
    RETURN
*************************************
END

