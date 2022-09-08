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

* Version 1 dd/mm/yy  GLOBUS Release No. G14.2.00 18/12/2003
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.DRAWINGS.G14.2(ID,REC,FILE)
*******************************************************
*
*   This record routine populates values into the
*   newly added fields, APP.DRAW.AMT & MULTI.DR.AMT,
*   of all existing DRAWINGS records.
*
*******************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    REC<190> = REC<3>
    REC<191> = 0
    RETURN
*
END
