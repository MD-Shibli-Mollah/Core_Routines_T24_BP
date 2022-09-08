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
    $PACKAGE DX.Position
    SUBROUTINE CONV.DX.REP.POS.200508(DX.REP.POS.ID,R.DX.REP.POSITION,FN.DX.REP.POSITION)
*---------------------------------------------------------------------
* This routine is developed to change the reference of the concat file
* DX.CUST.POS from DX.POSITION to DX.REP.POSITION as the part of
* the SAR (SAR-2004-11-12-0001)
*---------------------------------------------------------------------
*22/05/07 - EN_10003365
*           DX.DATE.POS made as OBSOLETE in SAR-2007-04-17-0003
*---------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.REP.POSITION
*
    GOSUB INITIALISE
*
    GOSUB MAIN.PROCESS

    RETURN
*=====================================================================
INITIALISE:
*
    FN.DX.CUST.POS = "F.DX.CUST.POS"
    F.DX.CUST.POS = ""
    CALL OPF(FN.DX.CUST.POS,F.DX.CUST.POS)
*
*EN_10003365 -S/E
    CLEARFILE F.DX.CUST.POS
*
*EN_10003365 -S/E
    RETURN
*====================================================================
MAIN.PROCESS:
*
    PORT.ID = FIELD(DX.REP.POS.ID,"*",1)
    CONCAT.UPDATE.ACTION = "I"
    CALL CONCAT.FILE.UPDATE(FN.DX.CUST.POS,PORT.ID,DX.REP.POS.ID,CONCAT.UPDATE.ACTION,"AR")

*EN_10003365 -S/E
    RETURN
*====================================================================
END
