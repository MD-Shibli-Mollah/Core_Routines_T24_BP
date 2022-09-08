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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctSecurityLending
    SUBROUTINE CONV.SC.DEPOT.POSITION.R07.LOAD
*--------------------------------------------------------------
*  Load routine for the conversion record SC.DEPOT.POSITION
*--------------------------------------------------------------
* 01/12/06 - GLOBUS_CI_10045393
*            Conversion SC.DEPOT.POSITION written as service

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.SC.DEPOT.POSITION.R07.COMMON

    FN.SECURITY.POSITION = 'F.SECURITY.POSITION'
    F.SECURITY.POSITION = ''
    CALL OPF(FN.SECURITY.POSITION,F.SECURITY.POSITION)

    FN.SC.DEPOT.POSITION = 'F.SC.DEPOT.POSITION'
    F.SC.DEPOT.POSITION = ''
    CALL OPF(FN.SC.DEPOT.POSITION,F.SC.DEPOT.POSITION)

    RETURN
END
