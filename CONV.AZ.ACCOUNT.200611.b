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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
    SUBROUTINE CONV.AZ.ACCOUNT.200611(AZ.ID,AZ.REC,YFILE)
*-------------------------------------------------------------------------------------
* This record routine copies the value of PAY.INT.AT.MAT from APP record to AZ.ACCOUNT.
*
* Merging CONV.AZ.ACCOUNT.200606
* Since CURR.HIST.No field is removed from AZ application.
* This conversion routine intialises all CURR.HIST number fields created previously.
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    APP.ID = AZ.REC<4>        ;*Read APP id from AZ.ACCOUNT
    APP.REC = ''
    APP.READ.FAIL = ''

    FN.APP = 'F.AZ.PRODUCT.PARAMETER'
    FV.APP = ''

    CALL EB.READ.PARAMETER(FN.APP,'N','',APP.REC,APP.ID,FV.APP,APP.READ.FAIL)

    AZ.REC<111> = APP.REC<108>          ;*Copy PAY.INT.AT.MAT from APP to AZ.ACCOUNT

    AZ.REC<101> = ''          ;* Initialising CURR.HIST.NO.
    RETURN
END
